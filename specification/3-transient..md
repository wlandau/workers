---
title: "Execution of transient workers"
author: "Will Landau"
date: "March 17, 2018"
output: html_document
---

## User input

- `workload`: a workload as described in the data structures chapter.
- `schedule`: a schedule as described in the data structures chapter.
- `workers`: maximum number of parallel workers to run at a time.
- `type`: `"transient"` in this case.
- `fun`: an apply-like function to create the workers.
- arguments to `fun`, passed with `...`.

## Master

#### Initialize

1. Convert the `workload` and `schedule` arguments to the standard internal formats (environment and `igraph`, respectively).
2. Determine the file path of the `liteq` database using `tempfile()`.
3. Use `liteq::ensure_queue()` to create the worker queues and the cleanup queue.
4. Create the priority queue from the schedule.
5. Launch a `future` for each transient worker.
6. Use a counter to keep track of how much work each worker has done so far.

#### Repeat

1. Move on to cleanup if the priority queue, the worker queues, and the cleanup queue are all empty.
2. Process the cleanup queue: while `liteq::try_consume()` returns a completed job,
    - Decrease the key (in the priority queue) of all jobs directly downstream.
    - Call `ack()` to remove the finished job from the cleanup queue.
    - Increment the worker's counter to keep track how much work the worker has done so far.
3. Renew any transient workers, if applicable. For each worker,
    - Check the counter. If the worker is running and its counter is high enough, send a "renew" message to the worker queue so the worker exits without destroying its queue.
    - If the worker is not running (if it was recently renewed) and the worker queue still exists, set the counter to zero and launch a fresh `future` to take the old worker's place.
4. Optionally, search the worker queues for failed jobs using `liteq::try_consume()`, push them to the priority queue, and decrease the keys to zero. The newly-pushed failed jobs should be behind the other jobs with priority zero. Eventually, we may want to make this part more nuanced with job-level retries and timeouts.
5. If there is a job with priority zero in the priority queue,
    - Pop the job from the priority queue.
    - Find the least busy worker.
    - Post the job to the worker queue of that worker.

6. If the priority queue is empty, and if the master did not do so already, send a "done" message to all the worker queues using `liteq::publish()`. This tells the workers to finish after they complete the jobs already assigned to them.
7. Sleep for a small length of time to avoid throttling.

#### Cleanup

1. Delete the cleanup queue using `liteq::delete_queue()`.
2. Wait for the workers to delete their worker queues.
3. Destroy the `liteq` database that contained the queues.

## Each worker

#### Initialize

Retrieve the worker queue using `liteq::ensure_queue()`.

#### Repeat

1. Check the worker queue using `liteq::consume()`.
2. If the result is a job,
    - Look up the command in the workload.
    - Execute the command.
    - Call `liteq::ack()` to remove the job from the worker queue. (For failed jobs, we may want to add nuance with `liteq::nack()`.)
3. Otherwise, if the result is a "renew" message, call `liteq::ack()` to remove it and exit.
4. Otherwise, if the result is a "done" message, call `liteq::ack()` to remove it and move on to cleanup.

#### Cleanup

Destroy the worker queue using `liteq::delete_queue()`.


## File system access?

One of the goals for transient workers was to provide an option for which the workers may not have access to the user's local file system. I am not yet sure how to accomplish this, especially because of the reliance on `liteq`.