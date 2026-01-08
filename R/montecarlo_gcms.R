#' Perform Monte Carlo Permutations on GCMs
#'
#' This function performs Monte Carlo permutations on a distance matrix and produces a violin plot showing the mean distance between subsets of the distance matrix.
#'
#' @param s A list of stacks of General Circulation Models (GCMs).
#' @param var_names Character. A vector of names of the variables to include, or 'all' to include all variables.
#' @param study_area An Extent object, or any object from which an Extent object can be extracted.
#' Defines the study area for cropping and masking the rasters.
#' @param scale Logical. Should the data be centered and scaled? Default is \code{TRUE}.
#' @param perm Integer. The number of permutations to perform.
#' @param dist_method Character. The method for distance matrix computation. Default is "euclidean." Possible values are:
#' "euclidean," "maximum," "manhattan," "canberra," "binary," or "minkowski." If \code{NULL}, clustering will be performed on the raw variable data.
#' @param clustering_method Character. The method for clustering. Default is "closestdist." Possible values are: "kmeans," "hclust," or "closestdist."
#' @param ... Additional arguments to pass to the clustering function.
#'
#' @return A violin plot showing the results. The dashed red line and red dots represent the mean absolute distance between subsets of GCMs using the clustering approach. The violin plot is generated from Monte Carlo permutations, selecting random subsets of GCMs from the provided set.
#'
#' @seealso \code{\link{hclust_gcms}} \code{\link{env_gcms}} \code{\link{kmeans_gcms}}
#'
#' @author Luíz Fernando Esser (luizesser@gmail.com)
#' https://luizfesser.wordpress.com
#'
#' @examples
#' var_names <- c("bio_1", "bio_12")
#' s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)[1:5]
#' study_area <- terra::ext(c(-80, -70, -50, -40)) |>
#'   terra::vect(crs="+proj=longlat +datum=WGS84 +no_defs")
#' montecarlo_gcms(s, var_names, study_area)
#'
#' @import checkmate
#' @import ggplot2
#' @importFrom usedist dist_subset
#' @importFrom terra crs project crop mask ext
#' @importFrom methods is as
#'
#' @export
montecarlo_gcms <- function(s, var_names = c("bio_1", "bio_12"), study_area = NULL, scale = TRUE,
                            perm = 10000, dist_method = "euclidean", clustering_method = "closestdist",
                            ...) {
  checkmate::assertCharacter(var_names, unique = TRUE, any.missing = FALSE)
  checkmate::assertSubset(var_names, c(names(s[[1]]), "all"))
  checkmate::assertCount(perm, positive = TRUE)
  checkmate::assertChoice(dist_method, c("euclidean", "maximum", "manhattan", "canberra", "minkowski"))
  checkmate::assertChoice(clustering_method, c("kmeans", "hclust", "closestdist"))

  if(is.list(s)){
    if(methods::is(s[[1]], "stars")){
      s <- sapply(s,
                  function(x){
                    x <- methods::as(x, "SpatRaster")
                    return(x)
                  },
                  USE.NAMES = TRUE,
                  simplify = FALSE)
    }
    if(methods::is(s[[1]], "RasterStack")){
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
    if(!methods::is(study_area, "SpatVector") & !methods::is(study_area, "Extent")){
      study_area <- methods::as(study_area, "SpatVector")
    }
    if(methods::is(study_area, "Extent")){
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
  mgcms_all <- mean(d)

  n <- length(s) - 1
  k <- NULL
  r <- replicate(perm, expr = {
    size <- sample(2:n, 1)
    gcms <- sample(names(s), size = size, replace = FALSE)
    df <- data.frame(k = size, mean = mean(usedist::dist_subset(d, gcms)))
    return(df)
  }, simplify = TRUE)
  r <- as.data.frame(t(r))
  r$k <- as.numeric(r$k)
  r$mean <- as.numeric(r$mean)

  df <- data.frame(k = NA, mean = NA)
  df2 <- list()
  if(clustering_method == "closestdist") {
    mean_diff <- list()
  }
  for (i in 2:n) {
    if(clustering_method == "kmeans") {
      m <- kmeans_gcms(s, var_names = var_names, k = i, method = dist_method, ...)$suggested_gcms
    }
    if(clustering_method == "hclust") {
      m <- hclust_gcms(s, var_names = var_names, k = i, ...)$suggested_gcms
    }
    if(clustering_method == "closestdist") {
      m2 <- closestdist_gcms(s, var_names = var_names, k = i, ...)
      mean_diff[[i]] <- m2$best_mean_diff
      m <- m2$suggested_gcms
    }
    df2[[i-1]] <- m
    m <- mean(usedist::dist_subset(d, m))
    df[i, ] <- c(i, m)
  }
  names(df2) <- paste0("k",2:n)
  df <- df[-1, ]

  r_plot <- r
  r_plot$mean <- abs(r_plot$mean-mgcms_all)

  df_plot <- df
  df_plot$mean <- abs(df_plot$mean-mgcms_all)

  if(clustering_method == "closestdist") {
    for (i in 3:length(mean_diff)) {
      if (mean_diff[[i]] >= mean_diff[[i - 1]]) {
        selected_k <- i-1
        break()
      }
    }
    if(!exists("selected_k")){
      i <- length(mean_diff)
    }
  }

  violin_plot <- ggplot2::ggplot(r_plot, ggplot2::aes(x = factor(k), y = mean, fill = factor(k))) +
    ggplot2::geom_violin() +
    ggplot2::geom_boxplot(width = 0.1, fill = "white") +
    ggplot2::geom_hline(yintercept = 0, color = "blue") +
    ggplot2::geom_line(data = df_plot, ggplot2::aes(x = k - 1, y = mean, group = 1), linetype = "dashed", color = "red") +
    ggplot2::geom_point(data = df_plot, ggplot2::aes(x = k - 1, y = mean, group = 1), color = "red") +
    ggplot2::xlab("Number of GCMs/Clusters") +
    ggplot2::ylab("Mean Absolute Distance from Global") +
    ggplot2::theme_minimal() +
    ggplot2::theme(legend.position = "none") +
    ggplot2::ggtitle(paste0("Monte Carlo Permutations - ", clustering_method))

  return(list(montecarlo_plot = violin_plot, suggested_gcms=df2))
}
