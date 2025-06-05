if (file.exists("~/.Rprofile")) sys.source("~/.Rprofile", envir = environment())

options(
  blogdown.author = "黄湘云", 
  blogdown.warn.future = FALSE,
  blogdown.method = 'html',
  digits = 4, formatR.indent = 2, 
  servr.port = 4321,
  blogdown.yaml.empty = FALSE, 
  blogdown.rename_file = TRUE,
  blogdown.title_case = function(x) {
    # if the title is pure ASCII, use title case
    if (xfun::is_ascii(x)) tools::toTitleCase(x) else x
  }, blogdown.hugo.server = c("--buildDrafts", "--buildFuture", "--navigateToChanged"),
  blogdown.publishDir = paste(getwd(), "public", sep = "-"),
  blogdown.files_filter = "content/post/",
  blogdown.draft.output = FALSE,
  blogdown.knit.on_save = TRUE,
  blogdown.new_bundle = FALSE,
  blogdown.serve_site.startup = FALSE
)

options(blogdown.hugo.version = "0.147.7")
