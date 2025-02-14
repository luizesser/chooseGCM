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

test_that("import_gcms imports files correctly", {
  path <- system.file("extdata", package = "chooseGCM")
  var_names <- c("bio1", "bio12")
  
  result <- import_gcms(path = path, var_names = var_names)
  
  expect_type(result, "list")
  expect_true(length(result) > 0)
  expect_true(all(sapply(result, inherits, "SpatRaster")))
})

test_that("import_gcms assigns correct variable names", {
  path <- system.file("extdata", package = "chooseGCM")
  var_names <- c("bio1", "bio12")
  
  result <- import_gcms(path = path, var_names = var_names)
  
  expect_true(all(sapply(result, function(x) all(names(x) == var_names))))
})

test_that("import_gcms handles missing variable names", {
  path <- system.file("extdata", package = "chooseGCM")
  var_names <- c("bio1", "bio12")
  
  result <- import_gcms(path = path, var_names = var_names)
  
  first_stack <- result[[1]]
  expected_var_names <- var_names
  expect_equal(names(first_stack), expected_var_names)
})

test_that("import_gcms imports files correctly", {
  path <- system.file("extdata", package = "chooseGCM")
  var_names <- c("bio1", "bio12")
  
  result <- import_gcms(path = path, var_names = var_names)
  
  expect_type(result, "list")
  expect_true(length(result) > 0)
  expect_true(all(sapply(result, inherits, "SpatRaster")))
})

test_that("import_gcms assigns correct variable names", {
  path <- system.file("extdata", package = "chooseGCM")
  var_names <- c("bio1", "bio12")
  
  result <- import_gcms(path = path, var_names = var_names)
  
  expect_true(all(sapply(result, function(x) all(names(x) == var_names))))
})