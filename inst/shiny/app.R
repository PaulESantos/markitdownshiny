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
  ".pdf",
  ".docx",
  ".pptx",
  ".xlsx",
  ".xls",
  ".html",
  ".htm",
  ".csv",
  ".json",
  ".xml",
  ".txt",
  ".zip",
  ".epub",
  ".jpg",
  ".jpeg",
  ".png",
  ".wav",
  ".mp3",
  ".eml",
  ".msg",
  collapse = ", "
)

accepted_types <- c(
  "pdf",
  "docx",
  "pptx",
  "xlsx",
  "xls",
  "html",
  "htm",
  "csv",
  "json",
  "xml",
  "txt",
  "zip",
  "epub",
  "jpg",
  "jpeg",
  "png",
  "wav",
  "mp3",
  "eml",
  "msg"
)

theme <- bs_theme(
  version = 5,
  primary = "#2563eb",
  secondary = "#64748b",
  success = "#15803d",
  danger = "#dc2626",
  base_font = font_google("Source Sans 3", local = FALSE),
  heading_font = font_google("IBM Plex Sans", local = FALSE),
  code_font = font_google("IBM Plex Mono", local = FALSE),
  "body-bg" = "#f5f7fb",
  "body-color" = "#172033",
  "border-color" = "#d7dee8",
  "link-color" = "#0f766e",
  "link-hover-color" = "#115e59"
)

