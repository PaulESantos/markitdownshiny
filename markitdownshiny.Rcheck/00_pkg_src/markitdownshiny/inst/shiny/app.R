library(shiny)
library(bslib)

if (!requireNamespace("markitdownshiny", quietly = TRUE)) {
  local_convert_path <- normalizePath(
    file.path(getwd(), "..", "..", "R", "convert.R"),
    winslash = "/",
    mustWork = FALSE
  )
  if (file.exists(local_convert_path)) {
    source(local_convert_path, local = globalenv())
  }
}

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
    actionButton("convert", "Convertir", class = "btn-primary"),
    downloadButton("download_md", "Descargar Markdown"),
    tags$hr(),
    tags$p(
      class = "text-muted small",
      "Formatos esperados: ",
      supported_extensions
    )
  ),
  layout_columns(
    col_widths = c(6, 6),
    card(
      card_header("Markdown"),
      verbatimTextOutput("markdown_text", placeholder = TRUE)
    ),
    card(
      card_header("Vista previa"),
      uiOutput("markdown_preview")
    )
  )
)

server <- function(input, output, session) {
  markdown_value <- reactiveVal("")
  source_name <- reactiveVal("document.md")

  observeEvent(input$convert, {
    req(input$document)

    uploaded <- input$document
    source_name(uploaded$name)

    withProgress(message = "Convirtiendo documento", value = 0.25, {
      target <- file.path(
        tempdir(),
        paste0(
          tools::file_path_sans_ext(basename(uploaded$name)),
          ".",
          tools::file_ext(uploaded$name)
        )
      )
      file.copy(uploaded$datapath, target, overwrite = TRUE)
      incProgress(0.35)

      converted <- if (requireNamespace("markitdownshiny", quietly = TRUE)) {
        markitdownshiny::convert_to_markdown(target, use_cli = input$use_cli)
      } else {
        convert_to_markdown(target, use_cli = input$use_cli)
      }

      markdown_value(converted)
      incProgress(0.40)
    })
  })

  output$markdown_text <- renderText({
    text <- markdown_value()
    if (!nzchar(text)) {
      return("Cargue un documento y presione Convertir.")
    }
    text
  })

  output$markdown_preview <- renderUI({
    text <- markdown_value()
    if (!nzchar(text)) {
      return(tags$p(class = "text-muted", "La vista previa aparecera aqui."))
    }

    html <- markdown::markdownToHTML(text = text, fragment.only = TRUE)
    htmltools::HTML(html)
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
