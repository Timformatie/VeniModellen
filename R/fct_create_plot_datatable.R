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
create_plot_datatable <- function(dt_pred, language, treatment_type, PMG) {

  # Determine probabilities patient will continue with surgery
  X_continue_surgery <- round(dt_continue_surgery[variable == PMG, X] * 100)
  X_no_surgery <- round((100 - X_continue_surgery))

  # Create datatables with probabilities
  if (treatment_type == "therapie") {
    from_values <- if (language == "nl") from_therapie_nl else from_therapie_en
    to_values <- if (language == "nl") to_therapie_nl else to_therapie_en
    weight_values <- c(round(dt_pred[1,Yes]*100), round(dt_pred[1,No]*100), X_continue_surgery, X_no_surgery, round(dt_pred[2,Yes]*100), round(dt_pred[2,No]*100))
  } else {
    from_values <- if (language == "nl") from_operatie_nl else from_operatie_en
    to_values <- if (language == "nl") to_operatie_nl else to_operatie_en
    weight_values <- c(round(dt_pred[1,Yes]*100), round(dt_pred[1,No]*100))
  }

  dt_results <- data.table(
    from = from_values,
    to = to_values,
    weight = weight_values,
    label = weight_values
  )

  # Alter weights to show sankey plot correctly
  if (nrow(dt_results)>2) {
    dt_results = dt_results[1:2, weight := label]

    from_node_value <- dt_results[3, from]
    from_node_weight_1 <- dt_results[to == from_node_value, label]
    dt_results[3:4, weight := as.numeric(from_node_weight_1)/100*as.numeric(label)]

    from_node_value <- dt_results[5, from]
    from_node_weight_2 <- dt_results[to == from_node_value, label]
    dt_results[5:6, weight := as.numeric(from_node_weight_1)/100*as.numeric(from_node_weight_2)/100*as.numeric(label)]

  }

  return(dt_results)
}
