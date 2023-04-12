#' Compare GCMS
#'
#' This function compares future climate projections from multiple Global Circulation Models (GCMs) based on their similarity in terms of bioclimatic variables. The function clusters the GCMs using k-means clustering and hierarchical clustering, calculates the Pearson correlation matrix, and generates plots for the clusters and the correlation matrix.
#'
#' @param s Character. Path to the folder containing the future stack files for the GCMs.
#' @param study_area Extent object, or any object from which an Extent object can be extracted. A object that defines the study area for cropping and masking the rasters.
#' @param var_names Character. The names of the bioclimatic variables to compare.
#' @param k Numeric. The number of clusters to use for k-means clustering.
#' @return A list with two items: suggested_gcms (the names of the GCMs suggested for further analysis) and statistics_gcms (a grid of plots).
#'
#' @examples
#' # compare GCMS
#' compare_gcms(folder_future_rasters_gcms = "path/to/folder",
#' study_area = raster("path/to/raster"),
#' var_names = c('bio_1', 'bio_12'),
#' gcm_names = c('gcm1', 'gcm2', 'gcm3'),
#' k = 3)
#'
#' @importFrom raster stack projectRaster mask crop
#' @import ggplot2
#' @import ggpubr
#' @import stats
#' @import utils
#' @import plyr
#' @import cowplot
#' @importFrom ggcorrplot ggcorrplot
#' @importFrom factoextra fviz_cluster fviz_nbclust fviz_dend
#' @export
compare_gcms <- function(s, study_area=NULL, var_names=c('bio_1','bio_12'), k=3){
  # Transform stacks
  s <- transform_gcms(s, c('bio_1', 'bio_2'), study_area=study_area)


  # Scale and flatten variables into one column.
  flatten_vars <- sapply(s, function(x){x <- scale(x)
                                        x <- as.vector(x)}, USE.NAMES=T)

  # Calculate the distance matrix
  dist_matrix <- dist(t(flatten_vars))

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

  # Run Hierarchical Cluster
  # hclust_plot <- hclust(dist_matrix)
  # Include elbow, silhouette and gap methods
  flatten_subset <- na.omit(flatten_vars)
  flatten_subset <- flatten_subset[sample(nrow(flatten_subset), nrow(flatten_subset)/20),]
  wss <- fviz_nbclust(flatten_subset, FUN = hcut, method = "wss")
  sil <- fviz_nbclust(flatten_subset, FUN = hcut, method = "silhouette")
  #gap <- fviz_gap_stat(flatten_subset, maxSE = list(method = "globalmax"))

  # Compute hierarchical clustering and cut into k clusters
  res <- hcut(t(flatten_subset), k = k)
  dend <- fviz_dend(res,
                    cex = 0.5,
                    ylim = c(max(res$height)*1.1/5*-1, max(res$height)*1.1),
                    palette="Set1",
                    main = "Hierarchical Clustering")

  # Run Correlation
  cor_matrix <- cor(flatten_vars, use='complete.obs')
  cor_plot <- ggcorrplot(cor_matrix,
                         method='circle',
                         type='lower',
                         lab=T,
                         lab_size = 3,
                         hc.order=T,
                         hc.method = 'ward.D2',
                         show.legend = F,
                         title='Pearson Correlation')

  # Plot everything together
  statistics_gcms <- plot_grid(kmeans_plot,
                               cor_plot,
                               dend,
                               plot_grid(wss,
                                         sil,
                                         ncol=1,
                                         labels=c("D", "E"),
                                         label_x = -0.05),
                               labels = c("A", "B", "C"),
                               ncol = 2,
                               rel_widths = 4)

  gcms <- apply(cl$centers, 1, function(x){which.min(x) %>% names()})


  return(list(suggested_gcms=gcms,
              statistics_gcms=statistics_gcms))
}



