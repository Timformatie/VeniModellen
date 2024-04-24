#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import bslib
#' @import shiny
#' @import shinyfullscreen
#' @import shiny.i18n
#' @import waiter
#' @noRd
app_ui <- function(request) {
  i18n <- golem::get_golem_options(which = "translator")
  i18n$set_translation_language("nl")

  tagList(
    # # Leave this function for adding external resources
    golem_add_external_resources(),
    useShinyjs(),
    usei18n(i18n),
    useWaiter(),
    waiterShowOnLoad(html = spin_three_bounce(), color = "#4876b3"),   # show loading screen while app is getting ready
    page_fluid(
      page_sidebar(
        title = "Veni Modellen",
        sidebar = sidebar(
          width = 300,
          title = "Model input",
          p(i18n$t("Op dit moment worden de gegevens getoond voor patientnummer xxx")),
          hr(style = "color: grey"),
          p(i18n$t("Toon uitkomsten voor:")),
          checkboxInput(inputId = "show_therapie",
                        label = i18n$t("Therapie"),
                        value = TRUE
          ),
          checkboxInput(inputId = "show_injectie",
                        label = i18n$t("Injectie"),
                        value = TRUE
          ),
          checkboxInput(inputId = "show_operatie",
                        label = i18n$t("Operatie"),
                        value = TRUE
          ),
          hr(style = "color: grey"),
          selectizeInput(inputId = "diagnose_in",
                         label = i18n$t("Diagnose"),
                         choices = NULL,
                         selected = NULL
          ),
          selectizeInput(inputId = "track_in",
                         label = i18n$t("Meettraject"),
                         choices = c(seq(1, 12, by = 1)),
                         selected = NULL
          ),
          selectizeInput(inputId = "track_type_in",
                         label = i18n$t("Meettraject type"),
                         choices = c(seq(1, 12, by = 1)),
                         selected = NULL
          ),
          selectizeInput(inputId = "age_in",
                         label = i18n$t("Leeftijd"),
                         choices = c(seq(16, 90, by = 1)),
                         selected = NULL
          ),
          selectizeInput(inputId = "weight_in",
                         label = i18n$t("Gewicht"),
                         choices = c(seq(40, 200, by = 1)),
                         selected = NULL
          ),
          selectizeInput(inputId = "duration_in",
                         label = i18n$t("Duur klachten (maanden)"),
                         choices = c(seq(1, 12, by = 1)),
                         selected = NULL
          ),
          # selectizeInput(inputId = "behandeling_clustered_in",
          #                label = i18n$t("Behandeling"),
          #                choices = c(seq(1, 12, by = 1)),
          #                selected = NULL
          # ),
          selectizeInput(inputId = "height_in",
                         label = i18n$t("Lengte"),
                         choices = c(seq(1, 12, by = 1)),
                         selected = NULL
          ),
          div(
            style = "display: flex",
            selectizeInput(inputId = "nrspainload_score_in",
                           label = i18n$t("NRS pijn bij belasting score"),
                           choices = c(seq(1, 10, by = 1)),
                           selected = NULL
            ),
            div(icon("pen"), id = "edit_icon_nrspainload_score")
          ),
          div(
            style = "display: flex",
            selectizeInput(inputId = "nrsfunction_score_in",
                           label = i18n$t("NRS functie score"),
                           choices = c(seq(1, 10, by = 1)),
                           selected = NULL
            ),
            div(icon("pen"), id = "edit_icon_nrsfunction_score")
          ),
          div(
            style = "display: flex",
            selectizeInput(inputId = "ipqconcern_SQ001_in",
                           label = i18n$t("IPQ item Concern"),
                           choices = c(seq(1, 10, by = 1)),
                           selected = NULL
            ),
            div(icon("pen"), id = "edit_icon_ipqconcern_SQ001")
          ),
          div(
            style = "display: flex",
            selectizeInput(inputId = "ipqemotionalresponse_SQ001_in",
                           label = i18n$t("IPQ item Emotional Response"),
                           choices = c(seq(1, 10, by = 1)),
                           selected = NULL
            ),
            div(icon("pen"), id = "edit_icon_ipqemotionalresponse_SQ001")
          ),
          # selectizeInput(inputId = "primPSN_int_in",
          #                label = i18n$t("PMG baseline score"),
          #                choices = c(seq(1, 12, by = 1)),
          #                selected = NULL
          # ),
          # selectizeInput(inputId = "primPSN_satisf_in",
          #                label = i18n$t("PMG score nodig om tevreden te zijn"),
          #                choices = c(seq(1, 12, by = 1)),
          #                selected = NULL
          # ),
          hr(style = "color: grey")
        ),
        div(
          style = "display: flex; justify-content:flex-end;",
          radioButtons(
            inputId = "language_in",
            label = "",
            choiceNames = c(
              tagList(img(src = "www/flag_nl.png", height = 15, width = 20)),
              tagList(img(src = "www/flag_en.png", height = 15, width = 20))
            ),
            choiceValues = c("nl", "en"),
            selected = "nl",
            inline = TRUE
          )
        ),
        layout_column_wrap(
          width = 1,
          card(
            style = "background-color: rgb(233, 233, 233)",
            card_body(
              class = "slider-card align-items-center",
              selectizeInput(inputId = "domain_in",
                             label = i18n$t("Primaire doel domein:"),
                             choices = NULL
                             ),
              layout_column_wrap(
                width = NULL,
                style = htmltools::css(grid_template_columns = "1fr 8fr 1fr", align.items = "center"),
                div(
                  class = "smiley-left",
                  img(id = "happy-smiley-left", src = "www/happy-smiley.webp", height = 25, width = 25),
                  img(id = "sad-smiley-left", src = "www/sad-smiley.png", height = 25, width = 25)
                ),
                sliderInput("pmg_slider",
                            "",
                            min = 0,
                            max = 10,
                            value = c(0,10),
                            width = 750,
                            dragRange = FALSE
                ),
                div(
                  class = "smiley-right",
                  img(id = "sad-smiley-right", src = "www/sad-smiley.png", height = 25, width = 25),
                  img(id = "happy-smiley-right", src = "www/happy-smiley.webp", height = 25, width = 25, class = "hide")
                )
              ),
              textOutput("MPG_text") %>% tagAppendAttributes(class = "MPG_text")
            )
          )
        ),
        card(
          class = "sankey_therapie",
          card_header("Sankey therapie (en injectie)"),
          card_body(
            checkboxInput(inputId = "injection_in",
                          label = i18n$t("Injectie"),
                          value = FALSE
            ),
            fullscreen_this(highchartOutput("sankey_therapie"))
          )
        ),
        card(
          class = "sankey_injectie",
          card_header("Sankey injectie"),
          card_body(
            fullscreen_this(highchartOutput("sankey_injectie"))
          )
        ),
        card(
          class = "sankey_operatie",
          card_header("Sankey operatie"),
          card_body(
            fullscreen_this(highchartOutput("sankey_operatie", width = "59%"))
          )
        )
      )
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(ext = 'png'),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "Veni modellen"
    ),
    tags$head(
      tags$link(
        rel = "stylesheet", type = "text/css", href = "www/custom.css"
      )
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()

  )
}
