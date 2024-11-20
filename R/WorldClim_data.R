#' Download WorldClim v2.1 Bioclimatic Data
#'
#' This function allows downloading data from WorldClim v2.1 (https://www.worldclim.org/data/index.html) for multiple GCMs, time periods, and SSPs.
#'
#' @usage worldclim_data(period = 'current', variable = 'bioc', year = '2030',
#' gcm = 'mi', ssp = '126', resolution = 10, path = NULL)
#'
#' @param period Character. Can be 'current' or 'future'.
#' @param variable Character. Specifies which variables to retrieve. Possible entries are:
#' 'tmax', 'tmin', 'prec', and/or 'bioc'.
#' @param path Character. Directory path to save the downloaded files. Default is NULL.
#' @param year Character or vector. Specifies the year(s) to retrieve data for. Possible entries are:
#' '2030', '2050', '2070', and/or '2090'.
#' @param gcm Character or vector. Specifies the GCM(s) to consider for future scenarios. See the table below for available options:
#'
#' | **CODE** | **GCM**              |
#' |----------|----------------------|
#' | ac       | ACCESS-CM2           |
#' | ae       | ACCESS-ESM1-5        |
#' | bc       | BCC-CSM2-MR          |
#' | ca       | CanESM5              |
#' | cc       | CanESM5-CanOE        |
#' | ce       | CMCC-ESM2            |
#' | cn       | CNRM-CM6-1           |
#' | ch       | CNRM-CM6-1-HR        |
#' | cr       | CNRM-ESM2-1          |
#' | ec       | EC-Earth3-Veg        |
#' | ev       | EC-Earth3-Veg-LR     |
#' | fi       | FIO-ESM-2-0          |
#' | gf       | GFDL-ESM4            |
#' | gg       | GISS-E2-1-G          |
#' | gh       | GISS-E2-1-H          |
#' | hg       | HadGEM3-GC31-LL      |
#' | in       | INM-CM4-8            |
#' | ic       | INM-CM5-0            |
#' | ip       | IPSL-CM6A-LR         |
#' | me       | MIROC-ES2L           |
#' | mi       | MIROC6               |
#' | mp       | MPI-ESM1-2-HR        |
#' | ml       | MPI-ESM1-2-LR        |
#' | mr       | MRI-ESM2-0           |
#' | uk       | UKESM1-0-LL          |
#'
#' @param ssp Character or vector. SSP(s) for future data. Possible entries are: '126', '245', '370', and/or '585'.
#' @param resolution Numeric. Specifies the resolution. Possible values are 10, 5, 2.5, or 30 arcseconds.
#'
#' @return This function does not return any value.
#'
#' @details This function creates a folder in \code{path}.
#' All downloaded data will be stored in this folder.
#' Note: While it is possible to retrieve a large volume of data, it is not recommended to do so due to the large file sizes.
#' For example, datasets at 30 arcseconds resolution can exceed 4 GB. If the function fails to retrieve large datasets,
#' consider increasing the timeout by setting \code{options(timeout = 600)}.
#'
#' @references https://www.worldclim.org/data/index.html
#'
#' @author Luíz Fernando Esser (luizesser@gmail.com)
#' https://luizfesser.wordpress.com
#'
#' @examples
#' \donttest{
#' # download data from multiple periods:
#' year <- c("2050", "2090")
#' worldclim_data("future", "bioc", year, "mi", "126", 10, path=tempdir())
#'
#' # download data from one specific period:
#' worldclim_data("future", "bioc", "2070", "mi", "585", 10, path=tempdir())
#' }
#'
#' @import checkmate
#' @import httr
#'
#' @export
worldclim_data <- function(period = "current", variable = "bioc", year = "2030",
                           gcm = "mi", ssp = "126", resolution = 10,
                           path = NULL) {
  if (!all(period %in% c("current", "future")) | !length(period) == 1) {
    stop("Assertion on 'period' failed: Must be one element of set {'current', 'future'}.")
  }
  if (!all(variable %in% c("bioc", "tmax", "tmin", "prec"))) {
    stop("Assertion on 'variable' failed: Must be element of set {'bioc', 'tmax','tmin','prec'}.")
  }
  if (!all(year %in% c("2030", "2050", "2070", "2090"))) {
    stop("Assertion on 'year' failed: Must be element of set {'2030', '2050', '2070', '2090'}.")
  }
  if (!all(gcm %in% c(
    "ac", "ae", "bc", "ca", "cc", "ce", "cn", "ch", "cr", "ec", "ev", "fi",
    "gf", "gg", "gh", "hg", "in", "ic", "ip", "me", "mi", "mp", "ml",
    "mr", "uk", "all"
  ))) {
    stop("Assertion on 'gcm' failed: Must be element of set {'ac','ae','bc','ca','cc','ce','cn','ch','cr','ec','ev','fi','gf','gg','gh','hg','in','ic','ip','me','mi','mp','ml','mr','uk', 'all'}.")
  }
  if (!all(ssp %in% c("126", "245", "370", "585"))) {
    stop("Assertion on 'ssp' failed: Must be element of set {'126', '245', '370', '585'}.")
  }
  if (!all(resolution %in% c(10, 5, 2.5, 30))) {
    stop("Assertion on 'resolution' failed: Must be element of set {10, 5, 2.5, 30}.")
  }

  assertCharacter(period)
  assertCharacter(variable)
  assertCharacter(year)
  assertCharacter(gcm)
  assertCharacter(ssp)
  assertNumeric(resolution)
  assertCharacter(path, null.ok = FALSE, len = 1)

  res <- ifelse(resolution == 30, "s", "m")

  if (period == "current") {
    if (!dir.exists(path)) {
      dir.create(path, recursive = TRUE)
    }
    if (length(list.files(path, pattern = ".tif$", full.names = TRUE)) == 0) {
      message(paste0("current_", resolution, res))
      GET(
        url = paste0(
          "https://geodata.ucdavis.edu/climate/worldclim/2_1/base/wc2.1_",
          resolution,
          res, "_bio.zip"
        ),
        write_disk(paste0("current_", resolution, "_", res, ".zip"))
      )
      utils::unzip(
        zipfile = paste0("current_", resolution, "_", res, ".zip"),
        exdir = paste0(path)
      )
    } else {
      message(paste0("The file for current scenario is already downloaded."))
    }
  }

  if (period == "future") {
    all_gcm <- c(
      "ac", "ae", "bc", "ca", "cc", "ce", "cn", "ch", "cr", "ec", "ev", "fi",
      "gf", "gg", "gh", "hg", "in", "ic", "ip", "me", "mi", "mp", "ml",
      "mr", "uk"
    )
    gcm2 <- c(
      "ACCESS-CM2", "ACCESS-ESM1-5", "BCC-CSM2-MR", "CanESM5", "CanESM5-CanOE", "CMCC-ESM2",
      "CNRM-CM6-1", "CNRM-CM6-1-HR", "CNRM-ESM2-1", "EC-Earth3-Veg",
      "EC-Earth3-Veg-LR", "FIO-ESM-2-0", "GFDL-ESM4", "GISS-E2-1-G",
      "GISS-E2-1-H", "HadGEM3-GC31-LL", "INM-CM4-8", "INM-CM5-0",
      "IPSL-CM6A-LR", "MIROC-ES2L", "MIROC6", "MPI-ESM1-2-HR",
      "MPI-ESM1-2-LR", "MRI-ESM2-0", "UKESM1-0-LL"
    )
    if (length(gcm) == 1) {
      if (gcm == "all") {
        gcm <- all_gcm
      }
    }
    if (!dir.exists(path)) {
      dir.create(path, recursive = TRUE)
    }
    gcm3 <- gcm2[match(gcm, all_gcm)]
    all_year <- c("2030", "2050", "2070", "2090")
    year2 <- c("2021-2040", "2041-2060", "2061-2080", "2081-2100")
    year3 <- year2[match(year, all_year)]
    for (g in 1:length(gcm)) {
      for (s in 1:length(ssp)) {
        for (y in 1:length(year)) {
          if (!file.exists(paste0(path, "/", gcm[g], "_ssp", ssp[s], "_", resolution, "_", year[y], ".tif"))) {
            message(paste0(gcm[g], "_ssp", ssp[s], "_", resolution, "_", year[y]))
            if (!http_error(paste0(
              "https://geodata.ucdavis.edu/cmip6/", resolution,
              res, "/", gcm3[g], "/ssp", ssp[s], "/wc2.1_", resolution,
              res, "_", variable, "_", gcm3[g], "_ssp", ssp[s], "_",
              year3[y], ".tif"
            ))) {
              try(GET(
                url = paste0(
                  "https://geodata.ucdavis.edu/cmip6/", resolution,
                  res, "/", gcm3[g], "/ssp", ssp[s], "/wc2.1_", resolution,
                  res, "_", variable, "_", gcm3[g], "_ssp", ssp[s], "_",
                  year3[y], ".tif"
                ),
                write_disk(paste0(
                  path, "/", gcm[g], "_ssp", ssp[s],
                  "_", resolution, "_", year[y], ".tif"
                ))
              ))
            }
          } else {
            message(paste0(
              "The file for future scenario (",
              paste0(path, "/", gcm[g], "_ssp", ssp[s], "_", resolution, res, "_", year[y], ".tif"),
              ") is already downloaded."
            ))
          }
        }
      }
    }
  }
}
