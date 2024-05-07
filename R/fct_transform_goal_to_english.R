#' fct_transform_goal_to_english
#'
#' @description this function translates the user selected primary goal from Dutch to English
#'
#' @param goal goal which should be translated from Dutch to English
#'
#' @return primary goal translated to English
#'
#' @noRd
transform_goal_to_english <- function(goal) {

  # Translate primary goal to english
  goal <- case_when(
    goal == "pijn" ~ "Pain",
    goal == "activiteiten uitvoeren" ~ "Activities",
    goal == "tintelingen" ~ "Tingling",
    goal == "soepelheid/beweeglijkheid" ~ "Mobility/flexibility",
    goal == "kracht" ~ "Strength",
    goal == "doofheid" ~ "Numbness",
    goal == "uiterlijk" ~ "Appearance",
    goal == "werk uitvoeren" ~ "Work"
  )

  return(goal)
}
