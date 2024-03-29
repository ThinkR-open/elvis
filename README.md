
<!-- README.md is generated from README.Rmd. Please edit that file -->

# elvis

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/thinkr-open/elvis/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/thinkr-open/elvis/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

\[EXPERIMENTAL, DO NOT USE\]

The goal of `{elvis}` is to provide safer render\* and observe\* in
`{shiny}` by providing a native tryCatch() mechanism.

Note that this is an experimental package, so the API might change and
some stuff might be buggy.

## Installation

You can install the development version of elvis like so:

``` r
remotes::install_github("thinkr-open/elvis")
```

## About

You’re reading the doc about version : 0.0.0.9000

This README has been compiled on the

``` r
Sys.time()
#> [1] "2023-03-27 11:49:29 CEST"
```

Here are the test & coverage results :

``` r
devtools::check(quiet = TRUE)
#> ℹ Loading elvis
#> ── R CMD check results ─────────────────────────────────── elvis 0.0.0.9000 ────
#> Duration: 5.9s
#> 
#> 0 errors ✔ | 0 warnings ✔ | 0 notes ✔
```

``` r
covr::package_coverage()
#> elvis Coverage: 0.00%
#> R/observer.R: 0.00%
#> R/renderDataTable.R: 0.00%
#> R/renderImage.R: 0.00%
#> R/renderPlot.R: 0.00%
#> R/renderPrint.R: 0.00%
#> R/renderTable.R: 0.00%
#> R/renderText.R: 0.00%
#> R/renderUI.R: 0.00%
#> R/utils.R: 0.00%
```

## What the heck

By default, `{shiny}` observers and renderers are not safe, and might
stop your app when they fail. One solution is to wrap your code inside
tryCatch, but that might be cumbersum to do this every time.

Here comes `{elvis}`, a series of wrappers around `{shiny}` observers
and renderers that have built in tryCatch.

``` r
output$plot <- try_renderPlot({
    stop("a")
  },
  errorHandler = function(e){
    showNotification("There was an error in the plot")
  }
)
```

The base idea is to prefix all the functions with `try_`, so that it’s
easier to port old code to `{elvis}`.

## Examples

Here is a simple example:

``` r
library(shiny)
library(elvis)
ui <- fluidPage(
  actionButton("go", "Go"),
  plotOutput("plot")
)

server <- function(input, output, session) {
  r <- reactiveValues(count = 0)

  output$plot <- try_renderPlot(
    {
      if (input$go %% 2 == 0) {
        plot(sample(1:100, 10))
      } else {
        stop("Nop")
      }
    },
    errorHandler = function(e) {
      isolate({
        r$count <- r$count + 1
      })
    }
  )

  observeEvent(
    r$count,
    {
      cli::cli_alert_danger(
        sprintf("It's been %s times", r$count)
      )
    }
  )
}

shinyApp(ui, server)
```

### observers

``` r
library(elvis)
library(shiny)
ui <- fluidPage(
  sliderInput("try_observeEvent", "try_observeEvent", 1, 100, 10),
  sliderInput("try_observe", "try_observe", 1, 100, 10)
)

server <- function(input, output, session) {
  try_observeEvent(
    input$try_observeEvent,
    ignoreInit = TRUE,
    {
      stop("pif")
    },
    errorHandler = function(e) {
      showModal(
        modalDialog(
          easyClose = TRUE,
          title = "There was an error in the try_observeEvent"
        )
      )
    }
  )
  # This one is here to prove that it works with non failing code
  try_observeEvent(
    input$try_observeEvent,
    ignoreInit = TRUE,
    {
      print(input$try_observeEvent)
    }
  )
  try_observe(
    {
      input$try_observe
      stop("paf")
    },
    errorHandler = function(e) {
      showModal(
        modalDialog(
          easyClose = TRUE,
          title = "There was an error in the try_observe"
        )
      )
    }
  )

  # This one is here to prove that it works with non failing code
  try_observe({
    print(input$try_observe)
  })
}

shinyApp(ui, server)
```

### renderers

- try_renderPlot

``` r
library(elvis)
library(shiny)
ui <- fluidPage(
  actionButton("plot", "Try to renderPlot"),
  plotOutput("plot"),
  plotOutput("plot2")
)

server <- function(input, output, session) {
  output$plot <- try_renderPlot(
    {
      input$plot
      stop("a")
    },
    errorHandler = function(e) {
      showNotification(
        "There was an error in the plot",
        type = "error"
      )
    }
  )
  # This one is here to prove that it works with non failing code
  output$plot2 <- try_renderPlot({
    input$plot
    plot(sample(1:100, 10))
  })
}

shinyApp(ui, server)
```

- try_renderDataTable

