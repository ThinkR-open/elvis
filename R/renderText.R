
#' try_renderText
#'
#' @inheritParams shiny::renderText
#' @inheritParams try_observeEvent
#'
#' @export
#'
try_renderText <- function(
  expr,
  env = parent.frame(),
  outputArgs = list(),
  sep = " ",
  errorHandler = elvis::elvis_error_handler,
  warningHandler = warning
) {
  env_ <- force(env)
  shiny::renderText(
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
    env = env_,
    quoted = TRUE,
    sep = sep,
    outputArgs = outputArgs
  )
}
