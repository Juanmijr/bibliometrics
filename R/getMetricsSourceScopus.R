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

getMetricsSourceScopus <- function(query, api) {
  print("HE ENTRADO A GETMETRICSSOURCESCOUPUS")
  apiConfig <- fromJSON("R/APIConfig.JSON")
  apiSelect <- apiConfig[apiConfig$name == api,]

  urlISSN <- paste(apiSelect$urlSource, "/issn/", query, sep = "")

  headers <- add_headers(
    "X-ELS-APIKey" = apiSelect$key,
    "X-ELS-Insttoken" = apiSelect$instant,
    "Accept" = "application/json"
  )

  response <- GET(url = urlISSN, headers, query = list(view = "enhanced"))
  content <- content(response, "text")
  result <- fromJSON(content, flatten = TRUE)


  View(result)

  entry <- result[["serial-metadata-response"]][["entry"]]

  df <- data.frame(
    "ISSN" = entry[["prism:issn"]],
    "Editorial" = entry[["dc:publisher"]],
    'Titulo' = entry[["dc:title"]],
    'AnoInicio' = entry[["coverageStartYear"]],
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

