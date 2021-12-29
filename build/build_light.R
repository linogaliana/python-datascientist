source(".Rprofile")

library(knitr)  
library(reticulate)  

content_rmd <- readLines("diff.txt")
content_rmd <- content_rmd[startsWith(content_rmd, "content/course")]
content_rmd <- content_rmd[endsWith(content_rmd, ".Rmd")]
#content_rmd <- content_rmd[!grepl("/git/", content_rmd)]
content_rmd <- content_rmd[!grepl("06a_exo_supp_webscraping.", content_rmd)]

file.remove(
  gsub(
    ".Rmd",".html", content_rmd
  )
)

knitr::knit_engines$set(python = reticulate::eng_python)
knitr::opts_chunk$set(fig.path = "")
knitr::opts_chunk$set(eval = TRUE, warning = FALSE, message = FALSE)


lapply(
  content_rmd, function(i){
    print(sprintf("Rendering %s", i))
    knitr::knit(i, envir = new.env(), output = gsub(".Rmd", ".md", i))
  })

file.remove(
  gsub(
    ".Rmd",".html", content_rmd
  )
)








