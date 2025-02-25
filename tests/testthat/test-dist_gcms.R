var_names <- c("bio_1", "bio_12")
s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)
study_area <- terra::ext(c(-80, -30, -50, 10)) |> terra::vect(crs="epsg:4326")

test_that("dist_gcms returns a list with distances and heatmap", {
  result <- dist_gcms(s, var_names, study_area)
  expect_type(result, "list")
  expect_named(result, c("distances", "heatmap"))
})

test_that("dist_gcms calculates distances correctly", {
  result <- dist_gcms(s, var_names, study_area, method = "euclidean")
  expect_s3_class(result$distances, "dist")
  expect_true(all(result$distances >= 0))
})

test_that("dist_gcms returns a ggplot object for heatmap", {
  result <- dist_gcms(s, var_names, study_area)
  expect_s3_class(result$heatmap, "ggplot")
})

test_that("dist_gcms handles scaling correctly", {
  result_scaled <- dist_gcms(s, var_names, study_area, scale = TRUE)
  result_unscaled <- dist_gcms(s, var_names, study_area, scale = FALSE)
  expect_false(identical(result_scaled$distances, result_unscaled$distances))
})

test_that("dist_gcms handles different distance methods", {
  methods <- c("euclidean", "manhattan", "pearson")
  for (method in methods) {
    result <- dist_gcms(s, var_names, study_area, method = method)
    expect_s3_class(result$distances, "dist")
  }
})

test_that("dist_gcms handles 'all' in var_names", {
  result <- dist_gcms(s, "all", study_area)
  expect_s3_class(result$distances, "dist")
})

test_that("dist_gcms handles invalid var_names", {
  expect_error(dist_gcms(s, c("invalid_var"), study_area))
})

test_that("dist_gcms handles invalid study_area", {
  invalid_study_area <- terra::ext(c(-30, -10, -60, -40)) |> terra::vect(crs="epsg:4326")
  expect_error(dist_gcms(s, var_names, invalid_study_area))
})

test_that("dist_gcms handles empty study_area", {
  empty_study_area <- terra::ext(c(0, 0, 0, 0)) |> terra::vect(crs="epsg:4326")
  expect_error(dist_gcms(s, var_names, empty_study_area))
})

test_that("dist_gcms handles non-list input for s", {
  expect_error(dist_gcms(s[[1]], var_names, study_area))
})

test_that("dist_gcms handles non-SpatRaster input in list", {
  invalid_s <- list(data.frame(bio_1 = rnorm(10), bio_12 = rnorm(10)))
  expect_error(dist_gcms(invalid_s, var_names, study_area))
})

test_that("dist_gcms handles missing var_names", {
  expect_error(dist_gcms(s, NULL, study_area))
})

