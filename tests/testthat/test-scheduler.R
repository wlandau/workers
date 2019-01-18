context("test-scheduler")

test_that("empty graph", {
  graph <- igraph::make_empty_graph()
})

test_that("one-vertex graph", {
  graph <- igraph::make_empty_graph() + igraph::vertices("x")
  envir <- new.env(parent = emptyenv())
  schedule(graph, list(x = function() envir$x <- TRUE))
  expect_true(envir$x)
})


test_that("uncomplicated graph", {
  code <- map(rlang::set_names(letters[1:4]), function(x) function() warning(x))

  edges <- data.frame(
    from = c("a", "a", "b", "c"),
    to = c("b", "c", "d", "d"),
    stringsAsFactors = FALSE
  )
  graph <- igraph::graph_from_data_frame(edges)

  schedule(graph, code)
})

test_that("uncomplicated graph, reversed", {
  code <- map(rlang::set_names(letters[1:4]), function(x) function() warning(x))

  edges <- data.frame(
    from = c("a", "a", "b", "c"),
    to = c("b", "c", "d", "d"),
    stringsAsFactors = FALSE
  )
  graph <- igraph::graph_from_data_frame(edges[4:1, ])

  schedule(graph, code[4:1])
})
