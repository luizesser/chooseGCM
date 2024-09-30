test_that("transform_gcms length matches s length", {
  bio_1 <-  raster::raster(matrix(runif(1000), ncol = 50))
  bio_2 <-  raster::raster(matrix(runif(1000), ncol = 50))
  bio_12 <- raster::raster(matrix(runif(1000), ncol = 50))
  ab <- raster::stack(bio_1, bio_2, bio_12)
  names(ab) <- c("bio_1", "bio_2", "bio_12")
  s <- list(ab, ab, ab)
  names(s) <- c("ab", "cd", "ef")
  x <- length(transform_gcms(s))
  y <- length(s)
  expect_equal(x, y)
})

test_that("transform_gcms input error (list of data.frames)", {
  bio_1 <- c(matrix(runif(1000), ncol = 50))
  bio_2 <- c(matrix(runif(1000), ncol = 50))
  bio_12 <- c(matrix(runif(1000), ncol = 50))
  ab <- data.frame(bio_1, bio_2, bio_12)
  names(ab) <- c("bio_1", "bio_2", "bio_12")
  s <- list(ab, ab, ab)
  names(s) <- c("ab", "cd", "ef")
  expect_no_error(transform_gcms(s))
})

test_that("transform_gcms input error (raster)", {
  s <- raster::raster(matrix(runif(1000), ncol = 50))
  expect_error(transform_gcms(s))
})

test_that("transform_gcms input error (stack()", {
  bio_1 <-  raster::raster(matrix(runif(1000), ncol = 50))
  bio_2 <-  raster::raster(matrix(runif(1000), ncol = 50))
  bio_12 <- raster::raster(matrix(runif(1000), ncol = 50))
  s <- raster::stack(bio_1, bio_2, bio_12)
  expect_error(transform_gcms(s))
})

test_that("transform_gcms one stack( list", {
  bio_1 <-  raster::raster(matrix(runif(1000), ncol = 50))
  bio_2 <-  raster::raster(matrix(runif(1000), ncol = 50))
  bio_12 <- raster::raster(matrix(runif(1000), ncol = 50))
  s <- raster::stack(bio_1, bio_2, bio_12)
  names(s) <- c("bio_1", "bio_2", "bio_12")
  s <- list(s)
  expect_no_error(result <- transform_gcms(s))
  expect_true(length(result) == 1)
  expect_true(all(colnames(result[[1]]) == c("bio_1", "bio_12")))
})

test_that("transform_gcms input error (data.frame)", {
  s <- data.frame(matrix(runif(1000), ncol = 50))
  expect_error(transform_gcms(s))
})

test_that("transform_gcms input error (var_names not in raster)", {
  bio_1 <- raster::raster(matrix(runif(1000), ncol = 50))
  bio_2 <- raster::raster(matrix(runif(1000), ncol = 50))
  bio_3 <- raster::raster(matrix(runif(1000), ncol = 50))
  ab <- raster::stack(bio_1, bio_2, bio_3)
  s <- list(ab, ab, ab)
  names(s) <- c("ab", "cd", "ef")
  expect_error(transform_gcms(s))
})

test_that("var_names length matches s length", {
  bio_1 <-  raster::raster(matrix(runif(1000), ncol = 50))
  bio_2 <-  raster::raster(matrix(runif(1000), ncol = 50))
  bio_12 <- raster::raster(matrix(runif(1000), ncol = 50))
  ab <- raster::stack(bio_1, bio_2, bio_12)
  var_names <- c("bio_1", "bio_2", "bio_12")
  names(ab) <- var_names
  s <- list(ab, ab, ab)
  names(s) <- c("ab", "cd", "ef")
  x2 <- transform_gcms(s, var_names = var_names)
  x <- ncol(x2[[1]])
  y <- length(var_names)
  expect_equal(x, y)
})

