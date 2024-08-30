library(httr)
library(jsonlite)
library(reticulate)


#' función para obtener articulos
#'
#' @param apis lista de apis diciendo con los valores de apis = true o false
#' @param query texto que queremos buscar
#'TENGO QUE ESCRIBIR ESTO
#' @return devuelve dataframe de los artículos de las apis a buscar
#' @export
#'
#' @examples
#' getArticle(c(wos=TRUE,scopus=TRUE, scholar=FALSE),"springer")
#' getArticle(c(wos=FALSE,scopus=TRUE, scholar=TRUE),"charte")
getAuthor <- function (apis, query){
  apiConfig<- fromJSON("R/APIConfig.JSON")


  selected <- names(apis)[apis]
  response<- data.frame()
  first<- TRUE
  for (ap in selected){
    apiSelect <- apiConfig[apiConfig$name == ap,]

   if (ap == "scholar") {
      result <- getAuthorsGoogle(query)
    } else if (ap == "scopus") {
      result <- getAuthorsScopus(query, apiSelect)
    } else {
      stop("Valor de 'ap' no válido")
    }

    if (first) {
      response <- result
      first <- FALSE
    } else {
      response <- rbind(response, result)
    }
  }



  return(response)
}








