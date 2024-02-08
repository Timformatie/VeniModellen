#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @import stringr
#' @import shinyjs
#' @noRd
app_server <- function(input, output, session) {

  # i18n <- reactive({
  #   i18n <- golem::get_golem_options(which = "translator")
  #   i18n$set_translation_language("en")
  #
  #   return(i18n)
  # })
  #
  # observeEvent(input$language_in, {
  #   update_lang(session = session, language = input$language_in)
  # })

  model_input <- reactiveValues(age = 40,
                                weight = 85,
                                current_pain = 8,
                                goal_pmg = 4,
                                duration = 1)

  # Update inputs with current input values ----
  observe({
    updateSelectizeInput(session = session,
                         inputId = "age_in",
                         selected = model_input$age
    )

    updateSelectizeInput(session = session,
                         inputId = "weight_in",
                         selected = model_input$weight
    )

    updateSliderInput(session = session,
                      inputId = "pmg_slider",
                      value = c(model_input$goal_pmg, model_input$current_pain)
    )
  })

  observeEvent(input$age_in, {
    model_input$age <- input$age_in
  })

  observeEvent(input$weight_in, {
    model_input$weight <- input$weight_in
  })

  observeEvent(input$pmg_slider, {

    model_input$goal_pmg <- min(input$pmg_slider)

    # Update slider with new minimum value (goal_pmg), but make sure the current pain value stays the same.
    isolate(
      updateSliderInput(session = session,
                      inputId = "pmg_slider",
                      value = c(model_input$goal_pmg, model_input$current_pain)
                      )
    )
  })

  output$sankey_1 <- renderHighchart({
    plot <- create_sankey(dt_sankey_4)
    return(plot)
  })

  output$sankey_2 <- renderHighchart({
    plot <- create_sankey(dt_sankey_5)
    return(plot)
  })

  output$sankey_3 <- renderHighchart({
    plot <- create_sankey(dt_sankey_3)
    return(plot)
  })

  output$MPG_text <- renderText({

    pmg_current <- max(input$pmg_slider)
    pmg_goal <- min(input$pmg_slider)

    text <- stringr::str_glue("U scoort nu een {pmg_current} op pijn. U bent tevreden met een {pmg_goal}.")

    return(text)
  })

  observeEvent(input$show_therapie, {

    show_plot <- input$show_therapie

    if (show_plot == TRUE) {
      shinyjs::show("sankey_1")
      shinyjs::show("sankey_3")
      shinyjs::show("divider")
    } else {
      shinyjs::hide("sankey_1")
      shinyjs::hide("sankey_3")
      shinyjs::hide("divider")
    }

  })

  observeEvent(input$show_operatie, {

    show_plot <- input$show_operatie

    if (show_plot == TRUE) {
      shinyjs::show("sankey_2")
      shinyjs::show("divider")
    } else {
      shinyjs::hide("sankey_2")
      shinyjs::hide("divider")
    }

  })

  observeEvent(c(input$pmg_slider, input$age_in, input$weight_in, input$duration_in), {

    # Op het moment dat de slider gewijzigd wordt, moeten opnieuw de kansen worden doorgerekend.
    # 1. Verzamel alle input voor het model, inclusief nieuwe input uit slider (reactiveValues?)
    # 2. Prepareer de input voor het model.

    # 3. Bereken de nieuwe kansen met het model voor zowel operatie als therapie.
    random_row <- round(runif(1, min = 1, max = nrow(dt_train)))
    pred_results_therapie <- predict(rfe_result_gbm, dt_train[random_row,])
    random_row <- random_row + 1
    pred_results_operatie <- predict(rfe_result_gbm, dt_train[random_row,])
    random_row <- random_row + 2
    pred_results_therapie_operatie <- predict(rfe_result_gbm, dt_train[random_row,])

    # 4. Genereer nieuwe input en sankey plots.
    dt_sankey_therapie <- data.frame(
      from=c("therapie","therapie", "doel niet behaald", "doel niet behaald"),
      to=c("doel behaald","doel niet behaald", "doel behaald <br> na operatie", "doel niet behaald <br> na operatie"),
      weight=c(round(pred_results_therapie[1,3]*100), round(pred_results_therapie[1,2]*100), round(pred_results_therapie_operatie[1,3]*100), round(pred_results_therapie_operatie[1,2]*100))
    )

    output$sankey_1 <- renderHighchart({
      plot <- create_sankey(dt_sankey_therapie)
      return(plot)
    })

    dt_sankey_operatie <- data.frame(
      from=c("operatie", "operatie"),
      to=c("doel behaald","doel niet behaald"),
      weight=c(round(pred_results_operatie[1,3]*100), round(pred_results_operatie[1,2]*100))
    )

    output$sankey_2 <- renderHighchart({
      plot <- create_sankey(dt_sankey_operatie)
      return(plot)
    })

    }, ignoreInit = TRUE)

  # Functie die kan berekenen voor de huidige input wat de uitkomsten van het model zijn
  # Trigger: er verandert iets aan de input.
  # 1. Verzamel huidige input in datatable
  # observe({
  #   browser()
  #   dt_input_model <- data.table::data.table(age = model_input$age,
  #                              weight = model_input$weight,
  #                              current_pain = model_input$current_pain,
  #                              goal_pmg = model_input$goal_pmg,
  #                              duration = model_input$duration
  #                              )
  # })

  #2. Voer eventuele voorbewerkingen uit op de inputdata. (functie: prepare_data)
  #3. Geef nieuwe input aan model, en bereken de uitkomsten.
  #4. Creeer met uitkomsten nieuwe sankey diagrammen. (functie: create_sankey)

}
