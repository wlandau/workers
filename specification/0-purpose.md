---
title: "The purpose of the `workers` package"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## The need for a general job scheduler

R has a lot of parallel computing functionality. Packages [`parallel`](https://stat.ethz.ch/R-manual/R-devel/library/parallel/doc/parallel.pdf), [`callr`](https://github.com/r-lib/callr), [`future`](https://github.com/HenrikBengtsson/future), and [`future.apply`](https://github.com/HenrikBengtsson/future.apply) can deploy batches of parallel jobs. Packages like [`batchtools`](https://github.com/mllg/batchtools) [`rslurm`](https://github.com/SESYNC-ci/rslurm) can deploy jobs high-performance computing systems. [`flowr`](https://github.com/sahilseth/flowr) is intricate and feature rich, with the ability to manage intricate job networks and deploy to a wide variety of computing environments.

However, R lacks a job scheduler that is simultaneously

1. Coordinates arbitrary networks of interdepenenty jobs.
2. Is platform-agnostic.
3. Deploys to a wide variety of computing systems.
4. Is R-focused, with commands written in R rather than shell scripts.

## Scope of `workers`

1. Persistent workers deployable with any `lapply`-like function. Here, workers are assumed to have access to the file local file system.
2. Semi-transient workers deployed with [`future`](https://github.com/HenrikBengtsson/future), where jobs are distributed among workers using an appropriate variant of the [knapsack problem](https://en.wikipedia.org/wiki/Knapsack_problem). Workers may or may not have access to the local file system.
