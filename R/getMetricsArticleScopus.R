


#' Método para obtener métricas de Scopus de un artículo mediante web scrapping
#'
#' @param uid Número de serie UID del artículo
#'
#' @return Este método, tras pasar el UID del artículo y haber introducido en el archivo .Renviron, genera un objeto data.frame con las métricas del artículo con dicho UID en Scopus, que posteriormente será devuelto.
#' @export
#' @examples
#' getMetricsScopus("2-s2.0-85187374370")
getMetricsScopus <- function(uid) {

  readRenviron(".Renviron")

  reticulate::python_config <- py_discover_config()

  reticulate::use_python("~/.virtualenvs/r-reticulate/Scripts/python.exe")



  if (!py_module_available("selenium")) {
    reticulate::py_install("selenium")
  }

  if (!py_module_available("pandas")) {
    reticulate::py_install("pandas")
  }

  reticulate::source_python("R/py/WebScrappingScopus.py")



  metrics <-getMetrics(uid, Sys.getenv("USER"), Sys.getenv("PASSWORD"))

  dfMetrics <- reticulate::py_to_r(metrics)

  return(dfMetrics)
}
