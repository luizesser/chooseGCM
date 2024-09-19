# test_that("import_gcms standard", {
#  expect_no_error(import_gcms(path = "input_data/WorldClim_data_future", extension = ".tif", recursive = TRUE, gcm_names = NULL))
# })

# test_that("import_gcms less gcm_names", {
#  expect_no_error(import_gcms(path = "input_data/WorldClim_data_future", extension = ".tif", recursive = TRUE, gcm_names = c("a")))
# })

test_that("import_gcms more gcm_names", {
  expect_error(import_gcms(path = "input_data/WorldClim_data_future", extension = ".tif", recursive = TRUE, gcm_names = rep("a", 100)))
})

test_that("import_gcms wrong path", {
  expect_error(import_gcms(path = "abcde", extension = ".tif", recursive = TRUE, gcm_names = c("a")))
})

test_that("import_gcms wrong path (numeric)", {
  expect_error(import_gcms(path = 4, extension = ".tif", recursive = TRUE, gcm_names = c("a")))
})

test_that("import_gcms wrong extension", {
  expect_error(import_gcms(path = "input_data/WorldClim_data_future", extension = ".jpeg", recursive = TRUE, gcm_names = NULL))
})

test_that("import_gcms wrong extension (numeric)", {
  expect_error(import_gcms(path = "input_data/WorldClim_data_future", extension = 4, recursive = TRUE, gcm_names = NULL))
})

test_that("import_gcms wrong recursive (character)", {
  expect_error(import_gcms(path = "input_data/WorldClim_data_future", extension = ".tif", recursive = "A", gcm_names = NULL))
})
