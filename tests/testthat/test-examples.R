context("examples")

test_that("example inputs to hire()", {
  expect_is(example_schedule(format = "tibble"), "tbl")
  expect_is(example_schedule(format = "igraph"), "igraph")
  expect_is(example_workload(format = "tibble"), "tbl")
  expect_is(example_workload(format = "environment"), "environment")
})
