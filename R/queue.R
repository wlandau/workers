new_queue <- function(graph){
  vertices <- igraph::V(graph)$name
  priorities <- lapply(
    X = vertices,
    FUN = function(vertex){
      length(
        dependencies(graph = graph, vertices = vertex, reverse = FALSE))
    }
  ) %>%
    unlist %>%
    as.numeric
  stopifnot(any(priorities < 1)) # Stop if nothing has ready deps.
  queue <- datastructures::fibonacci_heap("numeric", "character")
  datastructures::insert(obj = queue, x = priorities, y = vertices)
}

# Pop only if the element has priority 0
pop0 <- function(queue, tol = 1e-6){
  top_value <- unlist(datastructures::peek(queue), use.names = FALSE)
  top_meta <- datastructures::handle(queue, value = top_value)[[1]]
  top_key <- top_meta$key
  if (abs(top_key) < tol){
    unlist(datastructures::pop(queue), use.names = FALSE)
  } else {
    NULL
  }
}

decrease_revdep_keys <- function(vertices, graph, queue){
  if (!length(vertices)){
    return()
  }
  revdeps <- dependencies(
    graph = graph,
    vertices = vertices,
    reverse = TRUE
  )
  lapply(
    X = revdeps,
    FUN = decrease_single_key,
    queue = queue
  )
}

decrease_single_key <- function(queue, vertex){
  meta <- datastructures::handle(obj = queue, value = vertex)[[1]]
  datastructures::decrease_key(
    obj = queue, from = meta$key, to = meta$key - 1, handle = meta$handle)
}

dependencies <- function (graph, vertices, reverse = FALSE){
  if (!length(vertices)) {
    return(character(0))
  }
  igraph::adjacent_vertices(
    graph = graph,
    v = vertices,
    mode = ifelse(reverse, "out", "in")
  ) %>%
    lapply(FUN = names) %>%
    unlist %>%
    unname %>%
    unique
}
