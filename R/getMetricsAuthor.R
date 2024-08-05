library(httr)
library(jsonlite)

getMetricsAuthor<- function (apis, query){
  apiConfig<- fromJSON("R/APIConfig.JSON")
  apiSelect <- apiConfig[apiConfig$name == apis,]

  View(apiSelect)

    if (apis == "scholar") {
    result <- getMetricsAuthorScholar(query, apiSelect)
  } else if (apis == "scopus") {
    result <- getMetricsAuthorScopus(query, apiSelect)
  } else {
    stop("Valor de 'ap' no válido")
  }


  return(result)
}