test_that("study_area is an extent", {
  bio_1 <-  raster::raster(matrix(runif(1000), ncol = 50))
  bio_2 <-  raster::raster(matrix(runif(1000), ncol = 50))
  bio_12 <- raster::raster(matrix(runif(1000), ncol = 50))
  ab <- raster::stack(bio_1, bio_2, bio_12)
  var_names <- c("bio_1", "bio_2", "bio_12")
  names(ab) <- var_names
  s <- list(ab, ab, ab)
  names(s) <- c("ab", "cd", "ef")
  study_area <- raster::extent(0.4, 0.5, 0.4, 0.5)
  expect_no_error(result <- transform_gcms(s, var_names = var_names, study_area))
  expect_true(length(result) == 3)
  expect_true(all(colnames(result[[1]]) == var_names))
})

test_that("study_area partially in the raster extension", {
  bio_1 <-  raster::raster(matrix(runif(1000), ncol = 50))
  bio_2 <-  raster::raster(matrix(runif(1000), ncol = 50))
  bio_12 <- raster::raster(matrix(runif(1000), ncol = 50))
  ab <- raster::stack(bio_1, bio_2, bio_12)
  var_names <- c("bio_1", "bio_2", "bio_12")
  names(ab) <- var_names
  s <- list(ab, ab, ab)
  names(s) <- c("ab", "cd", "ef")
  study_area <- raster::extent(-0.4, 0.5, -0.4, 0.5)
  expect_no_error(result <- transform_gcms(s, var_names = var_names, study_area))
  expect_true(length(result) == 3)
  expect_true(all(colnames(result[[1]]) == var_names))
})

test_that("study_area out of the raster extension", {
  bio_1 <-  raster::raster(matrix(runif(1000), ncol = 50))
  bio_2 <-  raster::raster(matrix(runif(1000), ncol = 50))
  bio_12 <- raster::raster(matrix(runif(1000), ncol = 50))
  ab <- raster::stack(bio_1, bio_2, bio_12)
  var_names <- c("bio_1", "bio_2", "bio_12")
  names(ab) <- var_names
  s <- list(ab, ab, ab)
  names(s) <- c("ab", "cd", "ef")
  study_area <- raster::extent(-0.5, -0.4, -0.5, -0.4)
  expect_error(result <- transform_gcms(s, var_names = var_names, study_area))
})

test_that("study_area as projected sf", {
  bio_1 <-  raster::raster(matrix(runif(1000), ncol = 50))
  bio_2 <-  raster::raster(matrix(runif(1000), ncol = 50))
  bio_12 <- raster::raster(matrix(runif(1000), ncol = 50))
  ab <- raster::stack(bio_1, bio_2, bio_12)
  raster::crs(ab) <- 4326
  var_names <- c("bio_1", "bio_2", "bio_12")
  names(ab) <- var_names
  s <- list(ab, ab, ab)
  names(s) <- c("ab", "cd", "ef")
  study_area <- sf::st_sf(sf::st_sfc(sf::st_buffer(sf::st_point(c(0.5, 0.5)), 0.2), crs = sf::st_crs(s[[1]])))
  expect_no_error(result <- transform_gcms(s, var_names = var_names, study_area))
  expect_true(length(result) == 3)
  expect_true(all(colnames(result[[1]]) == var_names))
})

test_that("study_area as projected sf (different projection)", {
  bio_1 <-  raster::raster(matrix(runif(1000), ncol = 50))
  bio_2 <-  raster::raster(matrix(runif(1000), ncol = 50))
  bio_12 <- raster::raster(matrix(runif(1000), ncol = 50))
  ab <- raster::stack(bio_1, bio_2, bio_12)
  raster::crs(ab) <- 4326
  var_names <- c("bio_1", "bio_2", "bio_12")
  names(ab) <- var_names
  s <- list(ab, ab, ab)
  names(s) <- c("ab", "cd", "ef")
  study_area <- sf::st_sf(sf::st_sfc(sf::st_buffer(sf::st_point(c(0.5, 0.5)), 0.2), crs = 4689))
  expect_no_error(result <- transform_gcms(s, var_names = var_names, study_area))
  expect_true(length(result) == 3)
  expect_true(all(colnames(result[[1]]) == var_names))
})

