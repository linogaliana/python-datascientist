"""
syllabus_table.py

Charge doc/syllabus.json (liste de dicts), enrichit puis
retourne un DataFrame Polars prêt à être affiché avec great_tables.
"""

import re
import json
from pathlib import Path
from typing import Optional, Dict, Mapping, Union
import frontmatter

import polars as pl
import gt_extras as gte
from great_tables import *

DEFAULT_SECTION_MAP: Dict[str, str] = {
    "getting-started": "Introduction",
    "manipulation": "Manipuler des données",
    "visualisation": "Communiquer",
    "modelisation": "Modéliser",
    "NLP": "Natural Language Processing",
    "git": "Git",
}


def build_syllabus_pipeline(
    syllabus_json_path: Union[str, Path] = "doc/syllabus.json",
    section_map: Mapping[str, str] = DEFAULT_SECTION_MAP,
    active_color: str = "#E16462",
    inactive_color: str = "#E9ECEF",
    lang: str = "fr"
) -> Dict[str, pl.DataFrame] :
    df_prepared = build_syllabus_df(
        **{
            "syllabus_json_path": syllabus_json_path,
            "section_map": section_map,
            "active_color": active_color,
            "inactive_color": inactive_color
        }
    ) 
    df_prepared = add_titles_from_qmd(
        df_prepared, project_root=".", lang = lang
    )
    df_prepared = df_prepared.select(
        ["title_link", "section", "classroom_icon", "classroom", "material_icon", "type"]
    )

    syllabus = {k[0]: subdf for k, subdf in df_prepared.group_by("section")}

    return syllabus



def build_syllabus_df(
    syllabus_json_path: Union[str, Path] = "doc/syllabus.json",
    section_map: Mapping[str, str] = DEFAULT_SECTION_MAP,
    active_color: str = "#E16462",
    inactive_color: str = "#E9ECEF",
) -> pl.DataFrame:
    """
    Lit un fichier JSON de syllabus et renvoie un DataFrame Polars enrichi.

    Paramètres
    ----------
    syllabus_json_path:
        Chemin vers le fichier JSON (par défaut "doc/syllabus.json").
    section_map:
        Mapping {part: section} (part est le dossier après /content/).
    active_color:
        Couleur utilisée pour les icônes "actives".
    inactive_color:
        Couleur utilisée pour les icônes "inactives" (uniquement pour classroom_icon).

    Retour
    ------
    pl.DataFrame
        DataFrame avec colonnes: file, classroom, exercise, part, section,
        classroom_icon, material_icon
    """
    path = Path(syllabus_json_path)

    with path.open("r", encoding="utf-8") as f:
        syllabus = json.load(f)

    if not isinstance(syllabus, list):
        raise ValueError("Le JSON attendu doit être une liste de dictionnaires (list[dict]).")

    df = pl.DataFrame(syllabus)

    # 1) Extraire la "part" depuis /content/<part>/
    df = df.with_columns(
        part=pl.col("file").cast(pl.Utf8).str.extract(r"^/?content/([^/]+)/", 1)
    )

    # 2) Mapper vers une section lisible
    df = df.with_columns(
        section=pl.col("part").replace(section_map, default="Autre")
    )

    # 3) Icône classroom: active si classroom non nul
    df = df.with_columns(
        classroom_icon=pl.col("classroom")
        .is_not_null()
        .map_elements(
            lambda x: gte.fa_icon_repeat(
                name="chalkboard-user",
                fill=active_color if x else inactive_color,
            ),
            return_dtype=pl.String,
        )
    )
    df = df.with_columns(
        classroom=pl.when(pl.col("classroom").is_null())
        .then(pl.lit("En autoformation"))
        .otherwise(pl.concat_str([pl.col("classroom"), pl.lit(" ou autoformation")]))
    )    

    # 4) Icône matériel: laptop-code si exercise True, sinon book-open-reader (toujours active_color)
    df = df.with_columns(
        material_icon=pl.col("exercise")
        .fill_null(False)
        .map_elements(
            lambda x: gte.fa_icon_repeat(
                name="laptop-code" if x else "book-open-reader",
                fill=active_color,
            ),
            return_dtype=pl.String,
        )
    )

    df = df.with_columns(
        type = pl.when(pl.col("exercise").fill_null(False))
        .then(pl.lit("Lecture sur le site et notebooks d'exercices"))
        .otherwise(pl.lit("Lecture sur le site"))
    )

    return df



