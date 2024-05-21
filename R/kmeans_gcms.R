#' Perform k-means clustering on GCMs
#'
#' This function performs k-means clustering on a distance matrix and produces a scatter plot of the resulting clusters.
#'
#' @param s A list of stacks of General Circulation Models.
#' @param var_names Character. A vector with names of the bioclimatic variables to compare OR 'all'.
#' @param study_area Extent object, or any object from which an Extent object can be extracted. A object that defines the study area for cropping and masking the rasters.
#' @param k Number of clusters.
#' @param method The method for distance matrix computation. Standard value is "euclidean". Possible values are: "euclidean", "maximum", "manhattan", "canberra", "binary" or "minkowski". If NULL, will perform the clustering on raw variables data.
#'
#' @return A scatter plot of the resulting clusters.
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
#' kmeans_gcms(s, k = 3)
#'
#' @import checkmate
#' @importFrom factoextra fviz_cluster
#' @importFrom stats kmeans
#' @importFrom ggplot2 theme_minimal
#'
#' @export
kmeans_gcms <- function(s, var_names = c("bio_1", "bio_12"), study_area = NULL, k = 3, method = NULL) {
  assertList(s, types = "RasterStack")
  assertCharacter(var_names, unique = T, any.missing = F)
  assertCount(k, positive = T)

  if ("all" %in% var_names) {
    var_names <- names(s[[1]])
  }

  if (is.null(method)) {
    # Scale and calculate the means from variables.
    x <- transform_gcms(s, var_names, study_area)
    flatten_vars <- sapply(x, function(y) {
      y <- colMeans(y, na.rm = T)
    })

    # Run K-means
    cl <- kmeans(t(flatten_vars), k, nstart = 10000, iter.max = 1000)

    gcms <- vector()
    gcms_mat <- as.matrix(dist(t(cbind(t(cl$centers), flatten_vars))))[-c(1:k), c(1:k)]
    gcms_dist <- apply(gcms_mat, 2, min)[1:k]
    for (i in 1:length(gcms_dist)) {
      v <- names(which(gcms_mat[, i] == gcms_dist[i]))
      v <- ifelse(length(v) > 1, v[1], v)
      gcms[i] <- v
    }

    # plot
    kmeans_plot <- fviz_cluster(cl,
      data = t(flatten_vars),
      palette = "jco",
      ggtheme = theme_minimal(),
      main = "K-means Clustering Plot",
      legend = "none"
    )
  } else {
    assertChoice(method, c("euclidean", "maximum", "manhattan", "canberra", "binary", "minkowski"))

    # Scale and flatten variables into one column.
    x <- transform_gcms(s, var_names, study_area)
    flatten_vars <- flatten_gcms(x)

    # Calculate the distance matrix
    dist_matrix <- dist(t(flatten_vars), method = method)

    # Run K-means
    cl <- kmeans(dist_matrix, k, nstart = 10000, iter.max = 1000)

    gcms <- apply(cl$centers, 1, function(x) {
      which.min(x) %>% names()
    })

    # plot
    kmeans_plot <- fviz_cluster(cl,
      data = dist_matrix,
      palette = "jco",
      ggtheme = theme_minimal(),
      check_overlap = T,
      main = "K-means Clustering Plot",
      legend = "none",
      repel = TRUE
    )
  }

  return(list(
    suggested_gcms = gcms,
    kmeans_plot = kmeans_plot
  ))
}
