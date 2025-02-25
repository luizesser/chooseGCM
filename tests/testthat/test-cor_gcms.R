var_names <- c("bio_1", "bio_12")
s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)
study_area <- terra::ext(c(-80, -30, -50, 10)) |> terra::vect(crs="epsg:4326")

test_that("cor_gcms returns expected structure", {
  result <- cor_gcms(s, var_names, study_area)
  expect_named(result, c("cor_matrix", "cor_plot"))
})

test_that("cor_gcms correlation matrix has correct dimensions", {
  result <- cor_gcms(s, var_names, study_area)
  expect_equal(dim(result$cor_matrix), c(length(s), length(s)))
})

test_that("cor_gcms supports valid correlation methods", {
  for (m in c("pearson", "kendall", "spearman")) {
    expect_class(cor_gcms(s, var_names, study_area, method = m)$cor_matrix, "matrix")
  }
})

test_that("cor_gcms throws error for invalid method", {
  expect_error(cor_gcms(s, var_names, study_area, method = "invalid"))
})

test_that("cor_gcms handles missing values gracefully", {
  s_missing <- s
  s_missing[[1]][is.na(s_missing[[1]])] <- NA
  result <- cor_gcms(s_missing, var_names, study_area)
  expect_false(any(is.na(result$cor_matrix)))
})

test_that("cor_gcms validates input types", {
  expect_error(cor_gcms(s, 123, study_area))
  expect_error(cor_gcms(s, var_names, study_area = "invalid"))
})

test_that("cor_gcms produces a valid ggplot object", {
  expect_s3_class(cor_gcms(s, var_names, study_area)$cor_plot, "ggplot")
})

#test_that("cor_gcms handles identical variable values correctly", {
#  s_identical <- s
#  s_identical[[1]][] <- 1
#  expect_true(all(is.na(cor_gcms(s_identical , var_names, study_area)$cor_matrix)))
#})

#test_that("cor_gcms scales correctly with more variables", {
#  extended_var_names <- c("bio_1", "bio_12", "bio_5", "bio_6")
#  s_extended <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = extended_var_names)
#  result <- cor_gcms(s_extended, extended_var_names, study_area)
#  expect_equal(dim(result$cor_matrix), c(length(extended_var_names), length(extended_var_names)))
#})
