example_args <- function(){
  cmd <- c(
    small = "saveRDS(data.frame(x = rnorm(48), y = rnorm(48)), 'small.rds')",
    large = "saveRDS(data.frame(x = rnorm(64), y = rnorm(64)), 'large.rds')",
    regression_small = "saveRDS(lm(y ~ x, data = readRDS('small.rds')), 'regression_small.rds')",
    regression_large = "saveRDS(lm(y ~ x, data = readRDS('large.rds')), 'regression_large.rds')",
    summ_regression_small = "saveRDS(suppressWarnings(summary(readRDS('regression_small.rds')$residuals)), 'summ_regression_small.rds')",
    summ_regression_large = "saveRDS(suppressWarnings(summary(readRDS('regression_large.rds')$residuals)), 'summ_regression_large.rds')",
    coef_regression_small = "saveRDS(suppressWarnings(summary(readRDS('regression_small.rds')))$coefficients, 'coef_regression_small.rds')",
    coef_regression_large = "saveRDS(suppressWarnings(summary(readRDS('regression_large.rds')))$coefficients, 'coef_regression_large.rds')"
  )
  workload <- as.list(parse(text = cmd, keep.source = FALSE))
  names(workload) <- names(cmd)
  edges <- tibble::tribble(
    ~from, ~to,
    "small", "regression_small",
    "regression_small", "coef_regression_small",
    "regression_small", "summ_regression_small",
    "large", "regression_large",
    "regression_large", "coef_regression_large",
    "regression_large", "summ_regression_large"
  )
  schedule <- igraph::graph_from_data_frame(d = edges)
  list(schedule = schedule, workload = workload)
}
