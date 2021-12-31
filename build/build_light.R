source(".Rprofile")

library(knitr)  
library(reticulate)  

content_rmd <- readLines("diff.txt")
content_rmd <- content_rmd[startsWith(content_rmd, "content/course")]
content_rmd <- content_rmd[endsWith(content_rmd, ".Rmd")]
#content_rmd <- content_rmd[!grepl("/git/", content_rmd)]
content_rmd <- content_rmd[!grepl("06a_exo_supp_webscraping.", content_rmd)]

# make sure you also take _index.Rmd
content_index <- dirname(content_rmd)
content_index <- paste0(content_index, "/_index.Rmd")
content_index <- content_index[file.exists(content_index)]


content_rmd <- unique(c(content_rmd, content_index))
  
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








