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
#' @param output Output format. Use `"text"` to return only Markdown, or
#'   `"result"` to return a structured result with available metadata.
#'
#' @return A character scalar containing Markdown when `output = "text"`, or
#'   a `markitdownshiny_result` object when `output = "result"`.
#' @examples
#' \dontrun{
#' tmp <- tempfile(fileext = ".txt")
#' writeLines("Hello world", tmp)
#' convert_to_markdown(tmp)
#' }
#' @export
convert_to_markdown <- function(
  path,
  use_cli = FALSE,
  python = NULL,
  output = c("text", "result")
) {
  check_file_path(path)
  output <- match.arg(output)

  if (!is.null(python)) {
    reticulate::use_python(python, required = TRUE)
  }

  result <- if (isTRUE(use_cli)) {
    convert_with_cli(path)
  } else {
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

  format_conversion_output(result, output)
}

#' Check the Python MarkItDown installation
#'
#' Checks whether the active Python environment can import `markitdown` and
#' whether the `markitdown` command-line executable is available on `PATH`.
#'
#' @param python Optional path to a Python executable to use with `reticulate`.
#' @param quiet Logical. If `FALSE`, print a short diagnostic summary.
#'
#' @return A `markitdownshiny_installation` object with Python, package, CLI,
#'   version, and error details.
#' @examples
#' \dontrun{
#' check_markitdown_installation()
#' }
#' @export
check_markitdown_installation <- function(python = NULL, quiet = FALSE) {
  if (!is.null(python)) {
    reticulate::use_python(python, required = TRUE)
  }

  python_config <- tryCatch(
    reticulate::py_config(),
    error = function(error) error
  )

  python_available <- !inherits(python_config, "error")
  markitdown_available <- FALSE
  markitdown_version <- NA_character_
  python_error <- NULL

  if (python_available) {
    markitdown_available <- reticulate::py_module_available("markitdown")

    if (markitdown_available) {
      markitdown_version <- tryCatch(
        {
          metadata <- reticulate::import("importlib.metadata")
          as.character(metadata$version("markitdown"))
        },
        error = function(error) NA_character_
      )
    }
  } else {
    python_error <- conditionMessage(python_config)
  }

  cli_path <- Sys.which("markitdown")

  result <- structure(
    list(
      python_available = python_available,
      python = if (python_available) python_config$python else NA_character_,
      markitdown_available = markitdown_available,
      markitdown_version = markitdown_version,
      cli_available = nzchar(cli_path),
      cli_path = if (nzchar(cli_path)) unname(cli_path) else NA_character_,
      python_error = python_error
    ),
    class = "markitdownshiny_installation"
  )

  if (!isTRUE(quiet)) {
    print(result)
  }

  invisible(result)
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
  norm_path <- normalizePath(path, winslash = "/", mustWork = TRUE)
  result <- converter$convert_local(norm_path)
  markdown_text <- result$markdown

  if (is.null(markdown_text) || !is.character(markdown_text)) {
    stop("markitdown no retorno contenido Markdown de texto.", call. = FALSE)
  }

  title <- result$title
  if (is.null(title)) {
    title <- NA_character_
  }

  new_markitdown_result(
    markdown = paste(markdown_text, collapse = "\n"),
    title = title,
    source = norm_path,
    method = "python"
  )
}

convert_with_cli <- function(path) {
  cli_path <- Sys.which("markitdown")
  if (!nzchar(cli_path)) {
    stop("No se encontro el ejecutable `markitdown` en PATH.", call. = FALSE)
  }

  output <- tempfile(fileext = ".md")
  err <- tempfile(fileext = ".log")
  norm_path <- normalizePath(path, winslash = "/", mustWork = TRUE)
  norm_output <- normalizePath(output, winslash = "/", mustWork = FALSE)

  status <- system2(
    cli_path,
    args = c(shQuote(norm_path), "-o", shQuote(norm_output)),
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

  new_markitdown_result(
    markdown = paste(
      readLines(output, warn = FALSE, encoding = "UTF-8"),
      collapse = "\n"
    ),
    title = NA_character_,
    source = norm_path,
    method = "cli"
  )
}

new_markitdown_result <- function(
  markdown,
  title = NA_character_,
  source = NA_character_,
  method = NA_character_
) {
  structure(
    list(
      markdown = markdown,
      title = title,
      source = source,
      method = method
    ),
    class = "markitdownshiny_result"
  )
}

format_conversion_output <- function(result, output) {
  if (identical(output, "result")) {
    return(result)
  }

  result$markdown
}

#' @export
as.character.markitdownshiny_result <- function(x, ...) {
  x$markdown
}

#' @export
print.markitdownshiny_result <- function(x, ...) {
  cat(x$markdown, sep = "\n")
  invisible(x)
}

#' @export
print.markitdownshiny_installation <- function(x, ...) {
  cat("Python available: ", x$python_available, "\n", sep = "")
  cat("Python: ", x$python, "\n", sep = "")
  cat("MarkItDown available: ", x$markitdown_available, "\n", sep = "")
  cat("MarkItDown version: ", x$markitdown_version, "\n", sep = "")
  cat("CLI available: ", x$cli_available, "\n", sep = "")
  cat("CLI path: ", x$cli_path, "\n", sep = "")

  if (!is.null(x$python_error)) {
    cat("Python error: ", x$python_error, "\n", sep = "")
  }

  invisible(x)
}
