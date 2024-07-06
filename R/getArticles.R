library(httr)
library(jsonlite)



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
    "Titulo" = result$'search-results'$entry$`dc:title`,
    'Palabras clave' = NA,
    'Autor' = result$'search-results'$entry$`dc:creator`,
    'Año' = result$'search-results'$entry$`prism:coverDate`,
    'Source' = NA,
    'ISSN' = result$'search-results'$entry$`prism:issn`,
    'EISSN' = result$'search-results'$entry$`prism:eIssn`,
    "Citas" = NA,
    'Summary' = NA,
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


    "Titulo" = result$hits$title,
    'Palabras clave' = NA,
    'Autor' = vector_nombres,
    'Año' = result$hits$source$publishYear,
    'Source' = result$hits$source$sourceTitle,
    'ISSN' = result$hits$identifiers$issn,
    'EISSN' = result$hits$identifiers$eissn,
    "Citas" = NA,
    'Summary' = NA,
    stringsAsFactors = FALSE
  )


  return(df)
}


getArticleGoogle<- function(query, apiSelect){

  response<- GET(url=apiSelect$url, query=list("api_key"= apiSelect$key, "q" = query, "hl"= "es"))
  content<- content(response, "text")
  result <- fromJSON(content)


  df<- data.frame(
    "Titulo" = result$"organic_results"$title,
    'Palabras clave' = result$"organic_results"$snippet,
    'Autor' = NA,
    'Año' = NA,
    'Source' = NA,
    'ISSN' = NA,
    'EISSN' = NA,
    "Citas" = result$"organic_results"$"inline_links"$"cited_by"$total,
    'Summary' = result$"organic_results"$"publication_info"$summary,
    stringsAsFactors = FALSE
  )




  return(df)
}
