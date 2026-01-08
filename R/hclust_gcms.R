#' Hierarchical Clustering of GCMs
#'
#' This function performs hierarchical clustering on a random subset of raster values and produces a dendrogram visualization of the clusters.
#'
#' @param s A list of stacks of General Circulation Models (GCMs).
#' @param var_names Character. A vector of names of the variables to include, or 'all' to include all variables.
#' @param study_area An Extent object, or any object from which an Extent object can be extracted.
#' Defines the study area for cropping and masking the rasters.
#' @param scale Logical. Should the data be centered and scaled? Default is \code{TRUE}.
#' @param k Integer. The number of clusters to identify.
#' @param n Integer. The number of values to use in the clustering. If \code{NULL} (default), all data is used.
#'
#' @return A dendrogram visualizing the clusters and the suggested GCMs.
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
#' hclust_gcms(s, var_names, study_area, k = 4, n = 500)
#'
#' @import checkmate
#' @importFrom factoextra hcut fviz_dend
#' @importFrom stats dist
#'
#' @export
hclust_gcms <- function(s, var_names = c("bio_1", "bio_12"), study_area = NULL, scale = TRUE, k = 3, n = NULL) {
  if(is.list(s)){
    if(!is.data.frame(s[[1]])){
      checkmate::assertList(s, types = "SpatRaster")
    }
  }
  checkmate::assertCharacter(var_names, unique = TRUE, any.missing = FALSE)
  checkmate::assertCount(k, positive = TRUE)
  checkmate::assertCount(n, positive = TRUE, null.ok = TRUE)

  if ("all" %in% var_names) {
    var_names <- names(s[[1]])
  }

  if(!is.data.frame(s[[1]])){
    s <- transform_gcms(s, var_names, study_area)
    if (scale) {
      s <- lapply(s, function(x) {x <- as.data.frame(scale(x))})
    }
  }
  x <- flatten_gcms(s)
  x <- stats::na.omit(x)

  if (!is.null(n)) {
    flatten_subset <- x
    if (nrow(flatten_subset) > n) {
      x <- flatten_subset[sample(nrow(flatten_subset), n), ]
    }
  }

  res <- factoextra::hcut(t(x), k = k)

  mean_all <- sapply(s, function(y) {
    y <- colMeans(y, na.rm = TRUE)
  })
  mean_all <- rowMeans(mean_all)
  res2 <- vector()
  for (i in 1:k) {
    mean_cluster <- sapply(s[res$cluster==i], function(y) {
      y <- colMeans(y, na.rm = TRUE)
    })
    vals <- as.matrix(stats::dist(t(cbind(mean_cluster, mean_all))))[,"mean_all"]
    res2[i] <- names(which.min(vals[vals > 0]))
  }

  dend <- factoextra::fviz_dend(res,
    horiz = TRUE,
    cex = 0.8,
    palette = "jco",
    main = "Hierarchical Clustering",
    label_cols = ifelse(res$labels[res$order] %in% res2, "red", "black")
  )

  return(list(
    suggested_gcms = res2,
    dend_plot = dend
  ))
}
