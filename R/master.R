run_master <- function(cache, queue, schedule){
  workers <- cache$list(namespace = "status")
  while (work_remains(cache, queue)){
    for (worker in workers){
      
      cat("master is checking worker", worker, "\n")
      
      if (is_idle(worker = worker, cache = cache)){
        
        cat("master says", worker, "idle\n")
        
        collect_job(
          worker = worker,
          cache = cache,
          queue = queue,
          schedule = schedule
        )
        next_job <- pop0(queue)
        
        cat("next job", next_job, "\n")
        
        set_job(worker = worker, job = next_job, cache = cache)
        
        cat("set next job", next_job, "\n")
        
        set_running(worker = worker, cache = cache)
        
        cat(worker, "should be running.\n")
      }
    }
    Sys.sleep(1e-1)
  }
  terminate_workers(cache = cache)
}

work_remains <- function(cache, queue){
  datastructures::size(queue) > 0 || any(
    purrr::map_lgl(
      .x = cache$list(namespace = "status"),
      .f = is_running,
      cache = cache
    )
  )
}

collect_job <- function(worker, cache, queue, schedule){
  if (!has_job(worker = worker, cache = cache)){
    return()
  }
  job <- get_job(worker = worker, cache = cache)
  
  cat("collecting job", job, "\n")
  
  decrease_next_keys(job = job, queue = queue, schedule = schedule)
}
