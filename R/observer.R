#' Trycatch version of observeEvent
#'
#' @inheritParams shiny::observeEvent
#' @param errorHandler,warningHandler passed to tryCatch
#'
#' @export
try_observeEvent <- function(
  eventExpr,
  handlerExpr,
  event.env = parent.frame(),
  event.quoted = FALSE,
  handler.env = parent.frame(),
  handler.quoted = FALSE,
  ...,
  label = NULL,
  suspended = FALSE,
  priority = 0,
  domain = shiny::getDefaultReactiveDomain(),
  autoDestroy = TRUE,
  ignoreNULL = TRUE,
  ignoreInit = FALSE,
  once = FALSE,
  errorHandler = elvis::elvis_error_handler,
  warningHandler = warning
) {
  shiny::observeEvent(
    substitute(eventExpr),
    {
      substitute({
        tryCatch(
          handlerExpr,
          error = function(e) {
            errorHandler(e)
            return(NULL)
          },
          warning = function(w) {
            warningHandler(w)
          }
        )
      })
    },
    event.quoted = TRUE,
    handler.quoted = TRUE,
    event.env = event.env,
    handler.env = handler.env,
    ...,
    label = label,
    suspended = suspended,
    priority = priority,
    domain = domain,
    autoDestroy = autoDestroy,
    ignoreNULL = ignoreNULL,
    ignoreInit = ignoreInit,
    once = once
  )
}
