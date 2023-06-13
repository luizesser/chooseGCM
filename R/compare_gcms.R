#' Compare GCMS
#'
#' This function compares future climate projections from multiple Global Circulation Models (GCMs) based on their similarity in terms of bioclimatic variables. The function clusters the GCMs using k-means clustering and hierarchical clustering, calculates the Pearson correlation matrix, and generates plots for the clusters and the correlation matrix.
#'
#' @param s A list of stacks of General Circulation Models.
#' @param var_names Character. The names of the bioclimatic variables to compare.
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
#' compare_gcms(folder_future_rasters_gcms = "path/to/folder",
#' study_area = raster("path/to/raster"),
#' var_names = c('bio_1', 'bio_12'),
#' gcm_names = c('gcm1', 'gcm2', 'gcm3'),
#' k = 3)
#'
#' @import checkmate
#' @import cowplot
#' @import ggplot2
#' @import ggpubr
#' @import plyr
#' @import stats
#' @import utils
#' @importFrom factoextra fviz_cluster fviz_nbclust fviz_dend
#' @importFrom ggcorrplot ggcorrplot
#' @importFrom raster stack projectRaster mask crop
#'
#' @export
compare_gcms <- function(s, var_names=c('bio_1','bio_12'), study_area=NULL, k=3){

  assertList(s, types='RasterStack')
  assertCharacter(var_names, unique=T, any.missing=F)
  assertCount(k, positive = T)

  # Transform stacks
  x <- transform_gcms(s, var_names, study_area=study_area)
  flatten_vars <- flatten_gcms(x)

  # Calculate the distance matrix
  dist_matrix <- dist(t(flatten_vars))
  hm <- fviz_dist(
    dist_matrix,
    order = TRUE,
    show_labels = TRUE,
    lab_size = NULL,
    gradient = list(low = "#FDE725FF", mid = "#21908CFF", high = "#440154FF")) +
    ggtitle("Distance Matrix Heatmap")


  # Run K-means
  cl <- kmeans(dist_matrix, k, nstart=1000)

  # plot
  kmeans_plot <- fviz_cluster(cl,
                              data = dist_matrix,
                              palette = "jco",
                              ggtheme = theme_minimal(),
                              check_overlap = T,
                              main = "K-means Clustering Plot",
                              legend = 'none', repel = TRUE)

  # Run Hierarchical Cluster
  # hclust_plot <- hclust(dist_matrix)
  # Include elbow, silhouette and gap methods
  flatten_subset <- na.omit(flatten_vars)

  if(nrow(flatten_subset)>1000){
    n <- 1000
  } else {
    n <- nrow(flatten_subset)
  }

  flatten_subset <- flatten_subset[sample(nrow(flatten_subset), n),]
  #wss <- fviz_nbclust(flatten_subset, FUN = hcut, method = "wss")
  sil <- fviz_nbclust(flatten_subset, FUN = hcut, method = "silhouette")
  #gap <- fviz_gap_stat(flatten_subset, maxSE = list(method = "globalmax"))

  # Compute hierarchical clustering and cut into k clusters
  res <- hcut(t(flatten_subset), k = k)
  dend <- fviz_dend(res,
                    cex = 0.5,
                    ylim = c(max(res$height)*1.1/5*-1, max(res$height)*1.1),
                    palette="jco",
                    main = "Hierarchical Clustering")

  # Run Correlation
  #cor_matrix <- cor(flatten_vars, use='complete.obs')
  #cor_plot <- ggcorrplot(cor_matrix,
  #                       type='lower',
  #                       lab=T,
  #                       lab_size = 3,
  #                       hc.order=T,
  #                       hc.method = 'ward.D2',
  #                       show.legend = F,
  #                       title='Pearson Correlation')

  # Plot everything together
  #statistics_gcms <- plot_grid(kmeans_plot,
  #                             cor_plot,
  #                             dend,
  #                             plot_grid(wss,
  #                                       sil,
  #                                       ncol=1,
  #                                       labels=c("D", "E"),
  #                                       label_x = -0.05),
  #                             labels = c("A", "B", "C"),
  #                             ncol = 2,
  #                             rel_widths = 4)
  statistics_gcms <- plot_grid(kmeans_plot,
                               hm,
                               dend,
                               sil,
                               labels = c("A", "B", "C", "D"),
                               ncol = 2,
                               rel_widths = 4)
  gcms <- apply(cl$centers, 1, function(x){which.min(x) %>% names()})


  return(list(suggested_gcms=gcms,
              statistics_gcms=statistics_gcms))
}



