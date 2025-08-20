from build.sidebar import (
  build_metadata_dataframe
)

def make_li(path, title, scale_badge=0.8):
    """
    Retourne un <li> HTML avec lien + badge.
    Si index.qmd alors texte : Lire l’introduction de la partie
    Sinon : le titre normal
    """
    import os

    html_path = "/" + path.replace(".qmd", ".html")
    if path.endswith("index.qmd"):
      badge_html = ""
    else:
      badge_html = (
          f'<div style="transform:scale({scale_badge}); margin-top: -4px;">'
          f'{{{{< badges fpath="/{path}" printMessage="false" >}}}}</div>\n'
      )
    
    
    if path.endswith("index.qmd"):
        text = "Lire l’introduction de la partie"
    else:
        text = title
    
    return (
        f'<li><a href="{html_path}">{text}</a><br/>\n'
        f'{badge_html}'
        f'</li>'
    )

def make_details_for_part(group, part_name, field = "title"):
    """
    group = sous-dataframe d’un chapitre
    part_name = texte pour le <summary>
    """
    lis = "\n".join(make_li(row['path'], row[field]) for _, row in group.iterrows())
    
    return (
        f"<details>\n"
        f"  <summary>{part_name}</summary>\n"
        f'  <div style="margin-top:0.3rem;"></div>\n'
        f'  <ul style="margin-top: 0;">\n'
        f"{lis}\n"
        f"  </ul>\n"
        f"</details>"
    )

def create_div_chapter_list(version = "fr", introductory_text='', max_n = None):

    df = build_metadata_dataframe(f'_quarto-{version}.yml')
    if max_n is not None:
        df = df.head(max_n)
    field = "title"
    if version == "en":
        field = field + "-en"


    # 1) Extraire le "chapter" (= dossier parent)
    df['chapter'] = df['path'].str.rsplit('/', n=1).str[0]
    df = df.loc[~df['chapter'].str.contains('annexes')]

    # 2) Conserver l'ordre d'apparition des chapitres
    ordered_chapters = []
    seen = set()
    for chap in df['chapter']:
        if chap not in seen:
            ordered_chapters.append(chap)
            seen.add(chap)

    # 3) Construire le HTML dans l’ordre voulu
    html_blocks = []
    for chap in ordered_chapters:
        group = df[df['chapter'] == chap]
        # Nom de partie à mettre dans <summary> :
        part_title = group.iloc[0][field]
        html_blocks.append(make_details_for_part(group, part_title, field))

    final_html = (
        f'<div class="list-chapter-ordered-{version}">\n'
        f'{introductory_text}'
        f'{"\n\n".join(html_blocks)}'
        '</div>'
    )


    return final_html