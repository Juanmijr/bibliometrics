library(DT)
library(shinyjs)
library(stringr)
library(shiny)
library(plotly)
library(rmarkdown)
library(knitr)
library(writexl)


server <- function(input, output, session) {
  busqueda <- reactiveVal(NA)
  df <- reactiveVal(data.frame())


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
      runjs(
        '$("#selectApi option[value=\'scholar\']").attr("disabled", "disabled");
      $("#selectApi option[value=\'wos\']").attr("disabled","disabled");
               $("#selectApi").formSelect(); '
      )
    } else if (selected_option == "author") {
      runjs(
        '$("#selectApi option[value=\'scholar\']").removeAttr("disabled");
      $("#selectApi option[value=\'wos\']").attr("disabled","disabled");
               $("#selectApi").formSelect(); '
      )
    }
    else{
      runjs(
        '$("#selectApi option[value=\'scholar\']").attr("disabled", "disabled");
      $("#selectApi option[value=\'wos\']").attr("disabled","disabled");
            $("#selectApi").formSelect(); '
      )

    }
  })


  observe({
    if (nchar(input$searchText) > 1 && !is.null(input$selectApi)) {
      runjs("$('#search_button').prop('disabled', false);")
    } else {
      runjs("$('#search_button').prop('disabled', true);")
    }
  })

  create_slider_ui <- function(id, label, min_val, max_val) {
    tags$div(
      class = "input-field",
      id=paste("slider",id,sep = "-"),
      tags$div(
        class = "form-group shiny-input-container",
        tags$label(class = "divRange", label),
        tags$p(class = "range-fields", tags$div(id = id))
      ),
      tags$script(HTML(sprintf("
      $(document).ready(function() {
        var id = '%s';
        var min = %f;
        var max = %f;

        var %s = document.getElementById(id);
        var step =  (max - min) > 10000 ? 1000: 1;


        if (%s) {
          noUiSlider.create(%s, {
            start: [min, max],
            connect: true,
            step: step,
            orientation: 'horizontal',
            range: {
              'min': min,
              'max': max
            },
            format: wNumb({
              decimals: 0
            })
          });

          %s.noUiSlider.on('update', function(values) {
              var roundedValues = values.map(function(value) {
          return Math.round(parseFloat(value));
        });
            Shiny.setInputValue(id, roundedValues);
          });
        }
      });
    ", id,min_val, max_val,id, id, id, id)))
    )
  }

  create_select_ui <- function(id, label, choices) {
    tags$div(
      class = "input-field",
      id=paste("select",id,sep = "-"),
      tags$div(
        class = "form-group shiny-input-container",
        selectInput(
          inputId = id,
          label = label,
          choices = choices,
          multiple = TRUE
        )
      )
    )
  }




  observeEvent(input$search_button, {


    search_query <- input$searchText
    selected_option <- input$select_search
    selected_api <- input$selectApi


      all_names <- c("wos", "scopus", "scholar")
      selected_api <- setNames(all_names %in% selected_api, all_names)

      runjs("$('#loader').fadeIn();")


      df_switch <- switch(selected_option,
                          "article" = bibliometrics::getArticle(selected_api, search_query),
                          "author" = bibliometrics::getAuthor(selected_api, search_query),
                          "source" = bibliometrics::getSource(selected_api, search_query)
      )


      df_switch <-  df_switch[, colSums(is.na(df_switch)) != nrow(df_switch)]

      df(df_switch)
      busqueda(selected_option)


      observe({
        filtered_data <- df()


        removeUI("slider-sliderNumDocumentos")
        removeUI("slider-sliderCitesNum")
        removeUI("select-selectYear")
        removeUI("select-selectDOI")
        removeUI("select-selectAuthor")
        removeUI("select-selectBD")


      if (!'error' %in% names(filtered_data)){
        if (nrow(filtered_data) > 0) {
          if ('Año' %in% names(filtered_data) && !all(is.null(filtered_data$Año))){
            output$year <- renderUI({
              create_select_ui("selectYear", "Año:", filtered_data$Año)
            })
          } else {
            output$year <- renderUI({ NULL })
          }

          if ('DOI' %in% names(filtered_data) && !all(is.null(filtered_data$DOI))){
            output$doi <- renderUI({
              create_select_ui("selectDOI", "DOI:", filtered_data$DOI)
            })
          } else {
            output$doi <- renderUI({ NULL })
          }

          if ('Autor' %in% names(filtered_data) && !all(is.null(filtered_data$Autor))){
            output$author <- renderUI({
              create_select_ui("selectAuthor", "Autor:", filtered_data$Autor)
            })
          } else {
            output$author <- renderUI({ NULL })
          }

          if ('Citas' %in% names(filtered_data) && !all(is.na(filtered_data$Citas))) {
            min_cites <- min(filtered_data$Citas, na.rm = TRUE)
            max_cites <- max(filtered_data$Citas, na.rm = TRUE)
            output$citationNum <- renderUI({
              create_slider_ui("sliderCitesNum", "Número de citas:", min_cites, max_cites)
            })
          } else {
            output$citationNum <- renderUI({ NULL })
          }

          if ('BD' %in% names(filtered_data)){
            output$bd <- renderUI({
              create_select_ui("selectBD", "Base de datos:", filtered_data$BD)
            })
          } else {
            output$bd <- renderUI({ NULL })
          }

          if ('NumDocumentos' %in% names(filtered_data) && !all(is.na(filtered_data$NumDocumentos))) {
            min_docs <- min(filtered_data$NumDocumentos, na.rm = TRUE)
            max_docs <- max(filtered_data$NumDocumentos, na.rm = TRUE)
            output$documentNum <- renderUI({
              create_slider_ui("sliderDocsNum", "Número de documentos:", min_docs, max_docs)
            })
          } else {
            output$documentNum <- renderUI({ NULL })
          }

          filtered_data$Botón <- sprintf("<a name='buttonAnalize' id='buttonAnalize_%d' class='analize waves-effect waves-light btn ' data-row='%d'>Análisis</a>", seq_len(nrow(filtered_data)), seq_len(nrow(filtered_data)))
          output$resultados <- renderDT({
            datatable(
              filtered_data,
              selection = "none",
              escape = FALSE,
              options = list(
                pageLength = 5,
                scrollX = TRUE,
                autoWidth = TRUE
              ),
              callback = JS("
              table.on('click', '.analize', function() {
                var data = table.row($(this).parents('tr')).data();
                var rowData = {};
                table.columns().every(function() {
                  var colIdx = this.index();
                  var colTitle = table.column(colIdx).header().innerText.trim();
                  rowData[colTitle] = data[colIdx];
                });
                Shiny.setInputValue('button_clicked', rowData);
              });
            ")
            )
          })

          runjs("$('#cardFilter').show(); $('#resultados').show(); $('#instrucciones').hide(); $('#errorResultados').hide();")
        } else {
          runjs("$('#cardFilter').hide(); $('#resultados').hide(); $('#instrucciones').show(); $('#errorResultados').hide();")
        }


      }
        else{
          runjs("$('#cardFilter').hide(); $('#resultados').hide(); $('#instrucciones').hide(); $('#errorResultados').show();")

        }



        runjs("$('#loader').fadeOut();")
      })

  })



  filtered_data <- reactive({

    if (nrow(df()) > 0) {

      filtered <- df()

      # Filtrado por año
      if (!is.null(input$selectYear) && "Año" %in% colnames(filtered)) {
        filtered <- filtered[is.na(filtered$Año) | filtered$Año %in% input$selectYear, ]
      }

      # Filtrado por DOI
      if (!is.null(input$selectDOI) && "DOI" %in% colnames(filtered)) {
        filtered <- filtered[is.na(filtered$DOI) | filtered$DOI %in% input$selectDOI, ]
      }

      # Filtrado por autor
      if (!is.null(input$selectAuthor) && "Autor" %in% colnames(filtered)) {
        filtered <- filtered[is.na(filtered$Autor) | filtered$Autor %in% input$selectAuthor, ]
      }

      # Filtrado por número de citas
      if (!is.null(input$sliderCitesNum) && "Citas" %in% colnames(filtered)) {
        filtered <- filtered[is.na(filtered$Citas) |
                               (filtered$Citas >= input$sliderCitesNum[1] & filtered$Citas <= input$sliderCitesNum[2]), ]
      }

      # Filtrado por número de documentos
      if (!is.null(input$sliderDocsNum) && "NumDocumentos" %in% colnames(filtered)) {
        filtered <- filtered[is.na(filtered$NumDocumentos) |
                               (filtered$NumDocumentos >= input$sliderDocsNum[1] & filtered$NumDocumentos <= input$sliderDocsNum[2]), ]
      }

      # Filtrado por base de datos (BD)
      if (!is.null(input$selectBD) && "BD" %in% colnames(filtered)) {
        filtered <- filtered[is.na(filtered$BD) | filtered$BD %in% input$selectBD, ]
      }

      # Agrega una columna para el botón de análisis
      filtered$Botón <- sprintf(
        "<a name='buttonAnalize' id='buttonAnalize_%d' class='analize waves-effect waves-light btn' data-row='%d'>Análisis</a>",
        seq_len(nrow(filtered)), seq_len(nrow(filtered))
      )

      return(filtered)
    } else {
      return(NULL)
    }

  })



  observe({


      output$resultados <- renderDT({
      datatable(
        filtered_data(),
        selection = "none",
        escape = FALSE,
        options = list(
          pageLength = 5,
          scrollX = TRUE,
          autoWidth = TRUE
        ),
        callback = JS("
            table.on('click', '.analize', function() {
                var data = table.row($(this).parents('tr')).data();
                var rowData = {};
                table.columns().every(function() {
                    var colIdx = this.index();
                    var colTitle = table.column(colIdx).header().innerText.trim();
                    rowData[colTitle] = data[colIdx];
                });
                Shiny.setInputValue('button_clicked', rowData);
            });
        ")
      )
    })



      if(!is.null(filtered_data())){
        if (nrow(filtered_data()) > 0) {
          runjs("$('#cardFilter').show(); $('#resultados').show(); $('#instrucciones').hide(); $('#errorResultados').hide();")
        } else {

          runjs("$('#cardFilter').show(); $('#resultados').hide(); $('#instrucciones').hide(); $('#errorResultados').show();")
        }
      }
      else{
        runjs("$('#cardFilter').hide(); $('#resultados').hide(); $('#instrucciones').show(); $('#errorResultados').hide();")

      }
  })







  output$downloadXLSX <- downloadHandler(





    filename = function() {
      "data.xlsx"
    },
    content = function(file) {
      filtered_without <- filtered_data()
      filtered_without <- filtered_without[, colSums(is.na(filtered_without)) != nrow(filtered_without)]
      filtered_without <- filtered_without[, !names(filtered_without) %in% "Botón"]
      write_xlsx(filtered_without, path = file)
    }
  )


  output$downloadPDF <- downloadHandler(



    filename = function() {
      "data.pdf"
    },
    content = function(file) {
      filtered_without <- filtered_data()
      filtered_without <- filtered_without[, colSums(is.na(filtered_without)) != nrow(filtered_without)]
      filtered_without <- filtered_without[, !names(filtered_without) %in% "Botón"]

      tempReport <- file.path(tempdir(), "report.Rmd")
      file.copy("template.Rmd", tempReport, overwrite = TRUE)

      params <- list(df = filtered_without)

      rmarkdown::render(
        tempReport,
        output_file = file,
        params = params,
        envir = new.env(parent = globalenv())
      )
    }
  )

  observeEvent(input$button_clicked, {
    runjs("$('#loader').fadeIn();")

    row <- input$button_clicked

    if (busqueda() == "author") {
      metrics <- bibliometrics::getMetricsAuthor(row$BD, row$ID)

      runjs("$('#loader').fadeOut();")
      runjs("$('#liTab2').show();")

      if (row$BD == "scholar") {
        nomCol <- names(metrics)

        output$analisis <- renderUI({
          material_card(
            title = paste("Análisis de", clean_text(row$Nombre), sep = " "),
            tags$div(
              class = "container",
              tags$div(
                class = "masonry row",
                style = "position: relative;",
                material_row(material_column(
                  width = 12,
                  material_card(
                    title = paste("Comparación de", metrics[1, 1]),
                    depth = 5,
                    plot_ly(
                      labels = c(nomCol[3], "Años anteriores"),
                      values = c(
                        metrics[1, 3],
                        as.numeric(metrics[1, 2]) - as.numeric(metrics[1, 3])
                      ),
                      name = paste("Comparación de", metrics[1, 1]),
                      type = "pie",
                      textinfo = 'label',
                      textposition = 'inside'
                    )
                  )
                )),
                material_row(
                  material_column(
                    width = 6,
                    material_card(
                      title = paste("Comparación de", metrics[2, 1]),
                      depth = 5,
                      plot_ly(
                        x = c(nomCol[2], nomCol[3]),
                        y = c(as.numeric(metrics[2, 2]), as.numeric(metrics[2, 3])),
                        type = "bar"
                      )
                    )
                  ),
                  material_column(
                    width = 6,
                    material_card(
                      title = paste("Comparación de", metrics[3, 1]),
                      depth = 5,
                      plot_ly(
                        x = c(nomCol[2], nomCol[3]),
                        y = c(as.numeric(metrics[3, 2]), as.numeric(metrics[3, 3])),
                        type = "bar"
                      )
                    )
                  )
                )
              )
            )
          )
        })

      } else if (row$BD == "scopus") {
        output$analisis <- renderUI({
          material_card(
            title = paste(
              "Análisis de",
              metrics$Nombre,
              "-ORCID:",
              metrics$Orcid
            ),
            tags$div(
              class = "container",
              tags$div(
                class = "masonry row",
                style = "position: relative;",
                material_row(
                  material_column(
                    width = 4,
                    material_card(
                      style = "height: 220px;",
                      title = "Número documentos totales",
                      depth = 5,
                      tags$div(style = "text-align: center;", tags$h3(metrics$'NumDocs'))
                    )
                  ),
                  material_column(
                    width = 4,
                    material_card(
                      style = "height: 220px;",
                      title = "Número citas totales",
                      depth = 5,
                      tags$div(style = "text-align: center;", tags$h3(metrics$'NumCitas'))
                    )
                  ),
                  material_column(
                    width = 4,
                    material_card(
                      style = "height: 220px;",
                      title = "Número documentos citados",
                      depth = 5,
                      tags$div(style = "text-align: center;", tags$h3(metrics$'NumDocsCitados'))
                    )
                  )
                ),
                material_row(
                  material_column(
                    width = 6,
                    material_card(
                      style = "height: 220px;",
                      title = "Índice H",
                      depth = 5,
                      tags$div(style = "text-align: center;", tags$h3(metrics$'indiceh'))
                    )
                  ),
                  material_column(
                    width = 6,
                    material_card(
                      style = "height: 220px;",
                      title = "Número veces que es co-autor",
                      depth = 5,
                      tags$div(style = "text-align: center;", tags$h3(metrics$'numCoAutor'))
                    )
                  )
                )
              )
            )
          )
        })

      }
    } else if (busqueda() == "article") {
      if (row$BD == "wos") {
        # No hay código para esta condición
      } else if (row$BD == "scopus") {
        metrics <- bibliometrics::getMetricsScopus(row$ID)

        runjs("$('#loader').fadeOut();")
        runjs("$('#liTab2').show();")

        # Comprobar si todas las métricas relevantes son NULL
        if (is.null(metrics[["scopus_metrics"]][["citations_in_scopus"]]) &&
            is.null(metrics[["scopus_metrics"]][["percentile"]]) &&
            is.null(metrics[["scopus_metrics"]][["field_weighted_citation_impact"]]) &&
            is.null(metrics[["views_count"]][["total_views"]]) &&
            is.null(metrics[["views_count"]][["years"]]) &&
            is.null(metrics[["plumx_metrics"]][["mentions"]][["news_mentions"]]) &&
            is.null(metrics[["plumx_metrics"]][["mentions"]][["blog_mentions"]]) &&
            is.null(metrics[["plumx_metrics"]][["mentions"]][["references"]])) {

          # Si todas las métricas son NULL, mostrar un mensaje de error
          output$analisis <- renderUI({
            div(
            id = "errorAnalisis",
            div(
              class = "error-message",
              strong("ERROR"),
              "NO SE PUEDEN OBTENER DATOS PARA ANALIZAR"
            )
          )
          })
        } else {
          # Continuar con el análisis y renderizado si al menos una métrica no es NULL

          visit_all <- as.numeric(ifelse(is.null(metrics[["plumx_metrics"]][["captures"]][["readers"]]), 0, metrics[["plumx_metrics"]][["captures"]][["readers"]]))
          visit_actually <- as.numeric(ifelse(is.null(metrics[["views_count"]][["total_views"]]), 0, metrics[["views_count"]][["total_views"]]))
          visit_rest <- visit_all - visit_actually

          labelsVisit <- c(
            paste("Visitas desde", str_extract(metrics[["views_count"]][["years"]], "\\d{4}-\\d{4}")),
            "Visitas anteriores"
          )
          valorsVisit <- c(visit_actually, visit_rest)

          output$analisis <- renderUI({
            conditional_cards <- if (all(!is.na(valorsVisit))) {
              tagList(
                material_column(
                  width = 6,
                  material_card(
                    title = "Análisis de visitas:",
                    depth = 5,
                    plot_ly(
                      labels = labelsVisit,
                      values = valorsVisit,
                      type = "pie"
                    )
                  )
                ),
                material_column(
                  width = 6,
                  material_card(
                    title = "Otros datos del artículo:",
                    depth = 5,
                    plot_ly(
                      x = c(
                        "News Mentions",
                        "Blog Mentions",
                        "References"
                      ),
                      y = c(
                        as.numeric(ifelse(is.null(metrics[["plumx_metrics"]][["mentions"]][["news_mentions"]]), 0, metrics[["plumx_metrics"]][["mentions"]][["news_mentions"]])),
                        as.numeric(ifelse(is.null(metrics[["plumx_metrics"]][["mentions"]][["blog_mentions"]]), 0, metrics[["plumx_metrics"]][["mentions"]][["blog_mentions"]])),
                        as.numeric(ifelse(is.null(metrics[["plumx_metrics"]][["mentions"]][["references"]]), 0, metrics[["plumx_metrics"]][["mentions"]][["references"]]))
                      ),
                      type = "bar"
                    )
                  )
                )
              )
            }

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
                        tags$p(paste(
                          "Número de percentil: ",
                          gsub("th", "º", metrics[["scopus_metrics"]][["percentile"]]),
                          sep = " "
                        )),
                        tags$div(style = "text-align: center;", tags$h3(metrics[["scopus_metrics"]][["citations_in_scopus"]]))
                      )
                    ),
                    material_column(
                      width = 4,
                      material_card(
                        title = "Número de visitas",
                        depth = 5,
                        tags$p(
                          gsub("Views count", "Desde", metrics[["views_count"]][["years"]])
                        ),
                        tags$div(style = "text-align: center;", tags$h3(metrics[["views_count"]][["total_views"]]))
                      )
                    ),
                    material_column(
                      width = 4,
                      material_card(
                        title = "Índice Feild Weight Citation Impact (FWCI)",
                        depth = 5,
                        tags$div(style = "text-align: center;", tags$h3(metrics[["scopus_metrics"]][["field_weighted_citation_impact"]]))
                      )
                    )
                  ),
                  material_row(conditional_cards)
                )
              )
            )
          })
        }
      }
    } else {
      metrics <- bibliometrics::getMetricsSource(row$BD, row$ID, row$Titulo)

      runjs("$('#loader').fadeOut();")
      runjs("$('#liTab2').show();")

      if (row$BD == "scopus") {
        yearly_data_long <- data.frame(
          year = rep(metrics[[4]]$ano, times = 5),
          metric = rep(
            c(
              "numDocsAno",
              "numCitasAno",
              "numDocsNoCitados",
              "porcentajeDocsNoCitados",
              "porcentajesArtRevision"
            ),
            each = nrow(metrics[[4]])
          ),
          value = c(
            metrics[[4]]$numDocsAno,
            metrics[[4]]$numCitasAno,
            metrics[[4]]$numDocsNoCitados,
            metrics[[4]]$porcentajeDocsNoCitados,
            metrics[[4]]$porcentajesArtRevision
          )
        )

        output$analisis <- renderUI({
          conditional_row <- if (!is.null(metrics[[3]])) {
            material_row(
              material_column(
                width = 6,
                material_card(
                  style = "height: 220px;",
                  title = "SNIP",
                  depth = 5,
                  tags$p(paste("Año:  ", metrics[[3]][["year"]][1])),
                  tags$div(style = "text-align: center;", tags$h3(metrics[[3]][["total"]][1]))
                )
              ),
              material_column(
                width = 6,
                material_card(
                  style = "height: 220px;",
                  title = "SJR",
                  depth = 5,
                  tags$p(paste("Año:  ", metrics[[3]][["year"]][2])),
                  tags$div(style = "text-align: center;", tags$h3(metrics[[3]][["total"]][2]))
                )
              )
            )
          } else {
            NULL
          }

          material_card(
            title = paste("Análisis de", metrics[[1]][["Titulo"]], "(", metrics[[1]][["ISSN"]], ")"),
            tags$div(
              class = "container",
              tags$div(
                class = "masonry row",
                style = "position: relative;",
                material_row(
                  material_column(
                    width = 8,
                    material_card(
                      style = "height: 220px; text-align: center;",
                      title = "Editorial",
                      depth = 5,
                      tags$div(
                        tags$h3(
                        ifelse(is.na(metrics[[1]][["Editorial"]]),
                          "No aparece en base de datos",
                          metrics[[1]][["Editorial"]])
                        )
                      )
                    )
                  ),
                  material_column(
                    width = 4,
                    material_card(
                      style = "height: 220px;",
                      title = "Año de fundación",
                      depth = 5,
                      tags$div(style = "text-align: center;", tags$h3(metrics[[1]][["AnoInicio"]]))
                    )
                  )
                ),
                conditional_row,
                material_row(material_column(
                  width = 12,
                  material_card(
                    title = "Otros datos del artículo:",
                    depth = 5,
                    plot_ly(
                      yearly_data_long,
                      x = ~ year,
                      y = ~ value,
                      color = ~ metric,
                      type = 'scatter',
                      mode = 'lines'
                    ) %>%
                      layout(
                        title = "Tendencias Anuales",
                        xaxis = list(title = "Año"),
                        yaxis = list(title = "Valor"),
                        legend = list(title = list(text = "Métricas"))
                      ) %>%
                      style(line = list(width = 2))
                  )
                ))
              )
            )
          )
        })

      }
    }
  })


}
