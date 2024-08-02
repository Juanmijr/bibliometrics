
.bibliometricsEnv <- new.env(parent=emptyenv())




#' almacena email corporativo para poder acceder a recursos
#'
#' @param value debe ir el correo electrónico corporativo
#'TENGO QUE ESCRIBIR ESTO
#'@return None
#' @examples
#' setEmail("prueba@red.ujaen.es")

setEmail <- function (value){
  assign("email",value, envir=.bibliometricsEnv)
}



#' almacena contraseña de la cuenta corporativa
#'
#' @param value debe ir contraseña a guardar
#'@return None
#' @examples
#' setPass("prueba")
#' setPass("contrasena")
setPass <- function (value){
  assign("pass",value,envir=.bibliometricsEnv)
}



#' almacena ruta de python
#'
#' @param value debe ser la ruta del directorio que aloje el ejecutable python
#'
#' @return None
#' @export
#'
#' @examples
#' setPython("C:/User/Python")
setPython<- function(value){
  assign("python",value,envir=.bibliometricsEnv)
}



getVariable<-function(name){
  if(exists(name,envir=.bibliometricsEnv)){
    return(get(name,envir = .bibliometricsEnv))
  } else{
    stop(paste("Variable", name, "no encontrada."))
  }
}
