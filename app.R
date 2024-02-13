# Launch the ShinyApp (Do not remove this comment)

pkgload::load_all()
options( "golem.app.prod" = FALSE, "golem.pkg.name" = "VeniModellen")
options(shiny.port = 8080)
#options(auth0_config_file = app_sys("app/_auth0.yml"))
run_app()
