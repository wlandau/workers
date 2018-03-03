#' @title Hire a crew of R workers.
#' @description Hire a crew of R workers.
#' @export
#' @return nothing
#' @param workload named list of jobs.
#'   The names are job IDs and the values are expressions or language objects.
#' @param schedule an `igraph` object linking the job IDs together.
#'   This is how `crew` knows how to execute some jobs before other jobs.
#' @param type character scalar naming the type of crew to hire.
#'   Currently, `"lapply"` is the only crew type.
#' @param fun an `lapply`-like function to use for persistent workers
#'   if `type` is `"lapply"`.
#' @param ... additional arguments.
#' @examples
#' \dontrun{
#' withr::with_dir(tempfile(), {
#' attach(example_args()) # Get an example workload and schedule.
#' # Run all the jobs in the workload in the
#' # correct order given in the schedule.
#' # Use 2 persistent workers.
#' hire(
#'   workload = workload,
#'   schedule = schedule,
#'   fun = parallel::mclapply,
#'   workers = 2,
#'   mc.cores = 2
#' )
#' })
#' }
hire <- function(
  workload,
  schedule,
  workers = 1,
  type = "lapply",
  fun = lapply,
  ...
){
  type <- match.arg(type)
  if (type == "lapply"){
    hire_lapply_crew(
      workload = workload,
      schedule = schedule,
      workers = workers,
      fun = fun,
      ...
    )
  }
  invisible()
}

hire_lapply_crew <- function(
  workload,
  schedule,
  workers = 1,
  fun = lapply,
  ...
){
  cache <- new_crew_cache(workers = workers)
  queue <- new_job_queue(schedule = schedule)
  args <- list(cache = cache, queue = queue, schedule = schedule)
  callr::r_bg(func = run_master, args = args)
  fun(
    X = cache$list(namespace = "status"),
    FUN = run_worker,
    cache = cache,
    workload = workload,
    ...
  )
  cache$destroy()
}

new_crew_cache <- function(workers){
  path <- ".crew_workers"
  cache <- storr::storr_rds(
    path = path,
    mangle_key = TRUE
  )
  writeLines(text = "*", con = file.path(path, ".gitignore"))
  lapply(X = as.character(seq_len(workers)), FUN = set_idle, cache = cache)
  cache
}
