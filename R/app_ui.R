#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import bs4Dash
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    # # Leave this function for adding external resources
    golem_add_external_resources(),
    # # Your application UI logic
    # fluidPage(
    #   h1("BasisShinyDashboard")
    # )
    dashboardPage(
      title = "BasisShinyDashboard",
      # Disable full screen option
      fullscreen = FALSE,
      # Disable the toggle between the default light and dark themes of bs4Dash
      dark = NULL,
      # HEADER ----
      header = bs4DashNavbar(
        # Title of the dashboard displayed on top of sideBar
        title = "<Header title>",
        border = TRUE,
        ## Left UI ----
        leftUi = tagList(
          tags$li(
            class = "dropdown",
            #auth0::logoutButton(class = "logout-button", label = "Uitloggen")
          )
        )#,
        ## Right UI ----
        # rightUi = tagList("Right UI")
      ),
      # SIDEBAR ----
      sidebar = dashboardSidebar(
        # Define using the "light" theme parameters defined above
        skin = "light",
        # No shadow over main body
        elevation = 0,
        minified = FALSE,
        collapsed = FALSE,
        fixed = FALSE,
        id = "dashboard_sidebar",

        ## User panel ----
        sidebarUserPanel(
          image = "",
          name = "<User panel output>"
        ),

        # Space between user panel and sidebar menu
        br(), br(),

        ## sidebar menu ----
        "<Sidebar menu output>",

        ## custom area ----
        customArea = "<Logo>"
      ),

      ## FOOTER ----
      footer = dashboardFooter(
        left = "<Footer>",
        right =  tags$a("Powered by timformatie.", href = "https://timformatie.nl/")
      ),

      ## BODY ----
      body = dashboardBody(
        box(
          width = 12,
          title = "Sankey plot",
          highchartOutput("sankey_1"),
          highchartOutput("sankey_2", height = 250, width = "59%")
        )
      )

      # )
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
