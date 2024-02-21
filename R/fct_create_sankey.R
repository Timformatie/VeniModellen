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

  data = data[, sentence := case_when(
    from == "therapie" & to == "doel <br> behaald" ~ paste0(weight, "% van de mensen die therapie hebben gekregen, heeft daarna hun doel behaald."),
    from == "therapie" & to == "doel niet <br> behaald" ~ paste0(weight, "% van de mensen die therapie hebben gekregen, heeft daarna hun doel niet behaald."),
    from == "doel niet <br> behaald" & to == "operatie" ~ paste0(weight, "% van de mensen die hun doel niet behaald hebben, kiest daarna voor een operatie."),
    from == "doel niet <br> behaald" & to == "geen <br> operatie" ~ paste0(weight, "% van de mensen die hun doel niet behaald hebben, kiest daarna niet voor een operatie."),
    from == "operatie" & to == "doel <br> behaald " ~ paste0(weight, "% van de mensen die na therapie een operatie hebben gekregen, heeft daarna hun doel behaald."),
    from == "operatie" & to == "doel niet <br> behaald " ~ paste0(weight, "% van de mensen die na therapie een operatie hebben gekregen, heeft daarna hun doel niet behaald."),
    from == "operatie" & to == "doel <br> behaald" ~ paste0(weight, "% van de mensen die een operatie hebben gekregen, heeft daarna hun doel behaald."),
    from == "operatie" & to == "doel niet <br> behaald" ~ paste0(weight, "% van de mensen die een operatie hebben gekregen, heeft daarna hun doel niet behaald."),
    from == "nonsurgical <br> treatment" & to == "goal <br> obtained" ~ paste0(weight, "% of people who have received nonsurgical treatment, has obtained their goal."),
    from == "nonsurgical <br> treatment" & to == "goal not <br> obtained" ~ paste0(weight, "% of people who have received nonsurgical treatment, did not obtain their goal."),
    from == "goal not <br> obtained" & to == "surgical <br> treatment" ~ paste0(weight, "% of people who did not obtain their goal, subsequently choose surgery."),
    from == "goal not <br> obtained" & to == "no surgical <br> treatment" ~ paste0(weight, "% of people who did not obtain their goal, subsequently choose surgery."),
    from == "surgical <br> treatment" & to == "goal <br> obtained " ~ paste0(weight, "% of people who received surgery after nonsurgical treatment, has obtained their goal."),
    from == "surgical <br> treatment" & to == "goal not <br> obtained " ~ paste0(weight, "% people who received surgery after nonsurgical treatment, did not obtain their goal."),
    from == "surgical <br> treatment" & to == "goal <br> obtained" ~ paste0(weight, "% of people who have received surgical treatment, has obtained their goal."),
    from == "surgical <br> treatment" & to == "goal not <br> obtained" ~ paste0(weight, "% of people who have received surgical treatment, did not obtain their goal.")
  )]

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
              nodeWidth = 120,
              nodePadding = 15,
              linkColorMode = "gradient",
              dataLabels = list(nodeFormat = "{point.name}",
                                format = paste0('<span style = "letter-spacing: 0.15rem">', "{point.weight}%", '</span>'),
                                style = list(fontSize = "18px",
                                             color = "white"),
                                padding = 25)
              ) %>%
    hc_tooltip(headerFormat = "",
               pointFormat = paste0('<span style = "color: white; font-size: 16px">', "{point.sentence}", '</span>'),
               backgroundColor = "#4876b3",
               borderColor = "black")

#{point.fromNode.name} → {point.toNode.name}: <b>{point.weight}%</b><br/>

  return(sankey_plot)

}
