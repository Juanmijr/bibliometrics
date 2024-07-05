library(DT)
library(shinyjs)
library(stringr)
library(shiny)
library(bibliometrics)

server <- function(input, output, session) {




  observeEvent(input$search_button,{
    df<-data.frame()
    search_result<-data.frame()
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
              "$(document).on('click', '.analize', function(e){
                console.log('HE ENTRADO AQUÍ');
                Shiny.onInputChange('button_clicked', this.id);
        });"
            ),

          )
        }, width="100%", server=FALSE)


      }







    if (nrow(search_result)>0){
      runjs("$('#cardFilter').show();");

    }
    else{
      runjs("$('#cardFilter').hide();");

    }



  })




  observeEvent(input$button_clicked, {
    print("ENTRO EN EL OBSERVER")

    button_id <- input$button_clicked
    row_clicked <- as.numeric(sub("buttonAnalize_", "", button_id))  # Obtener la fila desde el ID del botón

  })


}







