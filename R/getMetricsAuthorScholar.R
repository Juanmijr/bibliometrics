library(jsonlite)
library(reticulate)

getMetrics <- function(uid) {

  python_config <- py_discover_config()

  use_python("~/.virtualenvs/r-reticulate/Scripts/python.exe")



  if (!py_module_available("selenium")) {
    py_install("selenium")
  }

  if (!py_module_available("pandas")) {
    py_install("pandas")
  }

  source_python("R/py/WebScrappingGoogle.py")

  metrics <-getMetrics(uid)

  dfMetrics <- py_to_r(metrics)

  return(dfMetrics)
}
