#' Compare GCMS
#'
#' This function compares future climate projections from multiple Global Circulation Models (GCMs) based on their similarity in terms of bioclimatic variables. The function clusters the GCMs using k-means clustering and hierarchical clustering, calculates the Euclidean distance matrix, and generates plots for the clusters and the distance matrix.
#'
#' @param s A list of stacks of General Circulation Models.
#' @param var_names Character. A vector with names of the bioclimatic variables to compare OR 'all'.
#' @param study_area Extent object, or any object from which an Extent object can be extracted. A object that defines the study area for cropping and masking the rasters.
#' @param k Numeric. The number of clusters to use for k-means clustering.
#'
#' @return A list with two items: suggested_gcms (the names of the GCMs suggested for further analysis) and statistics_gcms (a grid of plots).
#'
#' @author Luíz Fernando Esser (luizesser@gmail.com)
#' https://luizfesser.wordpress.com
#'
#' @examples
#' # compare GCMS
#' compare_gcms(
#'   folder_future_rasters_gcms = "path/to/folder",
#'   study_area = raster("path/to/raster"),
#'   var_names = c("bio_1", "bio_12"),
#'   gcm_names = c("gcm1", "gcm2", "gcm3"),
#'   k = 3
#' )
#'
#' @import checkmate
#' @import ggplot2
#' @import ggpubr
#' @import stats
#' @import utils
#' @importFrom factoextra fviz_cluster fviz_nbclust fviz_dend
#' @importFrom ggcorrplot ggcorrplot
#' @importFrom raster stack projectRaster mask crop
#' @importFrom cowplot plot_grid
#'
#' @export
compare_gcms <- function(s, var_names = c("bio_1", "bio_12"), study_area = NULL, k = 3) {
  assertList(s, types = "RasterStack")
  assertCharacter(var_names, unique = T, any.missing = F)
  assertCount(k, positive = T)

  if ("all" %in% var_names) {
    var_names <- names(s[[1]])
  }

  # Transform stacks
  x <- transform_gcms(s, var_names, study_area = study_area)
  flatten_vars <- flatten_gcms(x)

  # Calculate the distance matrix
  dist_matrix <- dist(t(flatten_vars))
  # hm <- fviz_dist(
  #  dist_matrix,
  #  order = TRUE,
  #  show_labels = TRUE,
  #  lab_size = NULL,
  #  gradient = list(low = "#FDE725FF", mid = "#21908CFF", high = "#440154FF")) +
  #  ggtitle("Distance Matrix Heatmap")

  # Calculate the Monte Carlo permutations
  mc <- montecarlo_gcms(s, var_names, study_area, perm = 10000, method = "euclidean")

  # Run K-means
  cl <- kmeans(dist_matrix, k, nstart = 10000, iter.max = 1000)

  # plot
  kmeans_plot <- fviz_cluster(cl,
    data = dist_matrix,
    palette = "jco",
    ggtheme = theme_minimal(),
    check_overlap = T,
    main = "K-means Clustering Plot",
    legend = "none", repel = TRUE
  )

  # Include elbow, silhouette and gap methods
  flatten_subset <- na.omit(flatten_vars)
  #
  # if(nrow(flatten_subset)>1000){
  #  n <- 1000
  # } else {
  #  n <- nrow(flatten_subset)
  # }
  #
  # flatten_subset <- flatten_subset[sample(nrow(flatten_subset), n),]
  # sil <- fviz_nbclust(flatten_subset, FUN = kmeans, method = "silhouette")

  # Plot Environment
  gcms <- apply(cl$centers, 1, function(x) {
    which.min(x) |> names()
  })
  env <- env_gcms(s, var_names, study_area, highlight = gcms)

  # Compute hierarchical clustering and cut into k clusters
  res <- hcut(t(flatten_subset), k = k)
  dend <- fviz_dend(res,
    cex = 0.5,
    ylim = c(max(res$height) * 1.1 / 5 * -1, max(res$height) * 1.1),
    palette = "jco",
    main = "Hierarchical Clustering"
  )

  statistics_gcms <- plot_grid(kmeans_plot,
    # hm,
    mc$montecarlo_plot,
    dend,
    # sil,
    env,
    labels = c("A", "B", "C", "D"),
    ncol = 2,
    rel_widths = 4
  )

  return(list(
    suggested_gcms = gcms,
    statistics_gcms = statistics_gcms
  ))
}
