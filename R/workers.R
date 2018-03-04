run_worker <- function(worker, cache, workload){
  while (!is_done(worker = worker, cache = cache)){
    if (is_idle(worker = worker, cache = cache)){
      Sys.sleep(1e-9)
    } else {
      job <- get_job(worker = worker, cache = cache)
      if (length(job)){
        eval(workload[[job]])
      }
      set_idle(worker = worker, cache = cache)
    }
  }
}

worker_ids <- function(workers){
  as.character(seq_len(workers))
}

get_job <- function(worker, cache){
  cache$get(key = worker, namespace = "job")
}

set_job <- function(worker, job, cache){
  cache$set(key = worker, value = job, namespace = "job")
}

has_job <- function(worker, cache){
  cache$exists(key = worker, namespace = "job")
}

is_running <- function(worker, cache){
  cache$exists(key = worker, namespace = "running")
}

set_running <- function(worker, cache){
  cache$set(key = worker, value = TRUE, namespace = "running")
}

is_done <- function(worker, cache){
  cache$exists(key = worker, namespace = "done")
}

set_done <- function(worker, cache){
  cache$set(key = worker, value = TRUE, namespace = "done")
}

is_idle <- function(worker, cache){
  !is_running(worker = worker, cache = cache) &&
  !is_done(worker = worker, cache = cache)
}

set_idle <- function(worker, cache){
  cache$del(key = worker, namespace = "running")
}
