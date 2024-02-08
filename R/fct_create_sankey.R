#' create_sankey
#'
#' @description This function creates a Sankey plot.
#'
#' @param data the data needed to create the Sankey plot.
#'
#' @return A Sankey plot.
#'
#' @noRd
#'
#' @import highcharter
#' @import dplyr
create_sankey <- function(data) {

  sankey_plot <- hchart(data,
              type = "sankey",
              hcaes(from = from, to = to, weight = weight),
              name = "Basic Sankey Diagram",
              nodes = list(list(id = "doel behaald", color = "green"),
                           list(id = "doel niet behaald", color = "red"),
                           list(id = "therapie", color = "dimgray"),
                           list(id = "operatie", color = "dimgray"),
                           list(id = "geen operatie", color = "dimgray"),
                           list(id = "doel behaald <br> na operatie", color = "green"),
                           list(id = "doel niet behaald <br> na operatie", color = "red"),
                           list(id = "doel behaald ", color = "green"),
                           list(id = "doel niet behaald ", color = "red")
              ),
              colorByPoint = FALSE,
              color = c("#cbd4e4"),
              nodeWidth = 170,
              nodePadding = 15,
              linkColorMode = "gradient",
              dataLabels = list(nodeFormat = "{point.name}",
                                format = "{point.weight}%",
                                style = list(fontSize = "15px",
                                             color = "white"),
                                padding = 25)
              ) %>%
    hc_tooltip(pointFormat = "<b>Percentage</b> {point.weight}%")

  return(sankey_plot)

}
