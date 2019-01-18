context("test-scheduler")

success <- function() {
  future::future(list(success = TRUE))
}

test_that("empty graph", {
  code <- list()
  graph <- igraph::make_empty_graph()
  expect_error(schedule(graph), NA)
})

test_that("one-vertex graph", {
  x <- 1
  code <- list(
    a = function() { x <<- 2; success() }
  )

  vertices <- tibble::tibble(name = "a", code)
  edges <- tibble::tibble(from = character(), to = character())
  graph <- igraph::graph_from_data_frame(edges, vertices = vertices)

  schedule(graph)
  expect_equal(x, 2)
})


test_that("linear graph", {
  x <- 1
  code <- list(
    a = function() { x <<- x * 2; success() },
    b = function() { x <<- x + 1; success() }
  )

  vertices <- tibble::tibble(name = letters[1:2], code)
  edges <- tibble::tibble(from = "a", to = "b")
  graph <- igraph::graph_from_data_frame(edges, vertices = vertices)

  schedule(graph)
  expect_equal(x, 3)
})

test_that("linear graph, reversed", {
  skip("WTF")

  x <- 1
  code <- list(
    a = function() { x <<- x * 2; success() },
    b = function() { x <<- x + 1; success() }
  )

  vertices <- tibble::tibble(name = letters[1:2], code)
  edges <- tibble::tibble(from = "a", to = "b")
  graph <- igraph::graph_from_data_frame(edges, vertices = vertices)

  schedule(graph[2:1])
  expect_equal(x, 3)
})

test_that("linear graph, delayed", {
  skip("NYI")

  x <- 1
  delayed_future <- future.callr::callr({ Sys.sleep(1); list(success = TRUE) })
  code <- list(
    a = function() { delayed_future },
    b = function() { if (future::resolved(delayed_future)) x <<- x + 1; success() }
  )

  vertices <- tibble::tibble(name = letters[1:2], code)
  edges <- tibble::tibble(from = "a", to = "b")
  graph <- igraph::graph_from_data_frame(edges, vertices = vertices)

  schedule(graph)
  expect_equal(x, 2)
})

test_that("diamond graph", {
  x <- NULL
  y <- NULL
  z <- NULL
  w <- NULL
  code <- list(
    a = function() { x <<- 2; success() },
    b = function() { y <<- x + 1; success() },
    c = function() { z <<- x * 2; success() },
    d = function() { w <<- 3 * y + z; success() }
  )

  vertices <- tibble::tibble(name = letters[1:4], code)
  edges <- tibble::tibble(
    from = c("a", "a", "b", "c"),
    to = c("b", "c", "d", "d")
  )
  graph <- igraph::graph_from_data_frame(edges, vertices = vertices)
  schedule(graph)

  expect_equal(x, 2)
  expect_equal(y, 3)
  expect_equal(z, 4)
  expect_equal(w, 13)
})

test_that("diamond graph, reversed", {
  x <- NULL
  y <- NULL
  z <- NULL
  w <- NULL
  code <- list(
    a = function() { x <<- 2; success() },
    b = function() { y <<- x + 1; success() },
    c = function() { z <<- x * 2; success() },
    d = function() { w <<- 3 * y + z; success() }
  )

  vertices <- tibble::tibble(name = letters[1:4], code)
  edges <- tibble::tibble(
    from = c("a", "a", "b", "c"),
    to = c("b", "c", "d", "d")
  )
  graph <- igraph::graph_from_data_frame(
    edges[4:1, ],
    vertices = vertices[4:1, ]
  )
  schedule(graph)

  expect_equal(x, 2)
  expect_equal(y, 3)
  expect_equal(z, 4)
  expect_equal(w, 13)
})
