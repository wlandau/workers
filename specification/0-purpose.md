---
title: "The purpose of the `workers` package"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## Need

R has a lot of parallel computing functionality. Packages [`parallel`](https://stat.ethz.ch/R-manual/R-devel/library/parallel/doc/parallel.pdf), [`callr`](https://github.com/r-lib/callr), [`future`](https://github.com/HenrikBengtsson/future), and [`future.apply`](https://github.com/HenrikBengtsson/future.apply) can deploy batches of parallel jobs. Packages like [`batchtools`](https://github.com/mllg/batchtools) [`rslurm`](https://github.com/SESYNC-ci/rslurm) can deploy jobs high-performance computing systems. [`flowr`](https://github.com/sahilseth/flowr) is intricate and feature rich, with the ability to manage intricate job networks and deploy to a wide variety of computing environments.

However, R appears to lack a fully general, R-focused scheduler. The `workers` package will

1. Coordinate arbitrary networks of interdepenenty jobs.
2. Be platform-agnostic.
3. Deploy to a wide variety of computing systems.
4. Be R-focused, with jobs written in R rather than shell commands.

Packages like [`drake`](https://github.com/ropensci/drake) and need such a scheduler.

## Scope

### Persistent `lapply`-like workers

If we use `lapply`-like functions to create persistent workers in the scheduler, we will

- Reduce the overhead of initializing workloads, especially in the case of `mclapply`.
- Leverage the wealth of popular R-focused parallel computing tools already in common use. There are already so many parallel `lapply`-like functions, such as `mclapply`, `parLapply`, and `future_lapply`. We achieve platform-independence and exceptional flexibility.

### Semi-transient `future`-based workers

Why are persistent workers not enough?

1. Because they run for a long time, moving from job to job until there are no jobs left. If we deploy to high-performance computing systems such as university clusters, workers may run too long and time out. 
2. Becuase the implementation of persistent workers will require the workers to have access to the local file system. Workers that deploy to cloud services may not have such access.
