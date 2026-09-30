"""
Check rendered notebooks for Quarto features that Google Colab cannot display.

Colab renders markdown cells with its own sanitised renderer: no Quarto CSS,
no <style> or <script>, no Pandoc attributes. Anything relying on those shows
up as raw markup or silently disappears. This script scans .ipynb files and
reports such leftovers.

Usage:
    uv run build/colab/check_notebooks.py temp_notebooks/notebooks
    uv run build/colab/check_notebooks.py _site/content --fail-on warning
"""

import argparse
import re
import sys
from collections import Counter
from dataclasses import dataclass
from pathlib import Path

import nbformat
from loguru import logger


@dataclass(frozen=True)
class Rule:
    id: str
    severity: str  # "error" or "warning"
    cell_type: str  # "markdown" or "code"
    pattern: re.Pattern
    message: str


RULES = [
    Rule(
        "callout-html",
        "error",
        "markdown",
        re.compile(r'class="callout[\s"]'),
        "Callout rendu en HTML Quarto, sans style dans Colab "
        "(à convertir avec build/colab/tweak_quarto_project.py)",
    ),
    Rule(
        "quarto-div",
        "error",
        "markdown",
        re.compile(r"^(?:>\s*)*:{3,}", re.MULTILINE),
        "Div Quarto (:::) non convertie",
    ),
    Rule(
        "shortcode",
        "error",
        "markdown",
        re.compile(r"\{\{<"),
        "Shortcode Quarto non résolu",
    ),
    Rule(
        "attr-span",
        "error",
        "markdown",
        re.compile(r"\]\{[.#][\w-]"),
        "Span avec attributs Pandoc ([texte]{.classe})",
    ),
    Rule(
        "crossref",
        "error",
        "markdown",
        re.compile(r"(?<![\w.])\??@(?:fig|tbl|sec|eq|lst|exr)-[\w-]+"),
        "Renvoi croisé Quarto non résolu",
    ),
    Rule(
        "python-fence",
        "error",
        "markdown",
        re.compile(r"^(?:>\s*)*(?:```|~~~)\s*\{python\}", re.MULTILINE),
        "Bloc ```{python} laissé dans une cellule markdown",
    ),
    Rule(
        "style-script",
        "warning",
        "markdown",
        re.compile(r"<(?:style|script)\b", re.IGNORECASE),
        "Balise <style>/<script> ignorée par Colab dans le markdown",
    ),
    Rule(
        "quarto-class",
        "warning",
        "markdown",
        re.compile(
            r'class="[^"]*\b(?:column-margin|panel-tabset|cell-output|quarto-[\w-]+|badge-container)\b'
        ),
        "Classe CSS propre au site Quarto, sans effet dans Colab",
    ),
    Rule(
        "cell-option",
        "warning",
        "code",
        re.compile(r"^#\|\s*(?:echo|output|include)\s*:\s*false", re.MULTILINE),
        "Option de cellule Quarto ignorée par Colab (le code/la sortie restera visible)",
    ),
]

SEVERITY_ORDER = {"never": 3, "error": 2, "warning": 1}

FENCED_CODE = re.compile(r"^(?:>\s*)*(```|~~~).*?^(?:>\s*)*\1\s*$", re.MULTILINE | re.DOTALL)
INLINE_CODE = re.compile(r"`[^`\n]+`")


def mask_code(markdown: str) -> str:
    """
    Blank out code spans so rules do not fire on documented syntax.

    Fenced blocks keep their line breaks so reported line numbers stay right.
    Fences announcing {python} are kept, since the python-fence rule targets them.
    """

    def blank_fence(match):
        first_line = match.group(0).split("\n", 1)[0]
        if "{python}" in first_line:
            return match.group(0)
        return "\n" * match.group(0).count("\n")

    masked = FENCED_CODE.sub(blank_fence, markdown)
    return INLINE_CODE.sub(lambda m: " " * len(m.group(0)), masked)


@dataclass
class Finding:
    path: Path
    cell: int
    line: int
    rule: Rule
    excerpt: str

    def __str__(self):
        return (
            f"{self.path}: cellule {self.cell}, ligne {self.line} "
            f"[{self.rule.severity}:{self.rule.id}] {self.rule.message}\n"
            f"    {self.excerpt}"
        )


def check_notebook(path: Path) -> list[Finding]:
    """
    Run every rule on each cell of a notebook.

    Args:
        path (Path): Path to the .ipynb file.

    Returns:
        list[Finding]: One finding per rule match.
    """
    try:
        nb = nbformat.read(path, as_version=4)
        nbformat.validate(nb)
    except Exception as e:
        invalid = Rule("invalid-notebook", "error", "", re.compile(""), "Notebook invalide")
        return [Finding(path, 0, 0, invalid, str(e).splitlines()[0])]

    findings = []
    for index, cell in enumerate(nb.cells):
        source = cell.source
        scanned = mask_code(source) if cell.cell_type == "markdown" else source
        lines = source.splitlines()
        for rule in RULES:
            if rule.cell_type != cell.cell_type:
                continue
            for match in rule.pattern.finditer(scanned):
                line = scanned.count("\n", 0, match.start())
                excerpt = lines[line].strip()[:120] if line < len(lines) else ""
                findings.append(Finding(path, index, line + 1, rule, excerpt))
    return findings


def collect_notebooks(paths: list[str]) -> list[Path]:
    notebooks = []
    for p in map(Path, paths):
        if p.is_dir():
            notebooks.extend(sorted(p.rglob("*.ipynb")))
        elif p.suffix == ".ipynb":
            notebooks.append(p)
        else:
            logger.warning(f"Ignoré (ni dossier ni .ipynb) : {p}")
    return [nb for nb in notebooks if ".ipynb_checkpoints" not in nb.parts]


def main():
    parser = argparse.ArgumentParser(
        description="Check rendered notebooks for features Google Colab cannot display."
    )
    parser.add_argument("paths", nargs="+", help=".ipynb files or directories to scan")
    parser.add_argument(
        "--fail-on",
        choices=["error", "warning", "never"],
        default="error",
        help="Lowest severity that makes the script exit with status 1 (default: error)",
    )
    args = parser.parse_args()

    notebooks = collect_notebooks(args.paths)
    if not notebooks:
        logger.error("Aucun notebook trouvé")
        sys.exit(1)

    findings = [f for nb in notebooks for f in check_notebook(nb)]
    for finding in findings:
        print(finding)

    by_rule = Counter((f.rule.severity, f.rule.id) for f in findings)
    affected = len({f.path for f in findings})
    print(f"\n{len(notebooks)} notebooks analysés, {affected} avec au moins un problème")
    for (severity, rule_id), count in sorted(by_rule.items()):
        print(f"  {severity:<8}{rule_id:<18}{count}")

    threshold = SEVERITY_ORDER[args.fail_on]
    if any(SEVERITY_ORDER[f.rule.severity] >= threshold for f in findings):
        sys.exit(1)


if __name__ == "__main__":
    main()
