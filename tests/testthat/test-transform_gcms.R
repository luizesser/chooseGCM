bio_1 = raster(matrix(runif(1000), ncol=50))
bio_2 = raster(matrix(runif(1000), ncol=50))
bio_12 = raster(matrix(runif(1000), ncol=50))
ab = stack(bio_1, bio_2, bio_12)
names(ab) <- c('bio_1','bio_2','bio_12')
s <- list(ab, ab, ab)
names(s) <- c('ab', 'cd', 'ef')

test_that("transform_gcms length matches s length", {
  expect_equal(length(transform_gcms(s)), length(s))
})


