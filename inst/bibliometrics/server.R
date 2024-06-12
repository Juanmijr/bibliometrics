library(DT)
server <- function(input, output, session) {
  # Ejemplo de datos
  df <- data.frame(
    Nombre = c("Alice", "Bob", "Charlie", "David", "Eve"),
    stringsAsFactors = FALSE
  )

  # Generar botones

  generateButton <- function(FUN, len, id, ...) {
    buttons <- character(len)
    for (i in seq_len(len)) {
      buttons[i] <- as.character(FUN(paste0(id, i), ...))
    }
    buttons
  }

  df$Actions <- generateButton(actionButton, nrow(df), 'button_', label = "Análisis", onclick = 'Shiny.onInputChange(\"select_button\", this.id)')

  # Renderizar la tabla con botones y botón de exportación
  output$resultados <- renderDT({
    datatable(
      df,
      select='none',
      escape = FALSE,
      options = list(
        pageLength = 5,
        options = list(
          initComplete = JS(
            "function(settings, json) {",
            "$(this.api().table().header()).css({'background-color': '#f0faf9', 'color': '#fff'});",
            "}")
        )
      ),
      callback = JS(
        "table.on('click', '.action-button', function() {
        var data = table.row($(this).parents('tr')).data();
        console.log(data);

      });"
      ))
  })

  # Manejar eventos de los botones
  observeEvent(input$select_button, {
    selectedButton <- input$select_button
    rowData <- input$row_data

    material_modal(
      modal_id = "example_modal",
      button_text = "Modal",
      button_icon = "open_in_browser",
      title = "Showcase Modal Title",
      tags$p("Modal Content")
    )

  })


}
