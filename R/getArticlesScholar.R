#' Title
#'
#' @param query
#' @param apiSelect
#'
#' @return
#' @export
#'
#' @examples
getArticlesGoogle<- function(query, apiSelect){

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

