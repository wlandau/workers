#' crew is a job scheduler for R.
#' @docType package
#' @name crew-package
#' @aliases crew
#' @author William Michael Landau \email{will.landau@@gmail.com}
#' @references <https://github.com/wlandau/crew>
#' @importFrom magrittr %>%
#' @import callr datastructures igraph magrittr storr tibble
#' @examples
#' \dontrun{
#' withr::with_dir(tempfile(), {
#' attach(example_args()) # Get an example workload and schedule.
#' # Run all the jobs in the workload in the
#' # correct order given in the schedule.
#' # Use 2 persistent workers.
#' hire(
#'   workload = workload,
#'   schedule = schedule,
#'   fun = parallel::mclapply,
#'   workers = 2,
#'   mc.cores = 2
#' )
#' })
#' }
NULL
