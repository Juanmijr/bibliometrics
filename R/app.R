#' The \pkg{dataesgobr} package contains a basic Shiny-based GUI that you can
#' use in order to work easily while you are using the package.
#' You have to install the \pkg{shiny} package to use this GUI.
#'
#' @title Launches the web-based GUI for dataesgobr
#' @return nothing
#' @description Download, load and edit using an interactive user interface in the web browser
#' @examples
#' \dontrun{
#' library(dataesgobr)
#' runGUI()
#' }
#' @import shiny
#' @export
runGUI <- function() {
  appDir <- system.file("C:/Users/Juanmi/Desktop/TFG/codigo/bibliometrics/inst/bibliometrics", package = "bibliometrics")
  shiny::runApp(appDir, launch.browser = TRUE)
  print(appDir)
  invisible()
}
