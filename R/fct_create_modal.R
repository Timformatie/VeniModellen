#' create_modal
#'
#' @description creates modal for modifying model input
#'
#' @return returns a modal
#'
#' @noRd
create_modal <- function(question, dt_input, i18n) {

  question_text <- dt_questions[Variable == question, `Informatie/mouse over NL`]
  input_id <- paste0(question, "_modal_in")
  label <- dt_questions[Variable == question, `NL label variabele naam`]

  showModal(
    modalDialog(
      title = i18n()$t("Vul vraag in"),
      i18n()$t(question_text),
      hr(style = "color: grey"),
      selectizeInput(inputId = input_id,
                     label = i18n()$t(label),
                     choices = c(seq(1, 10, by = 1)),
                     selected = dt_input[[question]]
      ),
      size = 'm',
      footer = tagList(
        modalButton("Cancel"),
        actionButton("ok", "OK")
      )
    )
  )

}
