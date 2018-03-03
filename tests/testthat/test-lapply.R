context("test-lapply.R")

test_with_dir("hire(type = \"lapply\") works", {
  workload <- example_workload()
  schedule <- example_schedule()
  hire(workload = workload, schedule = schedule, workers = 1)
  expect_true(file.exists("coef_regression_small.rds"))
})
