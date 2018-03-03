run_master <- function(cache, queue, schedule){
  
  workers <- cache$list(namespace = "status")
  
  cat("Workers:", workers, "\n", file = "~/Downloads/out.txt")
  
  cat("Does work remain?: ", work_remains(cache, queue), "\n")
  
  while (work_remains(cache, queue)){
    
    cat("Work remains.\n", file = "~/Downloads/out.txt")
    
    for (worker in workers){
      
      cat("checking worker", worker, "\n", file = "~/Downloads/out.txt")
      
      if (is_idle(worker = worker, cache = cache)){
        
        cat("worker", worker, "is idle.\n", file = "~/Downloads/out.txt")
        
        collect_job(
          worker = worker,
          cache = cache,
          queue = queue,
          schedule = schedule
        )
        next_job <- pop0(queue)
        set_job(worker = worker, job = next_job, cache = cache)
        set_running(worker = worker, cache = cache)
      }
    }
    Sys.sleep(1)
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
  decrease_next_keys(job = job, queue = queue, schedule = schedule)
}