test_that("study_area is a projected raster", {
  bio_1 <-  raster::raster(matrix(runif(1000), ncol = 50))
  bio_2 <-  raster::raster(matrix(runif(1000), ncol = 50))
  bio_12 <- raster::raster(matrix(runif(1000), ncol = 50))
  ab <- raster::stack(bio_1, bio_2, bio_12)
  raster::crs(ab) <- 4326
  var_names <- c("bio_1", "bio_2", "bio_12")
  names(ab) <- var_names
  s <- list(ab, ab, ab)
  names(s) <- c("ab", "cd", "ef")
  study_area <- raster::raster(matrix(runif(100), ncol = 10))
  raster::crs(study_area) <- 4326
  raster::extent(study_area) <- c(0.4, 0.5, 0.4, 0.5)
  expect_error(transform_gcms(s, var_names = var_names, study_area))
})

test_that("study_area is a projected raster (different projection)", {
  bio_1 <-  raster::raster(matrix(runif(1000), ncol = 50))
  bio_2 <-  raster::raster(matrix(runif(1000), ncol = 50))
  bio_12 <- raster::raster(matrix(runif(1000), ncol = 50))
  ab <- raster::stack(bio_1, bio_2, bio_12)
  raster::crs(ab) <- 4326
  var_names <- c("bio_1", "bio_2", "bio_12")
  names(ab) <- var_names
  s <- list(ab, ab, ab)
  names(s) <- c("ab", "cd", "ef")
  study_area <- raster::raster(matrix(runif(100), ncol = 10))
  raster::crs(study_area) <- 4689
  raster::extent(study_area) <- c(0.4, 0.5, 0.4, 0.5)
  expect_error(transform_gcms(s, var_names = var_names, study_area))
})

test_that("study_area is a raster not projected", {
  bio_1 <-  raster::raster(matrix(runif(1000), ncol = 50))
  bio_2 <-  raster::raster(matrix(runif(1000), ncol = 50))
  bio_12 <- raster::raster(matrix(runif(1000), ncol = 50))
  ab <- raster::stack(bio_1, bio_2, bio_12)
  var_names <- c("bio_1", "bio_2", "bio_12")
  names(ab) <- var_names
  s <- list(ab, ab, ab)
  names(s) <- c("ab", "cd", "ef")
  study_area <- raster::raster(matrix(runif(1000), ncol = 50))
  expect_error(result <- transform_gcms(s, var_names = var_names, study_area))
})

test_that("study_area is a stack( not projected", {
  bio_1 <-  raster::raster(matrix(runif(1000), ncol = 50))
  bio_2 <-  raster::raster(matrix(runif(1000), ncol = 50))
  bio_12 <- raster::raster(matrix(runif(1000), ncol = 50))
  ab <- raster::stack(bio_1, bio_2, bio_12)
  var_names <- c("bio_1", "bio_2", "bio_12")
  names(ab) <- var_names
  s <- list(ab, ab, ab)
  names(s) <- c("ab", "cd", "ef")
  study_area <- raster::stack(
    raster::raster(matrix(runif(1000), ncol = 50)),
    raster::raster(matrix(runif(1000), ncol = 50))
  )
  raster::extent(study_area) <- c(0.4, 0.5, 0.4, 0.5)
  expect_error(transform_gcms(s, var_names = var_names, study_area))
})

test_that("study_area is a stack( projected", {
  bio_1 <- raster::raster(matrix(runif(1000), ncol = 50))
  bio_2 <- raster::raster(matrix(runif(1000), ncol = 50))
  bio_12 <- raster::raster(matrix(runif(1000), ncol = 50))
  ab <- raster::stack(bio_1, bio_2, bio_12)
  raster::crs(ab) <- 4326
  var_names <- c("bio_1", "bio_2", "bio_12")
  names(ab) <- var_names
  s <- list(ab, ab, ab)
  names(s) <- c("ab", "cd", "ef")
  study_area <- raster::stack(
    raster::raster(matrix(runif(100), ncol = 10)),
    raster::raster(matrix(runif(100), ncol = 10))
  )
  raster::crs(study_area) <- 4689
  raster::extent(study_area) <- c(0.4, 0.5, 0.4, 0.5)
  expect_error(transform_gcms(s, var_names = var_names, study_area))
})

