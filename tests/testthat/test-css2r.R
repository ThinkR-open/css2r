test_that("css2r works", {

  skip_if_offline()

  thinkr <- css2r$new(url = "https://thinkr.fr")

  expect_true(
    inherits(thinkr, "css2r")
  )

  expect_equal(
    thinkr$url,
    "https://thinkr.fr"
  )

  expect_equal(
    thinkr$domain,
    "thinkr.fr"
  )

  expect_equal(
    length(thinkr$all_css_links),
    8
  )

  expect_equal(
    length(thinkr$domain_css_links),
    6
  )

  expect_equal(
    thinkr$fonts[[1]][[1]],
    "Rubik:300,400,500,700"
  )

  expect_equal(
    thinkr$shiny_code,
    "fluidPage(\n  theme = bslib::bs_theme(\n    bg = \"#FFFFFF\",\n    fg = \"#000000\",\n    primary = \"#38404C\",\n    secondary = \"#0046C8\",\n    base_font = bslib::font_google(\"Rubik\")\n  ),\n  h1(\"Hello World primary\", class = \"text-center text-secondary\"),\n  h1(\"Hello World secondary\", class = \"text-center text-primary\")\n)"
  )
})
