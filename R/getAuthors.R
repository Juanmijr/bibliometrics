library(httr)
library(jsonlite)
library(reticulate)


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
getAuthor <- function (apis, query){
  apiConfig<- fromJSON("R/APIConfig.JSON")


  selected <- names(apis)[apis]
  response<- data.frame()
  first<- TRUE
  for (ap in selected){
    apiSelect <- apiConfig[apiConfig$name == ap,]

   if (ap == "scholar") {
      result <- getAuthorGoogle(query)
    } else if (ap == "scopus") {
      result <- getAuthorScopus(query, apiSelect)
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

getAuthorScopus<-function(query, apiSelect){

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


  getAuthorGoogle<-function(query){


    python_config <- py_discover_config()

    use_python("~/.virtualenvs/r-reticulate/Scripts/python.exe")

    querySin <- gsub(" ", "", query)

    if (!py_module_available("selenium")) {
      py_install("selenium")
    }

    if (!py_module_available("pandas")) {
      py_install("pandas")
    }

    source_python("R/py/WebScrappingGoogle.py")

    authorsPY <-getAuthors(querySin)

    authors <- py_to_r(authorsPY)


    if (!"error" %in% colnames(authors)){
      df<- data.frame(
        "ID" = authors$ID,
        'Nombre' = authors$Name,
        'Apellido' = NA,
        'NumDocumentos' = NA,
        'Afiliación' = authors$Affiliation,
        'Citas' = as.numeric(authors$"Cited by"),
        'Campos' = authors$Interests,
        'BD'= 'scholar',
        stringsAsFactors = FALSE
      )
      return(df)
    }

    View(df)


    return(authors)

  }