def _normalize_title(title: Optional[str]) -> Optional[str]:
    """Règles de normalisation de titre."""
    if not title:
        return None

    title = title.strip()

    # "Partie ..." -> "Introduction à la partie ..."
    if re.match(r"^\s*Partie\b", title):
        title = re.sub(r"^\s*Partie\b", "Introduction à la partie", title, count=1)

    # "Partie ..." -> "Introduction à la partie ..."
    if re.match(r"^\s*Part\b", title):
        title = re.sub(r"^\s*Part\b", "Introduction to part", title, count=1)


    return title


def _extract_title_from_qmd(
    path: Path,
    lang: str = "fr"
    ) -> Optional[str]:
    """Extrait `title` du YAML front matter d'un .qmd via python-frontmatter."""
    if not path.exists():
        return None

    try:
        post = frontmatter.load(path)
    except Exception:
        return None

    title_location = "title" if lang == "fr" else "title-en"
    title = post.get(title_location)
    return _normalize_title(title) if isinstance(title, str) else None


def _md_link(label: Optional[str], href: str) -> Optional[str]:
    if not label:
        return None
    # Évite de casser le markdown si jamais le titre contient des crochets
    safe_label = label.replace("[", "\\[").replace("]", "\\]")
    return f"[{safe_label}]({href})"


def add_titles_from_qmd(
    df: pl.DataFrame,
    project_root: Union[str, Path] = ".",
    file_col: str = "file",
    title_col: str = "title",
    link_col: str = "title_link",
    lang: str = "fr"
) -> pl.DataFrame:
    """
    Ajoute:
    - `title_col`: titre normalisé (str ou None)
    - `link_col`: lien markdown "[titre](chemin)" (str ou None)

    `chemin` est basé sur la colonne `file` normalisée (sans slash initial).
    """
    root = Path(project_root)

    # Normalise les chemins: "/content/..." -> "content/..."
    df2 = df.with_columns(
        _file_norm=pl.col(file_col).cast(pl.Utf8).str.replace(r"^/+", "")
    )

    # Extraire titre
    df2 = df2.with_columns(
        pl.col("_file_norm").map_elements(
            lambda p: _extract_title_from_qmd(root / p, lang),
            return_dtype=pl.Utf8,
        ).alias(title_col)
    )

    # Construire lien markdown [titre](chemin)
    df2 = df2.with_columns(
        pl.struct(["_file_norm", title_col]).map_elements(
            lambda s: _md_link(s[title_col], s["_file_norm"]),
            return_dtype=pl.Utf8,
        ).alias(link_col)
    ).drop("_file_norm")

    return df2


def build_syllabus_gt(
    df_section: pl.DataFrame,
    dark_theme: bool = False,
) -> GT:
    """
    Construit une table great_tables (GT) pour une section du syllabus.

    Attendu dans df_section:
    - section (sera cachée)
    - title_link (markdown)
    - classroom_icon, classroom
    - material_icon, type
    """
    gt = (
        GT(df_section)
        .cols_hide(columns="section")
        .fmt_markdown("title_link")
        .cols_label(
            {
                "title_link": md("**Title**"),
                "classroom_icon": md("**Mode d'apprentissage**"),
                "material_icon": md("**Type de ressource**"),
            }
        )
        .cols_width({"title_link": "60%"})
        .pipe(gte.gt_merge_stack, col1="classroom_icon", col2="classroom")
        .pipe(gte.gt_merge_stack, col1="material_icon", col2="type")
    )

    if dark_theme:
        gt = gt.pipe(gte.gt_theme_dark)

    return gt