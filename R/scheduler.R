#' Run jobs in topological order
#' @param graph TBD
#' @export
schedule <- function(graph) {
  code <- V(graph)$code
  queue <- new_priority_queue(graph)
  workers <- new.env(parent = emptyenv())
  while (work_remains(queue, workers)) {
    launch_code(queue, workers)
    eapply(workers, resolve_worker)
    Sys.sleep(0.1) # Use backoff function
  }
} # rlang::invoke(code)

work_remains <- function(queue, workers) {
  !queue$empty() || length(names(workers))
}

launch_code <- function(queue, workers) {
  id <- queue$pop0()
  if (!length(id)) {
    return()
  }
  workers[[id]] <- rlang::invoke(code)
}

resolve_worker <- function(worker) {
  browser()
}
