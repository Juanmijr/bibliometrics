library(jsonlite)
library(reticulate)

#' Obtener métricas de Autores de Google Scholar
#'
#' @param uid id de Google Scholar
#'
#' @return dataframe de datos métricos
#' @export
#'
#' @examples
#'getMetricsAuthorScholar("i8l_80EAAAAJ")
getMetricsAuthorScholar <- function(uid) {

  python_config <- py_discover_config()

  use_python("~/.virtualenvs/r-reticulate/Scripts/python.exe")



  if (!py_module_available("selenium")) {
    py_install("selenium")
  }

  if (!py_module_available("pandas")) {
    py_install("pandas")
  }

  source_python("R/py/WebScrappingGoogle.py")

  metrics <-getMetricsAuthor(uid)

  dfMetrics <- py_to_r(metrics)

  View(dfMetrics)

  return(dfMetrics)
}
