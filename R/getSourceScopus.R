
#' Obtener revistas de SCOPUS
#'
#' @param query
#' @param apiSelect
#'
#' @return
#' @export
#'
#' @examples
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