ui <- page_sidebar(
  title = div(
    class = "app-title",
    div(class = "app-title__eyebrow", "MarkItDown"),
    div(class = "app-title__main", "Conversor de documentos"),
    div(class = "app-title__meta", "Salida Markdown con vista previa HTML")
  ),
  theme = theme,
  tags$head(
    tags$style(HTML(
      "
      :root {
        --bg: #f5f7fb;
        --surface: #ffffff;
        --surface-muted: #f8fafc;
        --sidebar-bg: #eef2f7;
        --border-soft: #d7dee8;
        --ink: #172033;
        --text-muted: #667085;
        --primary: #2563eb;
        --primary-hover: #1d4ed8;
        --primary-soft: #e8f0ff;
        --accent: #0f766e;
        --accent-hover: #115e59;
        --accent-soft: #e6f4f1;
        --danger: #dc2626;
        --danger-soft: #fee2e2;
        --success: #15803d;
        --success-soft: #e7f8ef;
        --code-bg: #f8fafc;
      }

      body {
        background: var(--bg);
        color: var(--ink);
        font-feature-settings: 'kern';
        -webkit-font-smoothing: antialiased;
      }

      .bslib-sidebar-layout {
        background: var(--bg);
        gap: 1rem;
      }

      .bslib-sidebar-layout > .main {
        background: var(--bg);
      }

      .bslib-sidebar-layout > .sidebar {
        background: var(--sidebar-bg);
        border-right: 1px solid var(--border-soft);
      }

      .navbar,
      .bslib-page-title {
        background: var(--surface) !important;
        border-bottom: 1px solid var(--border-soft);
        box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
      }

      .app-title {
        display: grid;
        gap: 0.1rem;
        padding: 0.35rem 0 0.45rem;
      }

      .app-title__eyebrow {
        color: var(--primary);
        font-size: 0.72rem;
        font-weight: 800;
        letter-spacing: 0;
        text-transform: uppercase;
      }

      .app-title__main {
        color: var(--ink);
        font-family: 'IBM Plex Sans', 'Source Sans 3', system-ui, sans-serif;
        font-size: 1.42rem;
        font-weight: 750;
        line-height: 1.15;
      }

      .app-title__meta {
        color: var(--text-muted);
        font-size: 0.92rem;
        font-weight: 400;
      }

      .card {
        border-color: var(--border-soft);
        box-shadow: 0 8px 24px rgba(15, 23, 42, 0.05);
      }

      .card-header {
        background: var(--surface);
      }

      .nav-tabs {
        --bs-nav-tabs-border-color: var(--border-soft);
        --bs-nav-tabs-link-active-color: var(--accent);
        --bs-nav-tabs-link-active-bg: var(--surface);
        --bs-nav-tabs-link-active-border-color:
          var(--border-soft) var(--border-soft) var(--surface);
      }

      .nav-tabs .nav-link {
        color: var(--text-muted);
        font-weight: 650;
      }

      .nav-tabs .nav-link:hover {
        color: var(--accent-hover);
      }

      .nav-tabs .nav-link.active {
        color: var(--accent);
      }

      .sidebar-section {
        border: 1px solid var(--border-soft);
        border-radius: 8px;
        background: var(--surface);
        padding: 0.9rem;
        margin-bottom: 0.85rem;
        box-shadow: 0 1px 2px rgba(15, 23, 42, 0.03);
      }

      .sidebar-section__title {
        color: #344054;
        font-size: 0.82rem;
        font-weight: 750;
        margin-bottom: 0.65rem;
      }

      label {
        color: var(--ink);
        font-weight: 600;
      }

      .form-control,
      .form-select {
        border-color: var(--border-soft);
        color: var(--ink);
      }

      .input-group .btn {
        font-weight: 650;
      }

      .btn {
        border-radius: 6px;
        font-weight: 650;
      }

      .btn-primary {
        background-color: var(--primary);
        border-color: var(--primary);
      }

      .btn-primary:hover,
      .btn-primary:focus {
        background-color: var(--primary-hover);
        border-color: var(--primary-hover);
      }

      .btn-outline-primary {
        border-color: var(--primary);
        color: var(--primary);
      }

      .btn-outline-primary:hover,
      .btn-outline-primary:focus {
        background-color: var(--primary-soft);
        border-color: var(--primary);
        color: var(--primary-hover);
      }

      .btn-outline-danger {
        border-color: #fca5a5;
        color: var(--danger);
      }

      .btn-outline-danger:hover,
      .btn-outline-danger:focus {
        background-color: var(--danger-soft);
        border-color: var(--danger);
        color: #991b1b;
      }

      #download_md {
        background: var(--accent);
        border-color: var(--accent);
        color: #ffffff;
      }

      #download_md:hover,
      #download_md:focus {
        background: var(--accent-hover);
        border-color: var(--accent-hover);
        color: #ffffff;
      }

      .action-stack {
        display: grid;
        gap: 0.5rem;
      }

      .copy-notice {
        min-height: 1.35rem;
        margin-top: 0.65rem;
        color: var(--text-muted);
        font-size: 0.86rem;
      }

      .copy-notice.is-success {
        color: var(--success);
      }

      .format-list {
        color: var(--text-muted);
        font-size: 0.84rem;
        line-height: 1.45;
        margin-bottom: 0;
      }

      .result-summary {
        align-items: center;
        border-bottom: 1px solid var(--border-soft);
        display: flex;
        flex-wrap: wrap;
        gap: 0.55rem;
        justify-content: space-between;
        padding: 0.8rem 1rem;
      }

      .result-status {
        align-items: center;
        display: inline-flex;
        gap: 0.45rem;
        font-weight: 700;
      }

      .status-dot {
        background: #98a2b3;
        border-radius: 999px;
        display: inline-block;
        height: 0.62rem;
        width: 0.62rem;
      }

      .status-dot.is-ready {
        background: var(--success);
      }

      .summary-chips {
        display: flex;
        flex-wrap: wrap;
        gap: 0.4rem;
      }

      .summary-chip {
        background: var(--primary-soft);
        border: 1px solid #c7d7fe;
        border-radius: 999px;
        color: #1e3a8a;
        font-size: 0.82rem;
        padding: 0.22rem 0.58rem;
        white-space: nowrap;
      }

      .result-empty {
        color: var(--text-muted);
        min-height: 18rem;
        align-content: center;
        text-align: center;
      }

      .result-pane {
        padding: 1rem;
      }

      #markdown_text {
        background: var(--code-bg);
        border: 1px solid var(--border-soft);
        border-radius: 8px;
        color: #111827;
        font-family:
          'IBM Plex Mono', 'Cascadia Code', Consolas, 'Liberation Mono',
          monospace;
        font-size: 0.9rem;
        line-height: 1.55;
        min-height: 28rem;
        padding: 1rem;
        white-space: pre-wrap;
      }

      .markdown-preview {
        background: var(--surface);
        border: 1px solid var(--border-soft);
        border-radius: 8px;
        line-height: 1.65;
        min-height: 28rem;
        padding: 1.15rem 1.25rem;
      }

      .markdown-preview code,
      .markdown-preview pre {
        font-family:
          'IBM Plex Mono', 'Cascadia Code', Consolas, 'Liberation Mono',
          monospace;
      }

      .markdown-preview h1,
      .markdown-preview h2,
      .markdown-preview h3 {
        line-height: 1.2;
        margin-top: 1.2rem;
      }

      .markdown-preview table {
        display: block;
        max-width: 100%;
        overflow-x: auto;
      }

      @media (max-width: 768px) {
        .app-title__main {
          font-size: 1.12rem;
        }

        .result-summary {
          align-items: flex-start;
          flex-direction: column;
        }

        .summary-chip {
          white-space: normal;
        }
      }
    "
    )),
    tags$script(HTML(
      "
      Shiny.addCustomMessageHandler('copy-markdown', async function(text) {
        let ok = false;
        try {
          if (navigator.clipboard && window.isSecureContext) {
            await navigator.clipboard.writeText(text);
            ok = true;
          } else {
            const area = document.createElement('textarea');
            area.value = text;
            area.style.position = 'fixed';
            area.style.left = '-9999px';
            document.body.appendChild(area);
            area.focus();
            area.select();
            ok = document.execCommand('copy');
            document.body.removeChild(area);
          }
        } catch (error) {
          ok = false;
        }
        Shiny.setInputValue('copy_status', {
          ok: ok,
          nonce: Math.random()
        }, {priority: 'event'});
      });
    "
    ))
  ),
  sidebar = sidebar(
    width = 340,
    div(
      class = "sidebar-section",
      div(class = "sidebar-section__title", "Entrada"),
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
      )
    ),
    div(
      class = "sidebar-section",
      div(class = "sidebar-section__title", "Acciones"),
      div(
        class = "action-stack",
        actionButton("convert", "Convertir", class = "btn-primary w-100"),
        actionButton(
          "copy_md",
          "Copiar Markdown",
          class = "btn-outline-primary w-100"
        ),
        downloadButton("download_md", "Descargar Markdown", class = "w-100"),
        actionButton(
          "stop_app",
          "Detener Aplicacion",
          class = "btn-outline-danger w-100"
        )
      ),
      uiOutput("copy_notice")
    ),
    div(
      class = "sidebar-section",
      div(class = "sidebar-section__title", "Limites y formatos"),
      tags$p(
        class = "format-list",
        paste0("Subida maxima: ", max_size_mb, " MB")
      ),
      tags$p(
        class = "format-list",
        supported_extensions
      )
    )
  ),
  navset_card_tab(
    full_screen = TRUE,
    title = "Resultado",
    header = uiOutput("result_summary"),
    nav_panel(
      "Markdown",
      div(
        class = "result-pane",
        verbatimTextOutput("markdown_text", placeholder = TRUE)
      )
    ),
    nav_panel(
      "Vista HTML",
      div(
        class = "result-pane",
        uiOutput("markdown_preview")
      )
    )
  )
)

