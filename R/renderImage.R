

#' try_renderImage
#'
#' @inheritParams shiny::renderImage
#' @inheritParams try_observeEvent
#'
#' @export
#'
try_renderImage <- function(
  expr,
  env = parent.frame(),
  deleteFile = FALSE,
  outputArgs = list(),
  errorHandler = elvis::elvis_error_handler,
  warningHandler = warning
) {
  env_ <- force(env)
  shiny::renderImage(
    expr = substitute({
      tryCatch(
        expr,
        error = function(e) {
          errorHandler(e)
          return(
            list(
              src = ""
            )
          )
        },
        warning = function(w) {
          warningHandler(w)
        }
      )
    }),
    env = env_,
    quoted = TRUE,
    deleteFile = deleteFile,
    outputArgs = outputArgs
  )
}