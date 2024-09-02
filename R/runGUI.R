#' El paquete \pkg{dataesgobr} contiene una interfaz gráfica que puedes utilizar para hacer más fácil su utilidad.
#'
#' @title Método para lanzar interfaz gráfica de BiblioMetric
#' @return nada
#' @description obtención de datos bibliométricos usando intefaz de usuario interactiva
#' @examples
#' \dontrun{
#' library(dataesgobr)
#' runGUI()
#' }
#' @import shiny
#' @export
runGUI <- function() {

  appDir <- system.file("bibliometrics", package = "bibliometrics")
  shiny::runApp(appDir, launch.browser = TRUE)

  invisible()
}
