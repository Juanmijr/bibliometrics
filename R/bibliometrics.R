.onLoad <- function(libname, pkgname) {
  if (!requireNamespace("tinytex", quietly = TRUE)) {
    stop("El paquete 'tinytex' no está instalado. Por favor, instálelo para usar este paquete.")
  }

  if (!tinytex::is_tinytex()) {
    message("TinyTeX no está instalado. Instalando TinyTeX...")
    tinytex::install_tinytex()
  } else {
    message("TinyTeX ya está instalado.")
  }
}
