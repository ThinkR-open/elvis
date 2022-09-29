#' try_renderPlot
#'
#' @inheritParams shiny::renderPlot
#' @inheritParams try_observeEvent
#'
#' @export
#'
try_renderPlot <- function(
  expr,
  width = "auto",
  height = "auto",
  res = 72,
  ...,
  alt = NA,
  env = parent.frame(),
  execOnResize = FALSE,
  outputArgs = list(),
  errorHandler = elvis::elvis_error_handler,
  warningHandler = warning
) {
  env_ <- force(env)
  shiny::renderPlot(
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
    width = width,
    height = height,
    res = res,
    ...,
    alt = alt,
    env = env_,
    quoted = TRUE,
    execOnResize = execOnResize,
    outputArgs = outputArgs
  )
}
