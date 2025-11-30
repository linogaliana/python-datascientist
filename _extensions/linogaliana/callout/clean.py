#!/usr/bin/env python3
import argparse
import json
import logging
import os
import re
from typing import Iterable, List, Tuple

logger = logging.getLogger(__name__)

HEADER_PATTERN = re.compile(
    r'>\s*\*\*(Tip|Caution|Note|Important|Warning)\*\*'
)


def process_notebook(path: str) -> Tuple[dict, int]:
    """
    Charge le notebook, modifie les blocs d’admonitions et retourne :
    - l'objet JSON du notebook
    - le nombre de blocs modifiés
    """
    with open(path, "r", encoding="utf-8") as f:
        nb = json.load(f)

    blocks_count = 0

    for cell in nb.get("cells", []):
        if cell.get("cell_type") != "markdown":
            continue

        text = "".join(cell.get("source", []))
        lines = text.splitlines()

        new_lines = []
        i = 0
        while i < len(lines):
            line = lines[i]

            m = HEADER_PATTERN.match(line)
            if not m:
                new_lines.append(line)
                i += 1
                continue

            # --- Bloc trouvé ---
            blocks_count += 1
            logger.debug("Bloc '%s' trouvé dans %s", m.group(1), path)

            # 1) On saute la ligne du header (ex: "> **Tip**")
            i += 1

            # 2) On récupère toutes les lignes citées qui suivent
            while i < len(lines) and lines[i].startswith(">"):
                l = lines[i]

                # On enlève exactement UN chevron au début de la ligne
                if l.startswith(">"):
                    l = l[1:]
                    if l.startswith(" "):
                        l = l[1:]

                new_lines.append(l)
                i += 1

            # 3) Si la ligne suivante est vide, on la garde telle quelle
            if i < len(lines) and lines[i].strip() == "":
                new_lines.append(lines[i])
                i += 1

        # On réécrit la cellule
        cell["source"] = [l + "\n" for l in new_lines]

    logger.debug("Notebook %s : %d bloc(s) modifié(s)", path, blocks_count)
    return nb, blocks_count


def iter_notebooks(paths: Iterable[str]) -> List[str]:
    """Retourne la liste de tous les fichiers .ipynb trouvés dans les chemins donnés."""
    notebooks = []

    for p in paths:
        p = os.path.abspath(p)
        if os.path.isfile(p):
            if p.endswith(".ipynb"):
                notebooks.append(p)
                logger.debug("Notebook trouvé (fichier): %s", p)
        elif os.path.isdir(p):
            logger.debug("Exploration du dossier: %s", p)
            for root, _, files in os.walk(p):
                for name in files:
                    if name.endswith(".ipynb"):
                        full = os.path.join(root, name)
                        notebooks.append(full)
                        logger.debug("Notebook trouvé (dossier): %s", full)
        else:
            logger.warning("Chemin introuvable ou invalide: %s", p)

    notebooks = sorted(set(notebooks))
    return notebooks


def main():
    parser = argparse.ArgumentParser(
        description=(
            "Nettoie les blocs '> **Tip/Note/...**' dans un ou plusieurs notebooks .ipynb.\n"
            "Tu peux passer des fichiers et/ou des dossiers (récursif)."
        )
    )
    parser.add_argument(
        "paths",
        nargs="+",
        help="Fichiers .ipynb et/ou dossiers contenant des notebooks",
    )
    parser.add_argument(
        "--replace",
        action="store_true",
        help="Réécrit les fichiers d'origine au lieu de créer des fichiers *_clean.ipynb",
    )
    parser.add_argument(
        "--verbose",
        "-v",
        action="store_true",
        help="Afficher plus de détails (niveau DEBUG).",
    )

    args = parser.parse_args()

    # Config du logging
    logging.basicConfig(
        level=logging.DEBUG if args.verbose else logging.INFO,
        format="%(levelname)s: %(message)s",
    )

    notebooks = iter_notebooks(args.paths)
    if not notebooks:
        logger.error("Aucun notebook .ipynb trouvé dans les chemins fournis.")
        raise SystemExit(1)

    logger.info("%d notebook(s) trouvé(s).", len(notebooks))

    modified_notebooks = 0
    total_blocks = 0

    for in_path in notebooks:
        logger.info("Traitement : %s", in_path)
        nb, blocks = process_notebook(in_path)

        if blocks == 0:
            logger.info("  Aucun bloc d'admonition trouvé (aucune modification).")
        else:
            logger.info("  %d bloc(s) d'admonition modifié(s).", blocks)
            modified_notebooks += 1
            total_blocks += blocks

        if args.replace:
            out_path = in_path
        else:
            root, ext = os.path.splitext(in_path)
            out_path = f"{root}_clean{ext}"

        with open(out_path, "w", encoding="utf-8") as f:
            json.dump(nb, f, ensure_ascii=False, indent=1)

        logger.debug("Notebook écrit dans : %s", out_path)

    logger.info(
        "Terminé. %d notebook(s) modifié(s), %d bloc(s) transformé(s).",
        modified_notebooks,
        total_blocks,
    )


if __name__ == "__main__":
    main()
