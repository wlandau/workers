new_workers_cache <- function(){
  path <- tempfile()
  cache <- storr::storr_rds(path = path)
  for (namespace in cache$list_namespaces()){
    # There probably won't be any namespaces leftover.
    cache$clear(namespace = namespace) # nocov
  }
  writeLines(text = "*", con = file.path(path, ".gitignore"))
  cache
}
