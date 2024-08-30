getAuthorsScopus<-function(query, apiSelect){

  df=NA

  textQuery=paste0("AUTHLASTNAME(",query,")")

  headers <- add_headers(
    "X-ELS-APIKey" = apiSelect$key,
    "X-ELS-Insttoken"= apiSelect$instant,
    "Accept" = "application/json"
  )


  response<- GET(url= apiSelect$urlAuthor,headers, query=list("query"=textQuery, "count"="25"))
  content<- content(response, "text")
  result <- fromJSON(content, flatten = TRUE)


  if (is.null(result[["search-results"]][["entry"]][["error"]])){
    subjectArea= character(length(result$'search-results'$entry$'subject-area'))

    for (i in 1:length(result$'search-results'$entry$'subject-area')) {

      if (!is.null(result[["search-results"]][["entry"]][["subject-area"]][[i]][["$"]])){

        cleaned_vector <- gsub("\\(all\\)", "", result[["search-results"]][["entry"]][["subject-area"]][[i]][["$"]])

        var<- paste(cleaned_vector,collapse=", ")

        subjectArea[i] <- var
      }
      else{
        subjectArea[i]<- NA
      }

    }
    name=character(length(result$'search-results'$entry$'name-variant'))
    surname = character(length(result$'search-results'$entry$'name-variant'))

    for (i in 1:length(result$'search-results'$entry$'name-variant')){
      if (length(result$'search-results'$entry$'name-variant'[[i]])>0){
        name[i]<-result$'search-results'$entry$'name-variant'[[i]]$'given-name'[1]
        surname[i]<-result$'search-results'$entry$'name-variant'[[i]]$'surname'[1]


      }
      else{
        name[i]<-""
        surname[i]<-""
      }
    }


    df<- data.frame(
      "ID" = result$'search-results'$entry$`eid`,
      'Nombre' = name,
      'Apellido' = surname,
      'NumDocumentos' =as.numeric(result$'search-results'$entry$`document-count`),
      'Afiliación' = result[["search-results"]][["entry"]][["affiliation-current.affiliation-name"]],
      'Citas' = NA,
      'Campos' = subjectArea,
      'BD'= 'scopus',
      stringsAsFactors = FALSE
    )


    View(df)


  }
  else{
    df<- data.frame(
      'error'= TRUE
    )
  }



  return(df)

}