server <- function(input, output, session) {
  markdown_value <- reactiveVal("")
  source_name <- reactiveVal("document.md")
  result_meta <- reactiveVal(NULL)
  copy_state <- reactiveVal(list(message = "", ok = NA))

  observeEvent(input$stop_app, {
    stopApp()
  })

  observeEvent(input$convert, {
    req(input$document)

    uploaded <- input$document
    source_name(uploaded$name)
    result_meta(NULL)
    copy_state(list(message = "", ok = NA))

    withProgress(message = "Convirtiendo documento", value = 0.25, {
      safe_filename <- paste0(
        gsub(
          "[^A-Za-z0-9_-]",
          "_",
          tools::file_path_sans_ext(basename(uploaded$name))
        ),
        ".",
        tools::file_ext(uploaded$name)
      )
      target <- file.path(tempdir(), safe_filename)
      file.copy(uploaded$datapath, target, overwrite = TRUE)
      incProgress(0.35)

      converted <- if (
        exists("convert_to_markdown", envir = globalenv(), mode = "function")
      ) {
        get("convert_to_markdown", envir = globalenv())(
          target,
          use_cli = input$use_cli
        )
      } else if (requireNamespace("markitdownshiny", quietly = TRUE)) {
        markitdownshiny::convert_to_markdown(target, use_cli = input$use_cli)
      } else {
        stop("No se encontro la funcion convert_to_markdown.")
      }

      markdown_value(converted)
      result_meta(list(
        name = uploaded$name,
        size = uploaded$size,
        extension = tools::file_ext(uploaded$name),
        method = if (isTRUE(input$use_cli)) "CLI" else "Python",
        chars = nchar(converted, type = "chars", allowNA = FALSE),
        lines = length(strsplit(converted, "\n", fixed = TRUE)[[1]])
      ))
      incProgress(0.40)
    })
  })

  output$markdown_text <- renderText({
    text <- markdown_value()
    if (!nzchar(text)) {
      return("")
    }
    text
  })

  output$markdown_preview <- renderUI({
    text <- markdown_value()
    if (!nzchar(text)) {
      return(div(
        class = "result-empty",
        "Cargue un documento y presione Convertir."
      ))
    }

    source <- tempfile(fileext = ".md")
    writeLines(text, source, useBytes = TRUE)
    html <- markdown::markdownToHTML(file = source, fragment.only = TRUE)
    div(class = "markdown-preview", HTML(html))
  })

  observeEvent(input$copy_md, {
    text <- markdown_value()
    if (!nzchar(text)) {
      copy_state(list(message = "No hay Markdown para copiar.", ok = FALSE))
      return()
    }

    session$sendCustomMessage("copy-markdown", text)
  })

  observeEvent(input$copy_status, {
    if (isTRUE(input$copy_status$ok)) {
      copy_state(list(message = "Markdown copiado al portapapeles.", ok = TRUE))
    } else {
      copy_state(list(
        message = "No se pudo copiar automaticamente.",
        ok = FALSE
      ))
    }
  })

  output$copy_notice <- renderUI({
    state <- copy_state()
    class <- if (isTRUE(state$ok)) {
      "copy-notice is-success"
    } else {
      "copy-notice"
    }

    div(class = class, state$message)
  })

  output$result_summary <- renderUI({
    meta <- result_meta()
    text <- markdown_value()

    if (is.null(meta) || !nzchar(text)) {
      return(div(
        class = "result-summary",
        div(
          class = "result-status",
          span(class = "status-dot"),
          "Sin conversion"
        )
      ))
    }

    div(
      class = "result-summary",
      div(
        class = "result-status",
        span(class = "status-dot is-ready"),
        "Resultado listo"
      ),
      div(
        class = "summary-chips",
        span(class = "summary-chip", basename(meta$name)),
        span(class = "summary-chip", format_file_size(meta$size)),
        span(class = "summary-chip", paste(meta$lines, "lineas")),
        span(class = "summary-chip", paste(meta$chars, "caracteres")),
        span(class = "summary-chip", meta$method)
      )
    )
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

format_file_size <- function(bytes) {
  if (is.null(bytes) || is.na(bytes)) {
    return("tamano desconocido")
  }

  units <- c("B", "KB", "MB", "GB")
  size <- as.numeric(bytes)
  unit <- 1

  while (size >= 1024 && unit < length(units)) {
    size <- size / 1024
    unit <- unit + 1
  }

  paste0(
    format(round(size, if (unit == 1) 0 else 1), trim = TRUE),
    " ",
    units[unit]
  )
}

shinyApp(ui, server)
