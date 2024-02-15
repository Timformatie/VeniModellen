#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import bslib
#' @import shiny
#' @import shinyfullscreen
#' @import shiny.i18n
#' @noRd
app_ui <- function(request) {
  i18n <- golem::get_golem_options(which = "translator")
  i18n$set_translation_language("nl")

  tagList(
    # # Leave this function for adding external resources
    golem_add_external_resources(),
    useShinyjs(),
    usei18n(i18n),
    page_fluid(
      page_sidebar(
        title = "Veni Modellen",
        sidebar = sidebar(
          title = "Model input",
          p(i18n$t("Op dit moment worden de gegevens getoond voor patientnummer xxx")),
          hr(style = "color: grey"),
          p(i18n$t("Toon uitkomsten voor:")),
          checkboxInput(inputId = "show_therapie",
                        label = i18n$t("Therapie"),
                        value = TRUE
          ),
          checkboxInput(inputId = "show_operatie",
                        label = i18n$t("Operatie"),
                        value = TRUE
          ),
          hr(style = "color: grey"),
          selectizeInput(inputId = "age_in",
                         label = i18n$t("Leeftijd"),
                         choices = c(seq(18, 90, by = 1)),
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
                             label = i18n$t("Kies een domein:"),
                             choices = NULL
                             ),
              sliderInput("pmg_slider",
                          "",
                          min = 0,
                          max = 10,
                          value = c(0,10),
                          width = 750,
                          dragRange = FALSE
                          ),
              textOutput("MPG_text") %>% tagAppendAttributes(class = "MPG_text")
            )
          )
        ),
        card(
          card_header("Sankey plot"),
          card_body(
            fullscreen_this(highchartOutput("sankey_therapie")),
            hr(id = "divider", style = "color: grey"),
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
