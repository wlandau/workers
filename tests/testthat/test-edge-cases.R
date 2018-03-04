context("edge cases")

test_that("edge cases", {
  expect_equal(dependencies(NULL), character(0))
  expect_silent(decrease_next_keys(NULL))
})
