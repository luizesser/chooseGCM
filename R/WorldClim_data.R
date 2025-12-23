#' Download WorldClim v.2.1 bioclimatic data
#'
#' This function allows to download data from WorldClim v.2.1
#' (https://www.worldclim.org/data/index.html) considering multiple GCMs, time periods and SSPs.
#'
#' @usage
#' WorldClim_data(path = NULL,
#'                period = "current",
#'                variable = "bioc",
#'                year = "2090",
#'                gcm = "mi",
#'                ssp = "585",
#'                resolution = 10)
#'
#' @param path Directory path to save downloads.
#' @param period Can be "current" or "future".
#' @param variable Allows to specify which variables you want to retrieve Possible entries are:
#' "tmax","tmin","prec" and/or "bioc".
#' @param year Specify the year you want to retrieve data. Possible entries are:
#' "2030", "2050", "2070" and/or "2090". You can use a vector to provide more than one entry.
#' @param gcm GCMs to be considered in future scenarios. You can use a vector to provide more than
#' one entry.
#' @param ssp SSPs for future data. Possible entries are: "126", "245", "370" and/or "585".
#' You can use a vector to provide more than one entry.
#' @param resolution You can select one resolution from the following alternatives: 10, 5, 2.5 OR 30.
#'
#' @details This function will create a folder. All the data downloaded will be stored in this
#' folder. Note that, despite being possible to retrieve a lot of data at once, it is not
#' recommended to do so, since the data is very heavy.
#'
#' @returns If data is not downloaded, the function downloads the data and has no return value.
#'
#' @references [https://www.worldclim.org/data/index.html](https://www.worldclim.org/data/index.html)
#'
#' @author Luíz Fernando Esser (luizesser@gmail.com)
#' [https://luizfesser.wordpress.com](https://luizfesser.wordpress.com)
#'
#' @examples
#' \donttest{
#' # download data from multiple periods:
#' year <- c("2050", "2090")
#' WorldClim_data(period = "future",
#'                variable = "bioc",
#'                year = year,
#'                gcm = "mi",
#'                ssp = "126",
#'                resolution = 10)
#'
#' # download data from one specific period
#' WorldClim_data(period = "future",
#'                variable = "bioc",
#'                year = "2070",
#'                gcm = "mi",
#'                ssp = "585",
#'                resolution = 10)
#' }
#'
#' @importFrom httr2 request req_url req_error req_perform resp_is_error resp_status
#' @importFrom cli cli_alert_warning cli_abort cli_inform
#' @importFrom utils unzip
#'
#' @export
WorldClim_data <- function(path = NULL,
                           period = "current",
                           variable = "bioc",
                           year = "2090",
                           gcm = "mi",
                           ssp = "585",
                           resolution = 10) {

  ## argument checks (unchanged)
  if (!all(period %in% c("current", "future"))) {
    cli::cli_abort(c(
      "x" = "Assertion on {.var period} failed.",
      "i" = "{.var period} must be element of set ['current', 'future']."
    ))
  }
  if (!all(variable %in% c("bioc", "tmax", "tmin", "prec"))) {
    cli::cli_abort(c(
      "x" = "Assertion on {.var variable} failed.",
      "i" = "{.var variable} must be element of set ['bioc', 'tmax','tmin','prec']."
    ))
  }
  if (!all(year %in% c("2030", "2050", "2070", "2090"))) {
    cli::cli_abort(c(
      "x" = "Assertion on {.var year} failed.",
      "i" = "{.var year} must be element of set ['2030', '2050', '2070', '2090']."
    ))
  }
  if (!all(gcm %in% c(
    "ac", "ae", "bc", "ca", "cc", "ce", "cn", "ch", "cr", "ec", "ev", "fi",
    "gf", "gg", "gh", "hg", "in", "ic", "ip", "me", "mi", "mp", "ml",
    "mr", "uk", "all"
  ))) {
    cli::cli_abort(c(
      "x" = "Assertion on {.var gcm} failed.",
      "i" = "{.var gcm} must be element of set ['ac','ae','bc','ca','cc','ce','cn','ch','cr','ec',
      'ev','fi','gf','gg','gh','hg','in','ic','ip','me','mi','mp','ml','mr','uk','all']."
    ))
  }
  if (!all(ssp %in% c("126", "245", "370", "585"))) {
    cli::cli_abort(c(
      "x" = "Assertion on {.var ssp} failed.",
      "i" = "{.var ssp} must be element of set ['126', '245', '370', '585']."
    ))
  }
  if (!all(resolution %in% c(10, 5, 2.5, 30))) {
    cli::cli_abort(c(
      "x" = "Assertion on {.var resolution} failed.",
      "i" = "{.var resolution} must be element of set [10, 5, 2.5, 30]."
    ))
  }

  assert_character_cli(period)
  assert_character_cli(variable)
  assert_character_cli(year)
  assert_character_cli(gcm)
  assert_character_cli(ssp)
  assert_numeric_cli(resolution)
  assert_character_cli(path, null.ok = TRUE, len = 1)

  res <- ifelse(resolution == 30, "s", "m")
  l <- list()

  .warn <- function(...) cli::cli_alert_warning(paste0(...))

  ## helper: GET file with httr2, but never throw on HTTP status
  .download_file_httr2 <- function(url, destfile) {
    req <- httr2::request(url) |>
      httr2::req_error(is_error = \(resp) FALSE)  # keep 4xx/5xx as responses, not errors [web:33][web:38]

    resp <- try(httr2::req_perform(req), silent = TRUE)

    if (inherits(resp, "try-error")) {
      .warn("Failed to perform request to ", url, ".")
      return(FALSE)
    }

    if (httr2::resp_is_error(resp)) {
      .warn("HTTP error ", httr2::resp_status(resp), " when requesting ", url, ".")
      return(FALSE)
    }

    # write raw body to disk; works for .zip and .tif [web:27][web:28]
    body <- httr2::resp_body_raw(resp)
    ok <- try(writeBin(body, destfile), silent = TRUE)
    if (inherits(ok, "try-error")) {
      .warn("Failed to write response body to file ", destfile, ".")
      return(FALSE)
    }
    TRUE
  }

  ## CURRENT PERIOD
  if (period == "current") {
    if (is.null(path)) {
      path <- "input_data/WorldClim_data_current"
    }
    if (!dir.exists(path)) {
      dir.create(path, recursive = TRUE)
    }

    tif_files <- list.files(path, pattern = ".tif$", full.names = TRUE)

    if (length(tif_files) == 0) {
      url <- paste0(
        "https://geodata.ucdavis.edu/climate/worldclim/2_1/base/wc2.1_",
        resolution, res, "_bio.zip"
      )
      zipfile <- file.path(path, paste0("current_", resolution, res, ".zip"))

      cli::cli_inform(c("Downloading WorldClim current data from {.url {url}}"))

      ok <- .download_file_httr2(url, zipfile)
      if (!ok) {
        .warn("Failed to download WorldClim current data. The server may be unavailable or the URL may have changed.")
        return(invisible(l))
      }

      uz <- try(utils::unzip(zipfile, exdir = path), silent = TRUE)
      if (inherits(uz, "try-error")) {
        .warn("Download succeeded but unzip failed for file ", zipfile, ".")
        return(invisible(l))
      }

      tif_files <- list.files(path, pattern = ".tif$", full.names = TRUE)
    } else {
      cli::cli_inform("The file for current scenario is already downloaded.")
    }
  }

  ## FUTURE PERIOD
  if (period == "future") {
    if (is.null(path)) {
      path <- "input_data/WorldClim_data_future"
    }
    if (!dir.exists(path)) {
      dir.create(path, recursive = TRUE)
    }

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
    if ("all" %in% gcm) {
      gcm <- all_gcm
    }
    gcm3 <- gcm2[match(gcm, all_gcm)]

    all_year <- c("2030", "2050", "2070", "2090")
    year2 <- c("2021-2040", "2041-2060", "2061-2080", "2081-2100")
    year3 <- year2[match(year, all_year)]

    for (g in seq_along(gcm)) {
      for (s in seq_along(ssp)) {
        for (y in seq_along(year)) {
          nome <- paste0(gcm[g], "_ssp", ssp[s], "_", resolution, "_", year[y])
          destfile <- file.path(path, paste0(nome, ".tif"))

          if (!file.exists(destfile)) {
            url <- paste0(
              "https://geodata.ucdavis.edu/cmip6/", resolution, res, "/",
              gcm3[g], "/ssp", ssp[s], "/wc2.1_", resolution, res, "_",
              variable, "_", gcm3[g], "_ssp", ssp[s], "_", year3[y], ".tif"
            )

            cli::cli_inform(c("Downloading WorldClim future data: {nome} from {.url {url}}"))

            ok <- .download_file_httr2(url, destfile)
            if (!ok) {
              .warn("Failed to download ", nome, ". The server may be unavailable or the URL may have changed.")
              next
            }
          } else {
            cli::cli_inform(paste0(
              "The file for future scenario (", destfile,") is already downloaded."
            ))
          }
        }
      }
    }
  }
  return(invisible(l))
}
