library(DT)
library(shinyjs)
library(stringr)
library(shiny)
library(bibliometrics)

server <- function(input, output, session) {



  runjs("$('#liTab2').hide();");


  observe({



    if (nchar(input$searchText) > 0) {
      runjs("$('#search_button').prop('disabled',false);");
    } else {
      runjs("$('#search_button').prop('disabled',true);");
    }
  })

  observeEvent(input$search_button,{
    search_result<-data.frame()
    df<-data.frame()
    search_query <-input$searchText




    selected <- input$selectApi

    if (!is.null(selected)) {
      print(selected)
      all_names <- c("wos", "scopus", "scholar")
      output_vector <- rep(FALSE, length(all_names))
      output_vector[all_names %in% selected] <- TRUE
      selected <- setNames(output_vector, all_names)

      df<-bibliometrics::getArticle(selected,search_query)


      is_all_na <- function(column) {
        all(is.na(column))
      }


      search_result <- df[, !sapply(df, is_all_na)]



        # Renderizar la tabla con botones y botón de exportación
      search_result$Botón<-sprintf("<a name='buttonAnalize' id='buttonAnalize_%d' class='analize waves-effect waves-light btn ' data-row='%d'>Análisis</a>",seq_len(nrow(df)), seq_len(nrow(df)))
        output$resultados <- renderDT({
          datatable(
            search_result,
            selection='none',
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
        }, width="100%", server=FALSE)


      }







    if (nrow(search_result)>0){
      runjs("$('#cardFilter').show();");
      runjs("$('#resultados').show();");
      runjs("$('#instrucciones').hide();");



    }
    else{
      runjs("$('#cardFilter').hide();");
      runjs("$('#resultados').hide();");
      runjs("$('#instrucciones').show();");



    }



  })




  observeEvent(input$button_clicked, {

    runjs("$('#liTab2').show();");


    row <- input$button_clicked


    output$datosAnalisis<- renderPrint({
      row
    })

    #update_material_side_nav(session, side_nav_tab_id = "cardAnalisis")


  })


}







