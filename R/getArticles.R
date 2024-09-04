
#' Método para obtener los artículos en cualquier base de datos posible, mediante una consulta
#'
#' @param apis Vector de las diferentes bases de datos, asignándole TRUE o FALSE, según la base de datos que queramos buscar.
#' @param query Elemento de texto, por el cual consultaremos en las bases de datos que son elegidas en apis.
#'
#' @return Este método, devuelve un dataframe de los artículos de que se obtienen de las diferentes bases de datos bibliométricas.
#' @export
#' @examples
#' getArticles(c(wos=TRUE,scopus=TRUE, scholar=FALSE),"tutorial autoencoder")
#' getArticles(c(wos=FALSE,scopus=TRUE, scholar=TRUE),"Strategies for time series forecasting with generalized regression neural networks")
getArticles <- function (apis, query){
  apiConfig<- jsonlite::fromJSON("R/APIConfig.JSON")


  selected <- names(apis)[apis]
  response<- data.frame()
  first<- TRUE
  for (ap in selected){
    apiSelect <- apiConfig[apiConfig$name == ap,]

    if (ap == "scopus") {
      result <- getArticlesScopus(query, apiSelect)
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




#' Método para obtener los artículos de la base de datos de Scopus
#'
#' @param query Elemento de texto, por el cual consultaremos en la base de datos de Scopus.
#' @param apiSelect Pasa una variable JSON, tal que:
#'    {
#' "name":"scopus",
#' "urlArticle": "https://api.elsevier.com/content/search/scopus",
#' "key": Clave de la API de Scopus,
#' "instant": Esta variable "no sería necesaria", pero la uso, ya que me permitieron acceder con esta variable a APIs que no podía acceder con un usuario normal.
#'}
#'
#' @return Este método, tras los parámetros facilitados, genera un objeto data.frame con los datos en los que coincide con la consulta obtenida por Scopus, que posteriormente será devuelto.
#' @export
#' @import httr
#' @import jsonlite
#' @examples
#'
#' getArticlesScopus("tutorial encoder", {
#' "name":"scopus",
#' "urlArticle": "https://api.elsevier.com/content/search/scopus",
#' "key": Clave de la API de Scopus,
#' "instant": Esta variable "no sería necesaria", pero la uso, ya que me permitieron acceder con esta variable a APIs que no podía acceder con un usuario normal.
#'})
#'
#' getArticlesScopus("Strategies for time series forecasting with generalized regression neural networks", {
#' "name":"scopus",
#' "urlArticle": "https://api.elsevier.com/content/search/scopus",
#' "key": Clave de la API de Scopus,
#' "instant": Esta variable "no sería necesaria", pero la uso, ya que me permitieron acceder con esta variable a APIs que no podía acceder con un usuario normal.
#'})
getArticlesScopus<-function(query, apiSelect){
  df=NA
  textQuery=paste0("TITLE-ABS-KEY(",query,")")

  headers <- add_headers(
    "X-ELS-APIKey" = apiSelect$key,
    "X-ELS-Insttoken"= apiSelect$instant,
    "Accept" = "application/json"
  )

  response<- httr::GET(url= apiSelect$urlArticle ,headers, query=list( "query"=textQuery, "count"="50"))
  content<- httr::content(response, "text")
  result <- jsonlite::fromJSON(content, flatten = TRUE)


  if (is.null(result[["search-results"]][["entry"]][["error"]])){

    df<- data.frame(
      "ID" = result$'search-results'$entry$`eid`,
      "Titulo" = result$'search-results'$entry$`dc:title`,
      'Autor' = result$'search-results'$entry$`dc:creator`,
      'Año' = format(as.Date(result$'search-results'$entry$`prism:coverDate`),"%Y"),
      'DOI' = result$'search-results'$entry$`prism:doi`,
      "Citas" = as.numeric(result$'search-results'$entry$`citedby-count`),
      'BD'= 'scopus',
      stringsAsFactors = FALSE
    )

  }
  else{
    df<- data.frame(
      'error'= TRUE
    )
  }
  return(df)


}




