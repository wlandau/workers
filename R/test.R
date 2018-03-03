test_with_dir <- function(desc, ...){
  new <- tempfile()
  dir_empty(new)
  withr::with_dir(
    new = new,
    code = {
      testthat::test_that(desc = desc, ...)
    }
  )
  invisible()
}

dir_empty <- function(x){
  unlink(x, recursive = TRUE, force = TRUE)
  dir.create(x)
}
