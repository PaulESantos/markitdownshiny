#' Launch the MarkItDown Shiny app
#'
#' Starts the bundled Shiny application for uploading documents, converting
#' them to Markdown, and downloading the `.md` output.
#'
#' @param max_file_size_mb Maximum allowed upload file size in megabytes (MB).
#'   Defaults to `50` MB.
#' @param ... Arguments passed to [shiny::runApp()].
#'
#' @return The result from [shiny::runApp()].
#' @examples
#' \dontrun{
#' if (interactive()) {
#'   # Launch with default 50 MB limit
#'   launch_markitdown_app()
#'
#'   # Launch with custom 100 MB upload limit
#'   launch_markitdown_app(max_file_size_mb = 100)
#' }
#' }
#' @export
launch_markitdown_app <- function(max_file_size_mb = 50, ...) {
  if (is.numeric(max_file_size_mb) && max_file_size_mb > 0) {
    options(shiny.maxRequestSize = max_file_size_mb * 1024^2)
  }

  app_dir <- system.file("shiny", package = "markitdownshiny")

  if (!nzchar(app_dir) || !file.exists(file.path(app_dir, "app.R"))) {
    local_app <- normalizePath(file.path(getwd(), "inst", "shiny"), winslash = "/", mustWork = FALSE)
    if (file.exists(file.path(local_app, "app.R"))) {
      app_dir <- local_app
    }
  }

  if (!nzchar(app_dir) || !file.exists(file.path(app_dir, "app.R"))) {
    stop("No se encontro la app Shiny instalada ni en la ruta local del paquete.", call. = FALSE)
  }

  shiny::runApp(app_dir, ...)
}
