#' try_renderUI
#'
#' @inheritParams shiny::renderUI
#' @inheritParams try_observeEvent
#'
#' @export
#'
try_renderUI <- function(
  expr,
  env = parent.frame(),
  outputArgs = list(),
  errorHandler = elvis::elvis_error_handler,
  warningHandler = warning
) {
  env_ <- force(env)
  shiny::renderUI(
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
    outputArgs = outputArgs
  )
}
