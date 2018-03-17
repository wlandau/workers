---
title: "Data structures and terminology"
author: "Will Landau"
date: "March 17, 2018"
output: html_document
---

# Basic

## Job

A job is a piece of work to do. Each job has

- A unique ID (character string).
- A command (piece of R code).

## Worker

A worker is a unit of execution that runs one or more jobs. It could be an process forked by `mclapply()` or `callr::r_bg()`, a [`future`](https://github.com/HenrikBengtsson/future), or some other process or thread. Workers may be persistent or transient.

#### Persistent workers

A persistent worker runs until there are no jobs left. For `workers`, we will assume each worker has access to the local file system. We will deploy persistent workers with a user-specified `lapply`-like function such as `mclapply` or `future_lapply`.

#### Transient workers

A transient worker runs one or more jobs. The purpose of transient workers is to provide an option that

1. Avoids timeouts for long-running jobs on HPC systems, and
2. Does not require workers to be able to access the user's local file system.

Transient workers will be lanuched using `future`.

## Master

The master is the process that governs and coordinates the workers, assigning them the right jobs at the right times. At the implementation level, it is either a background [`callr::r_bg()`](https://github.com/r-lib/callr) process (for persistent workers) or just the user's R session (for transient workers).

# User input

## Workload

The workload is the collection of all the user's jobs. Internally, for fast lookup and retrieval, it is represented as an environment containing language objects named by their job IDs. For convenience, the user may simply supply a `data.frame` or `tibble` of job IDs and commands, which `workers` will promptly convert to an environment in a preprocessing step.

## Schedule

The schedule is a directed acyclic graph of the dependency structure among the jobs. The nodes are job IDs, and the directed edges indicate the upstream/downstream relationships among the jobs. Upstream jobs will be executed before the downstream ones begin.

Internally, the schedule is an [`igraph`](https://github.com/igraph/rigraph) object with job IDs is names. For convenience, the user may instead supply a `data.frame` or `tibble` with columns `from` and `to` to denote the dependency relationships, and `workers` will promptly convert it into an [`igraph`](https://github.com/igraph/rigraph) as a preprocessing step.

# Internals

## Priority queue

This data structure is classic min-priority queue from computer science. It keeps track of the jobs that have not been yet been assigned to workers. For each listed job, the priority queue stores the job ID and its priority. A job's priority is the number of jobs that come before it in the schedule and have not yet completed.

At the beginning of the workflow, the priority queue is created from the schedule. Throughout execution, the master process continuously looks for jobs with priority zero and

1. Removes them from the priority queue, and
2. Deploys them to workers.

Whenever a job completes, the master process decreases the key of every job directly downstream of the completed one. That way, new jobs become available when their dependencies finish.

Internally, the priority queue is a Fibonacci heap as implemented in the [`datastructures` package](https://github.com/dirmeier/datastructures).

## Worker queues

Each worker has a queue containing the jobs assigned to it. Internally, each worker queue is a different [`liteq`](https://github.com/r-lib/liteq) queue, and all the queues will share the same database.

#### Master

As jobs become available, the master process deploys them by posting to the queues of the least busy workers. In the early days of the `workers` package, the master may just look for the workers with the fewest running or queued jobs. But eventually, we will move to a sophisticated load-balancing scheme, possibly a variant of the [knapsack problem](https://en.wikipedia.org/wiki/Knapsack_problem). When there are no more jobs to assign, the master publishes a "done" message to the workers to tell them to exit when all the jobs already in the worker queue are complete.

#### Individual workers

Each individual worker waits for its next job using `liteq::consume()`, looks up the command in the workload, and does the work. If the command completes successfully, the worker calls `liteq::ack()` to remove the job listing from the worker queue. There are many options to choose from when it comes to failed jobs. `liteq::nack()` may play a role here if we decide to let the master process reallocate failed jobs to different workers.

## Cleanup queue

The cleanup queue is also a [`liteq`](https://github.com/r-lib/liteq) queue. Workers post each finished job to the cleanup queue to alert the master process. The master peridically checks the cleanup queue and, for each completed job, decreases the key (in the priority queue) of all the jobs directly downstream.
