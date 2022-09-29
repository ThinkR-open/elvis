---
output: github_document
---

<!-- README.md is generated from README.Rmd. Please edit that file -->



# elvis

<!-- badges: start -->
<!-- badges: end -->

[PROOF OF CONCEPT, DO NOT USE]

The goal of `{elvis}` is to provide safer render* and observe* in `{shiny}` by providing a native tryCatch() mecanism. 

Note that this is an experimental package, so the API might change and some stuff might be buggy.

## Installation

You can install the development version of elvis like so:

``` r
remotes::install_github("thinkr-open/elvis")
```

## What the heck

By default, `{shiny}` observers and renderers are not safe, and might stop your app when they fail. 
One solution is to wrap your code inside tryCatch, but that might be cumbersum to do this every time. 

Here comes `{elvis}`, a series of wrappers around `{shiny}` observers and renderers that have built in tryCatch. 

```r
output$plot <- try_renderPlot({
    stop("a")
  },
  errorHandler = \(e){
    showNotification("There was an error with the plot")
  }
)
```

The base idea is to prefix all the functions with `try_`, so that it's easier to port old code to `{elvis}`.

## Examples

### observers


```r
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
    errorHandler = \(e){
      showModal(
        modalDialog(
          easyClose = TRUE,
          title = "There was an error with the try_observeEvent"
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
    errorHandler = \(e){
      showModal(
        modalDialog(
          easyClose = TRUE,
          title = "There was an error with the try_observe"
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

+ try_renderPlot


```r
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
    errorHandler = \(e){
      showNotification(
        "There was an error with the plot",
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

+ try_renderDataTable


```r
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
    errorHandler = \(e){
      showNotification(
        "There was an error with the DT",
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


+ try_renderImage


```r
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
    errorHandler = \(e){
      showNotification(
        "There was an error with the img",
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

+ try_renderPrint


```r
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
    errorHandler = \(e){
      showNotification(
        "There was an error with the print",
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


+ try_renderText


```r
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
    errorHandler = \(e){
      showNotification(
        "There was an error with the text",
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

+ try_renderTable


```r
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
    errorHandler = \(e){
      showNotification(
        "There was an error with the table",
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

+ try_renderUI


```r
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
    errorHandler = \(e){
      showNotification(
        "There was an error with the UI",
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
