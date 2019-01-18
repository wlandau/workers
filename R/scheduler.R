#' Run jobs in topological order
#' @param graph TBD
#' @export
schedule <- function(graph) {
  code <- V(graph)$code

  topo_order <- as.integer(topo_sort(graph))
  code <- code[topo_order]

  map(code, rlang::invoke)
  invisible()
}
