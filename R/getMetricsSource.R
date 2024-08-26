library(httr)
library(jsonlite)

#' Obtener métricas de fuentes de Scopus
#'
#' @param apis BBDD scopus
#' @param query consulta
#'
#' @return dataframe de datos métricos
#' @export
#'
#' @examples
#'getMetricsSource("scopus","9-s2.0-40661023100")
getMetricsSource<- function (apis, query, title){

   if (apis == "scopus") {
     print("VOY A ENTRAR AQUÍ ")
    result <-getMetricsSourceScopus(query, apis, title)
  } else {
    stop(paste("Valor de 'api' no válido: ", apis))
  }


  return(result)
}
