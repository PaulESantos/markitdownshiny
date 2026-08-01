
<!-- README.md is generated from README.Rmd. Please edit README.Rmd -->

# markitdownshiny

<!-- badges: start -->

[![R-CMD-check](https://img.shields.io/badge/R--CMD--check-passing-brightgreen)](https://github.com/PaulESantos/markitdownshiny)
[![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->

`markitdownshiny` provides an interactive 'Shiny' application and R
helpers for converting local documents to Markdown with Microsoft's
Python 'MarkItDown' library. It is intended for R users who want a
lightweight document conversion interface without leaving their R
session.

The package delegates conversion to Python through `reticulate` by
default and can also call the `markitdown` command-line tool when
requested. Python and the Python package `markitdown` are external
requirements and are not bundled with this R package.

## Installation

Install the CRAN release with:

``` r
install.packages("markitdownshiny")
```

You can install the development version from GitHub with:

``` r
pak::pak("PaulESantos/markitdownshiny")
```

## Python requirements

`markitdownshiny` requires Python 3.10 or later and the Python package
`markitdown`. Install the Python dependency in the Python environment
that will be used by `reticulate`:

``` bash
python -m pip install "markitdown[all]"
```

If you use a specific Python environment, configure it before converting
files:

``` r
library(reticulate)
use_python("/path/to/python", required = TRUE)
```

You can inspect the active Python and CLI setup from R:

``` r
library(markitdownshiny)

check_markitdown_installation()
```

## Usage

Launch the bundled application:

``` r
library(markitdownshiny)

launch_markitdown_app()
```

Use a larger upload limit for local sessions when needed:

``` r
launch_markitdown_app(max_file_size_mb = 100)
```

Convert a file programmatically:

``` r
md_text <- convert_to_markdown("document.docx")
cat(md_text)
```

Return a structured result with available metadata:

``` r
result <- convert_to_markdown("document.docx", output = "result")
result$title
result$markdown
```

Force use of the `markitdown` command-line executable:

``` r
md_text <- convert_to_markdown("report.pdf", use_cli = TRUE)
```

## Supported inputs

Supported formats depend on the installed Python `markitdown` package
and its optional extras. Common local formats include PDF, Microsoft
Word, PowerPoint, Excel, comma-separated values (CSV), HyperText Markup
Language (HTML), plain text, JavaScript Object Notation (JSON),
Extensible Markup Language (XML), EPUB, ZIP, JPEG, PNG, EML, and MSG
files.

Some `markitdown` features can require additional Python dependencies or
external services. For example, audio transcription and advanced image
or scanned-document extraction may send data to a third-party service
depending on the Python configuration. Review the Microsoft 'MarkItDown'
documentation before using those features with private or regulated
documents: <https://github.com/microsoft/markitdown>.

## Application behavior

The Shiny app copies uploaded files to R's session temporary directory
before conversion. It shows both the raw Markdown and a rendered HTML
preview, and it can copy or download the Markdown result.

For public Shiny deployments, configure upload limits and Python
environments explicitly. The app does not sandbox document parsers or
external Python dependencies.

## License

MIT. See the package license for copyright details.
