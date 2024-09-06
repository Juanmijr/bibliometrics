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

    if (!("USER" %in% names(Sys.getenv())) || !("PASSWORD" %in% names(Sys.getenv()))) {
      user <- readline(prompt = "Introduce tu nombre de usuario: ")
      password <- readline(prompt = "Introduce tu contraseña: ")

      renviron_path <- file.path(Sys.getenv("HOME"), ".Renviron")

      if (!file.exists(renviron_path)) {
        file.create(renviron_path)
      }

      cat(paste0("USER=", user, "\n"), file = renviron_path, append = TRUE)
      cat(paste0("PASSWORD=", password, "\n"), file = renviron_path, append = TRUE)

      message("Credenciales guardadas en .Renviron. Por favor, reinicia R para aplicar los cambios.")
    }


}
