library(httr)
library(jsonlite)



#' función para obtener articulos
#'
#' @param apis lista de apis diciendo con los valores de apis = true o false
#' @param query texto que queremos buscar
#'TENGO QUE ESCRIBIR ESTO
#' @return devuelve dataframe de los artículos de las apis a buscar
#' @export
#' @examples
#' getArticle(c(wos=TRUE,scopus=TRUE, scholar=FALSE),"springer")
#' getArticle(c(wos=FALSE,scopus=TRUE, scholar=TRUE),"charte")
getArticle <- function (apis, query){
  apiConfig<- fromJSON("R/APIConfig.JSON")


  selected <- names(apis)[apis]
  response<- data.frame()
  first<- TRUE
  for (ap in selected){
    apiSelect <- apiConfig[apiConfig$name == ap,]

    if (ap == "wos") {
      result <- getArticleWos(query, apiSelect)
    } else if (ap == "scholar") {
      result <- getArticleGoogle(query, apiSelect)
    } else if (ap == "scopus") {
      result <- getArticleScopus(query, apiSelect)
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


getArticleScopus<-function(query, apiSelect){
  df=NA
  textQuery=paste0("TITLE-ABS-KEY(",query,")")

  headers <- add_headers(
    "X-ELS-APIKey" = apiSelect$key,
    "X-ELS-Insttoken"= apiSelect$instant,
    "Accept" = "application/json"
  )

  response<- GET(url= apiSelect$urlArticle ,headers, query=list( "query"=textQuery, "count"="25"))
  content<- content(response, "text")
  result <- fromJSON(content, flatten = TRUE)


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


getArticleWos<- function(query, apiSelect){
  headers <- add_headers(
    "X-ApiKey" = apiSelect$key,
    "Accept" = "application/json"
  )

  textQuery=paste0("TS=",query)

  reponse<- GET(url=apiSelect$url,headers, query=list("q" = textQuery))
  content<- content(reponse, "text")
  result <- fromJSON(content)

  keywords = c()

  display_names= c()

  for (i in seq_along(result)) {
    display_names <- lapply(result[[i]]$names$authors, function(author) paste(author$displayName, collapse = " - "))


  }

  vector_nombres <- unlist(display_names)
  vector_nombres <- as.character(vector_nombres)




  df<- data.frame(

    "ID" = result$hits$uid,
    "Titulo" = result$hits$title,
    'Palabras clave' = NA,
    'Autor' = vector_nombres,
    'Año' = result$hits$source$publishYear,
    'Source' = result$hits$source$sourceTitle,
    'DOI' = result$hits$identifiers$doi,
    "Citas" = NA,
    'Summary' = NA,
    'BBDD'= 'wos',
    stringsAsFactors = FALSE
  )


  return(df)
}


getArticleGoogle<- function(query, apiSelect){

  response<- GET(url=apiSelect$url, query=list("api_key"= apiSelect$key, "q" = query, "hl"= "es"))
  content<- content(response, "text")
  result <- fromJSON(content)


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


