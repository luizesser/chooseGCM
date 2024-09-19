#' Transform General Circulation Model (GCM) stacks
#'
#' This function transforms a list of stacks of GCMs by subsetting it to only include the variable names specified in \code{var_names}, reprojecting it to match the CRS of \code{study_area}, cropping and masking it to \code{study_area}, and returning a list of data frames.
#'
#' @param s A list of stacks of General Circulation Models.
#' @param var_names Character. A vector with names of the bioclimatic variables to compare OR 'all'.
#' @param study_area Extent object, or any object from which an Extent object can be extracted. A object that defines the study area for cropping and masking the rasters.
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
#' @import raster
#' @importFrom sp CRS
#'
#' @export
transform_gcms <- function(s, var_names = c("bio_1", "bio_12"), study_area = NULL) {
  checkmate::assertList(s, types = "RasterStack")
  checkmate::assertCharacter(var_names, unique = T, any.missing = F)

  if ("all" %in% var_names) {
    var_names <- names(s[[1]])
  }

  if (var_names %in% names(s[[1]]) |> all()) {
    s <- sapply(s, function(x) { # Subset stacks to keep only var_names
      x <- x[[var_names]]
      # Reproject to match study_area crs.
      if (!is.null(study_area)) {
        if (any(class(study_area) %in% c("Extent"))) {
          # Crop and mask stacks
          x <- raster::crop(x, study_area)
        }
        if (any(class(study_area) %in% c("RasterLayer", "RasterStack", "RasterBrick"))) {
          if (!as.character(raster::crs(x)) == as.character(crs(study_area))) {
            if (any(class(study_area) %in% c("RasterStack", "RasterBrick"))) {
              if (any(class(study_area) %in% c("RasterStack"))) {
                study_area <- study_area[[1]]
              } else {
                study_area <- study_area[[1]][[1]]
              }
            }
            x <- raster::stack(projectRaster(x, crs = as.character(raster::crs(study_area))))
            e <- raster::rasterToPolygons(study_area)
            # Crop and mask stacks
            x <- raster::mask(raster::stack(raster::crop(x, e)), e)
          }
        }
        if (!any(class(study_area) %in% c("Extent", "RasterLayer"))) {
          if (!as.character(raster::crs(x)) == as.character(CRS(raster::crs(study_area))) |
            is.na(as.character(raster::crs(x)) == as.character(CRS(raster::crs(study_area))))) {
            if (!raster::crs(study_area) == "") {
              x <- raster::projectRaster(x, crs = CRS(raster::crs(study_area)))
            }
            # Crop and mask stacks
            x <- raster::mask(raster::crop(x, study_area), study_area)
          } else {
            x <- raster::mask(raster::crop(x, study_area), study_area)
          }
        }
      }

      # Transform in data.frames
      x <- x |>
        raster::stack() |>
        as.data.frame()
      return(x)
    },
    USE.NAMES = T,
    simplify = F
    )
    return(s)
  } else {
    stop("Variables names in s object do not match var_names!")
  }
}
