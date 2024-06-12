library(shiny)
library(shinymaterial)
library(rnaturalearth)
library(DT)


paisesSin <- ne_countries()
paises <- paisesSin$name


ui<- material_page(
  include_nav_bar = FALSE,
  tags$head(
    tags$meta(charset = "UTF-8"),
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css"),
    tags$link(rel= "stylesheets", type="text/css", href = "https://unpkg.com/material-components-web@latest/dist/material-components-web.min.css"),
    tags$link(rel= "stylesheets", type="text/css", href = "https://fonts.googleapis.com/icon?family=Material+Icons"),
    tags$script(src="https://unpkg.com/material-components-web@latest/dist/material-components-web.min.js"),
    tags$script(src="https://cdnjs.cloudflare.com/ajax/libs/materialize/1.0.0/js/materialize.min.js"),
    tags$title("BiblioMetrics")
  ),
  #NAVBAR
    tags$div(
      class = "nav-wrapper",
      tags$a(
        class="brand-logo",
        href="#",
        tags$img(src="TFG.png",alt = "logo bibliometrics")
      )
    ),

  #CUERPO COMPLETO DE LA APP
  tags$div(
    class= "row",
    tags$div(
      id = "filters",
      class = "col s12 m3 offset-s0 offset-m0",
      tags$div(
        class="card z-depth-4",
        tags$div(
          class="card-content",
          #SELECT MODALIDAD BÚSQUEDA
          tags$div(
            class = "input-field",
            tags$div(
              class = "form-group shiny-input-container",
              tags$select(
                tags$option("Búsqueda por artículo", value = "1", selected="selected"),
                tags$option("Búsqueda por autor", value = "2"),
                tags$option("Búsqueda por revista", value = "3")
              ),
              tags$label("Selecciona opción de búsqueda")

            )

          ),

          #BUSCADOR TEXTO
          tags$div(
            class = "input-field",
            tags$div(
              class = "form-group shiny-input-container",
              tags$i(class="material-icons prefix small-icon", "search"),
              tags$input(type = "text", id = "search", class = "validate shiny-bound-input", placeholder="Introduce lo que quieres buscar")

            )

          ),


          #SELECT DE API
          tags$div(
            tags$label("Selecciona API donde quieres realizar la búsqueda"),
            material_checkbox("wos_checkbox", label = "API WOS"),
            material_checkbox("scholar_checkbox", label = "API Google Scholar"),
            material_checkbox("scopus_checkbox", label = "API Scopus")
          ),

          #MÁXIMO ÍNDICE H
              tags$div(
                class="input-field",
                tags$div(
                  class="form-group shiny-input-container",
                  tags$label("Máximo ÍNDICE H"),
                  tags$input(type="range", min="0", max="100", value="0")
                )
              ),

          #MÁXIMO NÚMERO DE CITAS
          tags$div(
            class="input-field",
            tags$div(
              class="form-group shiny-input-container",
              tags$label("Máximo número de citas"),
              tags$input(type="range", min="0", max="100", value="0")
            )
          ),
          #FECHA PUBLICACIÓN MÍNIMA
          tags$div(
            class = "input-field",
            tags$div(
              class= "form-group shiny-input-container",
              tags$label("Fecha de publicación mínima:"),
              tags$input(id="fecha_publicacion", value = format(Sys.Date(), "%d/%m/%Y"))

            )
          ),
          #MÁXIMO INDICE H PROMEDIO
          tags$div(
            class="input-field",
            tags$div(
              class="form-group shiny-input-container",
              tags$label("Máximo índice H promedio"),
              tags$input(type="range", min="0", max="100", value="0")
            )
          ),
          #MÍNIMO DE CITAS TOTALES
          tags$div(
            class="input-field",
            tags$div(
              class="form-group shiny-input-container",
              tags$label("Mínimo de citas totales"),
              tags$input(type="range", min="0", max="100", value="0")
            )
          ),
          #ELECCIÓN PAÍS DEL AUTOR
          tags$div(
            class="input-field",
            tags$div(
              class="form-group shiny-input-container",
              selectInput("paises_seleccionados", "Selecciona país(es):", choices = paises, multiple = TRUE)
            )
          ),

          tags$div(
            class="input-field",
            tags$button(
              class="btn waves-effect waves-light",
              type="submit",
              name="action",
              "Buscar",
              tags$i(
                class="material-icons right",
                "searchh"
              )
            )
          )


        )
      )
      ),


    tags$div(
      class = "col s12 m9",
      material_card(
        title = "Datos obtenidos",
        tags$a(
          class="waves-effect waves-light btn modal-trigger",
          href="#modal1",
          "Modal"
        ),
        tags$div(
          id="modal1",
          class="modal",
          tags$div(
            class="modal-content",
            tags$h4("Modal Header"),
            tags$p("A bunch of text")
          ),
          tags$div(
            class="modal-footer",
            tags$a(
              href="#!",
              class="modal-close waves-effect btn-flat",
              "Aceptar"
            )
          )


        )
        ,
        DTOutput("resultados")
      )
    )




  ),

  tags$script(src = "index.js")


)
