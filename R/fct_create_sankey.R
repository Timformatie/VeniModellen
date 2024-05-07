#' create_sankey
#'
#' @description This function creates a Sankey plot.
#'
#' @param data the dataframe needed to create the Sankey plot
#' @param language language selected by user
#' @param PMG calculated value for PMG
#'
#' @return A Sankey plot.
#'
#' @import highcharter
#' @import dplyr
#'
#' @noRd
create_sankey <- function(data, language, PMG) {

  # Add text that is shown when hovered over link
  data = data[, sentence := case_when(
    # 1. First Sankey (therapy and injection)
    # NL
    from == "therapie" & to == "doel <br> behaald" ~ paste0(weight, "% van de mensen die therapie hebben gekregen, heeft daarna hun doel behaald."),
    from == "therapie" & to == "doel niet <br> behaald" ~ paste0(weight, "% van de mensen die therapie hebben gekregen, heeft daarna hun doel niet behaald."),
    from == "doel niet <br> behaald" & to == "operatie" ~ paste0(label, "% van de mensen die hun doel niet behaald hebben, kiest daarna voor een operatie."),
    from == "doel niet <br> behaald" & to == "geen <br> operatie" ~ paste0(label, "% van de mensen die hun doel niet behaald hebben, kiest daarna niet voor een operatie."),
    from == "operatie" & to == "doel <br> behaald " ~ paste0(label, "% van de mensen die na therapie een operatie hebben gekregen, heeft daarna hun doel behaald."),
    from == "operatie" & to == "doel niet <br> behaald " ~ paste0(label, "% van de mensen die na therapie een operatie hebben gekregen, heeft daarna hun doel niet behaald."),
    # EN
    from == "nonsurgical <br> treatment" & to == "goal <br> obtained" ~ paste0(weight, "% of people who have received nonsurgical treatment, has obtained their goal."),
    from == "nonsurgical <br> treatment" & to == "goal not <br> obtained" ~ paste0(weight, "% of people who have received nonsurgical treatment, did not obtain their goal."),
    from == "goal not <br> obtained" & to == "surgical <br> treatment" ~ paste0(label, "% of people who did not obtain their goal, subsequently choose surgery."),
    from == "goal not <br> obtained" & to == "no surgical <br> treatment" ~ paste0(label, "% of people who did not obtain their goal, subsequently choose surgery."),
    from == "surgical <br> treatment" & to == "goal <br> obtained " ~ paste0(label, "% of people who received surgery after nonsurgical treatment, has obtained their goal."),
    from == "surgical <br> treatment" & to == "goal not <br> obtained " ~ paste0(label, "% people who received surgery after nonsurgical treatment, did not obtain their goal."),

    # 2. Second Sankey (only injection)
    # NL
    from == "injectie" & to == "doel <br> behaald" ~ paste0(weight, "% van de mensen die een injectie hebben gekregen, heeft daarna hun doel behaald."),
    from == "injectie" & to == "doel niet <br> behaald" ~ paste0(weight, "% van de mensen die een injectie hebben gekregen, heeft daarna hun doel niet behaald."),
    # EN
    from == "injection" & to == "goal <br> obtained" ~ paste0(weight, "% of people who have received an injection, has obtained their goal."),
    from == "injection" & to == "goal not <br> obtained" ~ paste0(weight, "% of people who have received an injection, did not obtain their goal."),

    # 3. Third Sankey (surgery)
    # NL
    from == "operatie" & to == "doel <br> behaald" ~ paste0(weight, "% van de mensen die een operatie hebben gekregen, heeft daarna hun doel behaald."),
    from == "operatie" & to == "doel niet <br> behaald" ~ paste0(weight, "% van de mensen die een operatie hebben gekregen, heeft daarna hun doel niet behaald."),
    # EN
    from == "surgical <br> treatment" & to == "goal <br> obtained" ~ paste0(weight, "% of people who have received surgical treatment, has obtained their goal."),
    from == "surgical <br> treatment" & to == "goal not <br> obtained" ~ paste0(weight, "% of people who have received surgical treatment, did not obtain their goal.")

  )]

  # Add context to text for patients (not) continuing with surgery after therapy
  n_patients <- dt_continue_surgery[variable == PMG, n]
  small_sample <- dt_continue_surgery[variable == PMG, small_sample]

  if (small_sample == 0) {
    data = data[(from == "doel niet <br> behaald" & to == "operatie") | (from == "doel niet <br> behaald" & to == "geen <br> operatie"),
                sentence := paste0(sentence, " Percentage gebaseerd op ", n_patients, " patienten die ook een PMG van ", PMG, " hadden.")]
    data = data[(from == "goal not <br> obtained" & to == "surgical <br> treatment") | (from == "goal not <br> obtained" & to == "no surgical <br> treatment"),
                sentence := paste0(sentence, " Percentage based on ", n_patients, " patients who also had a PMG of ", PMG)]
  } else if (small_sample == 1) {
    data = data[(from == "goal not <br> obtained" & to == "surgical <br> treatment") | (from == "goal not <br> obtained" & to == "no surgical <br> treatment"),
                sentence := paste0(sentence, " Percentage based on the total mean of all patients, because the sample size of patients with the same PMG is too small.")]
  }

  # Values displayed on nodes
  from_values <- if (language == "nl") from_therapie_nl else from_therapie_en
  to_values <- if (language == "nl") to_therapie_nl else to_therapie_en

  # Create sankey plot
  sankey_plot <- hchart(data,
              type = "sankey",
              hcaes(from = from, to = to, weight = weight),
              name = "Basic Sankey Diagram",
              nodes = list(list(id = from_values[1], color = color_list$grey),
                           list(id = "injectie", color = color_list$grey),
                           list(id = to_values[1], color = color_list$green),
                           list(id = to_values[2], color = color_list$red),
                           list(id = to_values[3], color = color_list$grey),
                           list(id = to_values[4], color = color_list$grey),
                           list(id = to_values[5], color = color_list$green),
                           list(id = to_values[6], color = color_list$red)
              ),
              colorByPoint = FALSE,
              color = c("#cbd4e4"),
              nodeWidth = 120,
              nodePadding = 60,
              linkColorMode = "gradient",
              dataLabels = list(nodeFormat = "{point.name}",
                                format = paste0('<span style = "letter-spacing: 0.15rem">', "{point.label}%", '</span>'),
                                style = list(fontSize = "18px",
                                             color = "black"),
                                allowOverlap = TRUE)
              ) %>%
    hc_tooltip(headerFormat = "",
               pointFormat = paste0('<span style = "color: white; font-size: 16px">', "{point.sentence}", "</span>"),
               backgroundColor = "#4876b3",
               borderColor = "black",
               nodeFormat = "{point.name}")


  return(sankey_plot)

}
