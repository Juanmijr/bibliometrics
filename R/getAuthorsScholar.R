getAuthorsGoogle<-function(query){


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
