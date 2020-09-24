if (file.exists("~/.Rprofile")) {
  base::sys.source("~/.Rprofile", envir = environment())
}

options(blogdown.new_bundle = TRUE)



reminder_jupyter <- function(file = "./content/getting-started/06_rappels_classes.Rmd",
                             out = "ipynb"){

  sprintf(
    "jupytext --to %s %s",
    out,
    file
  )
  
}


reminder_badges <- function(notebook = ""){
  
  if (notebook != ""){
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
  onyxia_link <- "[![Onyxia](https://img.shields.io/badge/launch-onyxia-brightgreen)](https://spyrales.sspcloud.fr/my-lab/catalogue/inseefrlab-datascience/jupyter/deploiement)"
  binder_link <- sprintf(
    "[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/linogaliana/python-datascientist/master%s)",
    binder_path
  )
  colab_link <- sprintf("[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](http://colab.research.google.com/github/linogaliana/python-datascientist/blob/master%s)",
                        notebook)
  
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

