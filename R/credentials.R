#' Método para guardar credenciales para usar en Scopus
#'
#' @return Este método no devuelve nada
#' @export
#'
#' @examples
#' credentials()
credentials <- function() {
  # Solicitar al usuario el nombre de usuario y la contraseña
  user <- readline(prompt = "Introduce tu nombre de usuario: ")
  password <- readline(prompt = "Introduce tu contraseña: ")

  # Definir la ruta del archivo .Renviron
  renviron_path <- file.path(Sys.getenv("HOME"), ".Renviron")

  # Crear el archivo .Renviron si no existe
  if (!file.exists(renviron_path)) {
    file.create(renviron_path)
  }

  # Agregar el nombre de usuario y la contraseña al archivo .Renviron
  cat(paste0("USER=", user, "\n"), file = renviron_path, append = TRUE)
  cat(paste0("PASSWORD=", password, "\n"), file = renviron_path, append = TRUE)

  message("Credenciales guardadas en .Renviron. Por favor, reinicia R para aplicar los cambios.")
}
