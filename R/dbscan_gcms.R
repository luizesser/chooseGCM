#' Perform DBScan clustering on GCMs
#'
#' This function performs DBScan clustering and produces a scatter plot of the resulting clusters.
#'
#' @param s A list of stacks of General Circulation Models.
#' @param var_names Character. A vector with names of the bioclimatic variables to compare OR 'all'.
#' @param study_area Extent object, or any object from which an Extent object can be extracted. A object that defines the study area for cropping and masking the rasters.
#' @param scale Boolean. Apply center and scale in data? Default is TRUE.
#' @param eps Size (radius) of the epsilon neighborhood.
#' @param MinPts Number of minimum points required in the eps neighborhood for core points (including the point itself).
#' @param ... Arguments to pass to fpc::dbscan().
#'
#' @return A scatter plot of the resulting clusters and the suggested GCMs.
#'
#' @seealso \code{\link{transform_gcms}} \code{\link{flatten_gcms}}
#'
#' @author Luíz Fernando Esser (luizesser@gmail.com)
#' https://luizfesser.wordpress.com
#'
#' @examples
#'
#' \dontrun{
#' s <- list(stack("gcm1.tif"), stack("gcm2.tif"), stack("gcm3.tif"))
#' study_area <- extent(c(-57, -22, -48, -33))
#' var_names <- c("bio_1", "bio_12")
#'
#' dbscan_gcms(s, k = 3)
#' }
#'
#' @import checkmate
#' @importFrom fpc dbscan
#' @importFrom factoextra fviz_cluster
#' @importFrom ggplot2 theme_minimal
#'
#' @export
dbscan_gcms <- function(s, var_names = c("bio_1", "bio_12"), study_area = NULL, scale = TRUE, eps = length(s)-1, MinPts = 3, ...) {
  if(is.list(s)){
    if(!is.data.frame(s[[1]])){
      checkmate::assertList(s, types = "SpatRaster")
    }
  }
  checkmate::assertCharacter(var_names, unique = T, any.missing = F)
  checkmate::assertCount(MinPts, positive = T)
  checkmate::assertNumeric(eps, lower = 0, len=1)

  if ("all" %in% var_names) {
    var_names <- names(s[[1]])
  }

  s <- transform_gcms(s, var_names, study_area)
  if (scale) {
    s <- lapply(s, function(x) {x <- as.data.frame(scale(x))})
  }
  s_flat <- flatten_gcms(s)

  dbs <- fpc::dbscan(t(s_flat), eps=eps, MinPts = MinPts, ...)

  dbscan_plot <- factoextra::fviz_cluster(dbs,
                                          data = t(s_flat),
                                          palette = "jco",
                                          ggtheme = ggplot2::theme_minimal(),
                                          check_overlap = T,
                                          main = "DBScan Clustering Plot",
                                          legend = "none",
                                          repel = TRUE
  )

  mean_all <- sapply(s, function(y) {
    y <- colMeans(y, na.rm = T)
  })
  mean_all <- rowMeans(mean_all)
  res <- vector()
  for (i in 1:max(dbs$cluster)) {
    mean_cluster <- sapply(s[dbs$cluster==i], function(y) {
      y <- colMeans(y, na.rm = T)
    })
    vals <- as.matrix(dist(t(cbind(mean_cluster, mean_all))))[,"mean_all"]
    res[i] <- names(which.min(vals[vals > 0]))
  }

  return(list(
    suggested_gcms = res,
    dbscan_plot = dbscan_plot
  ))
}
