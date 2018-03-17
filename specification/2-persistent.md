---
title: "Execution of persistent workers"
author: "Will Landau"
date: "March 17, 2018"
output: html_document
---

## User input

- `workload`: a workload as described in the data structures chapter.
- `schedule`: a schedule as described in the data structures chapter.
- `workers`: maximum number of parallel workers to run at a time.
- `type`: `"persistent"` in this case.
- `fun`: an apply-like function to create the workers.
- arguments to `fun`, passed with `...`.

## Initialize

1. Convert the `workload` and `schedule` arguments to the standard internal formats (environment and `igraph`, respectively).
2. Determine the file path of the `liteq` database using `tempfile()`.
3. Use `liteq::ensure_queue()` to create the worker queues and the cleanup queue. 
4. Deploy the mater process using `callr::r_bg()`, passing to it the, number of workers, the schedule, and the path to the `liteq` database.
5. Deploy the workers by calling `fun`, the user-supplied `lapply`-like function. Workers should receive the workload, the path to the `liteq` database, and any user-defined arguments passed with `...`.

## Master

#### Initialize

1. Use `liteq::ensure_queue()` to retrieve the worker queues and the cleanup queue.
2. Create the priority queue from the schedule.

#### Repeat

1. Move on to cleanup if the priority queue, the worker queues, and the cleanup queue are all empty.
2. Process the cleanup queue. While `liteq::try_consume()` returns a completed job,
    - Decrease the key (in the priority queue) of all jobs directly downstream.
    - Call `ack()` to remove the finished job from the cleanup queue.
3. Optionally, search the worker queues for failed jobs using `liteq::try_consume()`, push them to the priority queue, and decrease the keys to zero. The newly-pushed failed jobs should be behind the other jobs with priority zero. Eventually, we may want to make this part more nuanced with job-level retries and timeouts.
4. If there is a job with priority zero in the priority queue,
    - Pop the job from the priority queue.
    - Find the least busy worker.
    - Post the job to the worker queue of that worker.
5. If the priority queue is empty, and if the master did not do so already, send a "done" message to all the worker queues using `liteq::publish()`. This tells the workers to finish after they complete the jobs already assigned to them.
6. Sleep for a small length of time to avoid throttling.

#### Cleanup

1. Delete the cleanup queue using `liteq::delete_queue()`.
2. Wait for the workers to delete their worker queues.
3. Destroy the `liteq` database that contained the queues.

## Each worker

#### Initialize

#### Repeat

1. Check the worker queue using `liteq::consume()`.
2. If the result is a job,
    - Look up the command in the workload.
    - Execute the command.
3. Otherwise, if the result is a "done" message, move on to cleanup.

#### Cleanup

Destroy the worker queue using `liteq::delete_queue()`.
