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


badge <- function(type = "onyxia"){
  if (type == "onyxia"){
    "[![Onyxia](https://img.shields.io/badge/SSPcloud-Tester%20via%20SSP--cloud-informational&color=yellow?logo=Python)](https://datalab.sspcloud.fr/launcher/inseefrlab-helm-charts-datascience/jupyter?onyxia.friendlyName=%C2%ABpython-datascientist%C2%BB&resources.requests.memory=%C2%AB4Gi%C2%BB)"
  }
}



reminder_badges <- function(notebook = "", onyxia_only = FALSE){
  
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
  } else{
    github_link <- 'https://github.com/linogaliana/python-datascientist'
    binder_path <- ""  
    nbviewer_link <- 'https://nbviewer.jupyter.org/github/linogaliana/python-datascientist/tree/master'
  }
  
  github_link <- sprintf('<a href="%s%s" class="github"><i class="fab fa-github"></i></a>',
                         github_link,
                         notebook)
  nbviewer_link <- paste0(
    "[![nbviewer](https://img.shields.io/badge/visualize-nbviewer-blue)](",
    nbviewer_link,")"
  )
  onyxia_link <- "[![Onyxia](https://img.shields.io/badge/SSPcloud-Tester%20via%20SSP--cloud-informational&color=yellow?logo=Python)](https://datalab.sspcloud.fr/launcher/inseefrlab-helm-charts-datascience/jupyter?onyxia.friendlyName=%C2%ABpython-datascientist%C2%BB&resources.requests.memory=%C2%AB4Gi%C2%BB)"
  binder_link <- sprintf(
    "[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/linogaliana/python-datascientist/master%s)",
    binder_path
  )
  colab_link <- sprintf("[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](http://colab.research.google.com/github/linogaliana/python-datascientist/blob/master%s)",
                        notebook)

  if (isTRUE(onyxia_only)){
    return(
    cat(
      c(
        github_link,
        nbviewer_link,
        onyxia_link
      ),
      sep = "\n"
    )
    )
  }

  return(
    cat(
      c(
        github_link,
        nbviewer_link,
        onyxia_link,
        binder_link,
        colab_link
      ),
      sep = "\n"
    )
  )
  
}


print_badges <- function(fpath = NULL, onyxia_only = FALSE){
  if (is.null(fpath)){
    fpath <- knitr::current_input(dir = TRUE)
  }
  fpath <- gsub(paste0(here::here(),"/./"), "", fpath)
  fpath <- gsub("Rmd", "ipynb", fpath)
  fpath <- gsub("content","notebooks",fpath)
  reminder_badges(fpath, onyxia_only = onyxia_only)
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


message("For local preview when the pages are built: blogdown::hugo_build(local = TRUE)")



