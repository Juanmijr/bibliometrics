#' Instalación por defecto de TinyTeX
#'
#' @param libname
#' @param pkgname
#'
#' @return
#' @export
#'
#' @examples
.onLoad <- function(libname, pkgname) {
  if (!tinytex::is_tinytex()) {
    message("Instalando TinyTeX, esto puede tardar unos minutos...")

    # Instala TinyTeX
    tinytex::install_tinytex()

    message("TinyTeX ha sido instalado correctamente.")
  } else {
    message("TinyTeX ya está instalado.")
  }
}
