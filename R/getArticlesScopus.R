
#' Title
#'
#' @param query
#' @param apiSelect
#'
#' @return
#' @export
#'
#' @examples
getArticlesScopus<-function(query, apiSelect){
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
