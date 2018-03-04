#' @title Return an example workload for [hire()].
#' @description Return an example workload for [hire()].
#' @export
#' @seealso [hire()], [example_schedule()]
#' @return a named list of language objects (jobs to run)
#' @param format Format of the output. If `"tibble"`, then the output
#'   will be a tibble with columns `job` and `command` to specify the jobs
#'   to run. The `job` column has alphanumeric job IDs, and the `command`
#'   column has langauge objects or expressions to evaluate.
#'   Ultimately, these tibbles
#'   and data frames are converted into environments because jobs
#'   are much faster to look up that way.
#'   But the conversion could take time for large workloads.
#'   For the sake of speed, you may want to supply the environment
#'   to [hire()] directly.
#'   To get an example environment,
#'   call `example_schedule(format = "environment")`.
#' @examples
#' # Tibbles and data frames are easy to look at...
#' example_workload(format = "tibble")
#' # But in `hire()`, they are ultimately converted into environments
#' # because objects are much faster to look up that way.
#' # For
#' envir <- example_workload(format = "environment")
#' envir
#' ls(envir)
#' envir$small
example_workload <- function(format = c("tibble", "environment")){
  format <- match.arg(format)
  workload <- tibble::tribble(
    ~job, ~command,
    "small", quote(saveRDS(data.frame(x = rnorm(48), y = rnorm(48)), "small.rds")), # nolint
    "large", quote(saveRDS(data.frame(x = rnorm(64), y = rnorm(64)), "large.rds")), # nolint
    "regression_small", quote(saveRDS(lm(y ~ x, data = readRDS("small.rds")), "regression_small.rds")), # nolint
    "regression_large", quote(saveRDS(lm(y ~ x, data = readRDS("large.rds")), "regression_large.rds")), # nolint
    "summ_regression_small", quote(saveRDS(suppressWarnings(summary(readRDS("regression_small.rds")$residuals)), "summ_regression_small.rds")), # nolint
    "summ_regression_large", quote(saveRDS(suppressWarnings(summary(readRDS("regression_large.rds")$residuals)), "summ_regression_large.rds")), # nolint
    "coef_regression_small", quote(saveRDS(suppressWarnings(summary(readRDS("regression_small.rds")))$coefficients, "coef_regression_small.rds")), # nolint
    "coef_regression_large", quote(saveRDS(suppressWarnings(summary(readRDS("regression_large.rds")))$coefficients, "coef_regression_large.rds")) # nolint
  )
  if (format == "environment"){
    workload <- parse_workload(workload)
  }
  workload
}

parse_workload <- function(workload){
  if (is.data.frame(workload)){
    jobs <- workload$job
    workload <- as.list(parse(text = workload$command, keep.source = FALSE))
    names(workload) <- jobs
    workload <- list2env(workload)
  }
  workload
}

#' @title Return an example schedule for [hire()].
#' @description Return an example schedule for [hire()].
#' @export
#' @seealso [hire()], [example_workload()]
#' @return an example value for the `schedule` argument to [hire()].
#' @param format Format of the output. If `"tibble"`, then the output
#'   will be a tibble with columns `from` and `to` to specify dependencies
#'   among the job IDs. For example, in `example_schedule(format = "tibble")`,
#'   the top row tells us that the job named `small` must complete before
#'   the job `regression_small` can begin. For isolated jobs (with no dependencies
#'   and nothing downstream) just include rows where `from` and `to` are the same.
#'   Ultimately, these tibbles
#'   and data frames are converted into `igraph` objects, which are faster
#'   to work with. But the conversion could take time for large schedules.
#'   For the sake of speed, you may want to supply the `igraph`
#'   directly to [hire()].
#'   To get an example igraph, call `example_schedule(format = "igraph")`.
#' @examples
#' # Tibbles and data frames are easy to look at...
#' example_schedule(format = "tibble")
#' # But in `hire()`, schedules are ultimately converted into `igraph`
#' # objects, which could take some time for large schedules.
#' example_schedule(format = "igraph")
example_schedule <- function(format = c("tibble", "igraph")){
  format <- match.arg(format)
  schedule <- tibble::tribble(
    ~from, ~to,
    "small", "regression_small",
    "regression_small", "coef_regression_small",
    "regression_small", "summ_regression_small",
    "large", "regression_large",
    "regression_large", "coef_regression_large",
    "regression_large", "summ_regression_large"
  )
  if (format == "igraph"){
    schedule <- parse_schedule(schedule)
  }
  schedule
}

parse_schedule <- function(schedule){
  if (is.data.frame(schedule)){
    schedule <- igraph::graph_from_data_frame(d = schedule) %>%
      igraph::simplify(remove.multiple = TRUE, remove.loops = TRUE)
  }
  schedule
}
