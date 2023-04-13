#' Optimize number of clusters for a dataset
#'
#' This function performs clustering analysis on a dataset and determines the optimal number of clusters based on a specified method.
#'
#' @param x a flatten gcm, output of flatten_gcms function.
#' @param n An integer specifying the number of randomly selected samples to use in the clustering analysis. Default is 10000.
#' @param method A character string specifying the method to use for determining the optimal number of clusters. Options are 'wss' for within-cluster sum of squares, 'silhouette' for average silhouette width and 'gap' for the gap statistic method. Default is 'wss'.
#'
#' @return A ggplot object representing the optimal number of clusters.
#'
#' @importFrom factoextra fviz_nbclust hcut
#'
#' @seealso \code{\link{transform_gcms}} \code{\link{flatten_gcms}}
#'
#' @author Luíz Fernando Esser (luizesser@gmail.com)
#' https://luizfesser.wordpress.com
#'
#' @examples
#'
#' s <- list(stack("gcm1.tif"), stack("gcm2.tif"), stack("gcm3.tif"))
#' study_area <- extent(c(-57, -22, -48, -33))
#' var_names <- c("bio_1", "bio_12")
#' s <- transform_gcms(s, var_names, study_area)
#' flattened_gcms <- flatten_gcms(s)
#'
#' optimize_clusters(flattened_gcms)
#'
#' @export
optimize_clusters <- function(x, n = 1000, method = 'wss') {
  flatten_subset <- na.omit(x)
  flatten_subset <- flatten_subset[sample(nrow(flatten_subset), n),]
  y <- fviz_nbclust(flatten_subset, FUN = hcut, method)
  return(y)
}
