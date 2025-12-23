var_names <- c("bio_1", "bio_12")
s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)
study_area <- terra::ext(c(-80, -30, -50, 10)) |> terra::vect(crs="+proj=longlat +datum=WGS84 +no_defs")

test_that("compare_gcms returns a list", {
  suppressWarnings(result <- compare_gcms(s, var_names, study_area, k = 3))
  expect_type(result, "list")
})

test_that("compare_gcms output contains expected elements", {
  result <- compare_gcms(s, var_names, study_area, k = 3)
  expect_named(result, c("suggested_gcms", "statistics_gcms"))
})

test_that("suggested_gcms is a list", {
  result <- compare_gcms(s, var_names, study_area, k = 3)
  expect_type(result$suggested_gcms, "list")
})

test_that("statistics_gcms is a ggplot object", {
  result <- compare_gcms(s, var_names, study_area, k = 3)
  expect_s3_class(result$statistics_gcms, "ggplot")
})

test_that("compare_gcms works with different clustering methods", {
  methods <- c("kmeans", "hclust", "closestdist")
  for (method in methods) {
    result <- compare_gcms(s, var_names, study_area, k = 3, clustering_method = method)
    expect_named(result, c("suggested_gcms", "statistics_gcms"))
  }
})

test_that("compare_gcms handles different k values", {
  for (k in 2:5) {
    result <- compare_gcms(s, var_names, study_area, k = k)
    expect_named(result, c("suggested_gcms", "statistics_gcms"))
  }
})

test_that("compare_gcms works with scaling enabled and disabled", {
  result1 <- compare_gcms(s, var_names, study_area, scale = TRUE)
  result2 <- compare_gcms(s, var_names, study_area, scale = FALSE)
  expect_named(result1, c("suggested_gcms", "statistics_gcms"))
  expect_named(result2, c("suggested_gcms", "statistics_gcms"))
})

test_that("compare_gcms accepts 'all' as var_names", {
  result <- compare_gcms(s, "all", study_area, k = 3)
  expect_named(result, c("suggested_gcms", "statistics_gcms"))
})

test_that("compare_gcms runs without a study area", {
  result <- compare_gcms(s, var_names, k = 3)
  expect_named(result, c("suggested_gcms", "statistics_gcms"))
})

test_that("compare_gcms fails with invalid parameters", {
  expect_error(compare_gcms(s, var_names, study_area, k = -1), "Assertion on 'k' failed")
  expect_error(compare_gcms(s, var_names, study_area, clustering_method = "invalid"), "Assertion on 'clustering_method' failed")
})