test_that("study_area is a brick not projected", {
  bio_1 <-  raster::raster(matrix(runif(1000), ncol = 50))
  bio_2 <-  raster::raster(matrix(runif(1000), ncol = 50))
  bio_12 <- raster::raster(matrix(runif(1000), ncol = 50))
  ab <- raster::stack(bio_1, bio_2, bio_12)
  var_names <- c("bio_1", "bio_2", "bio_12")
  names(ab) <- var_names
  s <- list(ab, ab, ab)
  names(s) <- c("ab", "cd", "ef")
  study_area <- raster::brick(raster::stack(
    raster::raster(matrix(runif(1000), ncol = 50)),
    raster::raster(matrix(runif(1000), ncol = 50))
  ))
  raster::extent(study_area) <- c(0.4, 0.5, 0.4, 0.5)
  expect_error(transform_gcms(s, var_names = var_names, study_area))
})

test_that("study_area is a brick projected", {
  bio_1 <- raster::raster(matrix(runif(1000), ncol = 50))
  bio_2 <- raster::raster(matrix(runif(1000), ncol = 50))
  bio_12 <- raster::raster(matrix(runif(1000), ncol = 50))
  ab <- raster::stack(bio_1, bio_2, bio_12)
  raster::crs(ab) <- 4326
  var_names <- c("bio_1", "bio_2", "bio_12")
  names(ab) <- var_names
  s <- list(ab, ab, ab)
  names(s) <- c("ab", "cd", "ef")
  study_area <- raster::brick(raster::stack(
    raster::raster(matrix(runif(1000), ncol = 50)),
    raster::raster(matrix(runif(1000), ncol = 50))
  ))
  raster::crs(study_area) <- 4689
  raster::extent(study_area) <- c(0.4, 0.5, 0.4, 0.5)
  expect_error(transform_gcms(s, var_names = var_names, study_area))
})

test_that("study_area is a spatraster with all vars", {
  bio_1 <- terra::rast(matrix(runif(1000), ncol = 50))
  bio_2 <- terra::rast(matrix(runif(1000), ncol = 50))
  bio_12 <- terra::rast(matrix(runif(1000), ncol = 50))
  ab <- c(bio_1, bio_2, bio_12)
  terra::crs(ab) <- "EPSG:4326"
  var_names <- c("bio_1", "bio_2", "bio_12")
  names(ab) <- var_names
  s <- list(ab, ab, ab)
  names(s) <- c("ab", "cd", "ef")
  expect_no_error(result <- transform_gcms(s, var_names = "all"))
  expect_true(length(result) == 3)
  expect_true(all(colnames(result[[1]]) == var_names))
})

test_that("study_area is a stars with all vars", {
  bio_1 <- terra::rast(matrix(runif(1000), ncol = 50)) |> stars::st_as_stars()
  bio_2 <- terra::rast(matrix(runif(1000), ncol = 50)) |> stars::st_as_stars()
  bio_12 <- terra::rast(matrix(runif(1000), ncol = 50)) |> stars::st_as_stars()
  ab <- c(bio_1, bio_2, bio_12)
  sf::st_crs(ab) <- "EPSG:4326"
  var_names <- c("bio_1", "bio_2", "bio_12")
  names(ab) <- var_names
  s <- list(ab, ab, ab)
  names(s) <- c("ab", "cd", "ef")
  expect_no_error(result <- transform_gcms(s, var_names = "all"))
  expect_true(length(result) == 3)
  expect_true(all(colnames(result[[1]]) == var_names))
})

