#' @title Initiate a group of workers.
#' @description Initiate a group of workers.
#' @export
#' @seealso [example_workload()], [example_schedule()]
#' @return nothing
#' @param workload the job IDs and commands to run them,
#'   either as a `tibble`/`data.frame` or an environment.
#'   For details, see [example_workload()].
#' @param schedule a schedule of job IDs with all the
#'   relevant jobs represented, either as a `tibble`/`data.frame`
#'   or an `igraph`. For details, see [example_schedule()].
#' @param workers number of parallel workers to spawn in the workers.
#'   If `type` is `"lapply"` (default), you may need to pass other arguments
#'   to `...` to ensure the workers actually run in parallel. For example,
#'   if `fun` is `parallel::mclapply`, then you should set `mc.cores`
#'   to the number of workers. For `fun` equal to `lapply` (default),
#'   no parallelism is possible no matter how many `workers` you request.
#' @param type character scalar naming the type of workers to hire.
#'   Currently, `"lapply"` is the only workers type.
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
    hire_lapply(
      workload = workload,
      schedule = schedule,
      workers = workers,
      fun = fun,
      ...
    )
  }
  invisible()
}

hire_lapply <- function(
  workload,
  schedule,
  workers = 1,
  fun = lapply,
  ...
){
  workload <- parse_workload(workload)
  schedule <- parse_schedule(schedule)
  cache <- new_workers_cache()
  args <- list(workers = workers, cache = cache, schedule = schedule)
  rx <- callr::r_bg(
    func = function(workers, cache, schedule){
      # Probably not covered because of the callr process.
      # Definitely run though.
      workers::run_master(workers = workers, cache = cache, schedule = schedule) # nocov # nolint
    },
    args = args
  )
  fun(
    X = worker_ids(workers),
    FUN = run_worker,
    cache = cache,
    workload = workload,
    ...
  )
  cache$destroy()
}
