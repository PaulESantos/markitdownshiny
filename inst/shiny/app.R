library(shiny)
library(bslib)

if (is.null(getOption("shiny.maxRequestSize"))) {
  options(shiny.maxRequestSize = 50 * 1024^2)
}

find_and_source_convert <- function() {
  candidates <- c(
    file.path(getwd(), "R", "convert.R"),
    file.path(getwd(), "..", "R", "convert.R"),
    file.path(getwd(), "..", "..", "R", "convert.R")
  )
  for (cand in candidates) {
    norm <- normalizePath(cand, winslash = "/", mustWork = FALSE)
    if (file.exists(norm)) {
      source(norm, local = globalenv())
      return(TRUE)
    }
  }
  FALSE
}

find_and_source_convert()

max_size_mb <- round(getOption("shiny.maxRequestSize") / (1024^2))

supported_extensions <- paste(
  ".pdf", ".docx", ".pptx", ".xlsx", ".xls", ".html", ".htm", ".csv", ".json",
  ".xml", ".txt", ".zip", ".epub", ".jpg", ".jpeg", ".png", ".wav", ".mp3",
  ".eml", ".msg",
  collapse = ", "
)

accepted_types <- c(
  "pdf", "docx", "pptx", "xlsx", "xls", "html", "htm", "csv", "json", "xml",
  "txt", "zip", "epub", "jpg", "jpeg", "png", "wav", "mp3", "eml", "msg"
)

theme <- bs_theme(
  version = 5,
  bootswatch = "flatly",
  primary = "#1f6feb",
  base_font = font_google("Inter", local = FALSE)
)

ui <- page_sidebar(
  title = "Conversor MarkItDown",
  theme = theme,
  sidebar = sidebar(
    width = 340,
    fileInput(
      "document",
      "Documento",
      accept = paste0(".", accepted_types),
      buttonLabel = "Seleccionar",
      placeholder = "Ningun archivo seleccionado"
    ),
    checkboxInput(
      "use_cli",
      "Usar ejecutable CLI si esta disponible",
      value = FALSE
    ),
    actionButton("convert", "Convertir", class = "btn-primary w-100 mb-2"),
    downloadButton("download_md", "Descargar Markdown", class = "w-100 mb-2"),
    actionButton("stop_app", "Detener Aplicacion", class = "btn-outline-danger w-100"),
    tags$hr(),
    tags$p(
      class = "text-muted small mb-1",
      paste0("Limite maximo de subida: ", max_size_mb, " MB")
    ),
    tags$p(
      class = "text-muted small",
      "Formatos esperados: ",
      supported_extensions
    )
  ),
  card(
    full_screen = TRUE,
    card_header("Resultado en formato Markdown"),
    verbatimTextOutput("markdown_text", placeholder = TRUE)
  )
)

server <- function(input, output, session) {
  markdown_value <- reactiveVal("")
  source_name <- reactiveVal("document.md")

  observeEvent(input$stop_app, {
    stopApp()
  })

  observeEvent(input$convert, {
    req(input$document)

    uploaded <- input$document
    source_name(uploaded$name)

    withProgress(message = "Convirtiendo documento", value = 0.25, {
      safe_filename <- paste0(
        gsub("[^A-Za-z0-9_-]", "_", tools::file_path_sans_ext(basename(uploaded$name))),
        ".",
        tools::file_ext(uploaded$name)
      )
      target <- file.path(tempdir(), safe_filename)
      file.copy(uploaded$datapath, target, overwrite = TRUE)
      incProgress(0.35)

      converted <- if (exists("convert_to_markdown", envir = globalenv(), mode = "function")) {
        get("convert_to_markdown", envir = globalenv())(target, use_cli = input$use_cli)
      } else if (requireNamespace("markitdownshiny", quietly = TRUE)) {
        markitdownshiny::convert_to_markdown(target, use_cli = input$use_cli)
      } else {
        stop("No se encontro la funcion convert_to_markdown.")
      }

      markdown_value(converted)
      incProgress(0.40)
    })
  })

  output$markdown_text <- renderText({
    text <- markdown_value()
    if (!nzchar(text)) {
      return("Cargue un documento y presione 'Convertir' para ver el resultado en Markdown.")
    }
    text
  })

  output$download_md <- downloadHandler(
    filename = function() {
      paste0(tools::file_path_sans_ext(basename(source_name())), ".md")
    },
    content = function(file) {
      writeLines(markdown_value(), file, useBytes = TRUE)
    }
  )
}

shinyApp(ui, server)
