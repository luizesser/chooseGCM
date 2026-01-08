#' Perform K-Means Clustering on GCMs
#'
#' This function performs k-means clustering on a distance matrix and produces a scatter plot of the resulting clusters.
#'
#' @param s A list of stacks of General Circulation Models (GCMs).
#' @param var_names Character. A vector of names of the variables to include, or 'all' to include all variables.
#' @param study_area An Extent object, or any object from which an Extent object can be extracted.
#' Defines the study area for cropping and masking the rasters.
#' @param scale Logical. Should the data be centered and scaled? Default is \code{TRUE}.
#' @param k Integer. The number of clusters to create.
#' @param method Character. The method for distance matrix computation. Default is "euclidean." Possible values are:
#' "euclidean," "maximum," "manhattan," "canberra," "binary," or "minkowski." If \code{NULL}, clustering will be performed on the raw variable data.
#'
#' @return A scatter plot showing the resulting clusters and the suggested GCMs.
#'
#' @seealso \code{\link{transform_gcms}} \code{\link{flatten_gcms}}
#'
#' @author Luíz Fernando Esser (luizesser@gmail.com)
#' https://luizfesser.wordpress.com
#'
#' @examples
#' var_names <- c("bio_1", "bio_12")
#' s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)[1:5]
#' study_area <- terra::ext(c(-80, -70, -50, -40)) |>
#'   terra::vect(crs="+proj=longlat +datum=WGS84 +no_defs")
#' kmeans_gcms(s, var_names, study_area, k = 3)
#'
#' @import checkmate
#' @import ggplot2
#' @importFrom factoextra fviz_cluster
#' @importFrom stats dist
#'
#' @export
kmeans_gcms <- function(s, var_names = c("bio_1", "bio_12"), study_area = NULL, scale = TRUE, k = 3, method = NULL) {
  if(is.list(s)){
    if(!is.data.frame(s[[1]])){
      checkmate::assertList(s, types = "SpatRaster")
    }
  }
  checkmate::assertCharacter(var_names, unique = TRUE, any.missing = FALSE)
  checkmate::assertCount(k, positive = TRUE)

  if ("all" %in% var_names) {
    var_names <- names(s[[1]])
  }

  if (is.null(method)) {
    # Scale and calculate the means from variables.
    if(!is.data.frame(s[[1]])){
      s <- transform_gcms(s, var_names, study_area)
      if (scale) {
        s <- lapply(s, function(x) {x <- as.data.frame(scale(x))})
      }
    }
    flatten_vars <- sapply(s, function(y) {
      y <- colMeans(y, na.rm = TRUE)
    })

    # Run K-means
    cl <- stats::kmeans(t(flatten_vars), k, nstart = 10000, iter.max = 1000)

    gcms <- vector()
    gcms_mat <- as.matrix(stats::dist(t(cbind(t(cl$centers), flatten_vars))))[-c(1:k), c(1:k)]
    gcms_dist <- apply(gcms_mat, 2, min)[1:k]
    for (i in 1:length(gcms_dist)) {
      v <- names(which(gcms_mat[, i] == gcms_dist[i]))
      v <- ifelse(length(v) > 1, v[1], v)
      gcms[i] <- v
    }

    # plot
    kmeans_plot <- factoextra::fviz_cluster(cl,
      data = t(flatten_vars),
      palette = "jco",
      ggtheme = ggplot2::theme_minimal(),
      main = "K-means Clustering Plot",
      legend = "none"
    )
  } else {
    checkmate::assertChoice(method, c("euclidean", "maximum", "manhattan", "canberra", "binary", "minkowski"))

    # Scale and flatten variables into one column.
    if(!is.data.frame(s[[1]])){
      s <- transform_gcms(s, var_names, study_area)
      if (scale) {
        s <- lapply(s, function(x) {x <- as.data.frame(scale(x))})
      }
    }
    flatten_vars <- flatten_gcms(s)

    # Calculate the distance matrix
    dist_matrix <- stats::dist(t(flatten_vars), method = method)

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
      check_overlap = TRUE,
      main = "K-means Clustering Plot",
      legend = "none",
      repel = TRUE,
      label.select = NA) +
      ggplot2::geom_text(ggplot2::aes(label = ifelse(colnames(cl$centers) %in% gcms, colnames(cl$centers), "")),
                color = "red",
                vjust = -1.5,
                size = 6) +
      ggplot2::geom_text(ggplot2::aes(label = ifelse(!colnames(cl$centers) %in% gcms, colnames(cl$centers), "")),
                         color = "black",
                         vjust = -1.5,
                         size = 4)

  }

  return(list(
    suggested_gcms = gcms,
    kmeans_plot = kmeans_plot
  ))
}
