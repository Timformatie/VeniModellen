#' create_plot_datatable
#'
#' @description This functions creates the input datatable for the sankey plots.
#'
#' @param dt_pred datatable with model predictions
#' @param language language selected by user
#' @param treatment_type type of treatment, can be "therapie" or "operatie"
#'
#' @return A datatable that can be used as input for creating the sankey plots.
#'
#' @importFrom data.table data.table
#'
#' @noRd
create_plot_datatable <- function(dt_pred, language, treatment_type) {

  if (treatment_type == "therapie") {
    from_values <- if (language == "nl") from_therapie_nl else from_therapie_en
    to_values <- if (language == "nl") to_therapie_nl else to_therapie_en
    weight_values <- c(round(dt_pred[1,3]*100), round(dt_pred[1,2]*100), 30, 70, round(dt_pred[2,3]*100), round(dt_pred[2,2]*100))
  } else {
    from_values <- if (language == "nl") from_operatie_nl else from_operatie_en
    to_values <- if (language == "nl") to_operatie_nl else to_operatie_en
    weight_values <- c(round(dt_pred[1,3]*100), round(dt_pred[1,2]*100))
  }

  dt_results <- data.table(
    from = from_values,
    to = to_values,
    weight = weight_values
  )

  return(dt_results)
}
