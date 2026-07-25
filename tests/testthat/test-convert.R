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
