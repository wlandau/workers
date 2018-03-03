new_queue <- function(schedule){
  jobs <- igraph::V(schedule)$name
  priorities <- lapply(
    X = jobs,
    FUN = function(job){
      length(
        dependencies(schedule = schedule, jobs = job, reverse = FALSE))
    }
  ) %>%
    unlist %>%
    as.numeric
  stopifnot(any(priorities < 1)) # Stop if nothing has ready deps.
  queue <- datastructures::fibonacci_heap("numeric", "character")
  datastructures::insert(obj = queue, x = priorities, y = jobs)
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

decrease_revdep_keys <- function(queue, jobs, schedule){
  if (!length(jobs)){
    return()
  }
  revdeps <- dependencies(
    schedule = schedule,
    jobs = jobs,
    reverse = TRUE
  )
  lapply(
    X = revdeps,
    FUN = decrease_single_key,
    queue = queue
  )
  invisible()
}

decrease_single_key <- function(queue, job){
  meta <- datastructures::handle(obj = queue, value = job)[[1]]
  datastructures::decrease_key(
    obj = queue, from = meta$key, to = meta$key - 1, handle = meta$handle)
}

dependencies <- function (schedule, jobs, reverse = FALSE){
  if (!length(jobs)) {
    return(character(0))
  }
  igraph::adjacent_vertices(
    graph = schedule,
    v = jobs,
    mode = ifelse(reverse, "out", "in")
  ) %>%
    lapply(FUN = names) %>%
    unlist %>%
    unname %>%
    unique
}
