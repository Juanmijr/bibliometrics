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
      result <- getSourceScopus(query, apiSelect)
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


getSourceScopus<-function(query, apiSelect){

  headers <- add_headers(
    "X-ELS-APIKey" = apiSelect$key,
    "X-ELS-Insttoken"= apiSelect$instant,
    "Accept" = "application/json"
  )

  response<- GET(url= apiSelect$urlSource ,headers, query=list( "title"=query, "view"="enhanced"))
  content<- content(response, "text")
  result <- fromJSON(content, flatten = TRUE)


  df<- data.frame(
    "ID" = result$'search-results'$entry$`eid`,
    "Titulo" = result$'search-results'$entry$`dc:title`,
    'Palabras clave' = NA,
    'Autor' = result$'search-results'$entry$`dc:creator`,
    'Año' = result$'search-results'$entry$`prism:coverDate`,
    'Source' = NA,
    'DOI' = result$'search-results'$entry$`prism:doi`,
    "Citas" = result$'search-results'$entry$`citedby-count`,
    'Summary' = NA,
    'BBDD'= 'scopus',
    stringsAsFactors = FALSE
  )


  return(df)


}
