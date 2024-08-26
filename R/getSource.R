#' función para obtener información de fuentes
#'
#' @param apis lista de apis diciendo con los valores de apis = true o false
#' @param query texto que queremos buscar
#'TENGO QUE ESCRIBIR ESTO
#' @return devuelve dataframe de la información de las fuentes de las apis a buscar
#' @export
#' @examples
#' getSource(c(wos=TRUE,scopus=TRUE, scholar=FALSE),"springer")
#' getSource(c(wos=FALSE,scopus=TRUE, scholar=TRUE),"charte")
getSource<- function (apis, query){
  apiConfig<- fromJSON("R/APIConfig.JSON")


  selected <- names(apis)[apis]
  response<- data.frame()
  first<- TRUE
  for (ap in selected){
    print(ap)
    apiSelect <- apiConfig[apiConfig$name == ap,]

    if (ap == "wos") {
      #result <- getArticleWos(query, apiSelect)
    } else if (ap == "scholar") {
      #result <- getArticleGoogle(query, apiSelect)
    } else if (ap == "scopus") {
      result <- bibliometrics::getSourceScopus(query, apiSelect)
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


