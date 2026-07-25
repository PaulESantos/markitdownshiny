#' Launch the MarkItDown Shiny app
#'
#' Starts the bundled Shiny application for uploading documents, converting
#' them to Markdown, previewing the result, and downloading the `.md` output.
#'
#' @param ... Arguments passed to [shiny::runApp()].
#'
#' @return The result from [shiny::runApp()].
#' @examples
#' \dontrun{
#' if (interactive()) {
#'   launch_markitdown_app()
#' }
#' }
#' @export
launch_markitdown_app <- function(...) {
  app_dir <- system.file("shiny", package = "markitdownshiny")

  if (!nzchar(app_dir)) {
    stop("No se encontro la app Shiny instalada en el paquete.", call. = FALSE)
  }

  shiny::runApp(app_dir, ...)
}
