#' try_renderTable
#'
#' @inheritParams shiny::renderTable
#' @inheritParams try_observeEvent
#'
#' @export
#'
try_renderTable <- function(
  expr,
  striped = FALSE,
  hover = FALSE,
  bordered = FALSE,
  spacing = c("s", "xs", "m", "l"),
  width = "auto",
  align = NULL,
  rownames = FALSE,
  colnames = TRUE,
  digits = NULL,
  na = "NA",
  ...,
  env = parent.frame(),
  outputArgs = list(),
  errorHandler = elvis::elvis_error_handler,
  warningHandler = warning
) {
  env_ <- force(env)
  shiny::renderTable(
    expr = substitute({
      tryCatch(
        expr,
        error = function(e) {
          errorHandler(e)
          return(NULL)
        },
        warning = function(w) {
          warningHandler(w)
        }
      )
    }),
    striped = striped,
    hover = hover,
    bordered = bordered,
    spacing = spacing,
    width = width,
    align = align,
    rownames = rownames,
    colnames = colnames,
    digits = digits,
    na = na,
    ...,
    env = env_,
    quoted = TRUE,
    outputArgs = outputArgs
  )
}
