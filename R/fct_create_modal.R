#' create_modal
#'
#' @description creates modal for modifying model input
#'
#' @param input_var input variable which needs to be edited
#' @param dt_input current model input datatable
#' @param i18n translator
#'
#' @return returns a modal
#'
#' @noRd
create_modal <- function(input_var, dt_input, i18n) {

  question_text <- dt_questions[Variable == input_var, `Informatie/mouse over NL`]
  input_id <- paste0(input_var, "_modal_in")
  label <- dt_questions[Variable == input_var, `NL label variabele naam`]

  showModal(
    modalDialog(
      title = i18n()$t("Vul vraag in"),
      i18n()$t(question_text),
      hr(style = "color: grey"),
      selectizeInput(inputId = input_id,
                     label = i18n()$t(label),
                     choices = c(seq(1, 10, by = 1)),
                     selected = dt_input[[input_var]]
      ),
      size = "m",
      footer = tagList(
        modalButton("Cancel"),
        actionButton("ok", "OK")
      )
    )
  )

}
