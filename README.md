[![Travis build status](https://travis-ci.org/wlandau/crew.svg?branch=master)](https://travis-ci.org/wlandau/crew)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github//wlandau/crew/?branch=master&svg=true)](https://ci.appveyor.com/project/wlandau/crew)
![stability-wip](https://img.shields.io/badge/stability-work_in_progress-lightgrey.svg)
![stability-experimental](https://img.shields.io/badge/stability-experimental-orange.svg)
![stability-unstable](https://img.shields.io/badge/stability-unstable-yellow.svg)

# Coordinated R Ensembles of Workers

The `crew` package is a job scheduler for R. It launches a group of workers to do a bunch of jobs. With `crew`, some jobs can depend on others. The workers wait to begin new jobs until the dependencies finish.

```r
hire(
  workload = example_workload(), # named list of jobs
  schedule = example_schedule(), # `igraph` network of the jobs dependencies
  fun = parallel::mclapply,      # `lapply()`-like function to launch persistent workers
  workers = 2,                   # number of persistent workers
  mc.cores = 2                   # arguments to the `lapply()`-like function
)
```

# Future development

### Debug the persistent workers.

The functionality for persistent workers is not currently working. The master process hangs, and the workers wait indefinitely for the master to post jobs. The top priority for `crew` is to debug this.

### Transient workers

Why would we want one transient worker per job? Because persistent workers can time out. In other words, your computing cluster may impose time limits on long-running workers spawned by `hire(..., fun = future.apply::future_lapply)`.

### Semi-transient workers

It takes a lot of overhead to launch a transient worker for every single job. We will eventually want to distribute groups of jobs among the workers using one of the [knapsack problems](https://en.wikipedia.org/wiki/List_of_knapsack_problems).

