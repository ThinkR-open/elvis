
#' try_renderPrint
#'
#' @inheritParams shiny::renderPrint
#' @inheritParams try_observeEvent
#'
#' @export
#'
try_renderPrint <- function(
  expr,
  env = parent.frame(),
  width = getOption("width"),
  outputArgs = list(),
  errorHandler = elvis::elvis_error_handler,
  warningHandler = warning
) {
  env_ <- force(env)
  shiny::renderPrint(
    expr = substitute({
      tryCatch(
        expr,
        error = function(e) {
          errorHandler(e)
          return("[Rendering error]")
        },
        warning = function(w) {
          warningHandler(w)
        }
      )
    }),
    env = env_,
    quoted = TRUE,
    width = width,
    outputArgs = outputArgs
  )
}
