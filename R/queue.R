new_job_queue <- function(schedule){
  jobs <- igraph::V(schedule)$name
  priorities <- lapply(
    X = jobs,
    FUN = function(job){
      length(
        dependencies(job = job, schedule = schedule, reverse = FALSE))
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
  if (size(queue) < 1){
    return()
  }
  top_value <- unlist(datastructures::peek(queue), use.names = FALSE)
  top_meta <- datastructures::handle(queue, value = top_value)[[1]]
  top_key <- top_meta$key
  if (abs(top_key) < tol){
    unlist(datastructures::pop(queue), use.names = FALSE)
  } else {
    NULL
  }
}

decrease_next_keys <- function(job, queue, schedule){
  if (!length(job)){
    return()
  }
  next_jobs <- dependencies(
    job = job,
    schedule = schedule,
    reverse = TRUE
  )
  lapply(
    X = next_jobs,
    FUN = decrease_single_key,
    queue = queue
  )
  invisible()
}

decrease_single_key <- function(job, queue){
  meta <- datastructures::handle(obj = queue, value = job)[[1]]
  datastructures::decrease_key(
    obj = queue, from = meta$key, to = meta$key - 1, handle = meta$handle)
}

dependencies <- function (job, schedule, reverse = FALSE){
  if (!length(job)) {
    return(character(0))
  }
  igraph::adjacent_vertices(
    graph = schedule,
    v = job,
    mode = ifelse(reverse, "out", "in")
  ) %>%
    lapply(FUN = names) %>%
    unlist %>%
    unname %>%
    unique
}
