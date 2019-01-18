#' Run jobs in topological order
#' @export
schedule <- function(graph, code) {
  node_labels <- igraph::vertex.attributes(graph)$name
  code <- code[node_labels]
  browser()
  map(code, rlang::invoke)
  invisible()
}
