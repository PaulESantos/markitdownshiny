#' Convert a document to Markdown
#'
#' Converts a local document to Markdown by delegating to Microsoft's Python
#' `markitdown` package. The function first tries the Python API through
#' `reticulate` and can optionally use the `markitdown` command-line utility.
#'
#' @param path Path to the source document.
#' @param use_cli Logical. If `TRUE`, use the `markitdown` executable instead
#'   of the Python API.
#' @param python Optional path to a Python executable to use with `reticulate`.
#'
#' @return A character scalar containing Markdown.
#' @examples
#' \dontrun{
#' tmp <- tempfile(fileext = ".txt")
#' writeLines("Hello world", tmp)
#' convert_to_markdown(tmp)
#' }
#' @export
convert_to_markdown <- function(path, use_cli = FALSE, python = NULL) {
  check_file_path(path)

  if (!is.null(python)) {
    reticulate::use_python(python, required = TRUE)
  }

  if (isTRUE(use_cli)) {
    return(convert_with_cli(path))
  }

  tryCatch(
    convert_with_python_api(path),
    error = function(api_error) {
      cli_path <- Sys.which("markitdown")
      if (!nzchar(cli_path)) {
        stop(
          paste(
            "No fue posible cargar markitdown desde Python.",
            "Instale Python >= 3.10 y ejecute:",
            "python -m pip install \"markitdown[all]\".",
            "Detalle:",
            conditionMessage(api_error)
          ),
          call. = FALSE
        )
      }
      convert_with_cli(path)
    }
  )
}

check_file_path <- function(path) {
  if (!is.character(path) || length(path) != 1 || !nzchar(path)) {
    stop("`path` debe ser una ruta local no vacia.", call. = FALSE)
  }

  if (!file.exists(path)) {
    stop("El archivo no existe: ", path, call. = FALSE)
  }

  if (dir.exists(path)) {
    stop("`path` debe apuntar a un archivo, no a un directorio.", call. = FALSE)
  }

  invisible(path)
}

convert_with_python_api <- function(path) {
  markitdown <- reticulate::import("markitdown", delay_load = FALSE)
  converter <- markitdown$MarkItDown()
  result <- converter$convert(normalizePath(path, winslash = "/", mustWork = TRUE))
  markdown_text <- result$text_content

  if (is.null(markdown_text) || !is.character(markdown_text)) {
    stop("markitdown no retorno contenido Markdown de texto.", call. = FALSE)
  }

  paste(markdown_text, collapse = "\n")
}

convert_with_cli <- function(path) {
  cli_path <- Sys.which("markitdown")
  if (!nzchar(cli_path)) {
    stop("No se encontro el ejecutable `markitdown` en PATH.", call. = FALSE)
  }

  output <- tempfile(fileext = ".md")
  err <- tempfile(fileext = ".log")
  status <- system2(
    cli_path,
    args = c(normalizePath(path, winslash = "/", mustWork = TRUE), "-o", output),
    stdout = TRUE,
    stderr = err
  )

  if (!identical(attr(status, "status"), NULL)) {
    details <- if (file.exists(err)) {
      paste(readLines(err, warn = FALSE), collapse = "\n")
    } else {
      ""
    }
    stop("La conversion con markitdown fallo.\n", details, call. = FALSE)
  }

  if (!file.exists(output)) {
    stop("markitdown no genero el archivo de salida esperado.", call. = FALSE)
  }

  paste(readLines(output, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
}
