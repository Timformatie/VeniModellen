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
    message("update language")
    # Update language
    update_lang(session = session, language = input$language_in)
  })

  # Initialiseer reactiveVal's
  selected_domain <- reactiveVal()
  negative_goal <- reactiveVal(NULL)
  show_sidebar <- reactiveVal(TRUE)

  # Initialiseer datatable with input values ----
  v <- reactiveValues(
    input = list(
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
    )
  )

  # Vul datatable met initiële waarden ----
  observeEvent(session$clientData$url_search, {
    message("create datatable with initial values from URL")

    # Extract query parameters from url
    params <- parseQueryString(URLdecode(session$clientData$url_search))
    params <- lapply(params, as.numeric)

    # Initiate default values for diagnosis, track and track type.
    # Track and track type depend on diagnosis.
    v$input$Diagnose <- "Trigger"
    v$input$Track <- dt_diagnosis_track[
      Diagnose_dt_train == v$input$Diagnose, Track
    ]
    v$input$Track_type <- dt_diagnosis_track[
      Diagnose_dt_train == v$input$Diagnose, `Track Type`
    ]

    # Update url based values
    if (!is.null(params$age)) {
      v$input$Age <- params$age
    }
    if (!is.null(params$weight)) {
      v$input$weight <- params$weight
    }
    if (!is.null(params$complaints)) {
      v$input$howLongComplaints <- params$complaints
    }
    if (!is.null(params$height)) {
      v$input$height <- params$height
    }
    if (!is.null(params$nrspainload)) {
      v$input$nrspainload_score <- params$nrspainload
    }
    if (!is.null(params$nrsfunction)) {
      v$input$nrsfunction_score <- params$nrsfunction
    }
    if (!is.null(params$ipqconcern)) {
      v$input$ipqconcern_SQ001 <- params$ipqconcern
    }
    if (!is.null(params$ipqemotionalresponse)) {
      v$input$ipqemotionalresponse_SQ001 <- params$ipqemotionalresponse
    }
    if (!is.null(params$primarygoal)) {
      v$input$PrimaryGoal.x <- recode_primary_goal(params$primarygoal)
    }
    if (!is.null(params$primpsnint)) {
      v$input$PrimPSN_Int <- params$primpsnint
    } else {
      v$input$PrimPSN_Int <- max(input$pmg_slider)
    }
    if (!is.null(params$primpsnsatisf)) {
      v$input$PrimPSN_Satisf <- params$primpsnsatisf
    } else {
      v$input$PrimPSN_Satisf <- min(input$pmg_slider)
    }

    # Determine sidebar status
    if (!is.null(params$sidebar)) {
      show_sidebar(params$sidebar == 1)
    }

  })

  # Sidebar is always shown when one or more inputs are missing.
  # If no input is missing, hide warning text
  # and toggle sidebar according to status.
  observeEvent(v$input, {
    message("check if input is missing and hide/show warning and toggle sidebar")
    if (!any(sapply(v$input, is.null))) {
      shinyjs::hide("warning_box")

      if (show_sidebar()) {
        toggle_sidebar("sidebar", open = TRUE)
      } else {
        toggle_sidebar("sidebar", open = FALSE)
      }
    }
  })

  # Initialize inputs with current values ----
  observe({
    message("initialize inputs with current values")

    updateSelectizeInput(
      session = session,
      inputId = "diagnose_in",
      choices = setNames(
        c(
          "Carpal Tunnel Syndrome", "CMC-1 OA", "Dupuytren fingers",
          "M. de Quervain", "TFCC", "Trigger"
        ),
        c(
          i18n()$t("Carpaal Tunnel Syndroom"), i18n()$t("CMC-1 artrose"),
          i18n()$t("M. Dupuytren"), i18n()$t("M. De Quervain"),
          i18n()$t("TFCC letsel"), i18n()$t("Trigger finger")
        )
      ),
      selected = isolate(v$input$Diagnose)
    )

    updateSelectizeInput(
      session = session,
      inputId = "age_in",
      choices = setNames(
        c("", seq(16, 120)),
        c(i18n()$t("Maak een keuze"), seq(16, 120))
      ),
      selected = isolate(v$input$Age)
    )

    updateSelectizeInput(
      session = session,
      inputId = "weight_in",
      choices = setNames(
        c("", seq(30, 200)),
        c(i18n()$t("Maak een keuze"), seq(30, 200))
      ),
      selected = isolate(v$input$weight)
    )

    updateSelectizeInput(
      session = session,
      inputId = "duration_in",
      choices = setNames(
        c("", seq(0, 1080)),
        c(i18n()$t("Maak een keuze"), seq(0, 1080))
      ),
      selected = isolate(v$input$howLongComplaints)
    )

    updateSelectizeInput(
      session = session,
      inputId = "height_in",
      choices = setNames(
        c("", seq(100, 230)),
        c(i18n()$t("Maak een keuze"), seq(100, 230))
      ),
      selected = isolate(v$input$height)
    )

    updateSelectizeInput(
      session = session,
      inputId = "ipqconcern_SQ001_in",
      choices = setNames(
        c("", seq(0, 10)),
        c(i18n()$t("Maak een keuze"), seq(0, 10))
      ),
      selected = isolate(v$input$ipqconcern_SQ001)
    )

    updateSelectizeInput(
      session = session,
      inputId = "nrspainload_score_in",
      choices = setNames(
        c("", seq(0, 10)),
        c(i18n()$t("Maak een keuze"), seq(0, 10))
      ),
      selected = isolate(v$input$nrspainload_score)
    )

    updateSelectizeInput(
      session = session,
      inputId = "nrsfunction_score_in",
      choices = setNames(
        c("", seq(0, 10)),
        c(i18n()$t("Maak een keuze"), seq(0, 10))
      ),
      selected = isolate(v$input$nrsfunction_score)
    )

    updateSelectizeInput(
      session = session,
      inputId = "ipqemotionalresponse_SQ001_in",
      choices = setNames(
        c("", seq(0, 10)),
        c(i18n()$t("Maak een keuze"), seq(0, 10))
      ),
      selected = isolate(v$input$ipqemotionalresponse_SQ001)
    )

    updateSelectizeInput(
      session = session,
      inputId = "primPSN_int_in",
      choices = setNames(
        c("", seq(0, 10)),
        c(i18n()$t("Maak een keuze"), seq(0, 10))
      ),
      selected = isolate(v$input$PrimPSN_Int)
    )

    updateSelectizeInput(
      session = session,
      inputId = "primPSN_satisf_in",
      choices = setNames(
        c("", seq(0, 10)),
        c(i18n()$t("Maak een keuze"), seq(0, 10))
      ),
      selected = isolate(v$input$PrimPSN_Satisf)
    )

    updateSelectizeInput(
      session = session,
      inputId = "domain_in",
      choices = setNames(
        c(
          "pijn", "tintelingen", "doofheid", "kracht", "activiteiten uitvoeren",
          "soepelheid/beweeglijkheid", "uiterlijk", "werk uitvoeren"
        ),
        c(
          i18n()$t("Pijn"), i18n()$t("Tintelingen"), i18n()$t("Doofheid"),
          i18n()$t("Kracht"), i18n()$t("Activiteiten uitvoeren"),
          i18n()$t("Soepelheid/beweeglijkheid"), i18n()$t("Uiterlijk"),
          i18n()$t("Werk uitvoeren")
        )
      ),
      selected = isolate(v$input$PrimaryGoal.x)
    )
    waiter_hide()
  })

  # If diagnosis is Dupuytren, hand therapy and injection plots should be hidden
  observeEvent(input$diagnose_in, {
    message("hide therapy and injection plots when patient has specific diagnosis")

    req(input$diagnose_in)
    if (input$diagnose_in == "Dupuytren fingers") {
      updateCheckboxInput(inputId = "show_therapie",
                          value = FALSE
      )
      updateCheckboxInput(inputId = "show_injectie",
                          value = FALSE
      )
    } else {
      updateCheckboxInput(inputId = "show_therapie",
                          value = TRUE
      )
      updateCheckboxInput(inputId = "show_injectie",
                          value = TRUE
      )
    }
  })

  # Get current and goal values for selected domain and update slider
  observe({
    message("get current and goal values for selected domain and update slider")

    req(isolate(v$input$PrimPSN_Int))
    req(isolate(v$input$PrimPSN_Satisf))

    current_val <- isolate(v$input$PrimPSN_Int)
    goal_val <- isolate(v$input$PrimPSN_Satisf)
    range_vector <- if(current_val > goal_val) {c(goal_val, current_val)} else {c(current_val, goal_val)}
    updateSliderInput(session = session,
                      inputId = "pmg_slider",
                      value = range_vector
                      )
  })

  # Update slider layout ----
  # Update slider layout when domain input changes
  observeEvent(input$domain_in, {
    message("Update slider layout when domain input changes")

    req(!input$domain_in == "")
    # Update selected domain reactiveVal
    selected_domain(input$domain_in)
    v$input$PrimaryGoal.x <- selected_domain()

    req(v$input$PrimPSN_Int)
    req(v$input$PrimPSN_Satisf)

    current_val <- v$input$PrimPSN_Int
    goal_val <- v$input$PrimPSN_Satisf
    goal <- selected_domain()
    negative_goal(FALSE)
    if (goal %in% reverse_domains & (goal_val < current_val)) {
      negative_goal(TRUE)
    } else if (!(goal %in% reverse_domains) & goal_val > current_val) {
      negative_goal(TRUE)
    }

    update_slider_layout(goal, current_val, goal_val)

  }, ignoreInit = TRUE)

  # Determine if button for resetting goal values should be shown
  observeEvent(negative_goal(), {
    message("Determine if button for resetting goal values should be shown")

    if (negative_goal()) {
      shinyjs::show(id = "reset_negative_goal_btn")
    } else {
      hide(id = "reset_negative_goal_btn")
    }

  })

  # Change text ----
  # Change text according to domain and slider values
  output$MPG_text <- renderText({
    message("Change text according to domain and slider values")

    req(!selected_domain() == "")
    req(v$input$PrimPSN_Int)
    req(v$input$PrimPSN_Satisf)

    current_val <- v$input$PrimPSN_Int
    goal_val <- v$input$PrimPSN_Satisf

    selected_domain <- tolower(i18n()$t(input$domain_in))

    if (negative_goal()) {
      text <- paste0(i18n()$t("Let op: u heeft een verslechtering als doel gekozen. Kies een ander doel of klik op de knop hieronder."))
      addClass(selector = ".MPG_text", class = "rood_text")
    } else {
      if (input$language_in == "nl") {
        text <- str_glue("U scoort nu een {current_val} op {selected_domain}. U bent tevreden met een score van {goal_val}.")
      } else {
        text <- str_glue("Your current score for {selected_domain} is {current_val}. Your goal is a score of {goal_val}.")
      }
      shinyjs::removeClass(selector = ".MPG_text", class = "rood_text")
    }

    return(text)
  })



  # Reset goal values
  observeEvent(input$reset_negative_goal_btn, {
    message("Negative goal reset")

    req(v$input$PrimPSN_Int)
    req(v$input$PrimPSN_Satisf)
    negative_goal(FALSE)

    current_val <- v$input$PrimPSN_Int
    if (selected_domain() %in% reverse_domains) {
      # slider max is 10
      if (current_val == 10) {
        v$input$PrimPSN_Satisf = 10
        v$input$PrimPSN_Int = 9
      } else {
        v$input$PrimPSN_Satisf = current_val + 1
      }
    } else {
      # slider min is 0
      if (current_val == 0) {
        v$input$PrimPSN_Satisf = 0
        v$input$PrimPSN_Int = 1
      } else {
        v$input$PrimPSN_Satisf = current_val - 1
      }
    }
    goal_val <- v$input$PrimPSN_Satisf
    current_val <- v$input$PrimPSN_Int

    range_vector <- if(current_val > goal_val) {c(goal_val, current_val)} else {c(current_val, goal_val)}

    updateSliderInput(session = session,
                      inputId = "pmg_slider",
                      value = range_vector
    )

  })

  # Update input data when input changes ----
  # Update data with current and goal value inputs when slider values change
  observeEvent(input$pmg_slider, {

    message("slider change - update current and goal values")
    req(!input$domain_in == "")
    req((!is.null(negative_goal())))
    req((!negative_goal()))

    if (selected_domain() %in% reverse_domains) {
      current_val <- min(input$pmg_slider)
      goal_val <- max(input$pmg_slider)
    } else {
      current_val <- max(input$pmg_slider)
      goal_val <- min(input$pmg_slider)
    }

    v$input$PrimPSN_Int <- current_val
    v$input$PrimPSN_Satisf <- goal_val

    update_slider_layout(selected_domain(), current_val, goal_val)

  }, ignoreInit = TRUE)

  observeEvent(input$age_in, {
    req(input$age_in)
    v$input[["Age"]] <- as.numeric(input$age_in)
  })

  observeEvent(input$weight_in, {
    req(input$weight_in)
    v$input[["weight"]] <- as.numeric(input$weight_in)
  })

  observeEvent(input$duration_in, {
    req(input$duration_in)
    v$input[["howLongComplaints"]] <- as.numeric(input$duration_in)
      })

  observeEvent(input$diagnose_in, {
    req(!input$diagnose_in == "")
    v$input[["Diagnose"]] <- input$diagnose_in
    v$input[["Track"]] <- dt_diagnosis_track[Diagnose_dt_train == v$input$Diagnose, Track]
    v$input[["Track_type"]] <- dt_diagnosis_track[Diagnose_dt_train == v$input$Diagnose, `Track Type`]

    updateSelectizeInput(session = session,
                         inputId = "track_in",
                         selected = isolate(v$input$Track)
    )

    updateSelectizeInput(session = session,
                         inputId = "track_type_in",
                         selected = isolate(v$input$Track_type)
    )

  })

  observeEvent(input$ipqemotionalresponse_SQ001_in, {
    req(input$ipqemotionalresponse_SQ001_in)
    v$input[["ipqemotionalresponse_SQ001"]] <- as.numeric(input$ipqemotionalresponse_SQ001_in)
  })

  observeEvent(input$ipqconcern_SQ001_in, {
    req(input$ipqconcern_SQ001_in)
    v$input[["ipqconcern_SQ001"]] <- as.numeric(input$ipqconcern_SQ001_in)
  })

  observeEvent(input$nrspainload_score_in, {
    req(input$nrspainload_score_in)
    v$input[["nrspainload_score"]] <- as.numeric(input$nrspainload_score_in)
  })

  observeEvent(input$nrsfunction_score_in, {
    req(input$nrsfunction_score_in)
    v$input[["nrsfunction_score"]] <- as.numeric(input$nrsfunction_score_in)
  })

  observeEvent(input$height_in, {
    req(input$height_in)
    v$input[["height"]] <- as.numeric(input$height_in)
  })

  # Calculate PMG
  PMG_val <- reactive({
    message("calculate PMG value")

    req(v$input$PrimPSN_Int)
    req(v$input$PrimPSN_Satisf)
    PMG <- abs(as.numeric(v$input$PrimPSN_Satisf) - as.numeric(v$input$PrimPSN_Int))
    return(PMG)
  })

  # 1. Sankey therapie ----
  ## predictions ----
  dt_pred_therapie_operatie <- reactive({
    req(!is.null(selected_domain()))
    req(!any(sapply(v$input, is.null)))

    # Goal should be positive, otherwise don't show predictions
    validate(
      need(!negative_goal(), "U heeft een verslechtering als doel gekozen.")
    )

    # Get input data
    dt_input <- as.data.table(v$input)

    # Transform goal from dutch to english
    dt_input$PrimaryGoal.x <- transform_goal_to_english(dt_input$PrimaryGoal.x)

    # Injection checkbox determines treatment input
    if (!input$injection_in) {
      dt_input$Behandeling_clustered <- "Hand therapy ± orthosis"
    } else {
      dt_input$Behandeling_clustered <- "Hand therapy ± orthosis + injection"
    }

    # When domain score lower is better (like pain), reverse variable scale
    if (!selected_domain() %in% reverse_domains) {
      dt_input$PrimPSN_Int <- 10 - dt_input$PrimPSN_Int
      dt_input$PrimPSN_Satisf <- 10 - dt_input$PrimPSN_Satisf
    }

    # Predict probs for therapy
    pred_therapie <- predict(model, dt_input, type = "prob")

    # Change treatment to surgery according to diagnosis for second part of Sankey
    dt_input$Behandeling_clustered <- dt_diagnosis_track[Diagnose_dt_train == v$input$Diagnose, Behandeling]

    # Predict probs for surgery
    pred_therapie_operatie <- predict(model, dt_input, type = "prob")

    # Merge probs into a single datatable
    dt_pred <- data.table(rbind(pred_therapie, pred_therapie_operatie))

    return(dt_pred)
  })

  ## data for plot ----
  dt_results_therapie_operatie <- reactive({
    dt_pred <- dt_pred_therapie_operatie()
    show_operation_results <- input$show_operation_results_in

    dt_sankey_therapie <- create_plot_datatable(dt_pred = dt_pred, language = input$language_in,
                                                treatment_type = "therapie",
                                                PMG = PMG_val(),
                                                show_operation_results = show_operation_results
                                                )
    return(dt_sankey_therapie)
  })


  # 2. Sankey injectie ----
  ## predictions ----
  dt_pred_injectie <- reactive({
    req(!is.null(selected_domain()))
    req(!any(sapply(v$input, is.null)))

    # Goal should be positive
    validate(
      need(!negative_goal(), "U heeft een verslechtering als doel gekozen.")
    )

    # Get input data
    dt_input <- as.data.table(v$input)

    # Transform goal from dutch to english
    dt_input$PrimaryGoal.x <- transform_goal_to_english(dt_input$PrimaryGoal.x)

    # When domain score lower is better (like pain), reverse variable scale
    if (!selected_domain() %in% reverse_domains) {
      dt_input$PrimPSN_Int <- 10 - dt_input$PrimPSN_Int
      dt_input$PrimPSN_Satisf <- 10 - dt_input$PrimPSN_Satisf
    }

    # Treatment input
    dt_input$Behandeling_clustered <- "Injection"
    # Predict probs for therapy
    pred_injectie <- predict(model, dt_input, type = "prob")

    # Change treatment to surgery according to diagnosis for second part of Sankey
    dt_input$Behandeling_clustered <- dt_diagnosis_track[Diagnose_dt_train == v$input$Diagnose, Behandeling]
    # Predict probs for surgery
    pred_injectie_operatie <- predict(model, dt_input, type = "prob")

    dt_pred <- data.table(rbind(pred_injectie, pred_injectie_operatie))

    return(dt_pred)
  })

  ## data for plot ----
  dt_results_injectie <- reactive({
    dt_pred <- dt_pred_injectie()
    dt_sankey_injectie <- create_plot_datatable(dt_pred = dt_pred, language = input$language_in,
                                                treatment_type = "injectie",
                                                PMG = PMG_val())
    return(dt_sankey_injectie)
  })


  # 3. Sankey operatie ----
  ## predictions ----
  dt_pred_operatie <- reactive({
    req(!is.null(selected_domain()))
    req(!any(sapply(v$input, is.null)))

    # Goal should be positive
    validate(
      need(!negative_goal(), "U heeft een verslechtering als doel gekozen.")
    )

    # Get input data
    dt_input <- as.data.table(v$input)

    # Transform goal from dutch to english
    dt_input$PrimaryGoal.x <- transform_goal_to_english(dt_input$PrimaryGoal.x)

    # Determine treatment/surgery based on diagnosis
    dt_input$Behandeling_clustered <- dt_diagnosis_track[Diagnose_dt_train == v$input$Diagnose, Behandeling]

    # When domain score lower is better (like pain), reverse variable scale
    if (!selected_domain() %in% reverse_domains) {
      dt_input$PrimPSN_Int <- 10 - dt_input$PrimPSN_Int
      dt_input$PrimPSN_Satisf <- 10 - dt_input$PrimPSN_Satisf
    }

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

  # Hide/show plots according to user input ----
  observeEvent(input$show_therapie, {
    req(!is.null(input$show_therapie))
    if (input$show_therapie == TRUE) {
      shinyjs::show(selector = "div.sankey_therapie")
    } else {
      hide(selector = "div.sankey_therapie")
    }
  })
  observeEvent(input$show_injectie, {
    req(!is.null(input$show_injectie))
    if (input$show_injectie == TRUE) {
      shinyjs::show(selector = "div.sankey_injectie")
    } else {
      hide(selector = "div.sankey_injectie")
    }
  })
  observeEvent(input$show_operatie, {
    req(!is.null(input$show_operatie))
    if (input$show_operatie == TRUE) {
      shinyjs::show(selector = "div.sankey_operatie")
    } else {
      hide(selector = "div.sankey_operatie")
    }
  })

  # Modify answers modals ----
  edit_question <- reactiveVal()

  # Open modal when user clicks pencil icon to modify question answer
  onclick("edit_icon_nrspainload_score", {
    create_modal(input_var = "nrspainload_score", dt_input = v$input, i18n = reactive(i18n()))
    edit_question("nrspainload_score")
    })
  onclick("edit_icon_nrsfunction_score", {
    create_modal(input_var = "nrsfunction_score", dt_input = v$input, i18n = reactive(i18n()))
    edit_question("nrsfunction_score")
  })
  onclick("edit_icon_ipqconcern_SQ001", {
    create_modal(input_var = "ipqconcern_SQ001", dt_input = v$input, i18n = reactive(i18n()))
    edit_question("ipqconcern_SQ001")
  })
  onclick("edit_icon_ipqemotionalresponse_SQ001", {
    create_modal(input_var = "ipqemotionalresponse_SQ001", dt_input = v$input, i18n = reactive(i18n()))
    edit_question("ipqemotionalresponse_SQ001")
  })

  # Modify model input and UI input when user clicks "ok" button in modal
  onclick("ok", {
    # determine variable to be modified
    modify_var <- edit_question()
    # modify variable in model input
    v$input[[modify_var]] <- as.numeric(input[[paste0(modify_var, "_modal_in")]])
    # modify corresponding UI input
    updateSelectizeInput(session = session,
                         inputId = paste0(modify_var, "_in"),
                         selected = as.numeric(input[[paste0(modify_var, "_modal_in")]])
    )
    removeModal()
  })

}
