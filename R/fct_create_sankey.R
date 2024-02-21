#' create_sankey
#'
#' @description This function creates a Sankey plot.
#'
#' @param data the dataframe needed to create the Sankey plot
#' @param language language selected by user
#'
#' @return A Sankey plot.
#'
#' @noRd
#'
#' @import highcharter
#' @import dplyr
create_sankey <- function(data, language) {

  from_values <- if (language == "nl") from_therapie_nl else from_therapie_en
  to_values <- if (language == "nl") to_therapie_nl else to_therapie_en

  sankey_plot <- hchart(data,
              type = "sankey",
              hcaes(from = from, to = to, weight = weight),
              name = "Basic Sankey Diagram",
              nodes = list(list(id = to_values[1], color = "green"),
                           list(id = to_values[2], color = "red"),
                           list(id = from_values[1], color = "dimgray"),
                           list(id = to_values[3], color = "dimgray"),
                           list(id = to_values[4], color = "dimgray"),
                           list(id = to_values[5], color = "green"),
                           list(id = to_values[6], color = "red")
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
