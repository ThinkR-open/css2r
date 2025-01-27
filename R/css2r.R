#' Extract CSS styles from a website to generate a Shiny theme
#'
#' @description
#' The css2r class analyzes CSS styles from a website and automatically generates
#' a corresponding Shiny theme. It extracts main colors, Google Fonts, and creates
#' compatible bslib code.
#'
#' @details
#' This class uses a step-by-step approach to:
#' * Download the HTML page
#' * Extract CSS links
#' * Analyze used colors
#' * Detect Google Fonts
#' * Generate a compatible Shiny theme
#'
#' @export
#'
#' @importFrom R6 R6Class
#' @importFrom rvest read_html html_nodes html_attr url_absolute
#' @importFrom urltools domain param_get
#' @importFrom curl has_internet
#' @importFrom httr GET content
#' @importFrom cli cli_alert cli_alert_danger cli_alert_info cli_alert_warning cli_alert_success
#' @importFrom purrr map map_chr keep compact
#' @importFrom bslib bs_theme font_google
#'
#' @field url URL of the website to analyze
#' @field domain Website domain
#' @field html_page HTML content of the page
#' @field all_css_links List of all found CSS links
#' @field domain_css_links Filtered CSS links from the domain
#' @field css_content Downloaded CSS content
#' @field all_colors List of all found colors
#' @field top_colors Analyzed main colors
#' @field fonts Detected Google Fonts
#' @field shiny_code Generated Shiny theme code
#' @field shiny_theme Generated Shiny theme
#'
#' @examples
#' \dontrun{
#' # Simple creation
#' site_theme <- css2r$new(url = "https://example.com")
#'
#' # Creation without automatic initialization
#' site_theme <- css2r$new(url = "https://example.com", on_initialize = FALSE)
#' site_theme$download_html()
#' site_theme$extract_css_links()
#' }
css2r <- R6Class(
  classname = "css2r",
  public = list(
    url = NULL,
    domain = NULL,
    html_page = NULL,
    all_css_links = NULL,
    domain_css_links = NULL,
    css_content = NULL,
    all_colors = NULL,
    top_colors = NULL,
    fonts = NULL,
    shiny_code = NULL,
    shiny_theme = NULL,

    #' @description
    #' Initialize a new css2r object
    #' @param url Character string. The URL of the website to analyze
    #' @param on_initialize Logical. If TRUE, starts analysis automatically
    #' @return A new `css2r` object
    initialize = function(url, on_initialize = TRUE) {
      self$url <- url
      self$domain <- domain(url)

      if (isTRUE(on_initialize)) {
        if (self$check_internet()) {
          self$download_html()
          self$extract_css_links()
          self$filter_css_links()
          self$download_css_files()
          self$extract_colors()
          self$analyze_colors()
          self$detect_google_fonts()
          self$generate_shiny_code()
        } else {
          private$danger("No internet connection.\n Please check your network connection before to continue.")
        }
      } else {
        private$success("Ready.\n Start to download your page when you're ready!")
        private$todo('mySite <- css2r$new(url = "', self$url, '", on_initialize = FALSE)' )
        private$todo('mySite$download_page()' )
      }
    },

    #' @description
    #' Check if internet connection is available
    #' @return Logical. TRUE if internet connection is available, FALSE otherwise
    check_internet = function() {
      if (has_internet()) {
        private$success("Internet ok")
        return(invisible(TRUE))
      } else {
        private$danger("Internet nok")
        return(invisible(FALSE))
      }
    },

    #' @description
    #' Download the HTML content of the specified URL
    #' @return Invisible. Updates the html_page field of the object
    download_html = function() {
      tryCatch({
        self$html_page <- read_html(x = self$url)
        private$success("html page downloaded")
      }, error = function(e) {
        private$danger("Failed to download html page")
      })
    },

    #' @description
    #' Extract all CSS stylesheet links from the HTML page
    #' @return Invisible. Updates the all_css_links field of the object
    extract_css_links = function() {
      if (is.null(self$html_page) || length(self$html_page) == 0) {
        private$danger("No html page to use.")
        private$todo("download_html() before to run.")
        return(invisible(FALSE))
      }

      self$all_css_links <- self$html_page |>
        html_nodes("link[rel='stylesheet']") |>
        html_attr("href") |>
        unique()
      private$success("CSS links extracted")
    },

    #' @description
    #' Filter CSS links to keep only those from the same domain
    #' @return Invisible. Updates the domain_css_links field of the object
    filter_css_links = function() {
      if (is.null(self$all_css_links) || length(self$all_css_links) == 0) {
        private$danger("No CSS links to use.")
        private$todo("extract_css_links() before to run.")
        return(invisible(FALSE))
      }

      self$domain_css_links <- self$all_css_links |>
        map_chr(
          .f = ~ ifelse(
            test = startsWith(.x, "http"),
            yes = .x,
            no = url_absolute(.x, self$url)
          )
        ) |>
        keep(
          .p = ~ domain(.x) == self$domain
        )
      private$success("CSS links filtered")
    },

    #' @description
    #' Download the content of all filtered CSS files
    #' @return Invisible. Updates the css_content field of the object
    download_css_files = function() {
      if (is.null(self$domain_css_links) || length(self$domain_css_links) == 0) {
        private$danger("No CSS links available to download.")
        private$todo("filter_css_links() before to run.")
        return(invisible(FALSE))
      }

      self$css_content <- self$domain_css_links |>
        map(
          .f = ~ private$get_css_content(.x)
        ) |>
        compact() |>
        paste(collapse = "\n")
      private$success("CSS downloaded")
    },

    #' @description
    #' Extract all hex color codes from the CSS content
    #' @return Invisible. Updates the all_colors field of the object
    extract_colors = function() {
      if (is.null(self$css_content)) {
        private$danger("CSS content is NULL. Ensure CSS files are downloaded and processed.")
        private$todo("download_css_files() before to run.")
        return(invisible(FALSE))
      }

      pattern <- "#[0-9A-Fa-f]{6}"
      matches <- gregexpr(
        pattern = pattern,
        text = self$css_content,
        perl = TRUE
      )

      colors_hex <- regmatches(
        x = self$css_content,
        m = matches
      ) |>
        unlist() |>
        toupper()

      table_colors_hex <- colors_hex |>
        table() |>
        as.data.frame(
          stringsAsFactors = FALSE
        )
      table_colors_hex <- table_colors_hex[order(table_colors_hex$Freq, decreasing = TRUE),]
      rownames(table_colors_hex) <- NULL
      colnames(table_colors_hex) <- c("Color", "Count")

      self$all_colors <- table_colors_hex
      private$success("Colors extracted successfully")
    },

    #' @description
    #' Analyze extracted colors to identify main color scheme
    #' @return Invisible. Updates the top_colors field of the object
    analyze_colors = function() {
      if (is.null(self$all_colors) || nrow(self$all_colors) == 0) {
        private$danger("No colors available to analyze. Run `extract_colors` first.")
        private$todo("extract_colors() before to run.")
        return(invisible(FALSE))
      }

      b_w <- c("#FFFFFF", "#000000")

      white_black <- self$all_colors[self$all_colors$Color %in% b_w ,]
      other_colors <- self$all_colors[!self$all_colors$Color %in% b_w ,]
      top_colors <- head(other_colors, 4)
      result <- list(
        white_black = white_black,
        top_colors = top_colors
      )

      self$top_colors <- result
      private$success("Colors analyzed successfully.")
    },

    #' @description
    #' Detect and extract Google Fonts information from CSS links
    #' @return Invisible. Updates the fonts field of the object
    detect_google_fonts = function() {
      if (is.null(self$all_css_links) || length(self$all_css_links) == 0) {
        private$danger("No CSS links to use.")
        private$todo("extract_css_links() before to run.")
        return(invisible(FALSE))
      }

      google_font_links <- self$all_css_links |>
        keep(
          ~ grepl(
            pattern = "fonts.googleapis.com",
            x = .x,
            fixed = TRUE
          )
        )

      if (length(google_font_links) > 0) {
        google_fonts_params <- private$extract_google_font_params(
          links = google_font_links
        )
        self$fonts <- google_fonts_params
        private$success("Google Fonts detected and analyzed.")
      } else {
        self$fonts <- NULL
        private$info("No Google Fonts detected.")
      }
    },

    #' @description
    #' Generate Shiny theme code based on extracted colors and fonts
    #' @return Character string. The generated bslib theme code
    generate_shiny_code = function() {
      if (is.null(self$top_colors) || is.null(self$top_colors$top_colors) || nrow(self$top_colors$top_colors) == 0) {
        private$danger("No top colors available.")
        private$todo("analyze_colors() before to run.")
        return(invisible(NULL))
      }

      primary_color <- if (nrow(self$top_colors$top_colors) > 0) self$top_colors$top_colors$Color[1] else "#000000"
      secondary_color <- if (nrow(self$top_colors$top_colors) > 1) self$top_colors$top_colors$Color[2] else "#000000"

      theme_params <- list(
        bg = "#FFFFFF",
        fg = "#000000",
        primary = primary_color,
        secondary = secondary_color
      )

      if (!is.null(self$fonts) && length(self$fonts) > 0) {
        google_fonts <- map_chr(
          .x = self$fonts,
          .f =  ~ {
            font_name <- strsplit(.x$family, ":")[[1]][1]
            return(font_name)
          }
        )

        theme_params$base_font <- font_google(google_fonts[1])
      }

      self$shiny_theme <- do.call(bslib::bs_theme, theme_params)

      theme_code <- paste0(
        'fluidPage(',
        '\n  theme = bslib::bs_theme(',
        '\n    bg = "#FFFFFF",',
        '\n    fg = "#000000",',
        '\n    primary = "', primary_color, '",',
        '\n    secondary = "', secondary_color, '"',
        if (!is.null(theme_params$base_font)) paste0(',\n    base_font = bslib::font_google("', theme_params$base_font$families, '")'),
        '\n  ),',
        '\n  h1("Hello World primary", class = "text-center text-secondary"),',
        '\n  h1("Hello World secondary", class = "text-center text-primary")',
        "\n)"
      )

      self$shiny_code <- theme_code
      private$success("Shiny theme code generated.")
      return(cat(self$shiny_code))
    }
  ),

  private = list(
    print = function(...) {
      private$info("url: ", self$url)
    },

    danger = function(...) {
      cli::cli_alert_danger(cli::col_red(...))
    },

    info = function(...) {
      cli::cli_alert_info(cli::col_blue(...))
    },

    todo = function(...) {
      cli::cli_alert(cli::col_black(...))
    },

    alert = function(...) {
      cli::cli_alert_warning(cli::col_yellow(...))
    },

    success = function(...) {
      cli::cli_alert_success(cli::col_black(...))
    },

    get_css_content = function(link) {
      tryCatch({
        res <- GET(link) |>
          content(
            as = "text",
            encoding = "UTF-8"
          )
        return(invisible(res))
      }, error = function(e) {
        self$alert("Failed to retrieve CSS from:", link)
        return(invisible(NULL))
      })
    },

    extract_google_font_params = function(links) {
      links |>
        purrr::map(
          .f = ~ {
            parsed_url <- urltools::param_get(.x)
            params_decoded <- purrr::map(parsed_url, URLdecode)
            return(params_decoded)
          }
        )
    }
  )
)
