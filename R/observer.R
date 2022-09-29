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
  event.env_ <- force(event.env)
  handler.env_ <- force(handler.env)
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
    event.env = event.env_,
    handler.env = handler.env_,
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

#' Trycatch version of observe
#'
#' @inheritParams shiny::observe
#' @inheritParams try_observeEvent
#'
#' @export
try_observe <- function(
  x,
  env = parent.frame(),
  ...,
  label = NULL,
  suspended = FALSE,
  priority = 0,
  domain = getDefaultReactiveDomain(),
  autoDestroy = TRUE,
  ..stacktraceon = TRUE,
  errorHandler = elvis::elvis_error_handler,
  warningHandler = warning
) {
  env_ <- force(env)
  shiny::observe(
    {
      substitute({
        tryCatch(
          x,
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
    env = env_,
    quoted = TRUE,
    ...,
    label = label,
    suspended = suspended,
    priority = priority,
    domain = domain,
    autoDestroy = autoDestroy,
    ..stacktraceon = ..stacktraceon
  )
}
