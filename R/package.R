#' crew is a job scheduler for R.
#' @docType package
#' @name crew-package
#' @aliases crew
#' @author William Michael Landau \email{will.landau@@gmail.com}
#' @references <https://github.com/wlandau/crew>
#' @importFrom callr r_bg
#' @importFrom datastructures decrease_key fibonacci_heap handle insert peek
#'   pop size
#' @importFrom magrittr %>%
#' @importFrom purrr map_lgl
#' @importFrom igraph adjacent_vertices graph_from_data_frame V
#' @importFrom storr storr_rds
#' @importFrom testthat test_that
#' @importFrom tibble as_tibble tribble
#' @importFrom withr with_dir
#' @examples
#' \dontrun{
#' withr::with_dir(tempfile(), {
#' # Run all the jobs in the workload in the
#' # correct order given in the schedule.
#' # Use 2 persistent workers.
#' hire(
#'   workload = workload = example_workload(),
#'   schedule = schedule = example_schedule(),
#'   fun = parallel::mclapply,
#'   workers = 2,
#'   mc.cores = 2
#' )
#' })
#' }
NULL
