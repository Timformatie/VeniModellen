#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {

  output$sankey_1 <- renderHighchart({
    plot <- create_sankey(dt_sankey_1)
    return(plot)
  })

  output$sankey_2 <- renderHighchart({
    plot <- create_sankey(dt_sankey_2)
    return(plot)
  })



}
