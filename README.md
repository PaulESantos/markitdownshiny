<!-- README.md is generated from README.Rmd. Please edit README.Rmd -->

# markitdownshiny

<!-- badges: start -->
[![R-CMD-check](https://img.shields.io/badge/R--CMD--check-passing-brightgreen)](https://github.com/paulefrens/markitdownshiny)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->

**`markitdownshiny`** es un paquete de R que proporciona una interfaz interactiva de **Shiny** y funciones programáticas para convertir archivos y documentos a formato **Markdown**, integrando la librería de Python [Microsoft MarkItDown](https://github.com/microsoft/markitdown) mediante `reticulate`.

## 🚀 Características principales

- **Interfaz Shiny Moderna:** Carga de documentos, vista previa de código Markdown plano y renderizado HTML interactivo utilizando estilos de `bslib` (Bootstrap 5).
- **Conversión Programática:** Función `convert_to_markdown()` para integrar la conversión directa en scripts de R y pipelines de procesamiento.
- **Soporte Multiformato Extenso:** Conversión de archivos PDF, Word (`.docx`), PowerPoint (`.pptx`), Excel (`.xlsx`, `.csv`), HTML, JSON, XML, ZIP, EPUB, imágenes (con metadatos/OCR), audio (transcripción) y más.
- **Integración Flexible con Python:** Permite conectar directamente mediante la API de Python a través de `reticulate` o usar el ejecutable CLI (`markitdown`).
- **Exportación:** Descarga inmediata del resultado en formato `.md`.

## 📦 Instalación

### 1. Requisitos de R

Puedes instalar la versión de desarrollo o instalar las dependencias necesarias ejecutando en R:

```r
# Instalar dependencias de R
install.packages(c("shiny", "bslib", "reticulate", "markdown", "htmltools"))

# Instalar la versión publicada en CRAN (cuando esté disponible):
# install.packages("markitdownshiny")

# O instalar la versión de desarrollo desde GitHub:
# devtools::install_github("paulefrens/markitdownshiny")
```

### 2. Requisitos de Python

`markitdownshiny` requiere **Python 3.10 o superior** y la librería `markitdown`. Instálala en tu entorno ejecutable de Python con:

```bash
python -m pip install "markitdown[all]"
```

Si utilizas un entorno específico de Python (Conda, venv, pyenv), puedes configurarlo en R antes de usar la librería:

```r
library(reticulate)
use_python("/ruta/a/tu/python", required = TRUE)
```

## 🛠️ Uso

### 1. Iniciar la Aplicación Shiny

Para lanzar la interfaz gráfica interactiva:

```r
library(markitdownshiny)

# Iniciar la aplicación Shiny
launch_markitdown_app()
```

Durante la etapa de desarrollo:

```r
devtools::load_all()
launch_markitdown_app()
```

### 2. Conversión Programática en R

Puedes realizar conversiones de archivos directamente desde código R sin abrir la interfaz Shiny:

```r
library(markitdownshiny)

# Convertir un documento Word o PDF a Markdown
md_text <- convert_to_markdown("documento.docx")

# Imprimir el resultado en consola
cat(md_text)

# Guardar en un archivo .md
writeLines(md_text, "resultado.md")
```

Si deseas forzar el uso de la herramienta CLI de `markitdown`:

```r
md_text <- convert_to_markdown("reporte.pdf", use_cli = TRUE)
```

## 📄 Formatos Compatibles

| Categoría | Extensiones Soportadas |
| :--- | :--- |
| **Documentos** | `.pdf`, `.docx`, `.pptx`, `.epub`, `.eml`, `.msg` |
| **Tablas y Datos** | `.xlsx`, `.xls`, `.csv`, `.json`, `.xml` |
| **Web y Texto** | `.html`, `.htm`, `.txt` |
| **Multimedia / OCR** | `.jpg`, `.jpeg`, `.png` (con metadatos/OCR), `.wav`, `.mp3` (transcripción) |
| **Compresiones** | `.zip` |

## 🏗️ Arquitectura y Seguridad

- **Procesamiento Local:** La conversión se ejecuta de forma local dentro del proceso de R / Python. Los archivos cargados se almacenan temporalmente en `tempdir()` y se eliminan al finalizar la sesión.
- **Seguridad en Servidores:** Si planeas desplegar la aplicación Shiny en un servidor (ej. Shiny Server o Posit Connect), ajusta los límites de tamaño máximo de subida (`options(shiny.maxRequestSize = ...)`).

## 👤 Autoría y Licencia

- **Autor y Mantenedor:** Paul E. Santos Andrade ([paulefrens@gmail.com](mailto:paulefrens@gmail.com)) - ORCID: [0000-0002-6635-0375](https://orcid.org/0000-0002-6635-0375)
- **Licencia:** MIT
