#' Compare GCMS
#'
#' This function compares future climate projections from multiple Global Circulation Models (GCMs) based on their similarity in terms of bioclimatic variables. The function clusters the GCMs using k-means clustering and hierarchical clustering, calculates the Pearson correlation matrix, and generates plots for the clusters and the correlation matrix.
#'
#' @param folder_future_rasters_gcms Character. Path to the folder containing the future stack files for the GCMs.
#' @param grid_study_area Extent object, or any object from which an Extent object can be extracted. A object that defines the study area for cropping and masking the rasters.
#' @param var_names Character. The names of the bioclimatic variables to compare.
#' @param gcm_names Character. The names of the GCMs to include in the analysis.
#' @param k Numeric. The number of clusters to use for k-means clustering.
#' @return A list with two items: suggested_gcms (the names of the GCMs suggested for further analysis) and statistics_gcms (a grid of plots).
#'
#' @examples
#' # compare GCMS
#' compare_gcms(folder_future_rasters_gcms = "path/to/folder",
#' grid_study_area = raster("path/to/raster"),
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
compare_gcms <- function(folder_future_rasters_gcms, grid_study_area, var_names=c('bio_1','bio_12'), gcm_names, k=3){
  # Get stacks files
  l <- list.files(folder_future_rasters_gcms, pattern='.tif', rec=T, full.names = T)
  # Import stacks
  s <- lapply(l[grep(gcm_names,l)], function(x){s <- stack(x)
                                                    names(s) <- paste0('bio_',1:19) # Rename rasters
                                                    return(s)})
  # Name list itens
  names(s) <- sort(gcm_names)

  # Transform stacks
  s <- sapply(s, function(x){# Subset stacks to keep only var_names
    x <- x[[var_names]]
    # Reproject to match grid_study_area crs.
    if(!as.character(crs(x))==as.character(CRS(crs(grid_study_area)))){
      x <- projectRaster(x, crs=CRS(crs(grid_study_area)))
    }
    # Crop and mask stacks
    x <- mask(crop(x, grid_study_area),grid_study_area)
    # Transform in data.frames
    x <- x %>% as.data.frame()
    return(x)},
    USE.NAMES = T,
    simplify = F)

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



