#' @title Create a decorated future.
#' @description A decorated future is a wrapper
#'   that assigns pre-work and post-work to an existing
#'   inner future. For more on futures, visit
#'   <https://github.com/HenrikBengtsson/future>.
#' @details When the scheduler executes a decorated future,
#'   the pre-work defined in `pre` runs on the master process,
#'   and then the inner future runs. When the scheduler collects
#'   a decorated future, it checks that the inner future is resolved
#'   and then does the post-work defined in `post`.
#' @export
#' @return A decorated future that wraps around `inner`.
#' @param inner The original future that the decorated future wraps around.
#' @param pre A function, the pre-work to be executed on the master process
#'   before the inner future.
#' @param post A function, the post-work to be executed on the master process
#'   after the inner future.
#' @examples
#' \dontrun{
#' success <- function() {
#'   future::future(list(success = TRUE))
#' }
#' x <- 1
#'
#' delayed_future <- future.callr::callr({
#'   Sys.sleep(1)
#'   list(success = TRUE)
#' })
#' decorated_future <- decorated_future(
#'   delayed_future,
#'   post = function() {
#'     x <<- x + 2
#'   }
#' )
#' code <- list(
#'   a = function() {
#'     decorated_future
#'   },
#'   b = function() {
#'     x <<- x * 3; success()
#'   }
#' )
#'
#' vertices <- tibble::tibble(name = letters[1:2], code)
#' edges <- tibble::tibble(from = "a", to = "b")
#' graph <- igraph::graph_from_data_frame(edges, vertices = vertices)
#'
#' schedule(graph)
#' print(x) # Should be 9.
#' }
decorated_future <- function(inner, pre = function() {}, post = function() {}) { # nolint
  structure(
    list(
      inner = inner,
      pre = pre,
      post = post
    ),
    class = c("DecoratedFuture", class(inner))
  )
}

#' @export
run.DecoratedFuture <- function(future, ...) {
  future$pre()
  future::run(future$inner)
}

#' @export
resolve.DecoratedFuture <- function(x, ...) {
  future::resolve(x$inner)
  x$post()
}

#' @export
resolved.DecoratedFuture <- function(x, ...) {
  future::resolved(x$inner)
}
