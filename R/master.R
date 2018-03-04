#' @title Internal function to run the master process
#' @description Do not call this function directly.
#'   It is only exported to make available to `callr::r_bg()`.
#'   It is not an interface function. The API is unstable.
#' @export
#' @keywords internal
#' @return nothing
#' @param cache a `storr` cache to communicate with the workers
#' @param schedule an `igraph` of job dependencies
run_master <- function(cache, schedule){
  queue <- new_job_queue(schedule = schedule)
  workers <- cache$list(namespace = "status")
  while (work_remains(cache = cache, queue = queue)){
    for (worker in workers){
      if (is_idle(worker = worker, cache = cache)){
        collect_job(
          worker = worker,
          cache = cache,
          queue = queue,
          schedule = schedule
        )
        next_job <- pop0(queue)
        set_job(worker = worker, job = next_job, cache = cache)
        set_running(worker = worker, cache = cache)
      }
    }
    Sys.sleep(1e-9)
  }
  terminate_workers(cache = cache)
}

work_remains <- function(cache, queue){
  datastructures::size(queue) > 0 || any(
    purrr::map_lgl(
      .x = cache$list(namespace = "status"),
      .f = is_running,
      cache = cache
    )
  )
}

collect_job <- function(worker, cache, queue, schedule){
  if (!has_job(worker = worker, cache = cache)){
    return()
  }
  job <- get_job(worker = worker, cache = cache)
  decrease_next_keys(job = job, queue = queue, schedule = schedule)
}
