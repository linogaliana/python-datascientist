arborescence <- list.dirs("./content", recursive = TRUE)

content_rmd <- list.files("./content", recursive = TRUE, pattern = "*.Rmd", full.names = TRUE)
content_rmd <- content_rmd[!grepl("/git/", content_rmd)]
content_rmd <- content_rmd[!grepl("06a_exo_supp_webscraping.", content_rmd)]
content_rmd <- content_rmd[5]

file.remove(
  gsub(
    ".Rmd",".html", content_rmd
  )
)



lapply(
  content_rmd, function(i){
    print(sprintf("Rendering %s", i))
    rmarkdown::render(i, envir = new.env(),
                      output_format = rmarkdown::md_document(variant = "commonmark"),
                      # output_file = gsub(".Rmd", ".md", basename(i)),
                      output_dir = dirname(i))
  })

file.remove(
  gsub(
    ".Rmd",".html", content_rmd
  )
)




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





