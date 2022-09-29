#' elvis_error_handler
#'
#' @param e The error
#'
#' @export
elvis_error_handler <- function(e) {
  shiny::showNotification(e)
  return(NULL)
}
