
<!-- README.md is generated from README.Rmd. Please edit that file -->

# elvis

<!-- badges: start -->
<!-- badges: end -->

\[PROOF OF CONCEPT, DO NOT USE\]

The goal of `{elvis}` is to provide safer render\* and observe\* in
`{shiny}` by providing a native tryCatch() mecanism.

Note that this is an experimental package, so the API might change and
some stuff might be buggy.

## Installation

You can install the development version of elvis like so:

``` r
remotes::install_github("thinkr-open/elvis")
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
  errorHandler = \(e){
    showNotification("There was an error with the plot")
  }
)
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(elvis)
ui <- fluidPage(
  sliderInput("n", "n", 1, 100, 10),
  plotOutput("plot")
)

server <- function(input, output, session) {
  try_observeEvent(
    input$n,
    {
      stop("plop")
    },
    errorHandler = \(e){
      showNotification("There was an error with the Input")
    }
  )
  output$plot <- try_renderPlot(
    {
      stop("a")
    },
    errorHandler = \(e){
      showNotification("There was an error with the plot")
    }
  )
}

shinyApp(ui, server)
```
