library(httr)
library(jsonlite)


#' Obtener métricas de Autores de Scopus
#'
#' @param uid id de Scopus
#'
#' @return dataframe de datos métricos
#' @export
#'
#' @examples
#'getMetricsAuthorScopus("9-s2.0-40661023100","scopus")
getMetricsAuthorScopus<- function(query, apis){

  apiConfig<- fromJSON("R/APIConfig.JSON")
  apiSelect <- apiConfig[apiConfig$name == apis,]



  headers <- add_headers(
    "X-ELS-APIKey" = apiSelect$key,
    "X-ELS-Insttoken"= apiSelect$instant,
    "Accept" = "application/json"
  )

  response<- GET(url= apiSelect$urlMetricsAuthor,headers, query=list("eid"=query, "count"="25", "view"="ENHANCED"))
  content<- content(response, "text")
  result <- fromJSON(content, flatten = TRUE)

  View(result)


  df<- data.frame(
    "Orcid" = result[["author-retrieval-response"]][["coredata.orcid"]],
    'Nombre' = paste(result[["author-retrieval-response"]][["author-profile.preferred-name.given-name"]],result[["author-retrieval-response"]][["author-profile.preferred-name.surname"]], sep=" "),
    "NumDocs" = result[["author-retrieval-response"]][["coredata.document-count"]],
    'NumCitas' = result[["author-retrieval-response"]][["coredata.citation-count"]],
    'NumDocsCitados' = result[["author-retrieval-response"]][["coredata.cited-by-count"]],
    'indice-h' =  result[["author-retrieval-response"]][["h-index"]],
    'numCoAutor' = result[["author-retrieval-response"]][["coauthor-count"]],
    'Afiliacion' = result[["author-retrieval-response"]][["author-profile.affiliation-current.affiliation.ip-doc.preferred-name.$"]],
    'lugarAfiliacion' = paste(result[["author-retrieval-response"]][["author-profile.affiliation-current.affiliation.ip-doc.address.city"]],result[["author-retrieval-response"]][["author-profile.affiliation-current.affiliation.ip-doc.address.state"]],result[["author-retrieval-response"]][["author-profile.affiliation-current.affiliation.ip-doc.address.country"]],sep=", "),
    stringsAsFactors = FALSE
  )


  return(df)

}
