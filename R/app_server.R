#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  rv <- reactiveValues(site = NULL)

  observeEvent(input$analyze_btn, {
    rv$result <- NULL
    rv$scroll <- NULL

    tryCatch(
      {
        rv$site <- css2r$new(url = input$url_input)

        if (!is.null(rv$site$html_page)) {
          if (!is.null(rv$site$domain_css_links) & length(rv$site$domain_css_links) > 0) {
            rv$continue <- input$analyze_btn
          } else {
            showModal(
              modalDialog(
                title = "Error",
                HTML("No CSS links found on the website. <br> ShinyCopy doesn\'t support inline CSS yet."),
                HTML("ShinyCopy is looking for CSS links starting with domain name (e.g. https://thinkr.fr/...).<br>"),
                size = "m",
                easyClose = TRUE
              )
            )
          }
        } else {
          showModal(
            modalDialog(
              title = "Error",
              HTML("An error occurred while analyzing the website. <br> Maybe a wrong URL?"),
              size = "m",
              easyClose = TRUE
            )
          )
        }
      },
      error = function(e) {
        showModal(
          modalDialog(
            title = "Error",
            "An error occurred while analyzing the website.",
            size = "m",
            easyClose = TRUE
          )
        )
      }
    )
  })

  observeEvent(rv$continue, {
    rv$scroll <- tagList(
      tags$a(
        id = "scroll_down",
        shiny::icon("circle-down fa-2x"),
        href = "#result_container"
      )
    )

    session$sendCustomMessage(
      type = "apply_gradient",
      message = list(
        colors = rv$site$top_colors$top_colors$Color
      )
    )

    session$setCurrentTheme(rv$site$shiny_theme)
  })

  observeEvent(rv$continue, {
    rv$domain <- tagList(
      h2(paste0("Domain", ": ", rv$site$domain))
    )

    rv$result <- tagList(
      div(
        class = "container-fluid",
        div(
          class = "row p-5",
          div(
            class = "col-lg-6 col-md-12",
            h1(paste0("Domain: ", rv$site$domain)),
            span(
              "\U0001f517 Website:  ",
              a(
                href = rv$site$url,
                rv$site$url,
                target = "_blank"
              )
            ),
            div(
              class = "mt-3",
              p(paste0(length(rv$site$domain_css_links), " CSS files found")),
              tags$ul(
                class = "list-group list-group-flush list-group-numbered",
                lapply(
                  rv$site$domain_css_links,
                  function(css_file) {
                    tags$li(
                      class = "list-group-item bg-transparent",
                      a(
                        href = css_file,
                        css_file,
                        class = "text-break",
                        target = "_blank"
                      )
                    )
                  }
                )
              )
            )
          ),
          div(
            class = "col-lg-6 col-md-12",
            div(
              h1("Top colors"),
              tags$ul(
                class = "list-group list-group-flush list-group-numbered",
                lapply(
                  rv$site$top_colors$top_colors$Color,
                  function(color) {
                    tags$li(
                      class = "list-group-item bg-transparent",
                      div(
                        class = "d-flex justify-content-between",
                        span(
                          style = paste0("background-color: ", color, "; width: 60px; height: 20px; display: inline-block;"),
                          ""
                        ),
                        color
                      )
                    )
                  }
                )
              )
            ),
            if (!is.null(rv$site$fonts)) {
              div(
                class = "mt-3",
                h1("Google Fonts"),
                tags$ul(
                  class = "list-group list-group-flush list-group-numbered",
                  lapply(
                    rv$site$fonts,
                    function(font) {
                      tags$li(
                        class = "list-group-item bg-transparent",
                        font[1]
                      )
                    }
                  )
                )
              )
            },
            div(
              class = "mt-3",
              h1("Reuse the code below to apply the theme to your Shiny app:"),
              h6(HTML("Add the following to your <code>app_ui.R</code> file:")),
              tags$pre(
                id = "shiny_code",
                style = "background-color: #f8f9fa; border-radius: 0.25rem;",
                rv$site$shiny_code[1]
              )
            )
          )
        ),
        div(
          class = "row p-5",
          h1("All colors"),
          tableOutput("all_colors")
        )
      )
    )
  })

  output$result <- renderUI({
    req(rv$continue)

    rv$result
  })

  output$all_colors <- renderTable(
    {
      rv$site$all_colors$Hex <- rv$site$all_colors$Color
      rv$site$all_colors$Color <- paste0(
        "<span style=\'background-color: ", rv$site$all_colors$Hex, "; width: 60px; height: 20px; display: inline-block;\'></span>"
      )
      rv$site$all_colors
    },
    sanitize.text.function = function(x) x,
    bordered = NULL,
    striped = TRUE,
    hover = TRUE
  )

  output$scroll <- renderUI({
    rv$scroll
  })
}
