#' recode_primary_goal
#'
#' @description Recode a primary goal code to a label.
#'
#' @param goal Numeric goal value.
#'
#' @return Primary goal label
recode_primary_goal <- function(goal) {
  recode <- data.frame(
    goal = c(2:9),
    label = c(
      "doofheid", "soepelheid/beweeglijkheid", "kracht", "pijn", "tintelingen",
      "activiteiten uitvoeren", "uiterlijk", "werk uitvoeren"
    )
  )
  return(recode$label[recode$goal == goal])
}
