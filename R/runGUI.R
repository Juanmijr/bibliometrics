

#' Lanza la aplicación de BiblioMetrics
#'
#' @return
#' @export
#'
#' @examples
runGUI <- function() {

  appDir <- system.file("bibliometrics", package = "bibliometrics")
  shiny::runApp(appDir, launch.browser = TRUE)

  invisible()
}
