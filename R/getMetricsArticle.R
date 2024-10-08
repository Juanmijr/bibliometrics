
#' Método para obtener métricas de un artículo de las diferentes bases de datos bibliométricas.
#'
#' @param apis Nombre de la base de datos a buscar
#' @param query En este caso será la consulta será el ID del artículo.
#' @return Este método, devuelve un dataframe de las métricas que se pueden obtener de un artículo de las diferentes bases de datos bibliométricas.
#' @export
#'
#' @examples
#'getMetricsSource("scopus","1874-9305", NA)
#'getMetricsSource("scopus",NA, "Elsevier Astrodynamics Series")

getMetricsArticle<- function (apis, query){

  if (apis == "scopus") {
    result <-getMetricsArticleScopus(query, apis, title)
  } else {
    stop(paste("Valor de 'api' no válido: ", apis))
  }


  return(result)
}





#' Método para obtener métricas de Scopus de un artículo mediante web scrapping
#'
#' @param uid Número de serie UID del artículo
#'
#' @return Este método, tras pasar el UID del artículo y haber introducido en el archivo .Renviron, genera un objeto data.frame con las métricas del artículo con dicho UID en Scopus, que posteriormente será devuelto.
#' @export
#' @import reticulate
#' @examples
#' getMetricsScopus("2-s2.0-85187374370")
getMetricsScopus <- function(uid) {

  env_path <- file.path("~/.virtualenvs", "myenv")


  if (!dir.exists(env_path)){
    reticulate::virtualenv_create(envname = "myenv")
  }

  reticulate::use_virtualenv("myenv")



  if (!py_module_available("selenium")) {
    reticulate::py_install("selenium")
  }

  if (!py_module_available("pandas")) {
    reticulate::py_install("pandas")
  }

  if (!reticulate::py_module_available("webdriver-manager")) {
    reticulate::py_install("webdriver-manager")
  }
  reticulate::source_python("R/py/WebScrappingScopus.py")

  metrics <-getMetrics(uid, Sys.getenv("USER"), Sys.getenv("PASSWORD"))

  dfMetrics <- reticulate::py_to_r(metrics)


  return(dfMetrics)
}
