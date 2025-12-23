var_names <- c("bio_1", "bio_12")
s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)
study_area <- terra::ext(c(-80, -30, -50, 10)) |> terra::vect(crs="+proj=longlat +datum=WGS84 +no_defs")

test_that("kmeans_gcms returns a list with expected elements", {
  result <- kmeans_gcms(s, var_names, study_area, k = 3)
  expect_type(result, "list")
  expect_true("suggested_gcms" %in% names(result))
  expect_true("kmeans_plot" %in% names(result))
})

test_that("kmeans_gcms returns exactly k suggested models", {
  k <- 4
  result <- kmeans_gcms(s, var_names, study_area, k = k)
  expect_length(result$suggested_gcms, k)
})

test_that("kmeans_gcms works with euclidean distance method", {
    result <- kmeans_gcms(s, var_names, study_area, k = 3, method = "euclidean")
    expect_type(result, "list")
    expect_true("suggested_gcms" %in% names(result))
    expect_true("kmeans_plot" %in% names(result))
})

test_that("kmeans_gcms works with maximum distance method", {
    result <- kmeans_gcms(s, var_names, study_area, k = 3, method = "maximum")
    expect_type(result, "list")
    expect_true("suggested_gcms" %in% names(result))
    expect_true("kmeans_plot" %in% names(result))
})

test_that("kmeans_gcms works with manhattan distance method", {
    result <- kmeans_gcms(s, var_names, study_area, k = 3, method = "manhattan")
    expect_type(result, "list")
    expect_true("suggested_gcms" %in% names(result))
    expect_true("kmeans_plot" %in% names(result))
})

test_that("kmeans_gcms works with canberra distance method", {
    result <- kmeans_gcms(s, var_names, study_area, k = 3, method = "canberra")
    expect_type(result, "list")
    expect_true("suggested_gcms" %in% names(result))
    expect_true("kmeans_plot" %in% names(result))
})

test_that("kmeans_gcms works with minkowski distance method", {
    result <- kmeans_gcms(s, var_names, study_area, k = 3, method = "minkowski")
    expect_type(result, "list")
    expect_true("suggested_gcms" %in% names(result))
    expect_true("kmeans_plot" %in% names(result))
})

test_that("kmeans_gcms throws an error for invalid values", {
  expect_error(kmeans_gcms(s, var_names, study_area, k = 0))
  expect_error(kmeans_gcms(s, var_names, study_area, k = -1))
  expect_error(kmeans_gcms(s, var_names, study_area, method = "invalid_method"))
})
