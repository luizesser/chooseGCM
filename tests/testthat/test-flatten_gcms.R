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
