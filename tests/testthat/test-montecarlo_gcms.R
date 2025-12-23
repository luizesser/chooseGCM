var_names <- c("bio_1", "bio_12")
s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)
study_area <- terra::ext(c(-80, -30, -50, 10)) |> terra::vect(crs="+proj=longlat +datum=WGS84 +no_defs")

test_that("montecarlo_gcms runs with default arguments", {
  result <- montecarlo_gcms(s, var_names, study_area)
  expect_type(result, "list")
})

test_that("Invalid var_names throws an error", {
  expect_error(montecarlo_gcms(s, var_names = c("bio_1", "invalid_var"), study_area),
               "Assertion on 'var_names' failed: Must be a subset of \\{'bio_1','bio_12','all'\\}, but has additional elements \\{'invalid_var'\\}")
})

test_that("montecarlo_gcms returns a ggplot object", {
  result <- montecarlo_gcms(s, var_names, study_area)
  expect_s3_class(result$montecarlo_plot, "gg")
})

test_that("Non-null study_area is handled correctly", {
  study_area_test <- terra::ext(c(-60, -20, -40, 5)) |> terra::vect(crs="+proj=longlat +datum=WGS84 +no_defs")
  result <- montecarlo_gcms(s, var_names, study_area_test)
  expect_s3_class(result$montecarlo_plot, "gg")
})


test_that("Scaling data works when scale = TRUE", {
  result <- montecarlo_gcms(s, var_names, study_area, scale = TRUE)
  expect_false(all(sapply(result$suggested_gcms, function(x) is.numeric(x) && all(scale(x) == scale(x)))))
})

test_that("Different permutation values work", {
  result_1000 <- montecarlo_gcms(s, var_names, study_area, perm = 1000)
  result_10000 <- montecarlo_gcms(s, var_names, study_area, perm = 10000)
  expect_true(length(result_1000$suggested_gcms) > 0)
  expect_true(length(result_10000$suggested_gcms) > 0)
})

test_that("Clustering with kmeans method works", {
  result <- montecarlo_gcms(s, var_names, study_area, clustering_method = "kmeans")
  expect_true(is.list(result$suggested_gcms))
})

test_that("Clustering with hclust method works", {
  result <- montecarlo_gcms(s, var_names, study_area, clustering_method = "hclust")
  expect_true(is.list(result$suggested_gcms))
})

test_that("Clustering with closestdist method works", {
  result <- montecarlo_gcms(s, var_names, study_area, clustering_method = "closestdist")
  expect_true(is.list(result$suggested_gcms))
})
