context("lapply")

test_with_dir("hire(type = \"lapply\") works", {
  workload <- example_workload()
  schedule <- example_schedule()
  hire(workload = workload, schedule = schedule, workers = 2, fun = lapply)
  expected_files <- paste0(ls(workload), ".rds")
  expect_true(all(file.exists(expected_files)))
})
