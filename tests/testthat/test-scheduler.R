context("test-scheduler")

test_that("empty graph", {
  graph <- igraph::make_empty_graph()
})

test_that("empty graph", {
  graph <- igraph::make_empty_graph() + igraph::vertices("x")
  schedule(graph)
})

test_that("uncomplicated graph", {
  vertices <- tibble::tibble(
    name = letters[1:4],
    code = map(letters[1:4], function(x) function() warning(x))
  )

  edges <- data.frame(
    from = c("a", "a", "b", "c"),
    to = c("b", "c", "d", "d"),
    stringsAsFactors = FALSE
  )
  graph <- igraph::graph_from_data_frame(edges, vertices = vertices)

  schedule(graph)
})
