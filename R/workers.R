run_worker <- function(worker, cache, workload){
  while(!is_done(worker = worker, cache = cache)){
    
    browser()
    
    if (is_idle(worker = worker, cache = cache)){
      Sys.sleep(1e-9)
    } else {
      job <- get_job(cache = cache, worker = worker)
      eval(workload[[job]])
      set_idle(worker = worker, cache = cache)
    }
  }
}

terminate_workers <- function(cache){
  lapply(
    X = cache$list(namespace = "status"),
    FUN = set_done,
    cache = cache
  )
}

get_job <- function(worker, cache){
  cache$get(key = worker, namespace = "job")
}

get_status <- function(worker, cache){
  cache$get(key = worker, namespace = "status")
}

has_job <- function(worker, cache){
  cache$exists(key = worker, namespace = "job")
}

is_done <- function(worker, cache){
  identical("done", get_status(worker = worker, cache = cache))
}

is_idle <- function(worker, cache){
  identical("idle", get_status(worker = worker, cache = cache))
}

is_running <- function(worker, cache){
  identical("running", get_status(worker = worker, cache = cache))
}

set_done <- function(worker, cache){
  set_status(worker = worker, status = "done", cache = cache)
}

set_idle <- function(worker, cache){
  set_status(worker = worker, status = "idle", cache = cache)
}

set_job <- function(worker, job, cache){
  cache$set(key = worker, value = job, namespace = "job")
}

set_running <- function(worker, cache){
  set_status(worker = worker, status = "running", cache = cache)
}

set_status <- function(worker, status, cache){
  cache$set(key = worker, value = status, namespace = "status")
}
