example_args <- function(){
  config <- drake::load_basic_example(envir = globalenv(), cache = storr::storr_environment())
  graph <- drake:::targets_graph(config)
  jobs <- config$plan
  list(graph = graph, jobs = jobs)
}
