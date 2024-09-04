

#' Método para obtener los autores que coincidan con una consulta de texto
#'
#' @param apis Vector de las diferentes bases de datos, asignándole TRUE o FALSE, según la base de datos que queramos buscar.
#' @param query Elemento de texto, por el cual consultaremos en las bases de datos que son elegidas en apis.
#' @return Este método, devuelve un dataframe de los autores que se obtienen de las diferentes bases de datos bibliométricas.
#' @export
#'
#' @examples
#' getAuthors(c(wos=TRUE,scopus=TRUE, scholar=FALSE),"Charte")
#' getAuthors(c(wos=FALSE,scopus=TRUE, scholar=TRUE),"Jiménez")
getAuthors <- function (apis, query){
  apiConfig<- jsonlite::fromJSON("R/APIConfig.JSON")


  selected <- names(apis)[apis]
  response<- data.frame()
  first<- TRUE
  for (ap in selected){
    apiSelect <- apiConfig[apiConfig$name == ap,]

   if (ap == "scholar") {
      result <- bibliometrics::getAuthorsGoogle(query)
    } else if (ap == "scopus") {
      result <- bibliometrics::getAuthorsScopus(query, apiSelect)
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


#' Método para obtener los autores de la base de datos de Google Scholar
#'
#' @param query Elemento de texto, por el cual consultaremos en las bases de datos que son elegidas en apis.
#'
#' @return Este método, tras los parámetros facilitados, genera un objeto data.frame con los datos en los que coincide con la consulta obtenida por Google Scholar, que posteriormente será devuelto.
#' @export
#' @import reticulate, stringi
#' @examples
#' getAuthorsGoogle("Charte")
#' getAuthorsGoogle("Jiménez")

getAuthorsGoogle<-function(query){


  python_config <- reticulate::py_discover_config()

  reticulate::use_python("~/.virtualenvs/r-reticulate/Scripts/python.exe")

  query <- tolower(query)

  query <- gsub(" ", "-", query)

  query <-stringi::stri_trans_general(query, "Latin-ASCII")

  query <- gsub("[^a-zA-Z0-9-]", "", query)



  if (!py_module_available("selenium")) {
    reticulate::py_install("selenium")
  }

  if (!py_module_available("pandas")) {
    reticulate::py_install("pandas")
  }

  reticulate::source_python("R/py/WebScrappingGoogle.py")

  authorsPY <-getAuthors(query)

  authors <- reticulate::py_to_r(authorsPY)



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

  return(authors)

}

#' Método para obtener los artículos de la base de datos de Scopus
#'
#' @param query Elemento de texto, por el cual consultaremos en la base de datos de Scopus.
#' @param apiSelect Pasa una variable JSON, tal que:
#'    {
#' "name":"scopus",
#' "urlArticle": "https://api.elsevier.com/content/search/scopus",
#' "key": Clave de la API de Scopus,
#' "instant": Esta variable "no sería necesaria", pero la uso, ya que me permitieron acceder con esta variable a APIs que no podía acceder con un usuario normal.
#'}
#'
#' @return Este método, tras los parámetros facilitados, genera un objeto data.frame con los datos en los que coincide con la consulta obtenida por Scopus, que posteriormente será devuelto.
#' @export
#' @import httr, jsonlite
#' @examples
#'
#' getArticlesScopus("Charte", {
#' "name":"scopus",
#' "urlAuthor":"https://api.elsevier.com/content/search/author",
#' "key": Clave de la API de Scopus,
#' "instant": Esta variable "no sería necesaria", pero la uso, ya que me permitieron acceder con esta variable a APIs que no podía acceder con un usuario normal.
#'})
#'
#' getArticlesScopus("Jiménez", {
#' "name":"scopus",
#' "urlAuthor":"https://api.elsevier.com/content/search/author",
#' "key": Clave de la API de Scopus,
#' "instant": Esta variable "no sería necesaria", pero la uso, ya que me permitieron acceder con esta variable a APIs que no podía acceder con un usuario normal.
#'})
getAuthorsScopus<-function(query, apiSelect){

  df=NA

  textQuery=paste0("AUTHLASTNAME(",query,")")

  headers <- add_headers(
    "X-ELS-APIKey" = apiSelect$key,
    "X-ELS-Insttoken"= apiSelect$instant,
    "Accept" = "application/json"
  )


  response<- httr::GET(url= apiSelect$urlAuthor,headers, query=list("query"=textQuery, "count"="50"))
  content<- httr::content(response, "text")
  result <- jsonlite::fromJSON(content, flatten = TRUE)


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


  }
  else{
    df<- data.frame(
      'error'= TRUE
    )
  }



  return(df)

}






