if (file.exists("~/.Rprofile")) {
  base::sys.source("~/.Rprofile", envir = environment())
}

options(blogdown.new_bundle = TRUE)
options(blogdown.hugo.version = "0.83.0")
options(blogdown.method = 'markdown')


reminder_jupyter <- function(file = "./content/getting-started/06_rappels_classes.Rmd",
                             out = "ipynb"){
  
  sprintf(
    "jupytext --to %s %s",
    out,
    file
  )
  
}

download_badge <- function(notebook = "", github_link = 'https://github.com/linogaliana/python-datascientist'){
  
  if (notebook == ""){
    link <- sprintf(
      "https://downgit.github.io/#/home?url=%s/blob/master/notebooks/course",
      github_link
    )
  } else{
    link <- sprintf(
      "https://downgit.github.io/#/home?url=%s%s",
      github_link,
      notebook
    )
  }
  
  
  return(
    sprintf(
      "[![Download](https://img.shields.io/badge/Download-Notebook-important?logo=Jupyter)](%s)",
      link
    )
  )
  
}

visualize_badge <- function(notebook = "", github_link = 'https://github.com/linogaliana/python-datascientist'){
  
  
  if (notebook == ""){
    nbviewer_link <- 'https://nbviewer.jupyter.org/github/linogaliana/python-datascientist/tree/master'
  } else{
    nbviewer_link <- sprintf(
      'https://nbviewer.jupyter.org/github/linogaliana/python-datascientist/blob/master%s',
      notebook
    )
  }
  
  
  return(
    sprintf(
      "[![nbviewer](https://img.shields.io/badge/Visualize-nbviewer-blue?logo=Jupyter)](%s)",
      nbviewer_link
    )
  )  
  
}


reminder_badges <- function(notebook = "", onyxia_only = FALSE, split = NULL,
                            type = c("md", "html")){
  
  type <- match.arg(type)
  
  if (notebook != ""){
    if (!endsWith(notebook, ".ipynb")){
      notebook <- paste0(notebook, ".ipynb")
    }
    github_link <- 'https://github.com/linogaliana/python-datascientist/blob/master'
    binder_path <- paste0("?filepath=",notebook)
    notebook <- paste0('/', notebook)
    nbviewer_link <- sprintf(
      'https://nbviewer.jupyter.org/github/linogaliana/python-datascientist/blob/master%s',
      notebook
    )
    chapter <- tools::file_path_sans_ext(basename(notebook))
    section <- basename(dirname(notebook))
  } else{
    github_link <- 'https://github.com/linogaliana/python-datascientist'
    binder_path <- ""  
    nbviewer_link <- 'https://nbviewer.jupyter.org/github/linogaliana/python-datascientist/tree/master'
  }
  
  if (type == "md"){
    download_link <- sprintf(
      "[![Download](https://img.shields.io/badge/Download-Notebook-important?logo=Jupyter)](https://downgit.github.io/#/home?url=%s%s)",
      github_link,
      notebook
    )
  } else{
    download_link <- sprintf(
      '<a href="https://downgit.github.io/#/home?url=%s%s" target="_blank" rel="noopener"><img src="https://img.shields.io/badge/Download-Notebook-important?logo=Jupyter" alt="Download"></a>',
      github_link,
      notebook
    )
  }
  
  github_link <- sprintf('<a href="%s%s" class="github"><i class="fab fa-github"></i></a>',
                         github_link,
                         notebook)
  
  if (type == "md"){
    nbviewer_link <- paste0(
      "[![nbviewer](https://img.shields.io/badge/Visualize-nbviewer-blue?logo=Jupyter)](",
      nbviewer_link,")"
    )
  } else{
    nbviewer_link <- sprintf(
      '<a href="%s" target="_blank" rel="noopener"><img src="https://img.shields.io/badge/Visualize-nbviewer-blue?logo=Jupyter" alt="nbviewer"></a>',
      nbviewer_link
    )
  }
  
  chapter <- tools::file_path_sans_ext(basename(notebook))
  section <- basename(dirname(notebook))
  
  onyxia_link_tmplt <- paste0(
    "https://datalab.sspcloud.fr/launcher/inseefrlab-helm-charts-datascience/jupyter",
    "?autoLaunch=true&onyxia.friendlyName=%C2%ABpython-datascience%C2%BB",
    "&init.personalInit=%C2%ABhttps%3A%2F%2Fraw.githubusercontent.com%2Flinogaliana%2Fpython-datascientist%2Fmaster%2Fsspcloud%2Finit-jupyter.sh%C2%BB",
    "&init.personalInitArgs=%C2%AB${section}%20${chapter}%C2%BB&security.allowlist.enabled=false"
  )
  onyxia_link_launcher <- stringr::str_interp(onyxia_link_tmplt, list(section=section, chapter=chapter))
  if (type == "md"){
    onyxia_link <- paste0(
      "[![Onyxia](https://img.shields.io/badge/SSPcloud-Tester%20via%20SSP--cloud-informational&color=yellow?logo=Python)]",
      "(",onyxia_link_launcher,")"
    )
  } else{
    onyxia_link <- sprintf(
      '<a href="%s" target="_blank" rel="noopener"><img src="https://img.shields.io/badge/SSPcloud-Tester%20via%20SSP--cloud-informational&amp;color=yellow?logo=Python" alt="Onyxia"></a>',
      onyxia_link_launcher
    )
  }
  
  if (!is.null(split) && (4 %in% split)){
    onyxia_link <- c(onyxia_link, "<br>")
  }
  
  if (type == "md"){
    binder_link <- sprintf(
      "[![Binder](https://img.shields.io/badge/Launch-Binder-E66581.svg?logo=data:image/png;base64,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)](https://mybinder.org/v2/gh/linogaliana/python-datascientist/master%s)",
      binder_path
    )
  } else{
    binder_link <- sprintf(
      '<a href="https://mybinder.org/v2/gh/linogaliana/python-datascientist/master?filepath=%s" target="_blank" rel="noopener"><img src="https://img.shields.io/badge/Launch-Binder-E66581.svg?logo=data:image/png;base64,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" alt="Binder"></a>',
      binder_path
    )
  }
  
  if (!is.null(split) && (5 %in% split)){
    binder_link <- c(binder_link, "<br>")
  }
  
  if (type == "md"){
    colab_link <- sprintf("[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](http://colab.research.google.com/github/linogaliana/python-datascientist/blob/master%s)",
                          notebook)
  } else{
    colab_link <- sprintf(
      '<a href="http://colab.research.google.com/github/linogaliana/python-datascientist/blob/master%s" target="_blank" rel="noopener"><img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab"></a>',
      notebook
    )
  }
  
  if (!is.null(split) && (6 %in% split)){
    colab_link <- c(colab_link, "<br>")
  }
  
  if (type == "md"){
    vscode_link <- sprintf("[![githubdev](https://open.vscode.dev/badges/open-in-vscode.svg)](https://github.dev/linogaliana/python-datascientist%s)",
                           notebook)
  } else{
    vscode_link <- sprintf(
      '<a href="https://github.dev/linogaliana/python-datascientist%s" target="_blank" rel="noopener"><img src="https://open.vscode.dev/badges/open-in-vscode.svg" alt="githubdev"></a></p>',
      notebook)
  }
  
  badges <- c(
    github_link,
    download_link,
    nbviewer_link,
    onyxia_link
  )
  
  if (isFALSE(onyxia_only)){
    badges <- c(badges,
                binder_link,
                colab_link,
                vscode_link)
  }
  
  if (type == "html") badges <- c('<p class="badges">', badges, '</p>')
  return(
    cat(badges, sep = "\n")
  )
  
}


