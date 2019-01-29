new_priority_queue <- function(graph) {
  targets <- igraph::V(graph)$name
  if (!length(targets)) {
    return(
      refclass_priority_queue$new(
        data = data.frame(
          target = character(0),
          ndeps = integer(0),
          priority = numeric(0),
          stringsAsFactors = FALSE
        )
      )
    )
  }
  ndeps <- lapply(
    X = targets,
    FUN = function(target) {
      igraph::degree(graph, v = target, mode = "in")
    }
  )
  ndeps <- unlist(ndeps)
  queue <- refclass_priority_queue$new(
    data = data.frame(
      target = as.character(targets),
      ndeps = as.integer(ndeps),
      priority = NA_integer_, # TODO: either implement or remove
      stringsAsFactors = FALSE
    )
  )
  queue$sort()
  queue
}

# This is not actually a serious O(log n) priority queue
# based on a binary heap. It is a naive placeholder.
# I we can drop down to C if we need something faster.
refclass_priority_queue <- methods::setRefClass(
  Class = "refclass_priority_queue",
  fields = list(data = "data.frame"),
  methods = list(
    size = function() {
      nrow(.self$data)
    },
    empty = function() {
      .self$size() < 1
    },
    list = function() {
      .self$data$target
    },
    sort = function() {
      ndeps <- priority <- NULL
      precedence <- with(.self$data, order(ndeps, priority))
      .self$data <- .self$data[precedence, ]
    },
    # Peek at the head node of the queue
    # if and only if its ndeps is 0.
    peek0 = function() {
      if (!.self$empty() && .self$data$ndeps[1] < 1) {
        .self$data$target[1]
      }
    },
    # Extract the head node of the queue
    # if and only if its ndeps is 0.
    pop0 = function() {
      if (!.self$empty() && .self$data$ndeps[1] < 1) {
        out <- .self$data$target[1]
        .self$data <- .self$data[-1, ]
        out
      }
    },
    # Get all the ready targets
    list0 = function() {
      if (!.self$empty() && .self$data$ndeps[1] < 1) {
        .self$data$target[.self$data$ndeps < 1]
      }
    },
    remove = function(targets) {
      .self$data <- .self$data[!(.self$data$target %in% targets), ]
      invisible()
    },
    # This is all wrong and inefficient.
    # Needs the actual decrease-key algorithm
    decrease_key = function(targets) {
      index <- .self$data$target %in% targets
      .self$data$ndeps[index] <- .self$data$ndeps[index] - 1
      .self$sort()
    }
  )
)

# Very specific to drake, does not belong inside
# a generic priority queue.
decrease_revdep_keys <- function(queue, graph, target) {
  opt <- igraph::igraph_opt("return.vs.es")
  on.exit(igraph::igraph_options(return.vs.es = opt))
  igraph::igraph_options(return.vs.es = FALSE)
  index <- igraph::adjacent_vertices(graph, v = target, mode = "out")
  revdeps <- V(graph)$name[unlist(index) + 1]
  revdeps <- intersect(revdeps, queue$list())
  queue$decrease_key(targets = revdeps)
}
