library(jsonlite)
library(reticulate)



#' Obtener Métricas de Scopus mediante web scrapping
#'
#' @param uid del artículo
#'
#' @return diccionario con métricas
#' @export
#' @examples
#' getMetricsScopus("2-s2.0-85187374370")
getMetricsScopus <- function(uid) {

  python_config <- py_discover_config()

  use_python("~/.virtualenvs/r-reticulate/Scripts/python.exe")



  if (!py_module_available("selenium")) {
    py_install("selenium")
  }

  if (!py_module_available("pandas")) {
    py_install("pandas")
  }

  source_python("R/py/WebScrappingScopus.py")

  metrics <-getMetrics(uid, getVariable('user'), getVariable('pass'))

  dfMetrics <- py_to_r(metrics)

  return(dfMetrics)
}
