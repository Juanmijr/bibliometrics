library(DT)
library(shinyjs)
library(stringr)
library(shiny)
library(bibliometrics)
library(plotly)
library(stringr)
library(xml2)



server <- function(input, output, session) {

  busqueda <- reactiveVal(NA)


  clean_text <- function(text) {
    text <- str_replace_all(text, "[^[:alnum:][:punct:] ]", "")
    text <- str_trim(text)

    return(text)
  }

  runjs("$('#liTab2').hide();")

  observe({
    runjs('$("#selectApi").val([])')
    selected_option <- input$'select_search'
    if (selected_option == "article") {
      runjs('$("#selectApi option[value=\'scholar\']").attr("disabled", "disabled");
      $("#selectApi option[value=\'wos\']").removeAttr("disabled");
               $("#selectApi").formSelect(); ')
    } else if (selected_option == "author"){
      runjs('$("#selectApi option[value=\'scholar\']").removeAttr("disabled");
      $("#selectApi option[value=\'wos\']").attr("disabled","disabled");
               $("#selectApi").formSelect(); ')
    }
    else{
      runjs('$("#selectApi option[value=\'scholar\']").attr("disabled", "disabled");
      $("#selectApi option[value=\'wos\']").attr("disabled","disabled");
            $("#selectApi").formSelect(); ')

    }
  })


  observe({
    if (nchar(input$searchText) > 0) {
      runjs("$('#search_button').prop('disabled',false);")
    } else {
      runjs("$('#search_button').prop('disabled',true);")
    }
  })

  observeEvent(input$search_button, {
    search_result <- data.frame()
    df <- data.frame()
    search_query <- input$searchText


    selected_option <- input$'select_search'


    selected_api <- input$selectApi

    if (!is.null(selected_api)) {
      all_names <- c("wos", "scopus", "scholar")
      output_vector <- rep(FALSE, length(all_names))
      output_vector[all_names %in% selected_api] <- TRUE
      selected_api <- setNames(output_vector, all_names)


      if (selected_option == "article"){
        df <- bibliometrics::getArticle(selected_api, search_query)
        busqueda("article")


      }
      else if(selected_option=="author"){
        df <- bibliometrics::getAuthor(selected_api,search_query)
        busqueda("author")
      }




      is_all_na <- function(column) {
        all(is.na(column))
      }


      search_result <- df[, !sapply(df, is_all_na)]



      # Renderizar la tabla con botones y botón de exportación
      search_result$Botón <- sprintf("<a name='buttonAnalize' id='buttonAnalize_%d' class='analize waves-effect waves-light btn ' data-row='%d'>Análisis</a>", seq_len(nrow(df)), seq_len(nrow(df)))
      output$resultados <- renderDT(
        {
          datatable(
            search_result,
            selection = "none",
            escape = FALSE,
            options = list(
              pageLength = 5,
              scrollX = TRUE,
              autoWidth = TRUE
            ),
            callback = JS(
              "
              table.on('click', '.analize',function(){
                var data = table.row($(this).parents('tr')).data();
                var rowData = {};

                table.columns().every(function() {
                  var colIdx = this.index();
                  var colTitle = table.column(colIdx).header().innerText.trim(); // Obtiene el nombre del encabezado de la columna
                  rowData[colTitle] = data[colIdx]; // Asigna el valor de la columna al objeto rowData usando el nombre del encabezado
                });

                Shiny.setInputValue('button_clicked', rowData);
              });"
            ),
          )
        },
        width = "100%",
        server = FALSE
      )
    }







    if (nrow(search_result) > 0) {
      runjs("$('#cardFilter').show();")
      runjs("$('#resultados').show();")
      runjs("$('#instrucciones').hide();")
    } else {
      runjs("$('#cardFilter').hide();")
      runjs("$('#resultados').hide();")
      runjs("$('#instrucciones').show();")
    }
  })







  observeEvent(input$button_clicked, {

    runjs("$('#loader').fadeIn();")

    row <- input$button_clicked

    print(busqueda())
    print(row$BBDD)

    if(busqueda() == "author"){
      if (row$BBDD=="scholar"){

      }
      else if(row$BBDD=="scopus"){

      }
    }
    else if (busqueda() == "article"){
      if (row$BBDD=="wos"){

      }
      else if (row$BBDD=="scopus"){
        metrics <-  bibliometrics::getMetricsScopus(row$ID)

        runjs("$('#loader').fadeOut();")

        runjs("$('#liTab2').show();")


        visit_all <- as.numeric(metrics$'plumx_metrics'[[2]][1])

        visit_actually<- as.numeric(metrics$'views_count'[[2]][1])

        visit_rest <- visit_all - visit_actually

        labelsVisit <- c(paste("Visitas desde ", str_extract(metrics$'views_count'[[2]][2], "\\d{4}-\\d{4}")), "Visitas anteriores")
        valorsVisit <- c(visit_actually,visit_rest)



        output$analisis <- renderUI({
          # Crear elementos condicionales
          conditional_cards <- if (valorsVisit[1] > 0 && valorsVisit[2] > 0) {
            tagList(
              material_column(
                width = 6,
                material_card(
                  title = "Análisis de visitas:",
                  depth = 5,
                  plot_ly(labels = labelsVisit, values = valorsVisit, type = "pie")
                )
              ),
              material_column(
                width = 6,
                material_card(
                  title = "Otros datos del artículo:",
                  depth = 5,
                  plot_ly(
                    y = c(metrics$'plumx_metrics'[[2]][2], metrics$'plumx_metrics'[[2]][3], metrics$'plumx_metrics'[[2]][4]),
                    x = c(metrics$'plumx_metrics'[[1]][2], metrics$'plumx_metrics'[[1]][3], metrics$'plumx_metrics'[[1]][4]),
                    name = "PlumX Metrics",
                    type = "bar"
                  )
                )
              )
            )
          } else {
            material_column(
              width = 12,
              material_card(
                title = "Otros datos del artículo:",
                depth = 5,
                plot_ly(
                  y = c(metrics$'plumx_metrics'[[2]][2], metrics$'plumx_metrics'[[2]][3], metrics$'plumx_metrics'[[2]][4]),
                  x = c(metrics$'plumx_metrics'[[1]][2], metrics$'plumx_metrics'[[1]][3], metrics$'plumx_metrics'[[1]][4]),
                  name = "PlumX Metrics",
                  type = "bar"
                )
              )
            )
          }

          # Renderizar UI
          material_card(
            title = paste("Análisis de", clean_text(row$Titulo), sep = " "),
            tags$div(
              class = "container",
              tags$div(
                class = "masonry row",
                style = "position: relative;",
                material_row(
                  material_column(
                    width = 4,
                    material_card(
                      title = "Número de citaciones",
                      depth = 5,
                      tags$p(paste("Número de percentil: ", gsub("th", "º", metrics$'scopus_metrics'[[2]][2]), sep = " ")),
                      tags$div(style = "text-align: center;",
                               tags$h3(metrics$'scopus_metrics'[[2]][1])  # Example of a highlighted number or statistic
                      )
                    )
                  ),
                  material_column(
                    width = 4,
                    material_card(
                      title = "Número de visitas",
                      depth = 5,  # Adjust the shadow depth
                      tags$p(gsub("Views count", "Desde", metrics$'views_count'[[2]][2])),
                      tags$div(style = "text-align: center;",
                               tags$h3(metrics$'views_count'[[2]][1])  # Example of a highlighted number or statistic
                      )
                    )
                  ),
                  material_column(
                    width = 4,
                    material_card(
                      title = "Índice Feild Weight Citation Impact (FWCI)",
                      depth = 5,  # Adjust the shadow depth
                      tags$div(style = "text-align: center;",
                               tags$h3(metrics$'scopus_metrics'[[2]][3])  # Example of a highlighted number or statistic
                      )
                    )
                  )
                ),
                material_row(
                  conditional_cards
                )
              )
            )
          )
        })

      }
    }
    else{
      if (row$BBDD=="scopus"){

      }
    }


  })
}

