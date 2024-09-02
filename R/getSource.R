library(httr)
library(jsonlite)


#' Método para obtener la información de todas las revistas
#'
#' @param apis Vector de las diferentes bases de datos, asignándole TRUE o FALSE, según si la base de datos que queramos buscar.
#' @param query Elemento de texto, por el cual consultaremos en las bases de datos que son elegidas en apis.
#'
#' @return Este método, devuelve un dataframe de las revistas que se obtienen de las diferentes bases de datos bibliométricas.
#' @export
#' @examples
#' getSource(c(wos=FALSE,scopus=TRUE, scholar=FALSE),"elsevier")
#' getSource(c(wos=FALSE,scopus=TRUE, scholar=FALSE),"neurocomputing")
getSource<- function (apis, query){
  apiConfig<- fromJSON("R/APIConfig.JSON")


  selected <- names(apis)[apis]
  response<- data.frame()
  first<- TRUE
  for (ap in selected){
    apiSelect <- apiConfig[apiConfig$name == ap,]

    if (ap == "scopus") {
      result <- bibliometrics::getSourceScopus(query, apiSelect)
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

#' Método para obtener la información de revistas de la base de datos de Scopus
#'
#' @param apis Vector de las diferentes bases de datos, asignándole TRUE o FALSE, según la base de datos que queramos buscar.
#' @param query Elemento de texto, por el cual consultaremos en las bases de datos que son elegidas en apis.
#'
#' @return Este método, tras los parámetros facilitados, genera un objeto data.frame con los datos en los que coincide con la consulta obtenida por Scopus, que posteriormente será devuelto.
#' @export
#' @import httr, jsonlite
#' @examples
#' getSourceScopus("scopus","elsevier")
#' getSourceScopus("scopus","neurocomputing")
getSourceScopus<-function(query, apiSelect){
  df=NA
  headers <- add_headers(
    "X-ELS-APIKey" = apiSelect$key,
    "X-ELS-Insttoken"= apiSelect$instant,
    "Accept" = "application/json"
  )

  response<- GET(url= apiSelect$urlSource ,headers, query=list( "title"=query, "view"="enhanced"))
  content<- content(response, "text")
  result <- fromJSON(content, flatten = TRUE)


  if (!is.null(result[["serial-metadata-response"]][["error"]])){

    df<- data.frame(
      'error'= TRUE
    )


  }
  else{

    subjectArea <- rep(NA, length(result[["serial-metadata-response"]][["entry"]][["subject-area"]]))



    for (i in seq_along(result[["serial-metadata-response"]][["entry"]][["subject-area"]])) {
      subject <- result[["serial-metadata-response"]][["entry"]][["subject-area"]][[i]]
      if (!is.null(subject[["$"]])) {
        cleaned_vector <- gsub("\\(all\\)", "", subject[["$"]])
        subjectArea[i] <- paste(cleaned_vector, collapse = ", ")
      }
    }


    df<- data.frame(
      "ID" = result[["serial-metadata-response"]][["entry"]][["prism:issn"]],
      "Titulo" = result[["serial-metadata-response"]][["entry"]][["dc:title"]],
      'Año' = result[["serial-metadata-response"]][["entry"]][["coverageStartYear"]],
      'Campos' = subjectArea,
      'BD'= 'scopus',
      stringsAsFactors = FALSE
    )
  }



  return(df)


}


