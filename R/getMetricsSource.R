library(httr)
library(jsonlite)

#' Método para obtener métricas de una revista de las diferentes bases de datos bibliométricas.
#'
#' @param apis Nombre de la base de datos a buscar
#' @param query En este caso será la consulta será el ISSN de la revista.
#' @param title En caso de que no se inserte la ISSN, se podrá buscar por el nombre de la revista.
#' @return Este método, devuelve una lista de dataframes de las métricas que se pueden obtener de una revista de las diferentes bases de datos bibliométricas.
#' @export
#'
#' @examples
#'getMetricsSource("scopus","1874-9305", NA)
#'getMetricsSource("scopus",NA, "Elsevier Astrodynamics Series")

getMetricsSource<- function (apis, query, title){

   if (apis == "scopus") {
     print("VOY A ENTRAR AQUÍ ")
    result <-getMetricsSourceScopus(query, apis, title)
  } else {
    stop(paste("Valor de 'api' no válido: ", apis))
  }


  return(result)
}


#' Método para obtener métricas de una revista de la base de datos bibliométrica de Scopus.
#'
#' @param query Variable con el valor de ISSN.
#' @param api Nombre asignado a la base de datos, siempre será "scopus" si entra en este método.
#' @param titleSource Nombre del artículo en caso de que la query no tenga valor.
#'
#' @return Este método devuelve una lista con varios dataframe en los cuales se hayarán datos métricos de la revista solicitada de la base de datos Scopus.
#' @export
#' @import httr, jsonlite

#' @examples
#'getMetricsSource("1874-9305","scopus",NA)
#'getMetricsSource(NA,"scopus","Elsevier Astrodynamics Series")
getMetricsSourceScopus <- function(query, api, titleSource=NULL) {
  apiConfig <- fromJSON("R/APIConfig.JSON")
  apiSelect <- apiConfig[apiConfig$name == api,]

  if(!is.null(query)){
    urlISSN <- paste(apiSelect$urlSource, "/issn/", query, sep = "")

    headers <- add_headers(
      "X-ELS-APIKey" = apiSelect$key,
      "X-ELS-Insttoken" = apiSelect$instant,
      "Accept" = "application/json"
    )

    response <- GET(url = urlISSN, headers, query = list(view = "enhanced"))

  }
  else{

    headers <- add_headers(
      "X-ELS-APIKey" = apiSelect$key,
      "X-ELS-Insttoken" = apiSelect$instant,
      "Accept" = "application/json"
    )
    response <- GET(url = apiSelect$urlSource, headers, query = list(title=titleSource,view = "enhanced"))

  }



  content <- content(response, "text")
  result <- fromJSON(content, flatten = TRUE)


  View(result)

  entry <- result[["serial-metadata-response"]][["entry"]]


  get_value <- function(data, key) {
    if (!is.null(data[[key]])) {
      return(data[[key]])
    } else {
      return(NA)
    }
  }

  df <- data.frame(
    "ISSN" = get_value(entry, "prism:issn"),
    "Editorial" = get_value(entry, "dc:publisher"),
    'Titulo' = get_value(entry, "dc:title"),
    'AnoInicio' = get_value(entry, "coverageStartYear"),
    stringsAsFactors = FALSE
  )

  subjectsAreas <- entry[["subject-area"]][[1]][["$"]]

  getMetrics <- function(data, metric_name) {
    metrics_data <- data[[paste0(metric_name, "List.", metric_name)]]
    if (is.null(metrics_data)) return(NULL)
    do.call(rbind, lapply(metrics_data, function(item) {
      data.frame(
        metric = metric_name,
        year = item$`@year`,
        total = item$`$`,
        stringsAsFactors = FALSE
      )
    }))
  }

  dfMetricsSNIP <- getMetrics(entry, "SNIP")
  dfMetricsSJR <- getMetrics(entry, "SJR")

  dfMetrics <- rbind(dfMetricsSNIP, dfMetricsSJR)

  yearly_data <- entry[["yearly-data.info"]][[1]]

  yearly_data[["zeroCitesPercentSCE"]][is.na(yearly_data[["zeroCitesPercentSCE"]])]<-0


  dfDataYearly <- data.frame(
    'ano' = as.numeric(yearly_data[["@year"]]),
    'numDocsAno' = as.numeric(yearly_data[["publicationCount"]]),
    'numCitasAno' =as.numeric(yearly_data[["citeCountSCE"]]),
    'numDocsNoCitados' = as.numeric(yearly_data[["zeroCitesSCE"]]),
    'porcentajeDocsNoCitados' = as.numeric(yearly_data[["zeroCitesPercentSCE"]]),
    'porcentajesArtRevision' = as.numeric(yearly_data[["revPercent"]]),
    stringsAsFactors = FALSE
  )

  return(list(df, subjectsAreas, dfMetrics, dfDataYearly))
}

