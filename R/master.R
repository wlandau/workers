run_master <- function(cache, queue, schedule){
  workers <- cache$list(namespace = "status")
  while (work_remains(cache, queue)){
    for (worker in workers){
      if (is_idle(worker = worker, cache = cache)){
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
    Sys.sleep(1e-9)
  } 
}

work_remains <- function(cache, queue){
  size(queue) > 0 || any(
    purrr::map_lgl(
      .x = cache$list(namespace = "status"),
      .f = is_running
    )
  )
}

collect_job <- function(worker, cache, queue, schedule){
  if (!has_job(worker = worker, cache = cache)){
    return()
  }
  job <- get_job(worker = worker, cache = cache)
  decrease_next_keys(jobs = job, queue = queue, schedule = schedule)
}

new_crew_cache <- function(n_workers){
  path <- ".crew_workers"
  cache <- storr::storr_rds(
    path = path,
    mangle_key = TRUE
  )
  writeLines(text = "*", con = file.path(path, ".gitignore"))
  workers <- as.character(seq_len(n_workers))
  lapply(X = workers, FUN = set_idle, cache = cache)
  cache
}
