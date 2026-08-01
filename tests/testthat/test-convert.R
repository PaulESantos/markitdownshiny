test_that("convert_to_markdown validates path input", {
  expect_snapshot(error = TRUE, {
    convert_to_markdown("")
  })

  expect_snapshot(error = TRUE, {
    convert_to_markdown("definitely-not-here.md")
  })
})

test_that("internal file validation rejects directories", {
  expect_snapshot(error = TRUE, {
    markitdownshiny:::check_file_path(tempdir())
  })
})

test_that("structured conversion results can be returned as text", {
  result <- markitdownshiny:::new_markitdown_result(
    markdown = "# Title",
    title = "Title",
    source = "input.md",
    method = "python"
  )

  expect_s3_class(result, "markitdownshiny_result")
  expect_identical(as.character(result), "# Title")
  expect_identical(
    markitdownshiny:::format_conversion_output(result, "text"),
    "# Title"
  )
  expect_identical(
    markitdownshiny:::format_conversion_output(result, "result"),
    result
  )
})

test_that("installation diagnostics return a stable shape", {
  info <- check_markitdown_installation(quiet = TRUE)

  expect_s3_class(info, "markitdownshiny_installation")
  expect_named(
    info,
    c(
      "python_available",
      "python",
      "markitdown_available",
      "markitdown_version",
      "cli_available",
      "cli_path",
      "python_error"
    )
  )
})
