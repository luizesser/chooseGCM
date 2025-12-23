var_names <- c("bio_1", "bio_12")
s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)
study_area <- terra::ext(c(-80, -30, -50, 10)) |> terra::vect(crs="+proj=longlat +datum=WGS84 +no_defs")

test_that("hclust_gcms returns a list with expected elements", {
  result <- hclust_gcms(s, var_names, study_area, k = 3, n = 500)
  expect_type(result, "list")
  expect_true("suggested_gcms" %in% names(result))
  expect_true("dend_plot" %in% names(result))
})

test_that("hclust_gcms handles different k values", {
  result_2 <- hclust_gcms(s, var_names, study_area, k = 2, n = 500)
  expect_length(result_2$suggested_gcms, 2)

  result_5 <- hclust_gcms(s, var_names, study_area, k = 5, n = 500)
  expect_length(result_5$suggested_gcms, 5)
})

test_that("hclust_gcms returns an error for invalid inputs", {
  expect_error(hclust_gcms(NULL, var_names, study_area))
  expect_error(hclust_gcms(s, "bio_1", study_area))
  expect_error(hclust_gcms("invalid", var_names, study_area))
})

test_that("hclust_gcms works correctly when n is NULL", {
  result <- hclust_gcms(s, var_names, study_area, k = 3, n = NULL)
  expect_type(result, "list")
  expect_true(length(result$suggested_gcms) == 3)
})

test_that("hclust_gcms preserves suggested GCM names", {
  result <- hclust_gcms(s, var_names, study_area, k = 3, n = 500)
  expect_type(result$suggested_gcms, "character")
  expect_true(all(result$suggested_gcms %in% names(s)))
})

test_that("hclust_gcms returns an error if k is greater than available GCMs", {
  expect_error(hclust_gcms(s, var_names, study_area, k = 100, n = 500),
               "elements of 'k' must be between 1 and 11")
})

#test_that("hclust_gcms produces different clusters for different variables", {
#  result_1 <- hclust_gcms(s, c("bio_1"), study_area, k = 3, n = 500)
#  result_2 <- hclust_gcms(s, c("bio_12"), study_area, k = 3, n = 500)
#
#  expect_false(identical(result_1$suggested_gcms, result_2$suggested_gcms))
#})

test_that("hclust_gcms handles incorrect CRS in study_area", {
  study_area_invalid <- terra::ext(c(-80, -30, -50, 10)) |>
    terra::vect(crs="+proj=longlat +datum=WGS84 +no_defs") |>
    terra::project("+proj=longlat +ellps=intl +no_defs")
  result <- hclust_gcms(s, var_names, study_area_invalid, k = 3, n = 500)
  expect_length(result, 2)
  expect_true("suggested_gcms" %in% names(result))
  expect_true("dend_plot" %in% names(result))
})
