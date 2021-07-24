content_rmd <-  list.files("./content", recursive = TRUE, pattern = "*.Rmd", full.names = TRUE)
content_rmd <- content_rmd[!grepl("/git/", content_rmd)]

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




Sys.setenv(HUGO_IGNOREERRORS = "error-remote-getjson",
           HUGO_BASEURL = "/",
           #HUGO_BASEURL = "https://linogaliana-teaching.netlify.app/",
           HUGO_RELATIVEURLS = "false",
           BLOGDOWN_POST_RELREF = "true",
           BLOGDOWN_SERVING_DIR = here::here())

cmd = blogdown:::find_hugo()
cmd_args = c("--themesDir themes", "-t github.com")#, "--gc")#, "--minify")
system2(cmd, cmd_args)


#blogdown::stop_server()


# Sys.setenv(HUGO_RELATIVEURLS = "true",
#            BLOGDOWN_POST_RELREF = "true")

# cmd = blogdown:::find_hugo()

#blogdown:::create_shortcode('postref.html', 'blogdown/postref', TRUE)

# cmd_args = c("--themesDir themes", "-t github.com")#, "--gc")#, "--minify")
# system2(cmd, cmd_args)

#blogdowntest::serve_site()

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





