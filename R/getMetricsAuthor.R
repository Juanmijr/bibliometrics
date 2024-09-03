library(jsonlite)
library(reticulate)
library(httr)

#' Método para obtener métricas de un autor de las diferentes bases de datos bibliométricas.
#'
#' @param apis La variable apis será el nombre en texto que tenemos asociado a cada base de datos bibliométrica
#' @param ID Variable de texto que tendremos asociado el ID del autor, para buscarlo.
#'
#' @return Este método devuelve un dataframe en el cual estará los datos métricos del autor solicitado por el ID de la base de datos escogida.
#' @export
#'
#' @examples
#' getMetricsAuthor("scholar","i8l_80EAAAAJ")
#' getMetricsAuthor("scopus","9-s2.0-40661023100")
getMetricsAuthor<- function (apis, ID){


    if (apis == "scholar") {
    result <- getMetricsAuthorScholar(ID)
  } else if (apis == "scopus") {
    result <-getMetricsAuthorScopus(ID, apis)
  } else {
    stop("Valor de 'ap' no válido")
  }


  return(result)
}

#' Método para obtener métricas de un autor de la base de datos bibliométrica Google Scholar.
#'
#' @param uid id de Google Scholar
#'
#' @return Este método devuelve un dataframe en el cual estará los datos métricos del autor solicitado por el ID de la base de datos Google Scholar.
#' @export
#' @import reticulate
#' @examples
#'getMetricsAuthorScholar("i8l_80EAAAAJ")
#'getMetricsAuthorScholar("iwXvlSAAAAAJ")
getMetricsAuthorScholar <- function(uid) {

  python_config <- reticulate::py_discover_config()

  reticulate::use_python("~/.virtualenvs/r-reticulate/Scripts/python.exe")



  if (!py_module_available("selenium")) {
    reticulate::py_install("selenium")
  }

  if (!py_module_available("pandas")) {
    reticulate::py_install("pandas")
  }

  reticulate::source_python("R/py/WebScrappingGoogle.py")

  metrics <-getMetricsAuthor(uid)

  dfMetrics <- reticulate::py_to_r(metrics)


  return(dfMetrics)
}


#' Método para obtener métricas de un autor de la base de datos bibliométrica de Scopus.
#'
#' @param ID Número de serie por el cual consultaremos en la base de datos de Scopus.
#' @param apis Nombre asignado a la base de datos, siempre será "scopus" si entra en este método.
#'
#' @return Este método devuelve un dataframe en el cual estará los datos métricos del autor solicitado por el ID de la base de datos Scopus.
#' @export
#' @import httr, jsonlite
#' @examples
#'getMetricsAuthorScopus("9-s2.0-40661023100","scopus")
#'
getMetricsAuthorScopus<- function(ID, apis){

  apiConfig<- jsonlite::fromJSON("R/APIConfig.JSON")
  apiSelect <- apiConfig[apiConfig$name == apis,]



  headers <- add_headers(
    "X-ELS-APIKey" = apiSelect$key,
    "X-ELS-Insttoken"= apiSelect$instant,
    "Accept" = "application/json"
  )

  response<- httr::GET(url= apiSelect$urlMetricsAuthor,headers, query=list("eid"=ID, "count"="25", "view"="ENHANCED"))
  content<- httr::content(response, "text")
  result <- jsonlite::fromJSON(content, flatten = TRUE)



  df <- data.frame(
    "Orcid" = ifelse(!is.null(result[["author-retrieval-response"]][["coredata.orcid"]]), result[["author-retrieval-response"]][["coredata.orcid"]], NA),
    'Nombre' = ifelse(!is.null(result[["author-retrieval-response"]][["author-profile.preferred-name.given-name"]]) &
                        !is.null(result[["author-retrieval-response"]][["author-profile.preferred-name.surname"]]),
                      paste(result[["author-retrieval-response"]][["author-profile.preferred-name.given-name"]],
                            result[["author-retrieval-response"]][["author-profile.preferred-name.surname"]], sep = " "),
                      NA),
    "NumDocs" = ifelse(!is.null(result[["author-retrieval-response"]][["coredata.document-count"]]), result[["author-retrieval-response"]][["coredata.document-count"]], NA),
    'NumCitas' = ifelse(!is.null(result[["author-retrieval-response"]][["coredata.citation-count"]]), result[["author-retrieval-response"]][["coredata.citation-count"]], NA),
    'NumDocsCitados' = ifelse(!is.null(result[["author-retrieval-response"]][["coredata.cited-by-count"]]), result[["author-retrieval-response"]][["coredata.cited-by-count"]], NA),
    'indiceh' = ifelse(!is.null(result[["author-retrieval-response"]][["h-index"]]), result[["author-retrieval-response"]][["h-index"]], NA),
    'numCoAutor' = ifelse(!is.null(result[["author-retrieval-response"]][["coauthor-count"]]), result[["author-retrieval-response"]][["coauthor-count"]], NA),
    'Afiliacion' = ifelse(!is.null(result[["author-retrieval-response"]][["author-profile.affiliation-current.affiliation.ip-doc.preferred-name.$"]]),
                          result[["author-retrieval-response"]][["author-profile.affiliation-current.affiliation.ip-doc.preferred-name.$"]],
                          NA),
    'lugarAfiliacion' = ifelse(!is.null(result[["author-retrieval-response"]][["author-profile.affiliation-current.affiliation.ip-doc.address.city"]]) &
                                 !is.null(result[["author-retrieval-response"]][["author-profile.affiliation-current.affiliation.ip-doc.address.state"]]) &
                                 !is.null(result[["author-retrieval-response"]][["author-profile.affiliation-current.affiliation.ip-doc.address.country"]]),
                               paste(result[["author-retrieval-response"]][["author-profile.affiliation-current.affiliation.ip-doc.address.city"]],
                                     result[["author-retrieval-response"]][["author-profile.affiliation-current.affiliation.ip-doc.address.state"]],
                                     result[["author-retrieval-response"]][["author-profile.affiliation-current.affiliation.ip-doc.address.country"]], sep = ", "),
                               NA),
    stringsAsFactors = FALSE
  )


  return(df)

}
