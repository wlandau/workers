#' Run jobs in topological order
#' @param graph TBD
#' @param code TBD
#' @export
schedule <- function(graph, code) {
  node_labels <- igraph::vertex.attributes(graph)$name
  topo_order <- as.integer(topo_sort(graph))
  code <- code[node_labels][topo_order]
  map(code, rlang::invoke)
  invisible()
}
