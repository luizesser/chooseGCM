#' Perform Monte Carlo permutations on GCMs
#'
#' This function performs Monte Carlo permutations on a distance matrix and produces a violin plot of the resulting mean distance between subsets of the distance matrix.
#'
#' @param s A list of stacks of General Circulation Models.
#' @param var_names Character. A vector with names of the bioclimatic variables to compare OR 'all'.
#' @param study_area Extent object, or any object from which an Extent object can be extracted. A object that defines the study area for cropping and masking the rasters.
#' @param perm Number of permutations.
#' @param method The method for distance matrix computation. Standard value is "euclidean". Possible values are: "euclidean", "maximum", "manhattan", "canberra", "binary" or "minkowski". If NULL, will perform the clustering on raw variables data.
#'
#' @return A violin plot of the result. Dashed red line and red dots represent the mean distance between selected GCMs using the kmeans approach. The blue line is the mean distance between all GCMs (i.e. using all available GCMs). Violin plot is built with Monte Carlo permutations, selecting random subsets of GCMs from the given set.
#'
#' @seealso \code{\link{transform_gcms}} \code{\link{flatten_gcms}} \code{\link{kmeans_gcms}}
#'
#' @author Luíz Fernando Esser (luizesser@gmail.com)
#' https://luizfesser.wordpress.com
#'
#' @examples
#'
#' s <- list(stack("gcm1.tif"), stack("gcm2.tif"), stack("gcm3.tif"))
#' study_area <- extent(c(-57, -22, -48, -33))
#' var_names <- c("bio_1", "bio_12")
#'
#' montecarlo_gcms(s, study_area=study_area)
#'
#' @import checkmate
#' @import ggplot2
#' @importFrom usedist dist_subset
#'
#' @export
montecarlo_gcms <- function(s, var_names=c('bio_1','bio_12'), study_area=NULL, perm=10000, method='euclidean'){
  assertList(s, types='RasterStack')
  assertCharacter(var_names, unique=T, any.missing=F)
  assertCount(perm, positive = T)
  assertChoice(method, c("euclidean", "maximum", "manhattan", "canberra", "binary", "minkowski"))

  if('all' %in% var_names){
    var_names <- names(s[[1]])
  }

  s <- sapply(s, function(x){x <- stack(mask(crop(x,study_area),study_area))}, simplify = FALSE, USE.NAMES = TRUE)

  d <- dist_gcms(s, var_names = var_names, method = method)$distances
  n <- length(s)-1
  r <- replicate(perm,expr = {
    size <- sample(2:n, 1)
    gcms <- sample(names(s), size=size, replace = F)
    df <- data.frame(k=size, mean=mean(dist_subset(d,gcms)))
    return(df)
  }, simplify = T)
  r <- as.data.frame(t(r))
  r$k <- as.numeric(r$k)
  r$mean <- as.numeric(r$mean)
  mgcms_all <- mean(d)

  df <- data.frame(k=NA, mean=NA)
  for(i in 2:n){
    m <- kmeans_gcms(s, var_names = var_names, k = i, method = method)$suggested_gcms
    m <- mean(dist_subset(d,m))
    df[i,] <- c(i, m)
  }
  df <- df[-1,]

  violin_plot <- ggplot(r, aes(x=factor(k), y=mean, fill=factor(k))) +
    geom_violin() +
    geom_boxplot(width=0.1, fill='white') +
    geom_hline(yintercept=mgcms_all, color = "blue") +
    geom_line(data=df, aes(x=k-1, y=mean, group=1), linetype = "dashed", color="red") +
    geom_point(data=df, aes(x=k-1, y=mean, group=1), color="red") +
    xlab('Number of GCMs/Clusters') +
    ylab('Mean Distance') +
    theme_minimal() +
    theme(legend.position = "none") +
    ggtitle('Monte Carlo Permutations')

  return(list(montecarlo_plot=violin_plot))
}



