#' @title Internal function to run the master process
#' @description Do not call this function directly.
#'   It is only exported to make available to `callr::r_bg()`.
#'   It is not an interface function. The API is unstable.
#' @export
#' @keywords internal
#' @return nothing
#' @param cache a `storr` cache to communicate with the workers
#' @param schedule an `igraph` of job dependencies
run_master <- function(workers, cache, schedule){
  queue <- new_job_queue(schedule = schedule)
  while (work_remains(workers = workers, cache = cache, queue = queue)){
    for (worker in worker_ids(workers)){
      if (is_idle(worker = worker, cache = cache)){
        collect_job(
          worker = worker,
          cache = cache,
          queue = queue,
          schedule = schedule
        )
        next_job <- pop0(queue)
        if (length(next_job)){
          set_job(worker = worker, job = next_job, cache = cache)
          set_running(worker = worker, cache = cache)
        } else {
          set_done(worker = worker, cache = cache)
        }
      }
    }
    Sys.sleep(1e-9)
  }
}

work_remains <- function(workers, cache, queue){
  datastructures::size(queue) > 0 || !all(
    purrr::map_lgl(
      .x = worker_ids(workers),
      .f = is_done,
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
