# Criterios de diseno y decisiones tecnicas

## Objetivo

El objetivo del proyecto es entregar un paquete R que despliegue una app Shiny
para convertir documentos a Markdown de forma practica. La aplicacion debe
permitir cargar archivos en diferentes formatos, visualizar el resultado en
Markdown y descargar el archivo `.md` generado.

## Fuente tecnica revisada

Se reviso la documentacion publica de `microsoft/markitdown` y PyPI. Los
puntos relevantes para el diseno son:

- `markitdown` es una utilidad Python ligera para convertir archivos a
  Markdown.
- El foco declarado es preparar contenido para LLMs y analisis de texto, no
  conversiones visuales de alta fidelidad.
- Soporta multiples formatos, incluidos PDF, Word, PowerPoint, Excel, HTML,
  CSV, JSON, XML, imagenes, audio, ZIP, YouTube URLs, EPUB y otros.
- Requiere Python 3.10 o superior.
- Se instala con `pip install "markitdown[all]"` para habilitar dependencias
  opcionales de multiples formatos.
- La libreria hace operaciones de entrada/salida con los permisos del proceso
  que la ejecuta, por lo que se deben controlar archivos no confiables y
  permisos del entorno.

## Decision: paquete R como envoltorio

No se reimplementa la conversion de documentos en R. El paquete funciona como
envoltorio alrededor de MarkItDown porque:

- MarkItDown ya concentra la logica especializada por formato.
- Evita mantener parsers separados para PDF, Office, HTML, imagenes y audio.
- Permite actualizar capacidades instalando nuevas versiones del paquete
  Python.
- Reduce el codigo R a integracion, UI, validacion y experiencia de usuario.

## Decision: `reticulate` como ruta principal

La funcion `convert_to_markdown()` usa `reticulate` para importar:

```python
from markitdown import MarkItDown
```

Esta ruta evita crear archivos intermedios de salida y permite integrar la API
Python dentro del proceso R. Si la importacion falla pero existe el ejecutable
`markitdown` en `PATH`, el paquete intenta la ruta CLI como respaldo.

## Decision: app Shiny incluida en `inst/shiny`

La app vive en `inst/shiny` y se lanza con `launch_markitdown_app()`. Esto
mantiene el paquete instalable y permite usar:

```r
markitdownshiny::launch_markitdown_app()
```

La app tambien incluye una ruta de desarrollo para poder ejecutarla desde el
directorio fuente durante pruebas locales.

## Flujo de usuario

El flujo se diseno para una tarea corta y repetible:

1. Cargar documento.
2. Presionar Convertir.
3. Revisar el Markdown crudo.
4. Revisar una vista previa renderizada.
5. Descargar el resultado `.md`.

La descarga usa el nombre base del documento original y reemplaza la extension
por `.md`.

## Criterios de interfaz

La interfaz usa un panel lateral para acciones y dos paneles principales:

- Markdown crudo: importante para revisar exactamente lo que se descargara.
- Vista previa: util para comprobar estructura, tablas, listas y encabezados.

Se evita una pagina tipo landing porque el requerimiento es una herramienta de
conversion. La primera pantalla es la experiencia de uso real.

## Formatos aceptados

La app declara extensiones frecuentes compatibles con MarkItDown:

- Documentos: `.pdf`, `.docx`, `.pptx`, `.xlsx`, `.xls`, `.epub`.
- Web y texto: `.html`, `.htm`, `.csv`, `.json`, `.xml`, `.txt`.
- Multimedia: `.jpg`, `.jpeg`, `.png`, `.wav`, `.mp3`.
- Contenedores y correo: `.zip`, `.eml`, `.msg`.

La lista es conservadora para guiar el selector de archivos. MarkItDown puede
soportar mas formatos dependiendo de sus dependencias opcionales instaladas.

## Seguridad y despliegue

MarkItDown advierte que sus conversiones realizan I/O con los permisos del
proceso actual. Por ello, en un despliegue multiusuario o con archivos no
confiables se recomienda:

- Ejecutar Shiny con una cuenta de sistema con permisos minimos.
- Mantener `shiny.maxRequestSize` acotado.
- Usar almacenamiento temporal dedicado.
- No montar directorios sensibles en el proceso de la app.
- Limpiar archivos temporales si se adapta el codigo para persistir resultados.
- Evitar habilitar plugins externos sin revision previa.

## Limitaciones conocidas

- La calidad del Markdown depende de MarkItDown y de las dependencias Python
  instaladas.
- Algunos formatos requieren extras especificos de Python.
- OCR, transcripcion de audio y servicios Azure pueden requerir dependencias,
  credenciales o costos adicionales.
- La vista previa HTML es una aproximacion; el artefacto canonico es el
  Markdown descargado.

## Referencias

- GitHub: <https://github.com/microsoft/markitdown>
- PyPI: <https://pypi.org/project/markitdown/>
