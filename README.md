
<!-- README.md is generated from README.Rmd. Please edit that file -->
![stability-wip](https://img.shields.io/badge/stability-work_in_progress-lightgrey.svg) [![CRAN](http://www.r-pkg.org/badges/version/workers)](http://cran.r-project.org/package=workers) [![downloads](http://cranlogs.r-pkg.org/badges/workers)](http://cran.rstudio.com/package=workers) [![Travis build status](https://travis-ci.org/wlandau/workers.svg?branch=master)](https://travis-ci.org/wlandau/workers) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/wlandau/workers?branch=master&svg=true)](https://ci.appveyor.com/project/wlandau/workers) [![Codecov](https://codecov.io/github/wlandau/workers/coverage.svg?branch=master)](https://codecov.io/github/wlandau/workers?branch=master)

Crews of Workers in R
=====================

The `workers` package is a job scheduler for R. It launches groups coordinated of workers, and the workers run your jobs in parallel and in the correct order.

Installation
============

`Workers` is a work in progress, and it is currently only available from GitHub.

``` r
devtools::install_github("wlandau/workers")
```

Usage
=====

Your workload is a collection of commands named with job IDs.

``` r
library(workers)
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

Some jobs depend the output from other jobs, so `workers` needs a schedule of job IDs.

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

To run your work, just hire a team of persistent workers.

``` r
hire(
  workload = workload,
  schedule = schedule,
  fun = parallel::mclapply,      # for Windows users, parallel::parLapply
  workers = 2,                   # number of persistent workers
  mc.cores = 2                   # arguments to the `lapply()`-like function
)
```

To deploy your workers to a high-performance computing system such as a [SLURM](https://slurm.schedmd.com/) cluster, use the `future_lapply()` function from the [`future.apply` package](https://github.com/HenrikBengtsson/future.apply) and supply the appropriate [`batchtools`](https://github.com/mllg/batchtools) [template file](https://github.com/mllg/batchtools/tree/master/inst/templates).

``` r
plan(
  batchtools_slurm,
  template = "slurm-simple.tmpl", # You supply this file.
  workers = 4
)
hire(
  workload = workload,
  schedule = schedule,
  fun = future.apply::future_lapply,
  workers = 4
)
```

Ongoing development
===================

The `workers` package is early in its proof-of-concept phase of development. Ideas and plans are discussed in the [issue tracker](https://github.com/wlandau/workers/issues) and outlined in the [design specification](https://github.com/wlandau/workers/tree/master/specification).
