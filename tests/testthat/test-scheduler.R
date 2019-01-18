context("test-scheduler")

test_that("empty graph", {
  edges <- data.frame(
    from = c("a", "a", "b", "c"),
    to = c("b", "c", "d", "d"),
    stringsAsFactors = FALSE
  )
  graph <- igraph::graph_from_data_frame(edges)

})

test_that("empty graph", {
  edges <- data.frame(
    from = c("a", "a", "b", "c"),
    to = c("b", "c", "d", "d"),
    stringsAsFactors = FALSE
  )
  graph <- igraph::graph_from_data_frame(edges)

})

test_that("uncomplicated graph", {
  edges <- data.frame(
    from = c("a", "a", "b", "c"),
    to = c("b", "c", "d", "d"),
    stringsAsFactors = FALSE
  )
  graph <- igraph::graph_from_data_frame(edges)

})
