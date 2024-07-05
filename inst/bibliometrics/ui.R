library(shiny)
library(shinymaterial)
library(rnaturalearth)
library(DT)
library(shinyjs)

paisesSin <- ne_countries()
paises <- paisesSin$name


ui<- material_page(
  primary_theme_color = "#26A69A",
  useShinyjs(),
  include_nav_bar = FALSE,
  tags$head(
    tags$meta(charset = "UTF-8"),
    tags$link(rel= "stylesheets", type="text/css", href ="nouislider.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css"),
    tags$link(rel= "stylesheets", type="text/css", href = "https://cdnjs.cloudflare.com/ajax/libs/materialize/1.0.0/css/materialize.min.css"),
    tags$link(rel= "stylesheets", type="text/css", href = "https://fonts.googleapis.com/icon?family=Material+Icons"),
    tags$script(src="https://cdnjs.cloudflare.com/ajax/libs/materialize/1.0.0/js/materialize.min.js"),
    tags$link(rel="icon", href="iconoBM.png", type="image/x-icon"),
    tags$script(src="nouislider.js"),
    tags$script(src="index.js"),
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

  # Define tabs
  material_tabs(
    tabs = c(
      "Inicio" = "inicio",
      "Análisis" = "analisis"
    )
  ),
  # Define tab content
  material_tab_content(
    tab_id = "inicio",
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
            id= "cardSearch",
            #SELECT MODALIDAD BÚSQUEDA
            tags$div(
              class = "input-field",
              tags$div(
                class = "form-group shiny-input-container",
                tags$select(
                  id="select_search",
                  tags$option("Búsqueda por artículo", value = "article", selected="selected"),
                  tags$option("Búsqueda por autor", value = "author"),
                  tags$option("Búsqueda por revista", value = "journal")
                ),
                tags$label("Selecciona opción de búsqueda")
              )
            ),



            #SELECT DE API

            material_dropdown(
              input_id = "selectApi",
              choices= c(
                "WOS" = "wos",
                "Google Scholar" = "scholar",
                "Scopus" = "scopus"
              ),
              multiple = TRUE,
              label="Selecciona base de datos:"
            ),

            #BUSCADOR TEXTO
            tags$div(
              class = "input-field",
              tags$div(
                class = "form-group shiny-input-container",
                tags$i(class="material-icons prefix small-icon", "search"),
                tags$input(type = "text", id = "searchText", placeholder="Introduce lo que quieres buscar")

              )



            ),

            material_button(
              input_id = "search_button",
              icon = "search",
              depth = 5,
              label="Buscar"
            )




          )
        ),
        tags$div(
          class="card z-depth-4",
          id="cardFilter",
          tags$div(
            class="card-content",
            #MÁXIMO ÍNDICE H
            tags$div(
              id="maxH",
              class="input-field",
              tags$div(
                class="form-group shiny-input-container",
                tags$label("Máximo ÍNDICE H"),
                tags$p(
                  class="range-fields",
                  tags$div(
                    id="slider-indiceH"
                  )
                )
              )
            ),



            #NÚMERO DE CITAS
            tags$div(
              class="input-field",
              tags$div(
                class="form-group shiny-input-container",
                tags$label(class="divRange","Número de citas"),
                tags$p(
                  class="range-fields",
                  tags$div(
                    id="slider-citas"
                  )
                )

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
            #INDICE H PROMEDIO
            tags$div(
              class="input-field",
              tags$div(
                class="form-group shiny-input-container",
                tags$label("Índice H promedio"),
                tags$p(
                  class="range-fields",
                  tags$div(
                    id="slider-indiceHProm"
                  )
                )
              )
            ),
            #CITAS TOTALES
            tags$div(
              class="input-field",
              tags$div(
                class="form-group shiny-input-container",
                tags$label(class="divRange","Citas totales"),
                tags$p(
                  class="range-fields",
                  tags$div(
                    id="slider-citasTotales"
                  )
                )
              )
            ),
            #ELECCIÓN PAÍS DEL AUTOR
            tags$div(
              class="input-field",
              tags$div(
                class="form-group shiny-input-container",
                selectInput("paises_seleccionados", "Selecciona país(es):", choices = paises, multiple = TRUE)
              )
            )
          )

        )
      ),


      tags$div(
        class = "col s12 m9",
        material_card(
          tags$span(
            class="card-title center-align",
            "Datos obtenidos"
          ),

          tags$a(
            class="waves-effect waves-light btn modal-trigger",
            href="#modalExport",
            "Exportar datos",
            tags$i(
              class="material-icons line",
              "ios_share"
            )
          ),
          tags$div(
            id="modalExport",
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


          ),

          DTOutput("resultados")

        )
      )




    ),
    tags$script("  document.addEventListener('DOMContentLoaded', function() {
            var sliderIndiceH = document.getElementById('slider-indiceH');
            var sliderPromedioH = document.getElementById('slider-indiceHProm');
            var sliderCitas = document.getElementById('slider-citas');
            var sliderCitasTotales = document.getElementById('slider-citasTotales');


            noUiSlider.create(sliderIndiceH, {
                start: [0, 100], // Valores iniciales del rango
                connect: true, // Conexión entre los dos valores
                step:1,
                orientation: 'horizontal',
                range: {
                    'min': 0, // Valor mínimo del rango
                    'max': 100 // Valor máximo del rango
                },
                format: wNumb({
                  decimals:0
                })
            });

            noUiSlider.create(sliderPromedioH, {
                start: [0, 100], // Valores iniciales del rango
                connect: true, // Conexión entre los dos valores
                step:1,
                orientation: 'horizontal',
                range: {
                    'min': 0, // Valor mínimo del rango
                    'max': 100 // Valor máximo del rango
                },
                format: wNumb({
                  decimals:0
                })
            });

            noUiSlider.create(sliderCitas, {
                start: [0, 100], // Valores iniciales del rango
                connect: true, // Conexión entre los dos valores
                step:1,
                orientation: 'horizontal',
                range: {
                    'min': 0, // Valor mínimo del rango
                    'max': 100 // Valor máximo del rango
                },
                format: wNumb({
                  decimals:0
                })
            });

            noUiSlider.create(sliderCitasTotales, {
                start: [0, 100], // Valores iniciales del rango
                connect: true, // Conexión entre los dos valores
                step:1,
                orientation: 'horizontal',
                range: {
                    'min': 0, // Valor mínimo del rango
                    'max': 100 // Valor máximo del rango
                },
                format: wNumb({
                  decimals:0
                })
            });

        });


")

  ),
  material_tab_content(
    tab_id = "analisis",
    tags$div(
      class = "col s12",
      material_card(
        h1("AQUÍ MANDA MI PENE")
    )
  )


)
)
