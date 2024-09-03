
#' Método para obtener los artículos en cualquier base de datos posible, mediante una consulta
#'
#' @param apis Vector de las diferentes bases de datos, asignándole TRUE o FALSE, según la base de datos que queramos buscar.
#' @param query Elemento de texto, por el cual consultaremos en las bases de datos que son elegidas en apis.
#'
#' @return Este método, devuelve un dataframe de los artículos de que se obtienen de las diferentes bases de datos bibliométricas.
#' @export
#' @examples
#' getArticle(c(wos=TRUE,scopus=TRUE, scholar=FALSE),"tutorial autoencoder")
#' getArticle(c(wos=FALSE,scopus=TRUE, scholar=TRUE),"Strategies for time series forecasting with generalized regression neural networks")
getArticle <- function (apis, query){
  apiConfig<- fromJSON("R/APIConfig.JSON")


  selected <- names(apis)[apis]
  response<- data.frame()
  first<- TRUE
  for (ap in selected){
    apiSelect <- apiConfig[apiConfig$name == ap,]

    if (ap == "scholar") {
      result <- getArticlesGoogle(query, apiSelect)
    } else if (ap == "scopus") {
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





#' Método para obtener los artículos de la base de datos de Google Scholar
#'
#' @param query Elemento de texto, por el cual consultaremos en la base de datos de Google Scholar.
#' @param apiSelect Pasa una variable JSON, tal que:
#'    {
#'      "name":"scholar",
#'      "urlArticle": "https://serpapi.com/search.json?engine=google_scholar",
#'      "key": clave de la API de google (serpapi)
#'    }
#' @return Este método, tras los parámetros facilitados, genera un objeto data.frame con los datos en los que coincide con la consulta obtenida por Google Scholar, que posteriormente será devuelto.
#' @export
#' @import httr, jsonlite
#' @examples
#'
#' getArticlesGoogle("tutorial encoder", "{"name":"scholar",
#'      "urlArticle": "https://serpapi.com/search.json?engine=google_scholar",
#'      "key": clave de la API de google (serpapi)}")
#'
#' getArticlesGoogle("Strategies for time series forecasting with generalized regression neural networks", "{"name":"scholar",
#'      "urlArticle": "https://serpapi.com/search.json?engine=google_scholar",
#'      "key": clave de la API de google (serpapi)}")
#'
getArticlesGoogle<- function(query, apiSelect){

  response<- httr::GET(url=apiSelect$url, query=list("api_key"= apiSelect$key, "q" = query, "hl"= "es"))
  content<- content(response, "text")
  result <- jsonlite::fromJSON(content)


  df<- data.frame(
    "ID" = result$"organic_results"$source-id,
    "Titulo" = result$"organic_results"$title,
    'Palabras clave' = result$"organic_results"$snippet,
    'Autor' = NA,
    'Año' = NA,
    'Source' = NA,
    'DOI' = NA,
    "Citas" = result$"organic_results"$"inline_links"$"cited_by"$total,
    'Summary' = result$"organic_results"$"publication_info"$summary,
    'BBDD'= 'scholar',
    stringsAsFactors = FALSE
  )




  return(df)
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
#' @import httr, jsonlite
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

  response<- httr::GET(url= apiSelect$urlArticle ,headers, query=list( "query"=textQuery, "count"="25"))
  content<- content(response, "text")
  result <- jsonlite::fromJSON(content, flatten = TRUE)


  if (is.null(result[["search-results"]][["entry"]][["error"]])){

    df<- data.frame(
      "ID" = result$'search-results'$entry$`eid`,
      "Titulo" = result$'search-results'$entry$`dc:title`,
      'Palabras clave' = NA,
      'Autor' = result$'search-results'$entry$`dc:creator`,
      'Año' = format(as.Date(result$'search-results'$entry$`prism:coverDate`),"%Y"),
      'Source' = NA,
      'DOI' = result$'search-results'$entry$`prism:doi`,
      "Citas" = as.numeric(result$'search-results'$entry$`citedby-count`),
      'Summary' = NA,
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




