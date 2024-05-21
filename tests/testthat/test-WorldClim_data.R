##
test_that("WorldClim_data input error (period is numeric)", {
  expect_error(WorldClim_data(period = 4))
})

test_that("WorldClim_data input error (period is not a correct value)", {
  expect_error(WorldClim_data(period = "past"))
})

test_that("WorldClim_data input error (period is a list of correct values)", {
  expect_error(WorldClim_data(period = list("current", "future")))
})

##
test_that("WorldClim_data input error (variable is numeric)", {
  expect_error(WorldClim_data(variable = 4))
})

test_that("WorldClim_data input error (variable is not a correct value)", {
  expect_error(WorldClim_data(variable = "past"))
})

test_that("WorldClim_data input error (variable is a list of correct values)", {
  expect_error(WorldClim_data(variable = list("bioc", "tmax")))
})

##
test_that("WorldClim_data input error (year is numeric)", {
  expect_error(WorldClim_data(year = 2050))
})

test_that("WorldClim_data input error (year is not a correct value)", {
  expect_error(WorldClim_data(year = "2055"))
})

test_that("WorldClim_data input error (year is a list of correct values)", {
  expect_error(WorldClim_data(year = list("2050", "2070")))
})

##
test_that("WorldClim_data input error (gcm is numeric)", {
  expect_error(WorldClim_data(gcm = 1))
})

test_that("WorldClim_data input error (gcm is not a correct value)", {
  expect_error(WorldClim_data(gcm = "zz"))
})

test_that("WorldClim_data input error (gcm is a list of correct values)", {
  expect_error(WorldClim_data(gcm = list("ac", "ae")))
})

##
test_that("WorldClim_data input error (ssp is numeric)", {
  expect_error(WorldClim_data(ssp = 240))
})

test_that("WorldClim_data input error (ssp is not a correct value)", {
  expect_error(WorldClim_data(ssp = "240"))
})

test_that("WorldClim_data input error (ssp is a list of correct values)", {
  expect_error(WorldClim_data(ssp))
})

##
test_that("WorldClim_data input error (resolution is character)", {
  expect_error(WorldClim_data(resolution = "10"))
})

test_that("WorldClim_data input error (resolution is not a correct value)", {
  expect_error(WorldClim_data(resolution = 25))
})

test_that("WorldClim_data input error (resolution is a list of correct values)", {
  expect_error(WorldClim_data(resolution = list(245, 585)))
})
