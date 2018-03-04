
<!-- README.md is generated from README.Rmd. Please edit that file -->
![stability-wip](https://img.shields.io/badge/stability-work_in_progress-lightgrey.svg) ![stability-experimental](https://img.shields.io/badge/stability-experimental-orange.svg) ![stability-unstable](https://img.shields.io/badge/stability-unstable-yellow.svg) <br> [![Travis build status](https://travis-ci.org/wlandau/crew.svg?branch=master)](https://travis-ci.org/wlandau/crew) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github//wlandau/crew/?branch=master&svg=true)](https://ci.appveyor.com/project/wlandau/crew) [![Codecov](https://codecov.io/github/wlandau/crew/coverage.svg?branch=master)](https://codecov.io/github/wlandau/crew?branch=master) [![CRAN](http://www.r-pkg.org/badges/version/crew)](http://cran.r-project.org/package=crew) | [![downloads](http://cranlogs.r-pkg.org/badges/crew)](http://cran.rstudio.com/package=crew)

Coordinated R Ensembles of Workers
==================================

The `crew` package is a job scheduler for R. It launches a crew of workers do a bunch of jobs together.

Installation
============

`Crew` is a work in progress, and it is currently only available from GitHub.

``` r
devtools::install_github("wlandau/crew")
```

Usage
=====

Your workload is a collection of commands named with job IDs.

``` r
library(crew)
workload <- example_workload()
workload
#> # A tibble: 8 x 2
#>   job                   command   
#>   <chr>                 <list>    
#> 1 small                 <language>
#> 2 large                 <language>
#> 3 regression_small      <language>
#> 4 regression_large      <language>
#> 5 summ_regression_small <language>
#> # ... with 3 more rows

workload$command[1:2]
#> [[1]]
#> saveRDS(data.frame(x = rnorm(48), y = rnorm(48)), "small.rds")
#> 
#> [[2]]
#> saveRDS(data.frame(x = rnorm(64), y = rnorm(64)), "large.rds")
```

Some jobs depend the output from other jobs, so `crew` needs a schedule of job IDs.

``` r
schedule <- example_schedule()
schedule
#> # A tibble: 6 x 2
#>   from             to                   
#>   <chr>            <chr>                
#> 1 small            regression_small     
#> 2 regression_small coef_regression_small
#> 3 regression_small summ_regression_small
#> 4 large            regression_large     
#> 5 regression_large coef_regression_large
#> # ... with 1 more row
```

To run your work, just hire a crew of persistent workers.

``` r
hire(
  workload = workload,
  schedule = schedule,
  fun = parallel::mclapply,      # `lapply()`-like function to launch persistent workers
  workers = 2,                   # number of persistent workers
  mc.cores = 2                   # arguments to the `lapply()`-like function
)
```

Future development
==================

### Debug the persistent workers.

The functionality for persistent workers is not currently working. The master process hangs, and the workers wait indefinitely for the master to post jobs. The top priority for `crew` is to debug this.

### Transient workers

Why would we want one transient worker per job? Because persistent workers can time out. In other words, your computing cluster may impose time limits on long-running workers spawned by `hire(..., fun = future.apply::future_lapply)`.

### Semi-transient workers

It takes a lot of overhead to launch a transient worker for every single job. We will eventually want to distribute groups of jobs among the workers using one of the [knapsack problems](https://en.wikipedia.org/wiki/List_of_knapsack_problems).
