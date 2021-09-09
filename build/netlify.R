
Sys.setenv(HUGO_IGNOREERRORS = "error-remote-getjson",
           HUGO_BASEURL = "/",
           #HUGO_BASEURL = "https://linogaliana-teaching.netlify.app/",
           HUGO_RELATIVEURLS = "false",
           BLOGDOWN_POST_RELREF = "true",
           BLOGDOWN_SERVING_DIR = here::here())

cmd = blogdown:::find_hugo()
cmd_args = c("--themesDir themes", "-t github.com")#, "--gc")#, "--minify")
system2(cmd, cmd_args)
