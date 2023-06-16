#' Optimize number of clusters for a dataset
#'
#' This function performs clustering analysis on a dataset and determines the optimal number of clusters based on a specified method.
#'
#' @param s A list of stacks of General Circulation Models.
#' @param var_names Character. The names of the bioclimatic variables to compare.
#' @param study_area Extent object, or any object from which an Extent object can be extracted. A object that defines the study area for cropping and masking the rasters.
#' @param method A character string specifying the method to use for determining the optimal number of clusters. Options are 'wss' for within-cluster sum of squares, 'silhouette' for average silhouette width and 'gap_stat' for the gap statistic method. Default is 'wss'.
#' @param n An integer specifying the number of randomly selected samples to use in the clustering analysis. Default is 10000.
#'
#' @return A ggplot object representing the optimal number of clusters.
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
#'
#' optk_gcms(flattened_gcms)
#'
#' @import checkmate
#' @importFrom factoextra fviz_nbclust hcut
#'
#' @export
optk_gcms <- function(s, var_names, study_area=NULL, method = 'wss', n = 1000) {

  assertList(s, types='RasterStack')
  assertCharacter(var_names, unique=T, any.missing=F)
  assertChoice(method, c("silhouette", "wss", "gap_stat"))
  assertCount(n, positive = T)

  x <- transform_gcms(s, var_names, study_area)
  x <- flatten_gcms(x)
  flatten_subset <- na.omit(x)
  if(is.null(n) | n > nrow(flatten_subset) ){
    if(nrow(flatten_subset)>1000){
      n <- 1000
    } else {
      n <- nrow(flatten_subset)
    }
  }
  flatten_subset <- flatten_subset[sample(nrow(flatten_subset), n),]
  y <- fviz_nbclust(flatten_subset, FUN = hcut, method)
  return(y)
}
