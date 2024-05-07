#' fct_slider_layout
#'
#' @description this function determines the layout for the slider input (color and direction of arrow)
#'
#' @param domain user selected primary goal
#' @param current_val current score for patient for primary goal
#' @param goal_val goal score for patient for primary goal
#'
#' @return returns the correct slider layout
#'
#' @noRd
update_slider_layout <- function(domain, current_val, goal_val) {

  if (domain %in% reverse_domains) { # Example: domain "kracht" --> higher score is better
    removeClass(selector = ".irs--shiny .irs-min", class = "groen")
    removeClass(selector = ".irs--shiny .irs-max", class = "rood")
    addClass(selector = ".irs--shiny .irs-min", class = "rood")
    addClass(selector = ".irs--shiny .irs-max", class = "groen")
    shinyjs::hide(id = "happy-smiley-left")
    shinyjs::show(id = "sad-smiley-left")
    shinyjs::show(id = "happy-smiley-right")
    shinyjs::hide(id = "sad-smiley-right")
    if (goal_val >= current_val) {
      removeClass(selector = ".irs.irs--shiny .irs-bar", class = "left-arrow")
      addClass(selector = ".irs.irs--shiny .irs-bar", class = "right-arrow")
      addClass(selector = ".irs.irs--shiny .irs-bar", class = "groen")
      removeClass(selector = ".irs.irs--shiny .irs-bar.right-arrow", class = "rood")
      addClass(selector = ".irs.irs--shiny .irs-bar.right-arrow", class = "groen")
    } else {
      removeClass(selector = ".irs.irs--shiny .irs-bar", class = "right-arrow")
      addClass(selector = ".irs.irs--shiny .irs-bar", class = "left-arrow")
      addClass(selector = ".irs.irs--shiny .irs-bar", class = "rood")
      removeClass(selector = ".irs.irs--shiny .irs-bar.left-arrow", class = "groen")
      addClass(selector = ".irs.irs--shiny .irs-bar.left-arrow", class = "rood")
    }
  } else {
    removeClass(selector = ".irs--shiny .irs-min", class = "rood")
    removeClass(selector = ".irs--shiny .irs-max", class = "groen")
    addClass(selector = ".irs--shiny .irs-min", class = "groen")
    addClass(selector = ".irs--shiny .irs-max", class = "rood")
    shinyjs::show(id = "happy-smiley-left")
    shinyjs::hide(id = "sad-smiley-left")
    shinyjs::hide(id = "happy-smiley-right")
    shinyjs::show(id = "sad-smiley-right")
    if (goal_val <= current_val) {
      removeClass(selector = ".irs.irs--shiny .irs-bar", class = "right-arrow")
      addClass(selector = ".irs.irs--shiny .irs-bar", class = "left-arrow")
      addClass(selector = ".irs.irs--shiny .irs-bar", class = "groen")
      removeClass(selector = ".irs.irs--shiny .irs-bar.left-arrow", class = "rood")
      addClass(selector = ".irs.irs--shiny .irs-bar.left-arrow", class = "groen")
    } else {
      removeClass(selector = ".irs.irs--shiny .irs-bar", class = "left-arrow")
      addClass(selector = ".irs.irs--shiny .irs-bar", class = "right-arrow")
      removeClass(selector = ".irs.irs--shiny .irs-bar", class = "groen")
      addClass(selector = ".irs.irs--shiny .irs-bar", class = "rood")
      removeClass(selector = ".irs.irs--shiny .irs-bar.right-arrow", class = "groen")
      addClass(selector = ".irs.irs--shiny .irs-bar.right-arrow", class = "rood")
    }
  }

}
