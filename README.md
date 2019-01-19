
<!-- README.md is generated from README.Rmd. Please edit that file -->

![stability-wip](https://img.shields.io/badge/stability-work_in_progress-lightgrey.svg)
[![CRAN](http://www.r-pkg.org/badges/version/workers)](http://cran.r-project.org/package=workers)
[![downloads](http://cranlogs.r-pkg.org/badges/workers)](http://cran.rstudio.com/package=workers)
[![Travis build
status](https://travis-ci.org/wlandau/workers.svg?branch=master)](https://travis-ci.org/wlandau/workers)
[![AppVeyor Build
Status](https://ci.appveyor.com/api/projects/status/github/wlandau/workers?branch=master&svg=true)](https://ci.appveyor.com/project/wlandau/workers)
[![Codecov](https://codecov.io/github/wlandau/workers/coverage.svg?branch=master)](https://codecov.io/github/wlandau/workers?branch=master)

# Purpose

The `workers` package is a platform-agnostic R-focused parallel job
scheduler. For computationally-depanding workflows, schedulers are
important. Some tasks need to complete before others start (for example,
the data munging steps that precede analysis) and `workers` takes
advantages of parallel computing opportunities while saving you the
trouble of figuring out what needs to run when.

# Installation

``` r
devtools::install_github("wlandau/workers")
```

# Usage

Represent your workflow as a dependency graph with functions as
attributes. Each function is a step in the pipeline.

``` r
success <- function() {
  future::future(list(success = TRUE))
}
code <- list(
  a = function() {
    x <<- 2
    success()
  },
  b = function() {
    y <<- x + 1
    success()
  },
  c = function() {
    z <<- x * 2
    success()
  },
  d = function() {
    w <<- 3 * y + z
    success()
  }
)
vertices <- tibble::tibble(name = letters[1:4], code)
edges <- tibble::tibble(
  from = c("a", "a", "b", "c"),
  to = c("b", "c", "d", "d")
)
graph <- igraph::graph_from_data_frame(edges, vertices = vertices)
plot(graph)
```

![](README-use-1.png)<!-- -->

Then, run your workflow with `schedule(graph)`.

``` r
library(workers)
schedule(graph)
```
