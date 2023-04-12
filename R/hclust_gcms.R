#' Hierarchical Clustering of GCMs
#'
#' Given a list of stacks containing GCMs, this function performs hierarchical clustering on a random subset of the raster values and produces a dendrogram visualization of the clusters.
#'
#' @param x A list of stacks containing GCMs.
#' @param k The number of clusters to identify.
#' @param n The number of values to use in the clustering (default: 1000).
#' @author Luíz Fernando Esser (luizesser@gmail.com)
#' https://luizfesser.wordpress.com
#' @return A dendrogram visualizing the clusters.
#'
#' @seealso \code{\link{transform_gcms}} \code{\link{flatten_gcms}}
#'
#' @import ggplot2
#' @import factoextra
#' @import raster
#' @importFrom grDevices colors
#'
#' @examples
#' s <- list(stack("gcm1.tif"), stack("gcm2.tif"), stack("gcm3.tif"))
#' study_area <- extent(c(-57, -22, -48, -33))
#' var_names <- c("bio_1", "bio_12")
#' s <- transform_gcms(s, var_names, study_area)
#' flattened_gcms <- flatten_gcms(s)
#' dend <- hclust_gcms(stack, k=4, n=500)
#' plot(dend)
#'
#' @export
hclust_gcms <- function(x, k=3, n=1000){
  flatten_subset <- na.omit(x)
  flatten_subset <- flatten_subset[sample(nrow(flatten_subset), n),]
  res <- hcut(t(x), k = k)
  dend <- fviz_dend(res,
                    cex = 0.5,
                    ylim = c(max(res$height)*1.1/5*-1, max(res$height)*1.1),
                    palette="Set1",
                    main = "Hierarchical Clustering")
  return(dend)
}
