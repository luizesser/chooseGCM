test_that("summary_gcms returns a list", {
  var_names <- c("bio_1", "bio_12")
  s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)
  study_area <- terra::ext(c(-80, -30, -50, 10)) |> terra::vect(crs="epsg:4326")
  result <- summary_gcms(s, var_names, study_area)
  expect_type(result, "list")
})

test_that("summary_gcms contains expected statistics", {
  var_names <- c("bio_1", "bio_12")
  s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)
  study_area <- terra::ext(c(-80, -30, -50, 10)) |> terra::vect(crs="epsg:4326")
  result <- summary_gcms(s, var_names, study_area)
  expect_true(all(c("min", "quantile_0.25", "median", "mean", "quantile_0.75", "max", "sd", "NAs", "n_cells") %in% colnames(result[[1]])))
})

test_that("summary_gcms correctly handles missing variables", {
  var_names <- c("bio_1", "bio_12")
  s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)
  study_area <- terra::ext(c(-80, -30, -50, 10)) |> terra::vect(crs="epsg:4326")
  expect_error(summary_gcms(s, c("bio_99"), study_area), "Assertion on 'var_names' failed")
})

test_that("summary_gcms accepts 'all' as argument for var_names", {
  var_names <- c("bio_1", "bio_12")
  s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)
  study_area <- terra::ext(c(-80, -30, -50, 10)) |> terra::vect(crs="epsg:4326")
  result <- summary_gcms(s, "all", study_area)
  expect_true(length(result) > 0)
})
