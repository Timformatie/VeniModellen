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
                           list(id = "therapie", color = "lightgrey"),
                           list(id = "operatie", color = "lightgrey"),
                           list(id = "doel behaald <br> na operatie", color = "green"),
                           list(id = "doel niet behaald <br> na operatie", color = "red")
              ),
              nodeWidth = 170
  ) %>%
    hc_plotOptions(series = list(dataLabels = list(style =list(fontSize = "15px",
                                                               color = "black"
                                                               ),
                                                   padding = 25))) %>%
    hc_tooltip(pointFormat = "<b>Percentage</b> {point.weight}%")

  return(sankey_plot)

}
