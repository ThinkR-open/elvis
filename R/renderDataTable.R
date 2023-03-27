
#' try_renderDataTable
#'
#' @inheritParams shiny::renderDataTable
#' @inheritParams try_observeEvent
#'
#' @export
#'
try_renderDataTable <- function(
  expr,
  options = NULL,
  searchDelay = 500,
  callback = "function(oTable) {}",
  escape = TRUE,
  env = parent.frame(),
  outputArgs = list(),
  errorHandler = elvis::elvis_error_handler,
  warningHandler = warning
) {
  env_ <- force(env)
  shiny::renderDataTable(
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
    options = options,
    searchDelay = searchDelay,
    callback = callback,
    escape = escape,
    env = env_,
    quoted = TRUE,
    outputArgs = outputArgs
  )
}
