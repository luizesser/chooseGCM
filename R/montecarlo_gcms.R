#' Perform Monte Carlo permutations on GCMs
#'
#' This function performs Monte Carlo permutations on a distance matrix and produces a violin plot of the resulting mean distance between subsets of the distance matrix.
#'
#' @param s A list of stacks of General Circulation Models.
#' @param var_names Character. A vector with names of the bioclimatic variables to compare OR 'all'.
#' @param study_area Extent object, or any object from which an Extent object can be extracted. A object that defines the study area for cropping and masking the rasters.
#' @param scale Boolean. Apply center and scale in data? Default is TRUE.
#' @param perm Number of permutations.
#' @param dist_method The method for distance matrix computation. Standard value is "euclidean". Possible values are: "euclidean", "maximum", "manhattan", "canberra", "binary" or "minkowski". If NULL, will perform the clustering on raw variables data.
#' @param clustering_method The method for clustering. Standard value is "kmeans". Possible values are: "kmeans" or "hclust".
#'
#' @return A violin plot of the result. Dashed red line and red dots represent the mean distance between selected GCMs using the kmeans approach. The blue line is the mean distance between all GCMs (i.e. using all available GCMs). Violin plot is built with Monte Carlo permutations, selecting random subsets of GCMs from the given set.
#'
#' @seealso \code{\link{hclust_gcms}} \code{\link{env_gcms}} \code{\link{kmeans_gcms}}
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
#' montecarlo_gcms(s, study_area = study_area)
#' }
#'
#' @import checkmate
#' @import ggplot2
#' @importFrom usedist dist_subset
#' @importFrom terra crs project crop mask ext
#'
#' @export
montecarlo_gcms <- function(s, var_names = c("bio_1", "bio_12"), study_area = NULL, scale = TRUE, perm = 10000, dist_method = "euclidean", clustering_method = "kmeans") {
  checkmate::assertCharacter(var_names, unique = T, any.missing = F)
  checkmate::assertSubset(var_names, c(names(s[[1]]), "all"))
  checkmate::assertCount(perm, positive = T)
  checkmate::assertChoice(dist_method, c("euclidean", "maximum", "manhattan", "canberra", "minkowski"))
  checkmate::assertChoice(clust_method, c("kmeans", "hclust"))

  if(is.list(s)){
    if(is(s[[1]], "stars")){
      s <- sapply(s,
                  function(x){
                    x <- as(x, "SpatRaster")
                    return(x)
                  },
                  USE.NAMES = TRUE,
                  simplify = FALSE)
    }
    if(is(s[[1]], "RasterStack")){
      s <- sapply(s,
                  function(x){
                    x <- rast(x)
                    return(x)
                  },
                  USE.NAMES = TRUE,
                  simplify = FALSE)
    }
  }

  if(!is.null(study_area)){
    if(!is(study_area, "SpatVector") & !is(study_area, "Extent")){
      study_area <- as(study_area, "SpatVector")
    }
    if(is(study_area, "Extent")){
      study_area <- terra::ext(study_area)
    }
  }

  if(!class(study_area) %in% c("SpatVector", "SpatExtent")) {
    checkmate::assertClass(study_area, classes = c("SpatVector"), null.ok = TRUE)
  }
  checkmate::assertList(s, types = "SpatRaster")

  if ("all" %in% var_names) {
    var_names <- names(s[[1]])
  }

  if(!is.null(study_area)){
    if(!terra::crs(s[[1]]) == terra::crs(study_area)) {
      study_area <- terra::project(study_area, terra::crs(s[[1]]))
    }
  }

  if(!is.null(study_area)){
    s <- sapply(s, function(x) {
      x <- terra::mask(terra::crop(x, study_area), study_area)
    }, simplify = FALSE, USE.NAMES = TRUE)
  }

  if(!is.data.frame(s[[1]])){
    s <- transform_gcms(s, var_names, study_area)
    if (scale) {
      s <- lapply(s, function(x) {x <- as.data.frame(scale(x))})
    }
  }

  d <- dist_gcms(s, var_names = var_names, method = dist_method)$distances
  n <- length(s) - 1
  k <- NULL
  r <- replicate(perm, expr = {
    size <- sample(2:n, 1)
    gcms <- sample(names(s), size = size, replace = F)
    df <- data.frame(k = size, mean = mean(usedist::dist_subset(d, gcms)))
    return(df)
  }, simplify = T)
  r <- as.data.frame(t(r))
  r$k <- as.numeric(r$k)
  r$mean <- as.numeric(r$mean)
  mgcms_all <- mean(d)

  df <- data.frame(k = NA, mean = NA)
  df2 <- list()
  for (i in 2:n) {
    if(clustering_method == "kmeans") {
      m <- kmeans_gcms(s, var_names = var_names, k = i, method = dist_method)$suggested_gcms
    }
    if(clustering_method == "hclust") {
      m <- hclust_gcms(s, var_names = var_names, k = i)$suggested_gcms
    }
    df2[[i-1]] <- m
    m <- mean(usedist::dist_subset(d, m))
    df[i, ] <- c(i, m)
  }
  names(df2) <- paste0("k=",2:n)
  df <- df[-1, ]

  violin_plot <- ggplot2::ggplot(r, ggplot2::aes(x = factor(k), y = mean, fill = factor(k))) +
    ggplot2::geom_violin() +
    ggplot2::geom_boxplot(width = 0.1, fill = "white") +
    ggplot2::geom_hline(yintercept = mgcms_all, color = "blue") +
    ggplot2::geom_line(data = df, ggplot2::aes(x = k - 1, y = mean, group = 1), linetype = "dashed", color = "red") +
    ggplot2::geom_point(data = df, ggplot2::aes(x = k - 1, y = mean, group = 1), color = "red") +
    ggplot2::xlab("Number of GCMs/Clusters") +
    ggplot2::ylab("Mean Distance") +
    ggplot2::theme_minimal() +
    ggplot2::theme(legend.position = "none") +
    ggplot2::ggtitle("Monte Carlo Permutations")

  return(list(montecarlo_plot = violin_plot, all_kmeans=df2))
}
