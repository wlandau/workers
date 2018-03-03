master <- function(queue, cache){
  # uses callr to spin up a master process.
  initialize_workers(cache)
  monitor_workers(queue, cache)
}

initialize_workers <- fucntion(cache){
  
}

monitor_workers <- function(){
  while (work_remains(queue = queue, workers = workers, config = config)){
    for (id in seq_along(workers)){
      if (is_idle(workers[[id]])){
        # Also calls decrease-key on the queue.
        workers[[id]] <- conclude_worker(
          worker = workers[[id]],
          config = config,
          queue = queue
        )
        # Pop the head target only if its priority is 0
        next_target <- queue$pop0(what = "names")
        if (!length(next_target)){
          # It's hard to make this line run in a small test workflow
          # suitable enough for unit testing, but
          # I did artificially stall targets and verified that this line
          # is reached in the future::multisession backend as expected.
          next # nocov
        }
        running <- running_targets(workers = workers, config = config)
        protect <- c(running, queue$list(what = "names"))
        workers[[id]] <- new_worker(
          id = id,
          target = next_target,
          config = config,
          protect = protect
        )
      }
    }
    Sys.sleep(1e-9)
  } 
}

workers <- function(){
  # calls an apply-like function to run the workers.
}

run <- function(){
  queue <- new_queue()
  cache <- new_cache()
  master(queue, cache)
  workers(cache)
}
