% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/getMetricsSource.R
\name{getMetricsSourceScopus}
\alias{getMetricsSourceScopus}
\title{Método para obtener métricas de una revista de la base de datos bibliométrica de Scopus.}
\usage{
getMetricsSourceScopus(query, api, titleSource = NULL)
}
\arguments{
\item{query}{Variable con el valor de ISSN.}

\item{api}{Nombre asignado a la base de datos, siempre será "scopus" si entra en este método.}

\item{titleSource}{Nombre del artículo en caso de que la query no tenga valor.}
}
\value{
Este método devuelve una lista con varios dataframe en los cuales se hayarán datos métricos de la revista solicitada de la base de datos Scopus.
}
\description{
Método para obtener métricas de una revista de la base de datos bibliométrica de Scopus.
}
\examples{
getMetricsSourceScopus("1874-9305","scopus",NA)
getMetricsSourceScopus(NA,"scopus","Elsevier Astrodynamics Series")
}
