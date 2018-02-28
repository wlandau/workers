new_worker_cache <- function(workers){
  path <- ".rsched"
  cache <- storr::storr_rds(
    path = path,
    mangle_key = TRUE
  )
  writeLines(text = "*", con = file.path(path, ".gitignore"))
  ids <- as.character(seq_len(workers))
  lapply(
    X = ids,
    FUN = function(id){
      cache$set(key = id, value = NA)
    }
  )
  cache
}

is_idle <- function(id, cache){
  is.na(cache$get(key = id))
}

decrease_revdep_keys <- function(id, cache, queue){
  vertex = cache$get(key = id)
  revdeps <- dependencies(
    vertices = vertex,
    graph = graph,
    reverse = TRUE
  ) %>%
    intersect(y = queue$list(what = "vertices"))
  queue$decrease_key(vertices = revdeps)
}

run <- function(graph, workers = 1){
  queue <- new_queue(graph)
  cache <- new_worker_cache(workers)
  ids <- cache$list()
  while (work_remains(cache = cache, queue = queue)){
    for (id in ids){
      if (is_idle(id = id, cache = cache)){
        decrease_revdep_keys(
          id = id,
          cache = cache,
          queue = queue
        )
        next_vertex <- pop0(queue)
        if (!length(next_target)){
          next # nocov
        }
        assign_worker()
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
