library(shiny)
library(shinymaterial)
library(rnaturalearth)
library(DT)
library(shinyjs)
library(plotly)

paisesSin <- ne_countries()
paises <- paisesSin$name


ui <- material_page(
  primary_theme_color = "#26A69A",
  useShinyjs(),
  include_nav_bar = FALSE,
  tags$head(
    tags$meta(charset = "UTF-8"),
    tags$link(rel = "stylesheets", type = "text/css", href = "nouislider.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css"),
    tags$link(rel = "stylesheets", type = "text/css", href = "https://cdnjs.cloudflare.com/ajax/libs/materialize/1.0.0/css/materialize.min.css"),
    tags$link(rel = "stylesheets", type = "text/css", href = "https://fonts.googleapis.com/icon?family=Material+Icons"),
    tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/materialize/1.0.0/js/materialize.min.js"),
    tags$link(rel = "icon", href = "iconoBM.png", type = "image/x-icon"),
    tags$script(src = "nouislider.js"),
    tags$title("BiblioMetrics"),


  ),


  # NAVBAR
  tags$div(class = "nav-wrapper", tags$a(
    class = "brand-logo",
    href = "#",
    tags$img(src = "TFG.png", alt = "logo bibliometrics")
  )),

  # TABS

  tags$ul(
    id = "tabs",
    class = "tabs tabs-fixed-width",
    tags$li(
      class = "tab",
      id = "liTab1",
      tags$a(href = "#cardHome", "Inicio")
    ),
    tags$li(
      class = "tab",
      id = "liTab2",
      tags$a(href = "#cardAnalisis", "Análisis")
    )
  ),


  tags$div(id = "loader", tags$div(class = "spinner")),

  # Define tab content
  material_tab_content(
    tab_id = "cardHome",
    # CUERPO COMPLETO DE LA APP
    tags$div(
      class = "row",
      tags$div(
        id = "filters",
        class = "col s12 m3 offset-s0 offset-m0",
        tags$div(
          class = "card z-depth-4",
          tags$div(
            class = "card-content",
            id = "cardSearch",
            # SELECT MODALIDAD BÚSQUEDA
            tags$div(
              class = "input-field",
              tags$div(
                class = "form-group shiny-input-container",
                tags$select(
                  id = "select_search",
                  tags$option("Búsqueda por artículo", value = "article", selected = "selected"),
                  tags$option("Búsqueda por autor", value = "author"),
                  tags$option("Búsqueda por revista", value = "source")
                ),
                tags$label("Selecciona opción de búsqueda")
              )
            ),



            # SELECT DE API

            material_dropdown(
              input_id = "selectApi",
              choices = c(
                "WOS" = "wos",
                "Google Scholar" = "scholar",
                "Scopus" = "scopus"
              ),
              multiple = TRUE,
              label = "Selecciona base de datos:"
            ),

            # BUSCADOR TEXTO
            tags$div(
              class = "input-field",
              tags$div(
                class = "form-group shiny-input-container",
                tags$i(class = "material-icons prefix small-icon", "search"),
                tags$input(
                  type = "text",
                  id = "searchText",
                  placeholder = "Introduce lo que quieres buscar"
                )
              )
            ),
            material_button(
              input_id = "search_button",
              icon = "search",
              depth = 5,
              label = "Buscar"
            )
          )
        ),
        tags$div(
          class = "card z-depth-4",
          id = "cardFilter",
          tags$div(
            class = "card-content",

            uiOutput("year"),
            uiOutput("citationNum"),
            uiOutput("documentNum"),
            uiOutput("author"),
            uiOutput("doi"),
            uiOutput("bd"),

          )
        )
      ),
      tags$div(
        class = "col s12 m9",
        material_card(
          id = "instrucciones",
          class="descripcion",
          tags$span(class = "card-title", "Descripción de la aplicación"),
          tags$p("BiblioMetrics es un paquete de R, desarrollado por Juan Miguel Jiménez Rivas, en su trabajo de fin de grado."),
          tags$p("La finalidad de este es obtener un análisis bibliométricos de artículos científicos de manera sencilla e intuitiva para el usuario."),
          tags$p("Mediante una búsqueda simple, puedes realizar búsqueda por artículos, autores y revistas en diferentes bases de datos."),
          tags$p("Antes de nada, para que la aplicación funcione, debes rellenar el archivo '.Renviron' con el usuario identificativo de la Universidad de Jaén y la contraseña."),
          tags$p("Espero que el uso sea de su agrado.")
          ),

        div(
          id = "errorResultados",
          div(
            class = "error-message",
            strong("ERROR"),
            "LA CONSULTA REALIZADA NO HA OBTENIDO DATOS"
          )
        ),
        material_card(
          id = "resultados",
          tags$span(class = "card-title center-align", "Datos obtenidos"),

            tags$div(
              shiny::tagList(
                downloadButton("downloadXLSX", "Descargar EXCEL"),
                downloadButton("downloadPDF", "Descargar PDF"),
              )
            ),
          DTOutput("resultados")
        )

      )
    )

  ),
  material_tab_content(tab_id = "cardAnalisis", uiOutput("analisis"))
)
