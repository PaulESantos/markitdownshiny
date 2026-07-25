# convert_to_markdown validates path input

    Code
      convert_to_markdown("")
    Condition
      Error:
      ! `path` debe ser una ruta local no vacia.

---

    Code
      convert_to_markdown("definitely-not-here.md")
    Condition
      Error:
      ! El archivo no existe: definitely-not-here.md

# internal file validation rejects directories

    Code
      markitdownshiny:::check_file_path(tempdir())
    Condition
      Error:
      ! `path` debe apuntar a un archivo, no a un directorio.