print_badges <- function(fpath = NULL, onyxia_only = FALSE, split = 4){
  if (is.null(fpath)){
    fpath <- knitr::current_input(dir = TRUE)
  }
  fpath <- gsub(paste0(here::here(),"/./"), "", fpath)
  fpath <- gsub("Rmd", "ipynb", fpath)
  fpath <- gsub("content","notebooks",fpath)
  reminder_badges(fpath, onyxia_only = onyxia_only, split = split)
}

github_link <- function(fpath = NULL){
  if (is.null(fpath)){
    fpath <- knitr::current_input(dir = TRUE)
  }
  fpath <- gsub(paste0(here::here(),"/./"), "", fpath)
  fpath <- gsub("Rmd", "ipynb", fpath)
  fpath <- gsub("content","notebooks",fpath)
  return(fpath)
}


reminder_box <- function(boxtype = "warning", type = c("html","markdown")){
  type <- match.arg(type)
  icon <- switch(boxtype,
                 warning = "fa fa-exclamation-triangle",
                 hint = "fa fa-lightbulb",
                 tip = "fa fa-lightbulb",
                 note = "fa fa-comment",
                 exercise = "fas fa-pencil-alt")
  box <- c(
    sprintf(
      '{{< panel status="%s" title="%s" icon="%s" >}}',
      boxtype,
      Hmisc::capitalize(boxtype),
      icon
    ),
    "Example",
    "{{< /panel >}}"
  )
  if (type == "html") cat(box, sep = "\n")
  
  box <- gsub("<","%", box)
  box <- gsub(">","%", box)
  
  cat(box, sep = "\n")
}

# Hook from Maelle Salmon: https://ropensci.org/technotes/2020/04/23/rmd-learnings/
modif_plot <- function(x, options, dir_path) {
  hugoopts <- options$hugoopts
  paste0(
    "{", "{<figure src=", # the original code is simpler
    # but here I need to escape the shortcode!
    '"', paste0(dir_path,"/",x), '" ',
    if (!is.null(hugoopts)) {
      glue::glue_collapse(
        glue::glue('{names(hugoopts)}="{hugoopts}"'),
        sep = " "
      )
    },
    ">}}\n"
  )
}


message("For local preview when the pages are built: blogdown::hugo_build(local = TRUE)")



