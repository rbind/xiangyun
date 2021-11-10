if (file.exists("~/.Rprofile")) sys.source("~/.Rprofile", envir = environment())

options(
  servr.port = 4321L, 
  blogdown.author = "黄湘云", 
  blogdown.warn.future = FALSE,
  blogdown.method = 'markdown',
  digits = 4, formatR.indent = 2, 
  blogdown.yaml.empty = FALSE, 
  blogdown.rename_file = TRUE,
  blogdown.title_case = function(x) {
    # if the title is pure ASCII, use title case
    if (xfun::is_ascii(x)) tools::toTitleCase(x) else x
  }, blogdown.hugo.server = c("--buildDrafts", "--buildFuture", "--navigateToChanged"),
  blogdown.publishDir = paste(getwd(), "public", sep = "-"),
  blogdown.hugo.version = "0.89.2",
  blogdown.files_filter = "content/post/",
  blogdown.draft.output = FALSE,
  blogdown.knit.on_save = TRUE,
  blogdown.new_bundle = FALSE,
  blogdown.serve_site.startup = FALSE
)
