
file.remove(
  gsub(
    ".Rmd",".html", list.files("./content", recursive = TRUE, pattern = "*.Rmd", full.names = TRUE)
  )
)

lapply(
  list.files("./content", recursive = TRUE, pattern = "*.Rmd", full.names = TRUE), function(i){
    print(sprintf("Rendering %s", i))
    rmarkdown::render(i, envir = new.env())
  })
