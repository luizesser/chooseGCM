var_names <- c("bio_1", "bio_12")
s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)
study_area <- terra::ext(c(-80, -30, -50, 10)) |> terra::vect(crs="epsg:4326")

test_that("Function returns a list with expected elements", {
  result <- closestdist_gcms(s, var_names, study_area)
  expect_type(result, "list")
  expect_true(all(c("suggested_gcms", "best_mean_diff", "global_mean") %in% names(result)))
})

test_that("Returned suggested GCMs are non-empty", {
  result <- closestdist_gcms(s, var_names, study_area)
  expect_gt(length(result$suggested_gcms), 0)
})

test_that("Global mean distance is a positive numeric value", {
  result <- closestdist_gcms(s, var_names, study_area)
  expect_type(result$global_mean, "double")
  expect_gt(result$global_mean, 0)
})

test_that("Best mean difference is non-negative", {
  result <- closestdist_gcms(s, var_names, study_area)
  expect_type(result$best_mean_diff, "double")
  expect_gte(result$best_mean_diff, 0)
})

test_that("Function handles different distance methods", {
  methods <- c("euclidean", "manhattan", "pearson")
  for (method in methods) {
    result <- closestdist_gcms(s, var_names, study_area, method = method)
    expect_type(result, "list")
  }
})

test_that("Function handles different values of k", {
  for (k in c(2, 5, 10)) {
    result <- closestdist_gcms(s, var_names, study_area, k = k)
    expect_lte(length(result$suggested_gcms), k)
  }
})

#test_that("Function applies scaling correctly", {
#  result_scaled <- closestdist_gcms(s, var_names, study_area, scale = TRUE)
#  result_unscaled <- closestdist_gcms(s, var_names, study_area, scale = FALSE)
#  expect_false(identical(result_scaled$suggested_gcms, result_unscaled$suggested_gcms))
#})

test_that("Function stops when max_difference is exceeded", {
  result <- closestdist_gcms(s, var_names, study_area, max_difference = 0.1)
  expect_lte(result$best_mean_diff, 0.1)
})

test_that("Function handles NULL study area", {
  result <- closestdist_gcms(s, var_names, study_area = NULL)
  expect_type(result, "list")
})

test_that("Function returns different results for different variable selections", {
  result1 <- closestdist_gcms(s, c("bio_1"), study_area)
  result2 <- closestdist_gcms(s, c("bio_12"), study_area)
  expect_false(identical(result1$suggested_gcms, result2$suggested_gcms))
})
