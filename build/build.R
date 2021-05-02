
file.remove(
  gsub(
    ".Rmd",".html", list.files("./content", recursive = TRUE, pattern = "*.Rmd", full.names = TRUE)
  )
)

lapply(
  list.files("./content", recursive = TRUE, pattern = "*.Rmd", full.names = TRUE), function(i){
    print(sprintf("Rendering %s", i))
    knitr::knit(i, envir = new.env(), output = gsub(".Rmd", ".md", i))
  })

file.remove(
  gsub(
    ".Rmd",".html", list.files("./content", recursive = TRUE, pattern = "*.Rmd", full.names = TRUE)
  )
)


Sys.setenv(HUGO_RELATIVEURLS = "true",
           BLOGDOWN_POST_RELREF = "true")

cmd = blogdown:::find_hugo()

cmd_args = c("--themesDir themes", "-t github.com")
system2(cmd, cmd_args)



# file.remove(
#   gsub(
#     ".Rmd",".md", list.files("./content", recursive = TRUE, pattern = "*.Rmd", full.names = TRUE)
#   )
# )

# file.remove(
#   gsub(
#     ".Rmd",".ipynb", list.files("./content", recursive = TRUE, pattern = "*.Rmd", full.names = TRUE)
#   )
# )





