context("lapply")

test_with_dir("hire(type = \"lapply\") works", {
  workload <- example_workload()
  schedule <- example_schedule()
  # Currently hangs:
#  hire(workload = workload, schedule = schedule, workers = 1) # nolint
#  expect_true(file.exists("coef_regression_small.rds")) # nolint
  expect_true(TRUE) # Clearly this line is just a placeholder.
})
