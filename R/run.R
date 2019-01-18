#' Run jobs in topological order
#' @export
schedule <- function(graph) {
  code <- igraph::vertex.attributes(graph)$code
  map(code, rlang::call2)
  invisible()
}
