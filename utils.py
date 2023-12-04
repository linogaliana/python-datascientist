import re


def reminder_badges(
    source_file = "content/01_toto.Rmd",
    type = ['md','html'],
    split = None,
    onyxia_only = False,
    ssp_cloud_service="python",
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
        nbviewer_link = "https://nbviewer.jupyter.org/" + \
            github_repo_notebooks_simplified + \
            "/tree/main"
    else:
        github_link = github_repo_notebooks + \
            '/blob/main'
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

    gpu_suffix = "-gpu" if GPU else ""

    sspcloud_jupyter_link_launcher = f"https://datalab.sspcloud.fr/launcher/ide/jupyter-{ssp_cloud_service}{gpu_suffix}"\
        f"?autoLaunch=true&onyxia.friendlyName=%C2%AB{chapter_no_extension}%C2%BB"\
        "&init.personalInit=%C2%ABhttps%3A%2F%2Fraw.githubusercontent.com%2Flinogaliana%2Fpython-datascientist%2Fmaster%2Fsspcloud%2Finit-jupyter.sh%C2%BB"\
        f"&init.personalInitArgs=%C2%AB{'%20'.join(onyxia_init_args)}%C2%BB&security.allowlist.enabled=false"

    if type == "md":
        sspcloud_jupyter_link = "[![Onyxia]"\
            "(https://img.shields.io/badge/SSP%20Cloud-Tester_avec_Jupyter-orange?logo=Jupyter&logoColor=orange)]"\
            f"({sspcloud_jupyter_link_launcher})"
    else:
        sspcloud_jupyter_link = f'<a href="{sspcloud_jupyter_link_launcher}" target="_blank" rel="noopener">'\
            '<img src="https://img.shields.io/badge/SSP%20Cloud-Tester_avec_Jupyter-orange?logo=Jupyter&logoColor=orange" alt="Onyxia"></a>'

    if split == 4:
        sspcloud_jupyter_link = f'{sspcloud_jupyter_link}<br>'

    sspcloud_vscode_link_launcher = f"https://datalab.sspcloud.fr/launcher/ide/vscode-{ssp_cloud_service}{gpu_suffix}"\
        f"?autoLaunch=true&onyxia.friendlyName=%C2%AB{chapter_no_extension}%C2%BB"\
        "&init.personalInit=%C2%ABhttps%3A%2F%2Fraw.githubusercontent.com%2Flinogaliana%2Fpython-datascientist%2Fmaster%2Fsspcloud%2Finit-vscode.sh%C2%BB"\
        f"&init.personalInitArgs=%C2%AB{'%20'.join(onyxia_init_args)}%C2%BB&security.allowlist.enabled=false"

    if type == "md":
        sspcloud_vscode_link = "[![Onyxia]"\
            "(https://img.shields.io/badge/SSP%20Cloud-Tester_avec_VSCode-blue?logo=visualstudiocode&logoColor=blue)]"\
            f"({sspcloud_vscode_link_launcher})"
    else:
        sspcloud_vscode_link = f'<a href="{sspcloud_vscode_link_launcher}" target="_blank" rel="noopener">'\
            '<img src="https://img.shields.io/badge/SSP%20Cloud-Tester_avec_VSCode-blue?logo=visualstudiocode&logoColor=blue" alt="Onyxia"></a>'

    if split == 5:
        sspcloud_vscode_link = f'{sspcloud_vscode_link}<br>'


    if type == "md":
        colab_link = "[![Open In Colab]"\
            "(https://colab.research.google.com/assets/colab-badge.svg)]"\
            f"(http://colab.research.google.com/{github_repo_notebooks_simplified}/blob/main{notebook_rel_path})"
    else:
        colab_link = f'<a href="https://colab.research.google.com/github/linogaliana/python-datascientist-notebooks/blob/main{notebook_rel_path}" target="_blank" rel="noopener">'\
            '<img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab"></a>'

    if split == 7:
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
        nbviewer_link, sspcloud_jupyter_link,
        sspcloud_vscode_link
        ]

    if onyxia_only is False:
        badges += [
            colab_link,
            vscode_link
        ]

    badges = "\n".join(badges)

    if type == "html":
        badges = f'<p class="badges">{badges}</p>'

    if onyxia_only is True:
        badges = sspcloud_jupyter_link + sspcloud_vscode_link

    return badges

def print_badges(
    fpath,
    onyxia_only=False,
    split=5,
    type="html",
    ssp_cloud_service="python",
    GPU = False,
    correction=False):
      
      badges = reminder_badges(
          fpath,
          type=type,
          split=split,
          onyxia_only=onyxia_only,
          ssp_cloud_service=ssp_cloud_service,
          GPU=GPU,
          correction=correction
          )
          
      print(badges)
