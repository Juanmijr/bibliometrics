library(httr)
library(jsonlite)

getRequest <- function (api, params = list()){

  apiConfig<- fromJSON("R/APIConfig.JSON")

  apiSelect <- apiConfig[apiConfig$name==api]

  params[["apiKey"]]=apiSelect$params$key


  response<- GET(apiSelect$params$url, query = params)
  content<- content(response, "text")
  result <- fromJSON(content, flatten = TRUE)
  print(result)
  return(result$entry)
}



