decorated_future <- function(inner, pre = function() {}, post = function() {}) {
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
resolve.dDecoratedFuture <- function(x, ...) {
  future::resolved(x$inner)
}
