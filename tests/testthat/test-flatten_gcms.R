test_that("flatten_gcms working (list of data.frames)", {
  bio_1 <- c(matrix(runif(1000), ncol = 50))
  bio_2 <- c(matrix(runif(1000), ncol = 50))
  bio_12 <- c(matrix(runif(1000), ncol = 50))
  ab <- data.frame(bio_1, bio_2, bio_12)
  names(ab) <- c("bio_1", "bio_2", "bio_12")
  s <- list(ab, ab, ab)
  names(s) <- c("ab", "cd", "ef")
  expect_no_error(flatten_gcms(s))
})

test_that("flatten_gcms working (list of one data.frame)", {
  bio_1 <- c(matrix(runif(1000), ncol = 50))
  bio_2 <- c(matrix(runif(1000), ncol = 50))
  bio_12 <- c(matrix(runif(1000), ncol = 50))
  ab <- data.frame(bio_1, bio_2, bio_12)
  names(ab) <- c("bio_1", "bio_2", "bio_12")
  s <- list(ab)
  expect_no_error(flatten_gcms(s))
})

test_that("flatten_gcms input error (list of stacks)", {
  bio_1 <- raster::raster(matrix(runif(1000), ncol = 50))
  bio_2 <- raster::raster(matrix(runif(1000), ncol = 50))
  bio_12 <- raster::raster(matrix(runif(1000), ncol = 50))
  ab <- raster::stack(bio_1, bio_2, bio_12)
  names(ab) <- c("bio_1", "bio_2", "bio_12")
  s <- list(ab, ab, ab)
  names(s) <- c("ab", "cd", "ef")
  expect_error(flatten_gcms(s))
})

test_that("flatten_gcms input error (list of one stack)", {
  bio_1 <- raster::raster(matrix(runif(1000), ncol = 50))
  bio_2 <- raster::raster(matrix(runif(1000), ncol = 50))
  bio_12 <- raster::raster(matrix(runif(1000), ncol = 50))
  ab <- raster::stack(bio_1, bio_2, bio_12)
  names(ab) <- c("bio_1", "bio_2", "bio_12")
  s <- list(ab)
  names(s) <- c("ab")
  expect_error(flatten_gcms(s))
})

test_that("flatten_gcms works correctly with real data", {
  var_names <- c("bio_1", "bio_12")
  s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)
  study_area <- terra::ext(c(-80, -30, -50, 10)) |> terra::vect(crs="+proj=longlat +datum=WGS84 +no_defs")
  s_trans <- transform_gcms(s, var_names, study_area)
  expect_no_error(result <- flatten_gcms(s_trans))
  expect_true(length(result) == 10340)
  expect_true(all(colnames(result[[1]]) == var_names))
})

test_that("flatten_gcms handles empty input gracefully", {
  s <- list()
  expect_no_error(flatten_gcms(s))
})
