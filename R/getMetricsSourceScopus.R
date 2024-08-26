library(httr)
library(jsonlite)


#' Obtener métricas de fuentes de Scopus
#'
#' @param uid id de Scopus
#'
#' @return dataframe de datos métricos
#' @export
#'
#' @examples
#'getMetricsSourceScopus("9-s2.0-40661023100","scopus")
library(httr)
library(jsonlite)

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

