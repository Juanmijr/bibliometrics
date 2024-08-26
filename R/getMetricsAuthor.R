library(httr)
library(jsonlite)

#' Obtener métricas de autor
#'
#' @param apis
#' @param query
#'
#' @return
#' @export
#'
#' @examples
getMetricsAuthor<- function (apis, query){


    if (apis == "scholar") {
    result <- getMetricsAuthorScholar(query)
  } else if (apis == "scopus") {
    result <-getMetricsAuthorScopus(query, apis)
  } else {
    stop("Valor de 'ap' no válido")
  }


  return(result)
}
