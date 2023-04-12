#' Perform k-means clustering on GCMs
#'
#' This function performs k-means clustering on a distance matrix and produces a scatter plot of the resulting clusters.
#'
#' @param dist_matrix A list of stacks representing GCMs.
#' @param k Number of clusters.
#' @param method The method for distance matrix computation. Standard value is "euclidean". Possible values are: "euclidean", "maximum", "manhattan", "canberra", "binary" or "minkowski".
#' @return A scatter plot of the resulting clusters.
#'
#' @author Luíz Fernando Esser (luizesser@gmail.com)
#' https://luizfesser.wordpress.com
#'
#'
#' @importFrom factoextra fviz_cluster
#' @importFrom stats kmeans
#' @importFrom ggplot2 theme_minimal
#' @examples
#' s <- list(stack("gcm1.tif"), stack("gcm2.tif"), stack("gcm3.tif"))
#' study_area <- extent(c(-57, -22, -48, -33))
#' var_names <- c("bio_1", "bio_12")
#' s <- transform_gcms(s, var_names, study_area)
#' kmeans_gcms(s, k=3)
#'
#' @export
kmeans_gcms <- function(dist_matrix, k=3, method='euclidean'){
  # Scale and flatten variables into one column.
  flatten_vars <- flatten_gcms(s)

  # Calculate the distance matrix
  dist_matrix <- dist(t(flatten_vars), method = method)

  # Run K-means
  cl <- kmeans(dist_matrix, k, nstart=1000)

  # plot
  kmeans_plot <- fviz_cluster(cl,
                              data = dist_matrix,
                              palette = "Set1",
                              labelsize = 10,
                              ggtheme = theme_minimal(),
                              main = "K-means Clustering Plot",
                              xlim=c(-3,3),
                              ylim=c(-3,3),
                              legend = 'none')

  return(kmeans_plot)
}



