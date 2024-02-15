#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @importFrom stringr str_glue
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

  # Initialiseer reactiveVal's
  selected_domain <- reactiveVal()

  # Initialiseer datatable with input values ----
  v <- reactiveValues(dt_input = data.table(age = NULL,
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

  # Vul datatable met initiële waarden ----
  # TODO: dit wordt een observeEvent op de URL met waarden van de betreffende patient
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

  # Initialiseer inputs with current input values ----
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

    updateSelectizeInput(session = session,
                         inputId = "domain_in",
                         choices = setNames(c("Pijn", "Tintelingen", "Doofheid", "Kracht"),
                                            c(i18n()$t("Pijn"),i18n()$t("Tintelingen"),i18n()$t("Doofheid"),i18n()$t("Kracht")))
    )
  }, priority = 1)

  # Update slider input ----
  # Set slider values when domain input changes
  observeEvent(input$domain_in, {
    req(!input$domain_in == "")

    # Update selected domain reactiveVal
    selected_domain(tolower(input$domain_in))

    # Get current and goal values for selected domain and update slider
    current_val <- v$dt_input[[paste0("current_", selected_domain())]]
    goal_val <- v$dt_input[[paste0("goal_", selected_domain())]]
    range_vector <- if(current_val > goal_val) {c(goal_val, current_val)} else {c(current_val, goal_val)}

    updateSliderInput(session = session,
                      inputId = "pmg_slider",
                      value = range_vector
    )

  })

  # Update input datatable wanneer input verandert ----
  observeEvent(input$age_in, {
    v$dt_input[["age"]] <- input$age_in
  })

  observeEvent(input$weight_in, {
    v$dt_input[["weight"]] <- input$weight_in
  })

  observeEvent(input$duration_in, {
    v$dt_input[["duration"]] <- input$duration_in
      })

  slider_value_list <- reactive({
    req(!is.null(selected_domain()))
    if (selected_domain() %in% reverse_domains) {
      current_val <- min(input$pmg_slider)
      goal_val <- max(input$pmg_slider)
    } else {
      current_val <- max(input$pmg_slider)
      goal_val <- min(input$pmg_slider)
    }
    return(c(current_val, goal_val))
  })

  # Update dataframe with model inputs when slider values change
  # Add CSS classes to format min and max colors on slider
  observeEvent(input$pmg_slider, {
    req(!input$domain_in == "")

    v$dt_input[[paste0("current_", selected_domain())]] <- slider_value_list()[1]
    v$dt_input[[paste0("goal_", selected_domain())]] <- slider_value_list()[2]

    # Change min and max colors on slider according to selected domain
    # CSS classes are added here instead of in observeEvent(input$domain_in),
    # because it seemed like shiny overwrote the added classes when updating
    # the slider with updateSliderInput.
    if (input$domain_in %in% reverse_domains) { # Example: domain "kracht" --> higher score is better
      addClass(selector = ".irs--shiny .irs-min", class = "rood")
      addClass(selector = ".irs--shiny .irs-max", class = "groen")
    } else {
      addClass(selector = ".irs--shiny .irs-min", class = "groen")
      addClass(selector = ".irs--shiny .irs-max", class = "rood")
    }
  }, ignoreInit = TRUE)

  # Change text according to domain and slider values
  output$MPG_text <- renderText({
    current_val <- slider_value_list()[1]
    goal_val <- slider_value_list()[2]

    selected_domain <- tolower(i18n()$t(input$domain_in))

    text <- paste0(i18n()$t("U scoort nu een"), " ", current_val, i18n()$t(" op "), selected_domain, ". ", i18n()$t("U bent tevreden met een"), " ", goal_val, ".")

    return(text)
  })

  # Sankey therapie ----
  ## predictions ----
  dt_pred_therapie_operatie <- reactive({
    # Get input data
    dt_input <- v$dt_input

    # TODO: Hier komt nog een functie voor datapreparatie (normaliseren etc.)

    # Predict new probabilities (for now demo probs are calculated)
    ##pred_operatie <- predict(model_naam, dt_input) --> this will be the correct code in the future
    ##pred_therapie_operatie <- predict(model_naam, dt_input) --> this will be the correct code in the future
    random_row <- round(runif(1, min = 1, max = nrow(dt_train)))
    pred_therapie <- predict(model, dt_train[random_row,])
    pred_therapie_operatie <- predict(model, dt_train[random_row + 1,])

    dt_pred <- rbind(pred_therapie, pred_therapie_operatie)

    return(dt_pred)
  })

  ## data for plot ----
  dt_results_therapie_operatie <- reactive({
    dt_pred <- dt_pred_therapie_operatie()
    dt_sankey_therapie <- create_plot_dataframe(dt_pred, input$language_in, "therapie")
    return(dt_sankey_therapie)
  })

  # Sankey operatie ----
  ## predictions ----
  dt_pred_operatie <- reactive({
    # Get input data
    dt_input <- v$dt_input

    # TODO: Hier komt nog een functie voor datapreparatie (normaliseren etc.)

    # Predict new probabilities (for now demo probs are calculated)
    ##pred_operatie <- predict(model_naam, dt_input) --> this will be the correct code in the future
    random_row <- round(runif(1, min = 1, max = nrow(dt_train)))
    pred_operatie <- predict(model, dt_train[random_row,])

    return(pred_operatie)
  })

  ## data for plot ----
  dt_results_operatie <- reactive({
    dt_pred <- dt_pred_operatie()
    dt_results_operatie <- create_plot_dataframe(dt_pred, input$language_in, "operatie")
    return(dt_results_operatie)
  })

  # Create sankey plots ----
  output$sankey_therapie <- renderHighchart({
    plot <- create_sankey(dt_results_therapie_operatie(), language = input$language_in)
    return(plot)
  })

  output$sankey_operatie <- renderHighchart({
    plot <- create_sankey(dt_results_operatie(), language = input$language_in)
    return(plot)
  })

  # Hide/show plots ----
  observeEvent(input$show_therapie, {
    if (input$show_therapie == TRUE) {
      shinyjs::show("sankey_therapie")
      shinyjs::show("divider")
    } else {
      shinyjs::hide("sankey_therapie")
      shinyjs::hide("divider")
    }
  })
  observeEvent(input$show_operatie, {
    if (input$show_operatie == TRUE) {
      shinyjs::show("sankey_operatie")
      shinyjs::show("divider")
    } else {
      shinyjs::hide("sankey_operatie")
      shinyjs::hide("divider")
    }
  })

}
