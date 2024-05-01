#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @importFrom stringr str_glue
#' @import shinyjs
#' @import shiny.i18n
#' @import data.table
#' @import waiter
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

  observe({
    disable("track_in")
    disable("track_type_in")
  })

  # Initialiseer reactiveVal's
  selected_domain <- reactiveVal()
  negative_goal <- reactiveVal(NULL)
  url_value <- reactiveVal(NULL)
  update_slider <- reactiveVal(NULL)

  # Initialiseer datatable with input values ----
  v <- reactiveValues(dt_input = data.table(Behandeling_clustered = NULL,
                                            Diagnose = NULL,
                                            Track = NULL,
                                            Track_type = NULL,
                                            Age = NULL,
                                            weight = NULL,
                                            height = NULL,
                                            howLongComplaints = NULL,
                                            nrsfunction_score = NULL,
                                            nrspainload_score = NULL,
                                            ipqconcern_SQ001 = NULL,
                                            ipqemotionalresponse_SQ001 = NULL,
                                            PrimaryGoal.x = NULL,
                                            PrimPSN_Int = NULL,
                                            PrimPSN_Satisf = NULL
                                            ))




  # Vul datatable met initiële waarden ----
  # TODO: dit wordt een observeEvent op de URL met waarden van de betreffende patient
  observeEvent(url_value, {

    dt <- isolate(v$dt_input)

    #TODO: determine correct diagnosis (and other values) from URL
    dt <- dt[, Diagnose := "Trigger"]
    dt <- dt[, Track := dt_diagnosis_track[Diagnose_dt_train == isolate(v$dt_input$Diagnose), Track]]
    dt <- dt[, Track_type := dt_diagnosis_track[Diagnose_dt_train == isolate(v$dt_input$Diagnose), `Track Type`]]
    dt <- dt[, Age := as.numeric(40)]
    dt <- dt[, weight := 85]
    dt <- dt[, howLongComplaints := 8]
    dt <- dt[, height := 178]
    dt <- dt[, nrspainload_score := 6]
    dt <- dt[, nrsfunction_score := 4]
    dt <- dt[, ipqconcern_SQ001 := 2]
    dt <- dt[, ipqemotionalresponse_SQ001 := 4]
    dt <- dt[, PrimaryGoal.x := "pijn"] # This input is above the slider input ("primaire doel domein")
    dt <- dt[, PrimPSN_Int := 7]
    dt <- dt[, PrimPSN_Satisf := 4]

  })

  # Initialiseer inputs with current values ----
  observe({

    updateSelectizeInput(session = session,
                         inputId = "diagnose_in",
                         choices = unique(dt_train$Diagnose),
                         selected = isolate(v$dt_input$Diagnose)
    )

    updateSelectizeInput(session = session,
                         inputId = "track_in",
                         choices = unique(dt_diagnosis_track$Track),
                         selected = isolate(v$dt_input$Track)
    )

    updateSelectizeInput(session = session,
                         inputId = "track_type_in",
                         choices = unique(dt_diagnosis_track$`Track Type`),
                         selected = isolate(v$dt_input$Track_type)
    )

    updateSelectizeInput(session = session,
                         inputId = "age_in",
                         choices = c(seq(16, 120, by = 1)),
                         selected = isolate(v$dt_input$Age)
    )

    updateSelectizeInput(session = session,
                         inputId = "weight_in",
                         choices = c(seq(30, 200, by = 1)),
                         selected = isolate(v$dt_input$weight)
    )

    updateSelectizeInput(session = session,
                         inputId = "duration_in",
                         choices = c(seq(0, 1080, by = 1)),
                         selected = isolate(v$dt_input$howLongComplaints)
    )

    updateSelectizeInput(session = session,
                         inputId = "height_in",
                         choices = c(seq(100, 230, by = 1)),
                         selected = isolate(v$dt_input$height)
    )

    updateSelectizeInput(session = session,
                         inputId = "ipqconcern_SQ001_in",
                         choices = c(seq(0, 10, by = 1)),
                         selected = isolate(v$dt_input$ipqconcern_SQ001)
    )

    updateSelectizeInput(session = session,
                         inputId = "nrspainload_score_in",
                         choices = c(seq(0, 10, by = 1)),
                         selected = isolate(v$dt_input$nrspainload_score)
    )

    updateSelectizeInput(session = session,
                         inputId = "nrsfunction_score_in",
                         choices = c(seq(0, 10, by = 1)),
                         selected = isolate(v$dt_input$nrsfunction_score)
    )

    updateSelectizeInput(session = session,
                         inputId = "ipqemotionalresponse_SQ001_in",
                         choices = c(seq(0, 10, by = 1)),
                         selected = isolate(v$dt_input$ipqemotionalresponse_SQ001)
    )

    updateSelectizeInput(session = session,
                         inputId = "primPSN_int_in",
                         choices = c(seq(0, 10, by = 1)),
                         selected = isolate(v$dt_input$PrimPSN_Int)
    )

    updateSelectizeInput(session = session,
                         inputId = "primPSN_satisf_in",
                         choices = c(seq(0, 10, by = 1)),
                         selected = isolate(v$dt_input$PrimPSN_Satisf)
    )

    updateSelectizeInput(session = session,
                         inputId = "domain_in",
                         choices = setNames(c("pijn", "tintelingen", "doofheid",
                                              "kracht", "activiteiten",
                                              "soepelheid/beweeglijkheid", "uiterlijk"),
                                            c(i18n()$t("Pijn"),i18n()$t("Tintelingen"),i18n()$t("Doofheid")
                                              ,i18n()$t("Kracht"), i18n()$t("Activiteiten")
                                              ,i18n()$t("Soepelheid/beweeglijkheid"), i18n()$t("Uiterlijk"))),
                         selected = isolate(v$dt_input$PrimaryGoal.x)
    )

    # Get current and goal values for selected domain and update slider
    current_val <- isolate(v$dt_input$PrimPSN_Int)
    goal_val <- isolate(v$dt_input$PrimPSN_Satisf)
    range_vector <- if(current_val > goal_val) {c(goal_val, current_val)} else {c(current_val, goal_val)}
    updateSliderInput(session = session,
                      inputId = "pmg_slider",
                      value = range_vector
    )

  })

  # Update slider layout ----
  # Update slider layout when domain input changes
  observeEvent(input$domain_in, {
    req(!input$domain_in == "")

    # Update selected domain reactiveVal
    selected_domain(input$domain_in)
    v$dt_input$PrimaryGoal.x <- selected_domain()

    current_val <- v$dt_input$PrimPSN_Int
    goal_val <- v$dt_input$PrimPSN_Satisf
    goal <- isolate(v$dt_input$PrimaryGoal.x)
    negative_goal(FALSE)
    if (goal %in% reverse_domains & (goal_val < current_val)) {
      negative_goal(TRUE)
    } else if (!(goal %in% reverse_domains) & goal_val > current_val) {
      negative_goal(TRUE)
    }

    if (tolower(input$domain_in) %in% reverse_domains) { # Example: domain "kracht" --> higher score is better
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

    waiter_hide()

  }, ignoreInit = TRUE)

  observeEvent(negative_goal(), {
    if (negative_goal()) {
      show(id = "reset_negative_goal_btn")
    } else {
      hide(id = "reset_negative_goal_btn")
    }

  })

  # Change text ----
  # Change text according to domain and slider values
  output$MPG_text <- renderText({
    req(!selected_domain() == "")

    current_val <- v$dt_input$PrimPSN_Int
    goal_val <- v$dt_input$PrimPSN_Satisf

    selected_domain <- tolower(i18n()$t(input$domain_in))

    if (negative_goal()) {
      text <- paste0(i18n()$t("Let op: u heeft een verslechtering als doel gekozen. Kies een ander doel of klik op de knop hieronder."))
      addClass(selector = ".MPG_text", class = "rood_text")
    } else {
      text <- paste0(i18n()$t("U scoort nu een"), " ", current_val, i18n()$t(" op "), selected_domain, ". ", i18n()$t("U bent tevreden met een"), " ", goal_val, ".")
      removeClass(selector = ".MPG_text", class = "rood_text")
      }

    return(text)
  })

  observeEvent(input$reset_negative_goal_btn, {
    negative_goal(FALSE)

    current_val <- v$dt_input$PrimPSN_Int
    if (selected_domain() %in% reverse_domains) {
      v$dt_input$PrimPSN_Satisf <- current_val + 1
    } else {
      v$dt_input$PrimPSN_Satisf <- current_val - 1
    }
    goal_val <- v$dt_input$PrimPSN_Satisf

    range_vector <- if(current_val > goal_val) {c(goal_val, current_val)} else {c(current_val, goal_val)}

    updateSliderInput(session = session,
                      inputId = "pmg_slider",
                      value = range_vector
    )

  })

  observe({
    invalidateLater(millis = 1000)
    current_val <- v$dt_input$PrimPSN_Int
    goal_val <- v$dt_input$PrimPSN_Satisf

    if (tolower(input$domain_in) %in% reverse_domains) { # Example: domain "kracht" --> higher score is better
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

  })


  # Update input datatable wanneer input verandert ----
  # Update dataframe with current and goal value inputs when slider values change
  observeEvent(input$pmg_slider, {
    req(!input$domain_in == "")
    req((!negative_goal()))

    if (selected_domain() %in% reverse_domains) {
      current_val <- min(input$pmg_slider)
      goal_val <- max(input$pmg_slider)
    } else {
      current_val <- max(input$pmg_slider)
      goal_val <- min(input$pmg_slider)
    }

    v$dt_input$PrimPSN_Int <- current_val
    v$dt_input$PrimPSN_Satisf <- goal_val

  }, ignoreInit = TRUE)

  observeEvent(input$age_in, {
    v$dt_input[["Age"]] <- as.numeric(input$age_in)
  })

  observeEvent(input$weight_in, {
    v$dt_input[["weight"]] <- as.numeric(input$weight_in)
  })

  observeEvent(input$duration_in, {
    v$dt_input[["howLongComplaints"]] <- as.numeric(input$duration_in)
      })

  observeEvent(input$diagnose_in, {
    req(!input$diagnose_in == "")
    v$dt_input[["Diagnose"]] <- input$diagnose_in
    v$dt_input[["Track"]] <- dt_diagnosis_track[Diagnose_dt_train == v$dt_input$Diagnose, Track]
    v$dt_input[["Track_type"]] <- dt_diagnosis_track[Diagnose_dt_train == v$dt_input$Diagnose, `Track Type`]

    updateSelectizeInput(session = session,
                         inputId = "track_in",
                         selected = isolate(v$dt_input$Track)
    )

    updateSelectizeInput(session = session,
                         inputId = "track_type_in",
                         selected = isolate(v$dt_input$Track_type)
    )

  })

  observeEvent(input$ipqemotionalresponse_SQ001_in, {
    v$dt_input[["ipqemotionalresponse_SQ001"]] <- as.numeric(input$ipqemotionalresponse_SQ001_in)
  })

  observeEvent(input$ipqconcern_SQ001_in, {
    v$dt_input[["ipqconcern_SQ001"]] <- as.numeric(input$ipqconcern_SQ001_in)
  })

  observeEvent(input$nrspainload_score_in, {
    v$dt_input[["nrspainload_score"]] <- as.numeric(input$nrspainload_score_in)
  })

  observeEvent(input$nrsfunction_score_in, {
    v$dt_input[["nrsfunction_score"]] <- as.numeric(input$nrsfunction_score_in)
  })

  observeEvent(input$height_in, {
    v$dt_input[["height"]] <- as.numeric(input$height_in)
  })

  # Calculate PMG
  PMG_val <- reactive({
    PMG <- abs(as.numeric(v$dt_input$PrimPSN_Satisf) - as.numeric(v$dt_input$PrimPSN_Int))
    return(PMG)
  })

  # 1. Sankey therapie ----
  ## predictions ----
  dt_pred_therapie_operatie <- reactive({
    req(!is.null(selected_domain()))

    # Goal should be positive, otherwise don't show predictions
    current_val <- v$dt_input$PrimPSN_Int
    goal_val <- v$dt_input$PrimPSN_Satisf
    if (selected_domain() %in% reverse_domains) {
      goal_positive <- ifelse(goal_val >= current_val, TRUE, FALSE)
    } else {
      goal_positive <- ifelse(goal_val <= current_val, TRUE, FALSE)
    }
    validate(
      need(goal_positive, "U heeft een verslechtering als doel gekozen.")
    )

    # Get input data
    dt_input <- v$dt_input

    # Transform goal from dutch to english
    dt_input$PrimaryGoal.x <- transform_goal_to_english(dt_input$PrimaryGoal.x)

    # Injection checkbox determines treatment input
    if (input$injection_in == FALSE) {
      dt_input$Behandeling_clustered <- "Hand therapy ± orthosis"
    } else {
      dt_input$Behandeling_clustered <- "Hand therapy ± orthosis + injection"
    }

    # Predict probs for therapy
    pred_therapie <- predict(model, dt_input, type = "prob")

    # Change treatment to surgery according to diagnosis for second part of Sankey
    dt_input$Behandeling_clustered <- dt_diagnosis_track[Diagnose_dt_train == v$dt_input$Diagnose, Behandeling]

    # Predict probs for surgery
    pred_therapie_operatie <- predict(model, dt_input, type = "prob")

    # Merge probs into a single datatable
    dt_pred <- data.table(rbind(pred_therapie, pred_therapie_operatie))

    return(dt_pred)
  })

  ## data for plot ----
  dt_results_therapie_operatie <- reactive({
    dt_pred <- dt_pred_therapie_operatie()
    dt_sankey_therapie <- create_plot_datatable(dt_pred = dt_pred, language = input$language_in,
                                                treatment_type = "therapie",
                                                PMG = PMG_val())
    return(dt_sankey_therapie)
  })


  # 2. Sankey injectie ----
  ## predictions ----
  dt_pred_injectie <- reactive({
    req(!is.null(selected_domain()))

    # Goal should be positive
    current_val <- v$dt_input$PrimPSN_Int
    goal_val <- v$dt_input$PrimPSN_Satisf
    if (selected_domain() %in% reverse_domains) {
      goal_positive <- ifelse(goal_val >= current_val, TRUE, FALSE)
    } else {
      goal_positive <- ifelse(goal_val <= current_val, TRUE, FALSE)
    }
    validate(
      need(goal_positive, "U heeft een verslechtering als doel gekozen.")
    )

    # Get input data
    dt_input <- v$dt_input

    # Transform goal from dutch to english
    dt_input$PrimaryGoal.x <- transform_goal_to_english(dt_input$PrimaryGoal.x)

    # Treatment input
    dt_input$Behandeling_clustered <- "Injection"
    # Predict probs for therapy
    pred_injectie <- predict(model, dt_input, type = "prob")

    # Change treatment to surgery according to diagnosis for second part of Sankey
    dt_input$Behandeling_clustered <- dt_diagnosis_track[Diagnose_dt_train == v$dt_input$Diagnose, Behandeling]
    # Predict probs for surgery
    pred_injectie_operatie <- predict(model, dt_input, type = "prob")

    dt_pred <- data.table(rbind(pred_injectie, pred_injectie_operatie))

    return(dt_pred)
  })

  ## data for plot ----
  dt_results_injectie <- reactive({
    dt_pred <- dt_pred_injectie()
    dt_sankey_injectie <- create_plot_datatable(dt_pred = dt_pred, language = input$language_in,
                                                treatment_type = "therapie",
                                                PMG = PMG_val())
    return(dt_sankey_injectie)
  })


  # 3. Sankey operatie ----
  ## predictions ----
  dt_pred_operatie <- reactive({
    req(!is.null(selected_domain()))

    # Goal should be positive
    current_val <- v$dt_input$PrimPSN_Int
    goal_val <- v$dt_input$PrimPSN_Satisf
    if (selected_domain() %in% reverse_domains) {
      goal_positive <- ifelse(goal_val >= current_val, TRUE, FALSE)
    } else {
      goal_positive <- ifelse(goal_val <= current_val, TRUE, FALSE)
    }
    validate(
      need(goal_positive, "U heeft een verslechtering als doel gekozen.")
    )

    # Get input data
    dt_input <- v$dt_input

    # Transform goal from dutch to english
    dt_input$PrimaryGoal.x <- transform_goal_to_english(dt_input$PrimaryGoal.x)

    # Determine treatment/surgery based on diagnosis
    dt_input$Behandeling_clustered <- dt_diagnosis_track[Diagnose_dt_train == v$dt_input$Diagnose, Behandeling]

    # Predict probs
    pred_operatie <- data.table(predict(model, dt_input, type = "prob"))

    return(pred_operatie)
  })

  ## data for plot ----
  dt_results_operatie <- reactive({
    dt_pred <- dt_pred_operatie()
    dt_results_operatie <- create_plot_datatable(dt_pred = dt_pred, language = input$language_in,
                                                 treatment_type = "operatie",
                                                 PMG = PMG_val())

    return(dt_results_operatie)
  })

  # Create sankey plots ----
  output$sankey_therapie <- renderHighchart({
    plot <- create_sankey(dt_results_therapie_operatie(), language = input$language_in, PMG = PMG_val())
    return(plot)
  })

  output$sankey_injectie <- renderHighchart({
    plot <- create_sankey(dt_results_injectie(), language = input$language_in, PMG = PMG_val())
    return(plot)
  })

  output$sankey_operatie <- renderHighchart({
    plot <- create_sankey(dt_results_operatie(), language = input$language_in, PMG = PMG_val())
    return(plot)
  })

  # Hide/show plots ----
  observeEvent(input$show_therapie, {
    if (input$show_therapie == TRUE) {
      shinyjs::show(selector = "div.sankey_therapie")
    } else {
      shinyjs::hide(selector = "div.sankey_therapie")
    }
  })
  observeEvent(input$show_injectie, {
    if (input$show_injectie == TRUE) {
      shinyjs::show(selector = "div.sankey_injectie")
    } else {
      shinyjs::hide(selector = "div.sankey_injectie")
    }
  })
  observeEvent(input$show_operatie, {
    if (input$show_operatie == TRUE) {
      shinyjs::show(selector = "div.sankey_operatie")
    } else {
      shinyjs::hide(selector = "div.sankey_operatie")
    }
  })

  edit_question <- reactiveVal()

  create_modal <- function(question) {

    edit_question(question)

    question_text <- dt_questions[Variable == question, `Informatie/mouse over NL`]
    input_id <- paste0(question, "_modal_in")
    label <- dt_questions[Variable == question, `NL label variabele naam`]

    showModal(
      modalDialog(
        title = "Vul vraag in",
        question_text,
        hr(style = "color: grey"),
        selectizeInput(inputId = input_id,
                       label = i18n()$t(label),
                       choices = c(seq(1, 10, by = 1)),
                       selected = v$dt_input[[question]]
        ),
        size = 'm',
        footer = tagList(
          modalButton("Cancel"),
          actionButton("ok", "OK")
        )
      )
    )

  }

  fct_edit_question <- function() {
    removeModal()
    edit_question <- edit_question()
    v$dt_input[[edit_question]] <- as.numeric(input[[paste0(edit_question, "_modal_in")]])
    updateSelectizeInput(session = session,
                         inputId = paste0(edit_question, "_in"),
                         selected = as.numeric(input[[paste0(edit_question, "_modal_in")]])
    )
  }

  onclick("edit_icon_nrspainload_score", create_modal("nrspainload_score"))
  onclick("edit_icon_nrsfunction_score", create_modal("nrsfunction_score"))
  onclick("edit_icon_ipqconcern_SQ001", create_modal("ipqconcern_SQ001"))
  onclick("edit_icon_ipqemotionalresponse_SQ001", create_modal("ipqemotionalresponse_SQ001"))

  onclick("ok", fct_edit_question())

}
