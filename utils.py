import re


def reminder_badges(
    source_file = "content/01_toto.Rmd",
    type = ['md','html'],
    split = None,
    onyxia_only = False,
    GPU=False,
    correction = False
):

    if isinstance(type, list):
        type = type[0]

    notebook = re.sub(
        r"(.Rmd|.qmd)",
        ".ipynb",
        source_file
    )
    if correction:
        notebook = re.sub(r"content", "corrections", notebook)
    else:
        notebook = re.sub(r"content", "notebooks", notebook)

    github_repo_notebooks_simplified = "github/linogaliana/python-datascientist-notebooks"
    github_alias = github_repo_notebooks_simplified.replace("github", "github.com")
    github_repo_notebooks = \
        f"https://{github_alias}"

    if notebook == "":
        github_link = github_repo_notebooks
        binder_path = ""  
        nbviewer_link = "https://nbviewer.jupyter.org/" + \
            github_repo_notebooks_simplified + \
            "/tree/main"
    else:
        github_link = github_repo_notebooks + \
            '/blob/main'
        binder_path = f"?filepath={notebook}"
        nbviewer_link = "https://nbviewer.jupyter.org/" +\
            github_repo_notebooks_simplified + \
            f"blob/main/{notebook}"

    notebook_rel_path = f"/{notebook}"
    section, chapter = notebook.rsplit("/", maxsplit=1)

    if type == "md":
        download_link = "[![Download]"\
            "(https://img.shields.io/badge/Download-Notebook-important?logo=Jupyter)]"\
            f"(https://downgit.github.io/#/home?url={github_link}{notebook_rel_path})"
    else:
        download_link = "<a href=\"https://downgit.github.io/#/home?url="\
        f'{github_link}{notebook_rel_path}\" target=\"_blank\" rel=\"noopener\">'\
        '<img src=\"https://img.shields.io/badge/Download-Notebook-important?logo=Jupyter\" alt=\"Download\"></a>'


    github_link = f'<a href="{github_link}{notebook_rel_path}" class="github">'\
        '<i class="fab fa-github"></i></a>'

    if type == "md":
        nbviewer_link = "[![nbviewer]"\
            "(https://img.shields.io/badge/Visualize-nbviewer-blue?logo=Jupyter)]"\
            f"({nbviewer_link})"
    else:
        nbviewer_link = f'<a href="{nbviewer_link}" target="_blank" rel="noopener">'\
            '<img src="https://img.shields.io/badge/Visualize-nbviewer-blue?logo=Jupyter" alt="nbviewer"></a>'

    section_latest = section.rsplit("/", maxsplit=1)[-1]
    chapter_no_extension = re.sub(".ipynb", "", chapter)
    onyxia_init_args = [section_latest, chapter_no_extension]

    if correction:
        onyxia_init_args.append("correction")

    if GPU is True:
        service_name = "jupyter-pytorch-gpu"
    else:
        service_name = "jupyter-python"

    onyxia_init_args = "%20".join(onyxia_init_args)
    onyxia_link_launcher = f"https://datalab.sspcloud.fr/launcher/ide/{service_name}"\
        "?autoLaunch=true&onyxia.friendlyName=%C2%ABpython-datascience%C2%BB"\
        "&init.personalInit=%C2%ABhttps%3A%2F%2Fraw.githubusercontent.com%2Flinogaliana%2Fpython-datascientist%2Fmaster%2Fsspcloud%2Finit-jupyter.sh%C2%BB"\
        f"&init.personalInitArgs=%C2%AB{onyxia_init_args}%C2%BB&security.allowlist.enabled=false"

    if type == "md":
        onyxia_link = "[![Onyxia]"\
            "(https://img.shields.io/badge/SSPcloud-Tester%20via%20SSP--cloud-informational&color=yellow?logo=Python)]"\
            f"({onyxia_link_launcher})"
    else:
        onyxia_link = f'<a href="{onyxia_link_launcher}" target="_blank" rel="noopener">'\
            '<img src="https://img.shields.io/badge/SSPcloud-Tester%20via%20SSP--cloud-informational&amp;color=yellow?logo=Python" alt="Onyxia"></a>'

    if split == 4:
        onyxia_link = f'{onyxia_link}<br>'

    if type == "md":
        binder_link = "[![Binder]"\
            "(https://img.shields.io/badge/Launch-Binder-E66581.svg?logo=data:image/png;base64,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)](https://mybinder.org/"\
            f"v2/gh/{github_repo_notebooks_simplified}/main{binder_path})"
    else:
        binder_link = '<a href="https://mybinder.org/v2/gh/'\
        'linogaliana/python-datascientist-notebooks/main?filepath={binder_path}" target="_blank" rel="noopener">'\
        '<img src="https://img.shields.io/badge/Launch-Binder-E66581.svg?logo=data:image/png;base64,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" alt="Binder"></a>'

    if split == 5:
        binder_link = f'{binder_link}<br>'

    if type == "md":
        colab_link = "[![Open In Colab]"\
            "(https://colab.research.google.com/assets/colab-badge.svg)]"\
            f"(http://colab.research.google.com/{github_repo_notebooks_simplified}/blob/main{notebook_rel_path})"
    else:
        colab_link = f'<a href="https://colab.research.google.com/github/linogaliana/python-datascientist-notebooks/blob/main{notebook_rel_path}" target="_blank" rel="noopener">'\
            '<img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab"></a>'

    if split == 6:
        colab_link = f'{colab_link}<br>'

    if type == "md":
        vscode_link = "[![githubdev]"\
            "(https://img.shields.io/static/v1?logo=visualstudiocode&label=&message=Open%20in%20Visual%20Studio%20Code&labelColor=2c2c32&color=007acc&logoColor=007acc)]"\
            f"(https://github.dev/linogaliana/python-datascientist-notebooks{notebook_rel_path})"
    else:
        vscode_link = f'<a href="https://github.dev/linogaliana/python-datascientist-notebooks{notebook_rel_path}" target="_blank" rel="noopener">'\
            '<img src="https://img.shields.io/static/v1?logo=visualstudiocode&label=&message=Open%20in%20Visual%20Studio%20Code&labelColor=2c2c32&color=007acc&logoColor=007acc" alt="githubdev"></a></p>'

    badges = [
        github_link, download_link,
        nbviewer_link, onyxia_link
        ]

    if onyxia_only is False:
        badges += [
            binder_link,
            colab_link,
            vscode_link
        ]

    badges = "\n".join(badges)

    if type == "html":
        badges = f'<p class="badges">{badges}</p>'

    if onyxia_only is True:
        badges = onyxia_link

    return badges

def print_badges(
    fpath,
    onyxia_only=False,
    split=4,
    type="html",
    GPU = False,
    correction=False):
      
      badges = reminder_badges(
          fpath,
          type=type,
          split=split,
          onyxia_only=onyxia_only,
          GPU=GPU,
          correction=correction
          )
          
      print(badges)
