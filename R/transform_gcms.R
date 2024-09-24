#' Transform General Circulation Model (GCM) stacks
#'
#' This function transforms a list of stacks of GCMs by subsetting it to only include the variable
#' names specified in \code{var_names}, reprojecting it to match the CRS of \code{study_area},
#' cropping and masking it to \code{study_area}, and returning a list of data frames.
#'
#' @param s A list of stacks of General Circulation Models.
#' @param var_names Character. A vector with names of the bioclimatic variables to compare OR 'all'.
#' @param study_area Extent object, or any object from which an Extent object can be extracted.
#' A object that defines the study area for cropping and masking the rasters.
#'
#' @return A list of data frames, with each element of the list corresponding to a GCM in the input list.
#'
#' @seealso \code{\link{summary_gcms}}
#'
#' @author Luíz Fernando Esser (luizesser@gmail.com)
#' https://luizfesser.wordpress.com
#'
#' @examples
#' \dontrun{
#' s <- list(stack("gcm1.tif"), stack("gcm2.tif"), stack("gcm3.tif"))
#' study_area <- extent(c(-57, -22, -48, -33))
#' var_names <- c("bio_1", "bio_12")
#' t <- transform_gcms(s, var_names, study_area)
#' }
#'
#' @import checkmate
#' @importFrom terra crs project crop mask ext rast
#'
#' @export
transform_gcms <- function(s, var_names = c("bio_1", "bio_12"), study_area = NULL) {
  if(is.list(s)){
    if(is(s[[1]], "stars")){
      s <- sapply(s,
                  function(x){
                    x <- as(x, "SpatRaster")
                    return(x)
                  },
                  USE.NAMES = TRUE,
                  simplify = FALSE)
    }
    if(is(s[[1]], "RasterStack")){
      s <- sapply(s,
                  function(x){
                    x <- terra::rast(x)
                    return(x)
                  },
                  USE.NAMES = TRUE,
                  simplify = FALSE)
    }
  }

  if(!is.null(study_area)){
    if(!is(study_area, "SpatVector") & !is(study_area, "Extent")){
      study_area <- as(study_area, "SpatVector")
    }
    if(is(study_area, "Extent")){
      study_area <- terra::ext(study_area)
    }
  }

  checkmate::assertList(s, types = "SpatRaster")
  checkmate::assertCharacter(var_names, unique = T, any.missing = F)
  checkmate::assertSubset(var_names, c(names(s[[1]]), "all"))
  if(!class(study_area) %in% c("SpatVector", "SpatExtent")) {
    checkmate::assertClass(study_area, classes = c("SpatVector"), null.ok = TRUE)
  }

  if ("all" %in% var_names) {
    var_names <- names(s[[1]])
  }

  if(!is.null(study_area)){
    if(!terra::crs(s[[1]]) == terra::crs(study_area)) {
      study_area <- terra::project(study_area, terra::crs(s[[1]]))
    }
  }

  s2 <- sapply(s, function(x){
    x <- x[[var_names]]
    if(!is.null(study_area)){
      x <- terra::mask(terra::crop(x, study_area), study_area)
    }
    x <- as.data.frame(x)
    return(x)
  }, USE.NAMES = T, simplify = F)

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
