#' Distance between GCMs
#'
#' This function compares future climate projections from multiple Global Circulation Models (GCMs) based on their similarity in terms of bioclimatic variables. The function calculates distance metrics and plot it on a heatmap.
#'
#' @param s A list of stacks of General Circulation Models.
#' @param var_names Character. A vector with names of the bioclimatic variables to compare OR 'all'.
#' @param study_area Extent object, or any object from which an Extent object can be extracted. A object that defines the study area for cropping and masking the rasters.
#' @param scale Boolean. Apply center and scale in data? Default is TRUE.
#' @param method The correlation method to use. Default is "euclidean". Possible values are "euclidean", "maximum", "manhattan", "canberra", "binary", "minkowski", "pearson", "spearman" or "kendall".
#'
#' @return A list with two items: distances (the distances between GCMs) and heatmap (a plot).
#'
#' @seealso \code{\link{transform_gcms}} \code{\link{flatten_gcms}}
#'
#' @author Luíz Fernando Esser (luizesser@gmail.com)
#' https://luizfesser.wordpress.com
#'
#' @examples
#' \dontrun{
#' s <- list(stack("gcm1.tif"), stack("gcm2.tif"), stack("gcm3.tif"))
#' study_area <- extent(c(-57, -22, -48, -33))
#' var_names <- c("bio_1", "bio_12")
#'
#' dist_gcms(s, method = "euclidean")
#' }
#'
#' @import checkmate
#' @importFrom factoextra fviz_dist get_dist
#'
#' @export
dist_gcms <- function(s, var_names = c("bio_1", "bio_12"), study_area = NULL, scale = TRUE, method = "euclidean") {
  if(is.list(s)){
    if(!is.data.frame(s[[1]])){
      checkmate::assertList(s, types = "SpatRaster")
    }
  }
  checkmate::assertCharacter(var_names, unique = T, any.missing = F)
  checkmate::assertChoice(method, c("euclidean", "maximum", "manhattan", "canberra", "binary", "minkowski", "pearson", "spearman", "kendall"), null.ok = TRUE)

  if ("all" %in% var_names) {
    var_names <- names(s[[1]])
  }

  # Scale and flatten variables into one column.
  if(!is.data.frame(s[[1]])){
    s <- transform_gcms(s, var_names, study_area)
    if (scale) {
      s <- lapply(s, function(x) {x <- as.data.frame(scale(x))})
    }
  }
  flatten_vars <- flatten_gcms(s)

  # Calculate the distance matrix
  dist_matrix <- factoextra::get_dist(t(flatten_vars), method = method)

  hm <- factoextra::fviz_dist(
    dist_matrix,
    order = TRUE,
    show_labels = TRUE,
    lab_size = NULL,
    gradient = list(low = "#FDE725FF", mid = "#21908CFF", high = "#440154FF")
  ) +
    ggplot2::ggtitle("Distance Matrix Heatmap")

  return(list(
    distances = dist_matrix,
    heatmap = hm
  ))
}
