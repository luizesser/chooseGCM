#' Transform General Circulation Model (GCM) Stacks
#'
#' This function transforms a list of GCM stacks by subsetting it to include only the variables
#' specified in \code{var_names}, reprojecting it to match the CRS of \code{study_area},
#' cropping and masking it to \code{study_area}, and returning a list of data frames.
#'
#' @param s A list of stacks of General Circulation Models (GCMs).
#' @param var_names Character. A vector of names of the variables to include, or 'all' to include all variables.
#' @param study_area An Extent object, or any object from which an Extent object can be extracted.
#' Defines the study area for cropping and masking the rasters.
#'
#' @return A list of data frames, where each element corresponds to a GCM in the input list.

#'
#' @seealso \code{\link{summary_gcms}}
#'
#' @author Luíz Fernando Esser (luizesser@gmail.com)
#' https://luizfesser.wordpress.com
#'
#' @examples
#' var_names <- c("bio_1", "bio_12")
#' s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)[1:5]
#' study_area <- terra::ext(c(-80, -70, -50, -40)) |>
#'   terra::vect(crs="+proj=longlat +datum=WGS84 +no_defs")
#' transform_gcms(s, var_names, study_area)
#'
#' @import checkmate
#' @importFrom terra crs project crop mask ext rast res
#' @importFrom methods is as
#'
#' @export
transform_gcms <- function(s, var_names = c("bio_1", "bio_12"), study_area = NULL) {
  if(is.list(s)){
    if(methods::is(s[[1]], "stars")){
      s <- sapply(s,
                  function(x){
                    x <- methods::as(x, "SpatRaster")
                    return(x)
                  },
                  USE.NAMES = TRUE,
                  simplify = FALSE)
    }
    if(methods::is(s[[1]], "RasterStack")){
      s <- sapply(s,
                  function(x){
                    x <- terra::rast(x)
                    return(x)
                  },
                  USE.NAMES = TRUE,
                  simplify = FALSE)
    }
    if(methods::is(s[[1]], "data.frame")){
      return(s)
    }
  }

  if(!is.null(study_area)){
    if(!methods::is(study_area, "SpatVector") & !methods::is(study_area, "Extent")){
      study_area <- methods::as(study_area, "SpatVector")
    }
    if(methods::is(study_area, "Extent")){
      study_area <- terra::ext(study_area)
    }
  }

  checkmate::assertList(s, types = "SpatRaster")
  checkmate::assertCharacter(var_names, unique = TRUE, any.missing = FALSE)
  checkmate::assertSubset(var_names, c(names(s[[1]]), "all"))
  if(!class(study_area) %in% c("SpatVector", "SpatExtent")) {
    checkmate::assertClass(study_area, classes = c("SpatVector"), null.ok = TRUE)
  }

  if ("all" %in% var_names) {
    var_names <- names(s[[1]])
  }

  s <- sapply(s, function(x){
    x <- x[[var_names]]
    return(x)
  })

  # check s data:
  crs_reference <- terra::crs(s[[1]])
  s <- lapply(s, function(r) {
    if (terra::crs(r) != crs_reference) {
      message("CRS are not identical. Reprojecting s.")
      terra::project(r, crs_reference)
    } else {
      r
    }
  })

  resolution_reference <- terra::res(s[[1]])
  s <- lapply(s, function(r) {
    if (!all(terra::res(r) == resolution_reference)) {
      message("Resolutions are not identical. Resampling s.")
      terra::resample(r, s[[1]], method = "bilinear")
    } else {
      r
    }
  })

  # check study_area
  if(!is.null(study_area)){
    if(!terra::crs(s[[1]]) == terra::crs(study_area)) {
      message("CRS from s and study_area are not identical. Reprojecting study area.")
      study_area <- terra::project(study_area, terra::crs(s[[1]]))
    }
  }

  s2 <- sapply(s, function(x){
    if(!is.null(study_area)){
      x <- terra::mask(terra::crop(x, study_area), study_area)
    }
    x <- as.data.frame(x)
    return(x)
  }, USE.NAMES = TRUE, simplify = FALSE)

  test <- lapply(s2, nrow) |> unlist() |> unique() |> length() != 1

  if (test) {
    message("Objects from s don't have the same number of cells. Filtering all available cells.")
    common_extent <- Reduce(terra::intersect, lapply(s, terra::ext))
    rasters_cropped <- lapply(s, function(r) {
      terra::crop(r, common_extent)
    })
    valid_cells_raster <- rasters_cropped[[1]] # [[which.max(lapply(rasters_cropped, function(r){sum(is.na(terra::values(r)))}))]]
    terra::values(valid_cells_raster) <- TRUE
    for (r in rasters_cropped) {
      x <- r
      terra::values(x) <- ifelse(is.na(terra::values(x)), NA, TRUE)
      valid_cells_raster <- valid_cells_raster & x
    }
    rasters_masked <- lapply(rasters_cropped, function(r) {
      terra::mask(r, valid_cells_raster)
    })

    s2 <- sapply(rasters_masked, function(x){
      if(!is.null(study_area)){
        x <- terra::mask(terra::crop(x, study_area), study_area)
      }
      x <- as.data.frame(x)
      return(x)
    }, USE.NAMES = TRUE, simplify = FALSE)

  }

  return(s2)

  #if (var_names %in% names(s[[1]]) |> all()) {
  #  s <- sapply(s, function(x) { # Subset stacks to keep only var_names
  #    x <- x[[var_names]]
  #    # Reproject to match study_area crs.
  #    if (!is.null(study_area)) {
  #      if (any(class(study_area) %in% c("Extent"))) {
  #        # Crop and mask stacks
  #        x <- terra::mask(x, study_area)
  #      }
  #      if (any(class(study_area) %in% c("RasterLayer", "RasterStack", "RasterBrick"))) {
  #        if (!as.character(raster::crs(x)) == as.character(terra::crs(study_area))) {
  #          if (any(class(study_area) %in% c("RasterStack", "RasterBrick"))) {
  #            if (any(class(study_area) %in% c("RasterStack"))) {
  #              study_area <- study_area[[1]]
  #            } else {
  #              study_area <- study_area[[1]][[1]]
  #            }
  #          }
  #          x <- raster::stack(projectRaster(x, crs = as.character(raster::crs(study_area))))
  #          e <- raster::rasterToPolygons(study_area)
  #          # Crop and mask stacks
  #          x <- raster::mask(raster::stack(raster::crop(x, e)), e)
  #        }
  #      }
  #      if(any(class(study_area) %in% c("SpatVector"))) {
#
  #      }
  #      if (!any(class(study_area) %in% c("Extent", "RasterLayer", "SpatVector"))) {
  #        if (!as.character(raster::crs(x)) == as.character(CRS(raster::crs(study_area))) |
  #          is.na(as.character(raster::crs(x)) == as.character(CRS(raster::crs(study_area))))) {
  #          if (!raster::crs(study_area) == "") {
  #            x <- raster::projectRaster(x, crs = CRS(raster::crs(study_area)))
  #          }
  #          # Crop and mask stacks
  #          x <- raster::mask(raster::crop(x, study_area), study_area)
  #        } else {
  #          x <- raster::mask(raster::crop(x, study_area), study_area)
  #        }
  #      }
  #    }
#
#
  #    # Transform in data.frames
  #    x <- x |>
  #      raster::stack() |>
  #      as.data.frame()
  #    return(x)
  #  },
  #  USE.NAMES = T,
  #  simplify = F
  #  )
  #  return(s)
  #} else {
  #  stop("Variables names in s object do not match var_names!")
  #}
}
