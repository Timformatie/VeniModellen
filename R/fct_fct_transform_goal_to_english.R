#' fct_transform_goal_to_english
#'
#' @description A fct function
#'
#' @return The return value, if any, from executing the function.
#'
#' @noRd
transform_goal_to_english <- function(goal) {

  # Translate primary goal to english
  goal <- case_when(
    goal == "pijn" ~ "Pain",
    goal == "activiteiten" ~ "Activities",
    goal == "tintelingen" ~ "Tingling",
    goal == "soepelheid/beweeglijkheid" ~ "Mobility/flexibility",
    goal == "kracht" ~ "Strength",
    goal == "doofheid" ~ "Numbness",
    goal == "uiterlijk" ~ "Appearance",
    goal == "werk uitvoeren" ~ "Work"
  )

  return(goal)
}
