new_queue <- function(graph){
  vertices <- igraph::V(graph)$name
  priorities <- lapply(
    X = vertices,
    FUN = function(vertex){
      length(
        dependencies(vertices = vertex, graph = graph, reverse = FALSE))
    },
    jobs = config$jobs
  ) %>%
    unlist
  stopifnot(any(priorities < 1)) # Stop if nothing has ready deps.
  fheap <- datastructures::fibonacci_heap("integer", "character")
  datastructures::insert(obj = fheap, x = priorities, y = targets)
}

# Pop only if the element has priority 0
pop0 <- function(queue, tol = 1e-6){
  top_value <- unlist(peek(fheap), use.names = FALSE)
  top_meta <- handle(fheap, value = top_value)[[1]]
  top_key <- top_meta$key
  if (abs(top_key) < tol){
    unlist(pop(fheap), use.names = FALSE)
  } else {
    NULL
  }
}

dependencies <- function (vertices, graph, reverse = FALSE){
  if (!length(nodes)) {
    return(character(0))
  }
  igraph::adjacent_vertices(
    graph = graph,
    v = targets,
    mode = ifelse(reverse, "out", "in")
  ) %>%
    lapply(FUN = names) %>%
    unlist %>%
    unname %>%
    unique
}
