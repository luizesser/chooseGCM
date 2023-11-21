#' Summarize General Circulation Model (GCM) data
#'
#' This function summarizes GCM data by calculating several statistics for each variable
#'
#' @param s A list of stacks of General Circulation Models.
#' @param var_names Character. A vector with names of the bioclimatic variables to compare OR 'all'.
#' @param study_area Extent object, or any object from which an Extent object can be extracted. A object that defines the study area for cropping and masking the rasters.
#'
#' @return a data frame with the summary statistics for each variable
#'
#' @seealso \code{\link{transform_gcms}}
#'
#' @author Luíz Fernando Esser (luizesser@gmail.com)
#' https://luizfesser.wordpress.com
#'
#' @examples
#' s <- list(stack("gcm1.tif"), stack("gcm2.tif"), stack("gcm3.tif"))
#' study_area <- extent(c(-57, -22, -48, -33))
#' var_names <- c("bio_1", "bio_12")
#' s <- transform_gcms(s, var_names, study_area)
#' summary_gcms(s)
#'
#' @import checkmate
#' @import dplyr
#' @import raster
#'
#' @export
summary_gcms <- function(s, var_names=c('bio_1','bio_12'), study_area=NULL){
  assertList(s, types='RasterStack')
  assertCharacter(var_names, unique=T, any.missing=F)

  if('all' %in% var_names){
    var_names <- names(s[[1]])
  }

  s2 <- transform_gcms(s, var_names, study_area)
  m <- sapply(s2, function(y){
                             df_m <- apply(y, 2, function(x) {
                               data.frame(min=min(x, na.rm=T),
                                          quantile_0.25=quantile(x, 0.25, na.rm=T),
                                          median=median(x, na.rm=T),
                                          mean=mean(x, na.rm=T),
                                          quantile_0.75=quantile(x, 0.75, na.rm=T),
                                          max=max(x, na.rm=T),
                                          sd=sd(x, na.rm=T),
                                          NAs=sum(is.na(x)),
                                          n_cells=length(x))
                               })
                             },
              USE.NAMES = T, simplify = F)
  #m <- m %>% as.data.frame() %>% t()
  m <- lapply(m, function(x){do.call(rbind, x)})
  return(m)
}
