#' @title Hire a crew of R workers.
#' @description Hire a crew of R workers.
#' @export
#' @seealso [example_workload()], [example_schedule()]
#' @return nothing
#' @param workload the job IDs and commands to run them.
#'   Possible options for input format:
#'   1. `tibble`: You can supply a `tibble` or `data.frame`
#'   with columns `job` (for the job ID) and `command`
#'   (for the R command to run). Job IDs are characters, and
#'   commands are language objects or expressions.
#'   (You can make a language object with `quote()`.)
#'   Example: `example_workload(format = "tibble")`.
#'   2. `environment`: Ultimately, any `tibble`
#'   and `data.frame` inputs are converted
#'   into `environment` objects, with the job IDs as names
#'   and commands (language objects) as value.
#'   Ultimately, job commands are much faster to look up this way.
#'   Example: `example_workload(format = "environment")`.
#' @param schedule a schedule of job IDs with all the
#'   relevant jobs represented.
#'  `crew` looks at the `schedule` to learn
#'  the order in which jobs can be executed.
#'   Possible options for input format:
#'   1. `tibble`: You can supply a `tibble` with columns `from` and `to`.
#'    For example, in `example_schedule(format = "tibble")`,
#'   the top row tells us that the job named `small` must complete before
#'   the job `regression_small` can begin. For isolated jobs
#'   (with no dependencies and nothing downstream)
#'   just include rows where `from` and `to` are the same.
#'   Example: `example_schedule(format = "tibble")`.
#'   2. `igraph`: Ultimately, any `tibble`
#'   and `data.frame` inputs are converted
#'   into `igraph` objects, which are faster
#'   to work with. But the conversion could take time for large schedules.
#'   For the sake of speed, you may want to supply the `igraph`
#'   directly to [hire()].
#'   Example: `example_schedule(format = "igraph")`.
#' @param workers number of parallel workers to spawn in the crew.
#'   If `type` is `"lapply"` (default), you may need to pass other arguments
#'   to `...` to ensure the workers actually run in parallel. For example,
#'   if `fun` is `parallel::mclapply`, then you should set `mc.cores`
#'   to the number of workers. For `fun` equal to `lapply` (default),
#'   no parallelism is possible no matter how many `workers` you request.
#' @param type character scalar naming the type of crew to hire.
#'   Currently, `"lapply"` is the only crew type.
#' @param fun an `lapply`-like function to use for persistent workers
#'   if `type` is `"lapply"`.
#' @param ... additional arguments.
#' @examples
#' \dontrun{
#' withr::with_dir(tempfile(), {
#' # Run all the jobs in the workload in the
#' # correct order given in the schedule.
#' # Use 2 persistent workers.
#' hire(
#'   workload = workload = example_workload(),
#'   schedule = schedule = example_schedule(),
#'   fun = lapply,
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
  workload <- parse_workload(workload)
  schedule <- parse_schedule(schedule)
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
  path <- tempfile()
  cache <- storr::storr_rds(path = path)
  writeLines(text = "*", con = file.path(path, ".gitignore"))
  lapply(X = as.character(seq_len(workers)), FUN = set_idle, cache = cache)
  cache
}
