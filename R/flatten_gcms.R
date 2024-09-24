#' Flatten GCMs
#'
#' Scale and flatten a list of rasters (GCMs) to a vector.
#'
#' @param s A list of transformed data frames (GCMs)
#'
#' @return A named list of flattened data.frame
#'
#' @author Luíz Fernando Esser (luizesser@gmail.com)
#' https://luizfesser.wordpress.com
#'
#' @examples
#' \dontrun{
#' s <- list(stack("gcm1.tif"), stack("gcm2.tif"), stack("gcm3.tif"))
#' study_area <- extent(c(-57, -22, -48, -33))
#' var_names <- c("bio_1", "bio_12")
#' s <- transform_gcms(s, var_names, study_area)
#' flattened_gcms <- flatten_gcms(s)
#' }
#'
#' @import checkmate
#'
#' @export
flatten_gcms <- function(s) {
  checkmate::assertList(s, types = "data.frame")
  sapply(s, function(x) {
    x <- scale(x)
    x <- as.vector(x)
  }, USE.NAMES = T)
}
