#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import bslib
#' @import shiny
#' @import shinyfullscreen
#' @noRd
app_ui <- function(request) {
  tagList(
    # # Leave this function for adding external resources
    golem_add_external_resources(),
    useShinyjs(),
    page_fluid(
      page_sidebar(
        title = "Veni Modellen",
        sidebar = sidebar(
          title = "Model input",
          p("Op dit moment worden de gegevens getoond voor patientnummer xxx"),
          hr(style = "color: grey"),
          p("Toon uitkomsten voor:"),
          checkboxInput(inputId = "show_therapie",
                        label = "Therapie",
                        value = TRUE
          ),
          checkboxInput(inputId = "show_operatie",
                        label = "Operatie",
                        value = TRUE
          ),
          hr(style = "color: grey"),
          selectizeInput(inputId = "age_in",
                         label = "Age",
                         choices = c(seq(18, 90, by = 1)),
                         selected = NULL
          ),
          selectizeInput(inputId = "weight_in",
                         label = "Weight",
                         choices = c(seq(40, 200, by = 1)),
                         selected = NULL
          ),
          selectizeInput(inputId = "duration_in",
                         label = "Duur klachten (maanden)",
                         choices = c(seq(1, 12, by = 1)),
                         selected = NULL
          ),
          hr(style = "color: grey")
        ),
        layout_column_wrap(
          width = 0.5,
          card(
            style = "background-color: rgb(233, 233, 233)",
            card_body(
              class = "slider-card align-items-center",
              selectizeInput(inputId = "domain_in",
                             label = "Kies een domein:",
                             choices = c("Pijn", "Tintelingen", "Doofheid", "Kracht"),
                             selected = "Pijn"
                             ),
              sliderInput("pmg_slider",
                          "",
                          min = 0,
                          max = 10,
                          value = c(3,10),
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
            fullscreen_this(highchartOutput("sankey_3")),
            hr(id = "divider", style = "color: grey"),
            fullscreen_this(highchartOutput("sankey_2", width = "59%", height = 200)),
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
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "BasisShinyDashboard"
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
