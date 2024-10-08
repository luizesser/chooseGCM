#' Distance between GCMs
#'
#' This function compares future climate projections from multiple Global Circulation Models (GCMs) based on their similarity in terms of variables.
#'
#' @param s A list of stacks of General Circulation Models.
#' @param var_names Character. A vector with names of the bioclimatic variables to compare OR 'all'.
#' @param study_area Extent object, or any object from which an Extent object can be extracted. A object that defines the study area for cropping and masking the rasters.
#' @param method The correlation method to use. Default is "euclidean". Possible values are "euclidean", "maximum", "manhattan", "canberra", "binary", "minkowski", "pearson", "spearman" or "kendall".
#'
#' @return Set of two GCMs that have mean distance closer to the mean of all GCMs provided in s.
#'
#' @seealso \code{\link{transform_gcms}} \code{\link{flatten_gcms}}
#'
#' @author Luíz Fernando Esser (luizesser@gmail.com)
#' https://luizfesser.wordpress.com
#'
#' @examples
#' \dontrun{
#' s <- list(stack("gcm1.tif"), stack("gcm2.tif"), stack("gcm3.tif"))
#' study_area <- extent(c(-57, -22, -48, -33))
#' var_names <- c("bio_1", "bio_12")
#'
#' closestdist_gcms(s, method = "euclidean")
#' }
#'
#' @import checkmate
#' @importFrom factoextra fviz_dist get_dist
#'
#' @export
closestdist_gcms <- function(s, var_names = c("bio_1", "bio_12"), study_area = NULL, method = "euclidean") {
  if(is.list(s)){
    if(!is.data.frame(s[[1]])){
      checkmate::assertList(s, types = "SpatRaster")
    }
  }
  checkmate::assertCharacter(var_names, unique = T, any.missing = F)
  checkmate::assertChoice(method, c("euclidean", "maximum", "manhattan", "canberra", "binary", "minkowski", "pearson", "spearman", "kendall"), null.ok = TRUE)
  d <- chooseGCM::dist_gcms(s=s, var_names=var_names, method=method, study_area=study_area)
  mean_d <- mean(d$distances)
  dmat <- as.matrix(d$distances)
  dmat_abs <- abs(dmat-mean_d)
  ind <- which(dmat_abs == min(dmat_abs),  arr.ind = TRUE)
  return(rownames(ind))
}
