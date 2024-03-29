#' Hierarchical Clustering of GCMs
#'
#' This function performs hierarchical clustering on a random subset of the raster values and produces a dendrogram visualization of the clusters.
#'
#' @param s A list of stacks of General Circulation Models.
#' @param var_names Character. A vector with names of the bioclimatic variables to compare OR 'all'.
#' @param study_area Extent object, or any object from which an Extent object can be extracted. A object that defines the study area for cropping and masking the rasters.
#' @param k The number of clusters to identify.
#' @param n The number of values to use in the clustering. If NULL (default) all data is used.
#'
#' @return A dendrogram visualizing the clusters.
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
#' dend <- hclust_gcms(stack, k=4, n=500)
#' plot(dend)
#'
#' @import checkmate
#' @import factoextra
#' @import ggplot2
#' @import raster
#' @importFrom grDevices colors
#'
#' @export
hclust_gcms <- function(s, var_names=c('bio_1','bio_12'), study_area=NULL, k=3, n=NULL){
  assertList(s, types='RasterStack')
  assertCharacter(var_names, unique=T, any.missing=F)
  assertCount(k, positive = T)
  if(!is.null(n)){assertCount(n, positive = T)}

  if('all' %in% var_names){
    var_names <- names(s[[1]])
  }

  x <- transform_gcms(s, var_names, study_area)
  x <- flatten_gcms(x)
  x <- na.omit(x)

  if(!is.null(n)){
    flatten_subset <- x
    if(nrow(flatten_subset)>n){
      x <- flatten_subset[sample(nrow(flatten_subset), n),]
    }
  }

  res <- hcut(t(x), k = k)
  dend <- fviz_dend(res,
                    cex = 0.5,
                    ylim = c(max(res$height)*1.1/5*-1, max(res$height)*1.1),
                    palette="jco",
                    main = "Hierarchical Clustering")
  return(dend)
}
