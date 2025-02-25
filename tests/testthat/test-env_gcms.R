var_names <- c("bio_1", "bio_12")
s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)
study_area <- terra::ext(c(-80, -30, -50, 10)) |> terra::vect(crs="epsg:4326")

test_that("env_gcms returns a ggplot object when no highlight is specified", {
  plot <- env_gcms(s, var_names, study_area)
  expect_true(is.ggplot(plot))
})

test_that("env_gcms returns a ggplot object when specific GCMs are highlighted", {
  plot <- env_gcms(s, var_names, study_area, highlight = c("ae", "ch", "cr"))
  expect_true(is.ggplot(plot))
})

test_that("env_gcms returns a ggplot object when 'sum' is highlighted", {
  plot <- env_gcms(s, var_names, study_area, highlight = "sum")
  expect_true(is.ggplot(plot))
})

test_that("env_gcms handles incorrect highlight values", {
  expect_error(env_gcms(s, var_names, study_area, highlight = "nonexistent_gcm"))
})

test_that("env_gcms handles incorrect var_names", {
  expect_error(env_gcms(s, var_names = c("nonexistent_var"), study_area))
})

test_that("env_gcms handles NULL study_area", {
  plot <- env_gcms(s, var_names, study_area = NULL)
  expect_true(is.ggplot(plot))
})

test_that("env_gcms handles different resolutions", {
  plot <- env_gcms(s, var_names, study_area, resolution = 50)
  expect_true(is.ggplot(plot))
})

test_that("env_gcms handles custom titles", {
  plot <- env_gcms(s, var_names, study_area, title = "Custom Title")
  expect_true(is.ggplot(plot))
  expect_equal(plot$labels$title, "Custom Title")
})

test_that("env_gcms handles an empty list of GCMs", {
  empty_list <- list()
  expect_error(env_gcms(empty_list, var_names, study_area))
})

test_that("env_gcms handles a single GCM", {
  single_gcm <- list("ae" = s[[1]])
  plot <- env_gcms(single_gcm, var_names, study_area)
  expect_true(is.ggplot(plot))
})

test_that("env_gcms handles a study area with a different CRS", {
  study_area_diff_crs <- terra::ext(c(-80, -30, -50, 10)) |> terra::vect(crs="epsg:4326") |> terra::project("+init=EPSG:6933")
  plot <- env_gcms(s, var_names, study_area_diff_crs)
  expect_true(is.ggplot(plot))
})

test_that("env_gcms handles a large resolution value", {
  plot <- env_gcms(s, var_names, study_area, resolution = 100)
  expect_true(is.ggplot(plot))
})
