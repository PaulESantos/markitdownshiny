# markitdownshiny

`markitdownshiny` is an R package that exposes a Shiny application for
converting uploaded documents to Markdown with Microsoft's Python
`markitdown` project.

## Why MarkItDown?

Microsoft describes MarkItDown as a lightweight Python utility for converting
files to Markdown for LLM and text analysis workflows. Its documented support
includes PDF, Word, PowerPoint, Excel, images with metadata/OCR, audio
metadata/transcription, HTML, CSV, JSON, XML, ZIP, YouTube URLs, EPUB and more.
The current Python package requires Python 3.10 or newer.

This R package does not reimplement document parsing. It delegates conversion
to the official Python package and focuses on a practical Shiny workflow:

- upload a supported document;
- convert it to Markdown;
- inspect the raw Markdown;
- inspect a rendered preview;
- download the resulting `.md` file.

## Installation

Install the R dependencies in your R environment:

```r
install.packages(c("shiny", "bslib", "reticulate", "markdown", "htmltools"))
```

Install MarkItDown in Python:

```bash
python -m pip install "markitdown[all]"
```

If you use a dedicated Python environment, configure `reticulate` before
launching the app, for example:

```r
reticulate::use_python("C:/path/to/python", required = TRUE)
```

## Usage

From the package source directory:

```r
devtools::load_all()
launch_markitdown_app()
```

After installation:

```r
markitdownshiny::launch_markitdown_app()
```

Programmatic conversion is also available:

```r
text <- markitdownshiny::convert_to_markdown("example.docx")
cat(text)
```

## Design Notes

The app intentionally keeps conversion local to the Shiny process. Uploaded
files are copied to R temporary storage, converted, displayed, and offered as a
download. Because MarkItDown performs I/O with the privileges of the current
process, deployments that accept untrusted uploads should run with minimal
filesystem permissions and conservative upload size limits.

See `docs/design-decisions.md` for detailed criteria and decisions.
