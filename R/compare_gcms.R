#' Compare GCMS
#'
#' This function compares future climate projections from multiple Global Circulation Models (GCMs) based on their similarity in terms of bioclimatic variables. The function clusters the GCMs using k-means clustering and hierarchical clustering, calculates the Euclidean distance matrix, and generates plots for the clusters and the distance matrix.
#'
#' @param s A list of stacks of General Circulation Models.
#' @param var_names Character. A vector with names of the bioclimatic variables to compare OR 'all'.
#' @param study_area Extent object, or any object from which an Extent object can be extracted. A object that defines the study area for cropping and masking the rasters.
#' @param scale Boolean. Apply center and scale in data? Default is TRUE.
#' @param k Numeric. The number of clusters to use for k-means clustering.
#'
#' @return A list with two items: suggested_gcms (the names of the GCMs suggested for further analysis) and statistics_gcms (a grid of plots).
#'
#' @author Luíz Fernando Esser (luizesser@gmail.com)
#' https://luizfesser.wordpress.com
#'
#' @examples
#' \dontrun{
#' # compare GCMS
#' compare_gcms(
#'   s = import_gcms("path/to/folder"),
#'   study_area = terra::vect("path/to/gpkg"),
#'   var_names = c("bio_1", "bio_12"),
#'   gcm_names = c("gcm1", "gcm2", "gcm3"),
#'   k = 3
#' )
#' }
#'
#' @import checkmate
#' @import ggplot2
#' @importFrom factoextra fviz_cluster fviz_nbclust fviz_dend
#' @importFrom cowplot plot_grid
#'
#' @export
compare_gcms <- function(s, var_names = c("bio_1", "bio_12"), study_area = NULL, k = 3, scale=TRUE, clustering_method = "closestdist") {
  checkmate::assertList(s, types = "SpatRaster")
  checkmate::assertCharacter(var_names, unique = T, any.missing = F)
  checkmate::assertCount(k, positive = T)
  checkmate::assertChoice(clustering_method, c("kmeans", "hclust", "closestdist"))

  if ("all" %in% var_names) {
    var_names <- names(s[[1]])
  }

  # Transform stacks
  x <- transform_gcms(s, var_names, study_area = study_area)
  if (scale) {
    x <- lapply(x, function(y) {y <- as.data.frame(scale(y))})
  }
  flatten_vars <- flatten_gcms(x)

  # Calculate the distance matrix
  dist_matrix <- stats::dist(t(flatten_vars))
  # hm <- fviz_dist(
  #  dist_matrix,
  #  order = TRUE,
  #  show_labels = TRUE,
  #  lab_size = NULL,
  #  gradient = list(low = "#FDE725FF", mid = "#21908CFF", high = "#440154FF")) +
  #  ggtitle("Distance Matrix Heatmap")

  # Calculate the Monte Carlo permutations
  mc <- montecarlo_gcms(s, var_names, study_area, perm = 10000, dist_method = "euclidean", clustering_method = "closestdist")

  # Run K-means
  cl <- stats::kmeans(dist_matrix, k, nstart = 10000, iter.max = 1000)
  gcms <- apply(cl$centers, 1, function(x) {
    which.min(x) |> names()
  })

  # plot
  kmeans_plot <- factoextra::fviz_cluster(cl,
                           data = dist_matrix,
                           palette = "jco",
                           ggtheme = ggplot2::theme_minimal(),
                           check_overlap = T,
                           main = "K-means Clustering Plot",
                           legend = "none",
                           repel = TRUE,
                           label.select = NA) +
    ggplot2::geom_text(ggplot2::aes(label = ifelse(colnames(cl$centers) %in% gcms, colnames(cl$centers), "")),
                       color = "red",
                       vjust = -1,
                       size = 4) +
    ggplot2::geom_text(ggplot2::aes(label = ifelse(!colnames(cl$centers) %in% gcms, colnames(cl$centers), "")),
                       color = "black",
                       vjust = -1,
                       size = 4) +
    ggplot2::theme(plot.margin = ggplot2::unit(c(0.2, 0, 0, 1), "cm"))

  # Include elbow, silhouette and gap methods
  flatten_subset <- stats::na.omit(flatten_vars)
  #
  # if(nrow(flatten_subset)>1000){
  #  n <- 1000
  # } else {
  #  n <- nrow(flatten_subset)
  # }
  #
  # flatten_subset <- flatten_subset[sample(nrow(flatten_subset), n),]
  # sil <- fviz_nbclust(flatten_subset, FUN = kmeans, method = "silhouette")

  # Plot Environment closest dist
  env <- env_gcms(s, var_names, study_area, highlight = mc$suggested_gcms[[k-1]], title = "Closest subset to the Global Mean")

  # Compute hierarchical clustering and cut into k clusters
  res <- factoextra::hcut(t(flatten_subset), k = k)
  mean_all <- sapply(x, function(y) {
    y <- colMeans(y, na.rm = T)
  })
  mean_all <- rowMeans(mean_all)
  res2 <- vector()
  for (i in 1:k) {
    mean_cluster <- sapply(x[res$cluster==i], function(y) {
      y <- colMeans(y, na.rm = T)
    })
    vals <- as.matrix(dist(t(cbind(mean_cluster, mean_all))))[,"mean_all"]
    res2[i] <- names(which.min(vals[vals > 0]))
  }
  dend <- factoextra::fviz_dend(res,
                                horiz=T,
                                cex = 0.8,
                                palette = "jco",
                                main = "Hierarchical Clustering",
                                label_cols = ifelse(res$labels[res$order] %in% res2, "red", "black")
  ) + ggplot2::theme(
    plot.margin = ggplot2::unit(c(0.2, 0, 0, 1), "cm")  # Adjust the left margin (last number) to add more space
  )

  statistics_gcms <- cowplot::plot_grid(kmeans_plot,
                                        dend,
                                        mc$montecarlo_plot,
                                        env,
                                        labels = c("A", "B", "C", "D"),
                                        ncol = 2,
                                        rel_widths = 4
  )

  return(list(
    suggested_gcms = mc$suggested_gcms,
    statistics_gcms = statistics_gcms
  ))
}
