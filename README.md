<!-- README.md is generated from README.Rmd. Please edit README.Rmd -->

# markitdownshiny

<!-- badges: start -->
[![R-CMD-check](https://img.shields.io/badge/R--CMD--check-passing-brightgreen)](https://github.com/paulefrens/markitdownshiny)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->

**`markitdownshiny`** es un paquete de R que proporciona una aplicación interactiva en **Shiny** y funciones utilitarias programáticas para convertir archivos y documentos a formato **Markdown**, integrando la librería de Python [Microsoft MarkItDown](https://github.com/microsoft/markitdown) mediante `reticulate`.

## 🚀 Características principales

- **Interfaz Shiny Moderna:** Carga intuitiva de documentos, visor de código Markdown a pantalla completa y botón de parada limpia de la aplicación (`Detener Aplicación`).
- **Límite de Subida Configurable:** Límite por defecto de **50 MB** en ejecuciones locales, ajustable de forma sencilla con el parámetro `max_file_size_mb`.
- **Doble Motor de Conversión:** Integración directa por API de Python mediante `reticulate` y soporte para el ejecutable de línea de comandos CLI (`markitdown`), con respaldo automático (*fallback*).
- **Procesamiento de Rutas Seguro:** Sanitización automática de nombres de archivo para gestionar rutas con espacios o caracteres especiales en Windows, macOS y Linux.
- **Soporte Multiformato Extenso:** Conversión de documentos PDF, Word (`.docx`), PowerPoint (`.pptx`), Excel (`.xlsx`, `.csv`), HTML, JSON, XML, ZIP, EPUB, imágenes (OCR/metadatos) y audio (transcripción).
- **Exportación Directa:** Descarga inmediata del resultado en archivos `.md`.

## 📦 Instalación

### 1. Requisitos de R

Puedes instalar la versión publicada en CRAN (cuando esté disponible) o instalar la versión de desarrollo en R:

```r
# Instalar la versión oficial desde CRAN (cuando esté disponible):
install.packages("markitdownshiny")

# O instalar dependencias y versión de desarrollo desde GitHub:
# install.packages(c("shiny", "bslib", "reticulate", "markdown", "htmltools"))
# pak::pak("PaulESantos/markitdownshiny")
```

### 2. Requisitos de Python

`markitdownshiny` requiere **Python 3.10 o superior** y el paquete `markitdown`. Instálalo en tu entorno ejecutable de Python con:

```bash
python -m pip install "markitdown[all]"
```

Si utilizas un entorno específico de Python (Conda, venv, pyenv), puedes configurarlo en R antes de invocar el paquete:

```r
library(reticulate)
use_python("/ruta/a/tu/python", required = TRUE)
```

## 🛠️ Uso

### 1. Iniciar la Aplicación Shiny

Para lanzar la interfaz gráfica interactiva con el límite por defecto de 50 MB:

```r
library(markitdownshiny)

# Lanzar la aplicación Shiny (límite predeterminado de 50 MB)
launch_markitdown_app()

# O especificar un límite de subida personalizado en Megabytes (ej. 100 MB):
launch_markitdown_app(max_file_size_mb = 100)
```

Durante la etapa de desarrollo local del paquete:

```r
devtools::load_all()
launch_markitdown_app()
```

### 2. Conversión Programática en R

Puedes realizar conversiones de documentos directamente desde scripts de R sin abrir la interfaz gráfica:

```r
library(markitdownshiny)

# Convertir un archivo Word o PDF a texto Markdown
md_text <- convert_to_markdown("documento.docx")

# Imprimir el resultado en consola
cat(md_text)

# Guardar en un archivo .md
writeLines(md_text, "resultado.md")
```

Si deseas forzar el uso del ejecutable de consola CLI de `markitdown`:

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

- **Procesamiento Local:** La conversión se ejecuta localmente dentro de tu entorno de R / Python. Los archivos subidos se copian de forma temporal a `tempdir()` con nombres sanitizados y se eliminan al cerrar la sesión.
- **Controles en Servidores:** Para despliegues en servidores públicos (ej. Shiny Server o Posit Connect), el parámetro `max_file_size_mb` permite ajustar el límite de subida para prevenir saturación de recursos.

## 👤 Autoría y Licencia

- **Autor y Mantenedor:** Paul E. Santos Andrade ([paulefrens@gmail.com](mailto:paulefrens@gmail.com)) - ORCID: [0000-0002-6635-0375](https://orcid.org/0000-0002-6635-0375)
- **Licencia:** MIT
