#' Flatten General Circulation Models (GCMs)
#'
#' Scale and flatten a list of GCMs \code{data.frame}s.
#'
#' @param s A list of transformed \code{data.frame}s representing GCMs.
#'
#' @return A \code{data.frame} with columns as GCMs and rows as values from each cell to each variable.
#'
#' @seealso \code{\link{transform_gcms}}
#'
#' @author Luíz Fernando Esser (luizesser@gmail.com)
#' https://luizfesser.wordpress.com
#'
#' @examples
#' var_names <- c("bio_1", "bio_12")
#' s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)
#' study_area <- terra::ext(c(-80, -30, -50, 10)) |> terra::vect(crs="epsg:4326")
#' s_trans <- transform_gcms(s, var_names, study_area)
#' flattened_gcms <- flatten_gcms(s_trans)
#'
#' @import checkmate
#'
#' @export
flatten_gcms <- function(s) {
  checkmate::assertList(s, types = "data.frame")
  sapply(s, function(x) {
    x <- scale(x)
    x <- as.vector(x)
  }, USE.NAMES = TRUE)
}
