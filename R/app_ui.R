#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @importFrom bslib page input_task_button
#' @noRd
app_ui <- function(request) {
  tagList(
    golem_add_external_resources(),

    page(
      theme = bs_theme(version = 5),
      div(
        div(
          id = "url_input_container",
          h1("Shiny Copy", class = "text-primary text-center"),
          tags$div(
            class = "input-group",
            style = "width: 50%;",
            tags$span(
              class = "input-group-text",
              "URL"
            ),
            tags$input(
              id = "url_input",
              type = "text",
              class = "shiny-input-text form-control",
              value="https://thinkr.fr/",
              placeholder = "https://thinkr.fr/"
            ),
            input_task_button(
              id = "analyze_btn",
              icon = icon("globe"),
              label = " Analyze",
              label_busy = "Extracting...",
              icon_busy = icon("magnifying-glass"),
              class = "btn btn-primary"
            )
          )
        ),
        uiOutput("scroll")
      ),
      div(
        id = "result_container",
        uiOutput("result")
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
      app_title = "css2r"
    )
  )
}
