#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @import stringr
#' @import shinyjs
#' @import shiny.i18n
#' @import data.table
#' @noRd
app_server <- function(input, output, session) {

  # Language and translation settings ----
  i18n <- reactive({
    i18n <- golem::get_golem_options(which = "translator")
    i18n$set_translation_language("nl")
    return(i18n)
  })

  observeEvent(input$language_in, {
    # Update language
    update_lang(session = session, language = input$language_in)
  })

  # 1. Initialiseer datatable waarin input wordt bijgehouden ----
  v <- reactiveValues(dt_input = data.table::data.table(age = NULL,
                                                        weight = NULL,
                                                        duration = NULL,
                                                        current_pain = NULL,
                                                        goal_pain = NULL,
                                                        current_tingling = NULL,
                                                        goal_tingling = NULL,
                                                        current_deafness = NULL,
                                                        goal_deafness = NULL,
                                                        current_strength = NULL,
                                                        goal_strength = NULL
                                                        ))

  # 2. Vul datatable met initiële waarden ----
  observe( {

    dt <- isolate(v$dt_input)

    dt <- dt[, age := 40]
    dt <- dt[, weight := 85]
    dt <- dt[, current_pijn := 8]
    dt <- dt[, goal_pijn := 4]
    dt <- dt[, current_tintelingen := 6]
    dt <- dt[, goal_tintelingen := 2]
    dt <- dt[, current_doofheid := 4]
    dt <- dt[, goal_doofheid := 3]
    dt <- dt[, current_kracht := 8]
    dt <- dt[, goal_kracht := 9]
    dt <- dt[, duration := 1]

  })

  # model_input <- reactiveValues(age = 40,
  #                               weight = 85,
  #                               current_pain = 8,
  #                               current_pijn = 8,
  #                               goal_pain = 4,
  #                               goal_pijn = 4,
  #                               current_tintelingen = 6,
  #                               goal_tintelingen = 2,
  #                               current_tingling = 6,
  #                               goal_tingling = 2,
  #                               current_doofheid = 4,
  #                               goal_doofheid = 3,
  #                               current_kracht = 8,
  #                               goal_kracht = 10,
  #                               current_deafness = 4,
  #                               goal_deafness = 3,
  #                               current_strength = 8,
  #                               goal_strength = 10,
  #                               duration = 1
  #                               )

  # 3. Initialiseer inputs with current input values ----
  observe({

    updateSelectizeInput(session = session,
                         inputId = "age_in",
                         selected = isolate(v$dt_input$age)
    )

    updateSelectizeInput(session = session,
                         inputId = "weight_in",
                         selected = isolate(v$dt_input$weight)
    )

    updateSelectizeInput(session = session,
                         inputId = "duration_in",
                         selected = isolate(v$dt_input$duration)
    )

    # Update selectizeinput
    updateSelectizeInput(session = session,
                         inputId = "domain_in",
                         choices = setNames(c("Pijn", "Tintelingen", "Doofheid", "Kracht"),
                                            c(i18n()$t("Pijn"),i18n()$t("Tintelingen"),i18n()$t("Doofheid"),i18n()$t("Kracht")))
    )

  })

  # 4. Data voor sankey therapie ----
  ## 4.1 Therapie: predictions ----
  dt_pred_therapie_operatie <- reactive({
    # Get input data
    dt_input <- v$dt_input

    # Predict new probabilities
    ##pred_therapie <- predict(model_naam, dt_input)
    ##pred_therapie_operatie <- predict(model_naam, dt_input)
    rfe_result_gbm <- get(load("rfe_result_gbm_20231102.RData"))
    random_row <- round(runif(1, min = 1, max = nrow(dt_train)))
    pred_therapie <- predict(rfe_result_gbm, dt_train[random_row,])
    random_row <- random_row + 2
    pred_therapie_operatie <- predict(rfe_result_gbm, dt_train[random_row,])

    dt_pred <- rbind(pred_therapie, pred_therapie_operatie)

    return(dt_pred)
  })

  ## 4.2 Therapie: datatable ----
  dt_results_therapie_operatie <- reactive({
    dt_pred <- dt_pred_therapie_operatie()

    language <- input$language_in
    from_values <- if (language=="nl") from_therapie_nl else from_therapie_en
    to_values <- if (language=="nl") to_therapie_nl else to_therapie_en

    dt_sankey_therapie <- data.frame(
      from = from_values,
      to = to_values,
      weight=c(round(dt_pred[1,3]*100), round(dt_pred[1,2]*100), 30, 70, round(dt_pred[2,3]*100), round(dt_pred[2,2]*100))
    )

    return(dt_sankey_therapie)
  })

  # 5. Data voor sankey operatie ----
  ## 5.1 Operatie: predictions ----
  dt_pred_operatie <- reactive({
    # Get input data
    dt_input <- v$dt_input

    # Predict new probabilities
    ##pred_operatie <- predict(model_naam, dt_input)
    rfe_result_gbm <- get(load("rfe_result_gbm_20231102.RData"))
    random_row <- round(runif(1, min = 1, max = nrow(dt_train)))
    random_row <- random_row + 1
    pred_operatie <- predict(rfe_result_gbm, dt_train[random_row,])

    return(pred_operatie)
  })

  ## 5.2 Operatie: datatable ----
  dt_results_operatie <- reactive({
    dt_pred <- dt_pred_operatie()

    language <- input$language_in
    from_values <- if (language=="nl") from_operatie_nl else from_operatie_en
    to_values <- if (language=="nl") to_operatie_nl else to_operatie_en

    dt_results_operatie <- data.frame(
      from = from_values,
      to = to_values,
      weight=c(round(dt_pred[1,3]*100), round(dt_pred[1,2]*100))
    )

    return(dt_results_operatie)
  })

  # 6. Create sankey plots ----
  output$sankey_2 <- renderHighchart({
    plot <- create_sankey(dt_results_operatie(), lang = input$language_in)
    return(plot)
  })

  output$sankey_3 <- renderHighchart({
    plot <- create_sankey(dt_results_therapie_operatie(), lang = input$language_in)
    return(plot)
  })

  # Get current values for slider when domain input changes
  observeEvent(input$domain_in, {
    req(!input$domain_in == "")

    dt_input <- v$dt_input

    selected_domain <- tolower(input$domain_in)
    current_val <- eval(parse(text = paste0("dt_input$current_", selected_domain)))
    goal_val <- eval(parse(text = paste0("dt_input$goal_", selected_domain)))
    range_vector <- if(current_val > goal_val) {c(goal_val, current_val)} else {c(current_val, goal_val)}

    updateSliderInput(session = session,
                      inputId = "pmg_slider",
                      value = range_vector
    )

  })

  # 7. Domein doel tekst ----
  output$MPG_text <- renderText({

    # Het hangt af van het domein of een hogere score beter of slechter is.

    selected_domain <- input$domain_in

    if (selected_domain %in% c("Kracht")) {
      current_val <- min(input$pmg_slider)
      goal_val <- max(input$pmg_slider)
    } else {
      current_val <- max(input$pmg_slider)
      goal_val <- min(input$pmg_slider)
    }

    selected_domain <- i18n()$t(input$domain_in)

    if (input$language_in == "nl") {
      text <- stringr::str_glue("U scoort nu een {current_val} op {selected_domain}. U bent tevreden met een {goal_val}.")
    } else {
      text <- stringr::str_glue("Your current score for {selected_domain} is {current_val}. Your goal is {goal_val}.")
    }

    return(text)
  })

  # 8. Hides/how plots ----
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

  # 9. Update input datatable wanneer input verandert ----
  observeEvent(input$age_in, {
    v$dt_input = copy(v$dt_input)[, age := input$age_in]
  })

  observeEvent(input$weight_in, {
    v$dt_input = copy(v$dt_input)[, weight := input$weight_in]
  })

  observeEvent(input$duration_in, {
    v$dt_input = copy(v$dt_input)[, duration := input$duration_in]
  })

  observeEvent(input$pmg_slider, {
    req(!input$domain_in == "")

    selected_domain <- tolower(input$domain_in)
    current_value <- max(input$pmg_slider)
    goal_value <- min(input$pmg_slider)

    v$dt_input[[paste0("current_", selected_domain)]] <- current_value
    v$dt_input[[paste0("goal_", selected_domain)]] <- goal_value

    v$dt_input <- copy(v$dt_input)

  }, ignoreInit = TRUE)

  observeEvent(input$pmg_slider, {

    if (input$domain_in %in% c("Pijn", "Doofheid", "Tintelingen")) {
      addClass(selector = ".irs--shiny .irs-min", class = "groen")
      addClass(selector = ".irs--shiny .irs-max", class = "rood")
    } else {
      addClass(selector = ".irs--shiny .irs-min", class = "rood")
      addClass(selector = ".irs--shiny .irs-max", class = "groen")
    }

  })



  # observeEvent(input$domain_in, {browser()})
  # observeEvent(input$pmg_slider, {browser()})
  # observeEvent(input$language_in, {browser()})

}
