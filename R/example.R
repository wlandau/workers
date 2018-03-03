#' @title Return an example workload for [hire()].
#' @description Return an example workload for [hire()].
#' @export
#' @seealso [hire()], [example_schedule()]
#' @return a named list of language objects (jobs to run)
#' @examples
#' example_workload()
example_workload <- function(){
  cmd <- c(
    small = "saveRDS(data.frame(x = rnorm(48), y = rnorm(48)), 'small.rds')",
    large = "saveRDS(data.frame(x = rnorm(64), y = rnorm(64)), 'large.rds')",
    regression_small = "saveRDS(lm(y ~ x, data = readRDS('small.rds')), 'regression_small.rds')", # nolint
    regression_large = "saveRDS(lm(y ~ x, data = readRDS('large.rds')), 'regression_large.rds')", # nolint
    summ_regression_small = "saveRDS(suppressWarnings(summary(readRDS('regression_small.rds')$residuals)), 'summ_regression_small.rds')", # nolint
    summ_regression_large = "saveRDS(suppressWarnings(summary(readRDS('regression_large.rds')$residuals)), 'summ_regression_large.rds')", # nolint
    coef_regression_small = "saveRDS(suppressWarnings(summary(readRDS('regression_small.rds')))$coefficients, 'coef_regression_small.rds')", # nolint
    coef_regression_large = "saveRDS(suppressWarnings(summary(readRDS('regression_large.rds')))$coefficients, 'coef_regression_large.rds')" # nolint
  )
  workload <- as.list(parse(text = cmd, keep.source = FALSE))
  names(workload) <- names(cmd)
  workload
}

#' @title Return an example schedule for [hire()].
#' @description Return an example schedule for [hire()].
#' @export
#' @seealso [hire()], [example_workload()]
#' @return an `igraph` object of job IDs corresponding to
#'   `names(example_workload())`.
#' @examples
#' example_schedule()
example_schedule <- function(){
  edges <- tibble::tribble(
    ~from, ~to,
    "small", "regression_small",
    "regression_small", "coef_regression_small",
    "regression_small", "summ_regression_small",
    "large", "regression_large",
    "regression_large", "coef_regression_large",
    "regression_large", "summ_regression_large"
  )
  igraph::graph_from_data_frame(d = edges)
}
