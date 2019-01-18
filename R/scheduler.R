#' Run jobs in topological order
#' @param graph TBD
#' @export
schedule <- function(graph) {
  code <- V(graph)$code
  names(code) <- V(graph)$name
  queue <- new_priority_queue(graph)
  workers <- new.env(parent = emptyenv())
  while (work_remains(queue, workers)) {
    launch_code(queue, workers, code)
    lapply(names(workers), resolve_worker, graph = graph, queue = queue, workers = workers)
    Sys.sleep(0.1) # Use backoff function
  }
} # rlang::invoke(code)

work_remains <- function(queue, workers) {
  !queue$empty() || length(names(workers))
}

launch_code <- function(queue, workers, code) {
  id <- queue$pop0()
  if (!length(id)) {
    return()
  }
  workers[[id]] <- rlang::invoke(code[[id]])
}

resolve_worker <- function(id, graph, queue, workers) {
  if (future::resolved(workers[[id]])) {
    rm(list = id, envir = workers)
    decrease_revdep_keys(queue, graph, id)
  }
}
