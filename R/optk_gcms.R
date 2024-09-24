#' Optimize number of clusters for a dataset
#'
#' This function performs clustering analysis on a dataset and determines the optimal number of clusters based on a specified method.
#'
#' @param s A list of stacks of General Circulation Models.
#' @param var_names Character. A vector with names of the bioclimatic variables to compare OR 'all'.
#' @param study_area Extent object, or any object from which an Extent object can be extracted. A object that defines the study area for cropping and masking the rasters.
#' @param cluster A character string specifying the method to build the clusters. Options are 'kmeans' (standard) or 'hclust'.
#' @param method A character string specifying the method to use for determining the optimal number of clusters. Options are 'wss' for within-cluster sum of squares, 'silhouette' for average silhouette width and 'gap_stat' for the gap statistic method. Default is 'wss'.
#' @param n An integer specifying the number of randomly selected samples to use in the clustering analysis. If NULL (default) all data is used.
#' @param nstart A
#' @param K.max A
#' @param B A
#'
#' @return A ggplot object representing the optimal number of clusters.
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
#' optk_gcms(flattened_gcms)
#' }
#'
#' @import checkmate
#' @importFrom factoextra fviz_nbclust hcut
#' @importFrom cluster clusGap
#'
#' @export
optk_gcms <- function(s, var_names = c("bio_1", "bio_12"), study_area = NULL, cluster = "kmeans", method = "wss", n = NULL, nstart = 10, K.max = 10, B = 100) {
  checkmate::assertList(s, types = "SpatRaster")
  checkmate::assertCharacter(var_names, unique = T, any.missing = F)
  checkmate::assertChoice(cluster, c("kmeans", "hclust"))
  checkmate::assertChoice(method, c("silhouette", "wss", "gap_stat"))
  checkmate::assertCount(n, positive = T, null.ok = T)
  checkmate::assertCount(nstart, positive = T)
  checkmate::assertCount(K.max, positive = T)
  checkmate::assertCount(B, positive = T)

  if ("all" %in% var_names) {
    var_names <- names(s[[1]])
  }

  x <- transform_gcms(s, var_names, study_area)
  x <- flatten_gcms(x)
  flatten_subset <- stats::na.omit(x)

  if (!is.null(n)) {
    if (nrow(flatten_subset) > n) {
      flatten_subset <- flatten_subset[sample(nrow(flatten_subset), n), ]
    }
  }

  if (cluster == "kmeans") {
    if (method == "gap_stat") {
      g <- cluster::clusGap(flatten_subset, FUNcluster = kmeans, nstart = nstart, K.max = K.max, B = B)
      y <- factoextra::fviz_gap_stat(g)
    } else {
      y <- factoextra::fviz_nbclust(flatten_subset, FUNcluster = kmeans, method)
    }
  }

  if (cluster == "hclust") {
    if (method == "gap_stat") {
      y <- factoextra::fviz_nbclust(flatten_subset, FUNcluster = hclust, method, k.max = K.max, nboot = B)
    } else {
      y <- factoextra::fviz_nbclust(flatten_subset, FUNcluster = hclust, method)
    }
  }

  return(y)
}
