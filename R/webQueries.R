library(httr)
library(jsonlite)


prueba <- function(opciones){




}


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
getArticle <- function (apis, query){
  apiConfig<- fromJSON("R/APIConfig.JSON")


  selected <- names(apis)[apis]
  response<- data.frame()
  first<- TRUE
  for (ap in selected){
    print(ap)
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
  print (apiSelect$url)
  textQuery=paste0("TITLE-ABS-KEY(",query,")")
  print(textQuery)
  response<- GET(url= apiSelect$url, query=list("apiKey"= apiSelect$key, "query"=textQuery, "count"="25"))
  content<- content(response, "text")
  result <- fromJSON(content, flatten = TRUE)



  df<- data.frame(
    "titulo" = result$'search-results'$entry$`dc:title`,
    'palabras clave' = NA,
    'autor/es' = result$'search-results'$entry$`dc:creator`,
    'año' = result$'search-results'$entry$`prism:coverDate`,
    'nombre fuente' = NA,
    'ISSN' = result$'search-results'$entry$`prism:issn`,
    'EISSN' = result$'search-results'$entry$`prism:eIssn`,
    "citas" = NA,
    'resumen cita' = NA,
    stringsAsFactors = FALSE
  )


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


    "titulo" = result$hits$title,
    'palabras clave' = NA,
    'autor/es' = vector_nombres,
    'año' = result$hits$source$publishYear,
    'nombre fuente' = result$hits$source$sourceTitle,
    'ISSN' = result$hits$identifiers$issn,
    'EISSN' = result$hits$identifiers$eissn,
    "citas" = NA,
    'resumen cita' = NA,
    stringsAsFactors = FALSE
  )


  return(df)
}


getArticleGoogle<- function(query, apiSelect){

  response<- GET(url=apiSelect$url, query=list("api_key"= apiSelect$key, "q" = query, "hl"= "es"))
  content<- content(response, "text")
  result <- fromJSON(content)


  df<- data.frame(
    "titulo" = result$"organic_results"$title,
    'palabras clave' = result$"organic_results"$snippet,
    'autor/es' = NA,
    'año' = NA,
    'nombre fuente' = NA,
    'ISSN' = NA,
    'EISSN' = NA,
    "citas" = result$"organic_results"$"inline_links"$"cited_by"$total,
    'resumen cita' = result$"organic_results"$"publication_info"$summary,
    stringsAsFactors = FALSE
  )




  return(df)
}