``` r
library(elvis)
library(shiny)
ui <- fluidPage(
  actionButton("dt", "Try to renderDataTable"),
  dataTableOutput("dt"),
  dataTableOutput("dt2")
)

server <- function(input, output, session) {
  output$dt <- try_renderDataTable(
    {
      input$dt
      stop("a")
    },
    errorHandler = function(e) {
      showNotification(
        "There was an error in the DT",
        type = "error"
      )
    }
  )
  # This one is here to prove that it works with non failing code
  output$dt2 <- try_renderDataTable({
    input$dt

    mtcars[
      sample(1:nrow(mtcars), 10),
    ]
  })
}

shinyApp(ui, server)
```

- try_renderImage

``` r
library(elvis)
library(shiny)
library(zeallot)
c(img1, img2, img3) %<-% replicate(
  3,
  (\(x){
    tempfile(fileext = ".jpg")
  })()
)
download.file(
  "https://www.widermag.com/media/krup1.jpg",
  img1
)
download.file(
  "https://www.cafeducycliste.com/fr_fr/wp/wp-content/uploads/2022/02/Anton-topbanner-10-02-22.jpg",
  img2
)
download.file(
  "https://www.suunto.com/globalassets/suunto-blogs/2021/03-march/anton-krupicka/2021-03-anton-blog-intro-body-1.jpg",
  img3
)
# Three images
ui <- fluidPage(
  actionButton("img", "Try to renderImage"),
  imageOutput("img"),
  imageOutput("img2")
)

server <- function(input, output, session) {
  output$img <- try_renderImage(
    {
      input$img
      stop("a")
    },
    errorHandler = function(e) {
      showNotification(
        "There was an error in the img",
        type = "error"
      )
    }
  )
  # This one is here to prove that it works with non failing code
  output$img2 <- try_renderImage({
    input$img
    outfile <- sample(
      c(
        img1,
        img2,
        img3
      ),
      1
    )
    list(
      src = outfile,
      alt = "This is alternate text"
    )
  })
}

shinyApp(ui, server)
```

- try_renderPrint

``` r
library(elvis)
library(shiny)
ui <- fluidPage(
  actionButton("rp", "Try to try_renderPrint"),
  verbatimTextOutput("rp"),
  verbatimTextOutput("rp2")
)

server <- function(input, output, session) {
  output$rp <- try_renderPrint(
    {
      input$rp
      stop("a")
    },
    errorHandler = function(e) {
      showNotification(
        "There was an error in the print",
        type = "error"
      )
    }
  )
  # This one is here to prove that it works with non failing code
  output$rp2 <- try_renderPrint({
    input$rp
    sample(1:100, 10)
  })
}

shinyApp(ui, server)
```

- try_renderText

``` r
library(elvis)
library(shiny)
ui <- fluidPage(
  actionButton("rt", "Try to try_renderText"),
  textOutput("rt"),
  textOutput("rt2")
)

server <- function(input, output, session) {
  output$rt <- try_renderText(
    {
      input$rt
      stop("a")
    },
    errorHandler = function(e) {
      showNotification(
        "There was an error in the text",
        type = "error"
      )
    }
  )
  # This one is here to prove that it works with non failing code
  output$rt2 <- try_renderText({
    input$rt
    sample(letters, 10)
  })
}

shinyApp(ui, server)
```

- try_renderTable

``` r
library(elvis)
library(shiny)
ui <- fluidPage(
  actionButton("dt", "Try to try_renderTable"),
  tableOutput("dt"),
  tableOutput("dt2")
)

server <- function(input, output, session) {
  output$dt <- try_renderTable(
    {
      input$dt
      stop("a")
    },
    errorHandler = function(e) {
      showNotification(
        "There was an error in the table",
        type = "error"
      )
    }
  )
  # This one is here to prove that it works with non failing code
  output$dt2 <- try_renderTable({
    input$dt

    mtcars[
      sample(1:nrow(mtcars), 10),
    ]
  })
}

shinyApp(ui, server)
```

- try_renderUI

``` r
library(elvis)
library(shiny)
ui <- fluidPage(
  actionButton("ui", "Try to try_renderUI"),
  uiOutput("ui"),
  uiOutput("ui2")
)

server <- function(input, output, session) {
  output$ui <- try_renderUI(
    {
      input$ui
      stop("a")
    },
    errorHandler = function(e) {
      showNotification(
        "There was an error in the UI",
        type = "error"
      )
    }
  )
  # This one is here to prove that it works with non failing code
  output$ui2 <- try_renderUI({
    input$ui

    sample(letters, 1)
  })
}

shinyApp(ui, server)
```

## Why the name?

With `{elvis}`, you’re t(rying to r)ender, t(ry)render, tender… and love
me tender, love me true.

## Code of Conduct

Please note that the elvis project is released with a [Contributor Code
of
Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
