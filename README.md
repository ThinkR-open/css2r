
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `{css2r}`

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

## Installation

You can install the development version of `{css2r}` like so:

``` r
remotes::install_github("ThinkR-open/css2r")
```

## Extract CSS properties from a webpage

``` r
library(css2r)

thinkr <- css2r$new(url = "https://thinkr.fr")
#> ✔ Internet ok
#> ✔ html page downloaded
#> ✔ CSS links extracted
#> ✔ CSS links filtered
#> ✔ CSS downloaded
#> ✔ Colors extracted successfully
#> ✔ Colors analyzed successfully.
#> ✔ Google Fonts detected and analyzed.
#> ✔ Shiny theme code generated.
#> fluidPage(
#>   theme = bslib::bs_theme(
#>     bg = "#FFFFFF",
#>     fg = "#000000",
#>     primary = "#38404C",
#>     secondary = "#0046C8",
#>     base_font = bslib::font_google("Rubik")
#>   ),
#>   h1("Hello World primary", class = "text-center text-secondary"),
#>   h1("Hello World secondary", class = "text-center text-primary")
#> )
```

### Extract CSS files

``` r
thinkr$domain_css_links
#> [1] "https://thinkr.fr/wp-includes/css/dist/block-library/style.min.css?ver=d05679c553c9330ebf77a126f5cbe471"             
#> [2] "https://thinkr.fr/wp-includes/js/mediaelement/mediaelementplayer-legacy.min.css?ver=a0b8817f2ea537894019ee894a03d46f"
#> [3] "https://thinkr.fr/wp-includes/js/mediaelement/wp-mediaelement.min.css?ver=d05679c553c9330ebf77a126f5cbe471"          
#> [4] "https://thinkr.fr/wp-content/plugins/contact-form-7/includes/css/styles.css?ver=56dc953aa6201753571ad248868111e6"    
#> [5] "https://thinkr.fr/wp-content/themes/thinkr/build/styles.min.css?ver=d05679c553c9330ebf77a126f5cbe471"                
#> [6] "https://thinkr.fr/wp-content/plugins/ics-calendar/assets/style.min.css?ver=c4c312147315328d9608fa93e291ea72"
```

### Extract top colors

``` r
thinkr$top_colors
#> $white_black
#>      Color Count
#> 10 #000000     3
#> 98 #FFFFFF     1
#> 
#> $top_colors
#>     Color Count
#> 1 #38404C   133
#> 2 #0046C8    72
#> 3 #F05622    40
#> 4 #20B8D6    23
```

### Show shiny theme

``` r
cat(thinkr$shiny_code)
#> fluidPage(
#>   theme = bslib::bs_theme(
#>     bg = "#FFFFFF",
#>     fg = "#000000",
#>     primary = "#38404C",
#>     secondary = "#0046C8",
#>     base_font = bslib::font_google("Rubik")
#>   ),
#>   h1("Hello World primary", class = "text-center text-secondary"),
#>   h1("Hello World secondary", class = "text-center text-primary")
#> )
```

## Run the application

You can launch the application by running:

``` r
css2r::run_app()
```

## About

You are reading the doc about version : 0.0.1

This README has been compiled on the

## Code of Conduct

Please note that the css2r project is released with a [Contributor Code
of
Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
