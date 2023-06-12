#' Distance Matrix
#'
#' This function compares future climate projections from multiple Global Circulation Models (GCMs) based on their similarity in terms of bioclimatic variables. The function calculates distance metrics and plot it on a heatmap.
#'
#' @param s A list of stacks of General Circulation Models.
#' @param var_names Character. The names of the bioclimatic variables to compare.
#' @param study_area Extent object, or any object from which an Extent object can be extracted. A object that defines the study area for cropping and masking the rasters.
#' @param method The correlation method to use. Default is "pearson". Possible values are "euclidean", "maximum", "manhattan", "canberra", "binary", "minkowski", "pearson", "spearman" or "kendall".
#'
#' @return A list with two items: distances (the distances between GCMs) and heatmap (a plot).
#'
#' @examples
#' # compare GCMS
#' compare_gcms(folder_future_rasters_gcms = "path/to/folder",
#' study_area = raster("path/to/raster"),
#' var_names = c('bio_1', 'bio_12'),
#' gcm_names = c('gcm1', 'gcm2', 'gcm3'),
#' k = 3)
#'
#' @importFrom factoextra fviz_dist get_dist
#' @export
distance_matrix <- function(s, var_names=c('bio_1','bio_12'), study_area=NULL, method = 'euclidean'){

  assertList(s, types='RasterStack')
  assertCharacter(var_names, unique=T, any.missing=F)
  assertChoice(method, c("euclidean", "maximum", "manhattan", "canberra", "binary", "minkowski", "pearson", "spearman", "kendall"))

  # Transform stacks
  s <- transform_gcms(s, var_names, study_area=study_area)


  # Scale and flatten variables into one column.
  flatten_vars <- sapply(s, function(x){x <- scale(x)
                                        x <- as.vector(x)}, USE.NAMES=T)

  # Calculate the distance matrix
  dist_matrix <- get_dist(t(flatten_vars), method=method)

  hm <- fviz_dist(
    dist_matrix,
    order = TRUE,
    show_labels = TRUE,
    lab_size = NULL,
    gradient = list(low = "red", mid = "white", high = "blue")
  )

  return(list(distances=dist_matrix,
              heatmap=hm))
}



