#' Distance Between GCMs
#'
#' This function compares future climate projections from multiple General Circulation Models (GCMs) based on their similarity in terms of variables. It calculates distance metrics and plots the results on a heatmap.
#'
#' @param s A list of stacks of General Circulation Models (GCMs).
#' @param var_names Character. A vector of names of the variables to compare, or 'all' to include all variables.
#' @param study_area An Extent object, or any object from which an Extent object can be extracted. Defines the study area for cropping and masking the rasters.
#' @param scale Logical. Whether to apply centering and scaling to the data. Default is \code{TRUE}.
#' @param method Character. The correlation method to use. Default is "euclidean". Possible values are: "euclidean", "maximum", "manhattan", "canberra", "binary", "minkowski", "pearson", "spearman", or "kendall".
#'
#' @return A list containing two items: \code{distances} (the calculated distances between GCMs) and \code{heatmap} (a plot displaying the heatmap).
#'
#' @seealso \code{\link{transform_gcms}} \code{\link{flatten_gcms}}
#'
#' @author Luíz Fernando Esser (luizesser@gmail.com)
#' https://luizfesser.wordpress.com
#'
#' @examples
#' var_names <- c("bio_1", "bio_12")
#' s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)
#' study_area <- terra::ext(c(-80, -30, -50, 10)) |> terra::vect(crs="epsg:4326")
#' dist_gcms(s, var_names, study_area, method = "euclidean")
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
  checkmate::assertCharacter(var_names, unique = TRUE, any.missing = FALSE)
  checkmate::assertChoice(method, c("euclidean", "maximum", "manhattan", "canberra", "binary",
                                    "minkowski", "pearson", "spearman", "kendall"), null.ok = TRUE)
  checkmate::assertLogical(scale, len=1, null.ok = FALSE, any.missing = FALSE, all.missing = FALSE)

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
