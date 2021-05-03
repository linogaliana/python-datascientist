content_rmd <-  list.files("./content", recursive = TRUE, pattern = "*.Rmd", full.names = TRUE)[1:14]

file.remove(
  gsub(
    ".Rmd",".html", content_rmd
  )
)

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


Sys.setenv(#HUGO_RELATIVEURLS = "true",
           BLOGDOWN_POST_RELREF = "true")

cmd = blogdown:::find_hugo()

cmd_args = c("--themesDir themes", "-t github.com", "--gc", "-b /")#, "--minify")
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





