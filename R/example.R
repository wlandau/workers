example_args <- function(){
  config <- drake::load_basic_example(
    envir = new.env(),
    cache = storr::storr_environment(),
    verbose = FALSE
  )
  unlink(c("report.md", "report.Rmd"))
  schedule <- drake:::targets_graph(config)
  cmd <- config$plan$command[-1]
  cmd[1] <- "data.frame(x = rnorm(48), y = rnorm(48))"
  cmd[2] <- "data.frame(x = rnorm(64), y = rnorm(64))"
  jobs <- as.list(parse(text = cmd, keep.source = FALSE))
  names(jobs) <- config$plan$target[-1]
  jobs <- list2env(jobs)
  list(schedule = schedule, jobs = jobs)
}
