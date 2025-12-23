test_that("optk_gcms works with kmeans and wss method", {
  var_names <- c("bio_1", "bio_12")
  s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)
  study_area <- terra::ext(c(-80, -30, -50, 10)) |> terra::vect(crs="+proj=longlat +datum=WGS84 +no_defs")
  result <- optk_gcms(s, var_names, study_area, cluster = "kmeans", method = "wss")
  expect_no_error(result)
  expect_true(ggplot2::is_ggplot(result))
})

test_that("optk_gcms works with kmeans and silhouette method", {
  var_names <- c("bio_1", "bio_12")
  s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)
  study_area <- terra::ext(c(-80, -30, -50, 10)) |> terra::vect(crs="+proj=longlat +datum=WGS84 +no_defs")
  result <- optk_gcms(s, var_names, study_area, cluster = "kmeans", method = "silhouette")
  expect_no_error(result)
  expect_true(ggplot2::is_ggplot(result))
})

test_that("optk_gcms fails with invalid cluster method", {
  var_names <- c("bio_1", "bio_12")
  s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)
  study_area <- terra::ext(c(-80, -30, -50, 10)) |> terra::vect(crs="+proj=longlat +datum=WGS84 +no_defs")
  expect_error(optk_gcms(s, var_names, study_area, cluster = "invalid_method"), "Assertion on 'cluster' failed")
})

test_that("optk_gcms fails with invalid method", {
  var_names <- c("bio_1", "bio_12")
  s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)
  study_area <- terra::ext(c(-80, -30, -50, 10)) |> terra::vect(crs="+proj=longlat +datum=WGS84 +no_defs")
  expect_error(optk_gcms(s, var_names, study_area, method = "invalid_method"), "Assertion on 'method' failed")
})
