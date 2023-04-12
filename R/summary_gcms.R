#' Summarize General Circulation Model (GCM) data
#'
#' This function summarizes GCM data by calculating several statistics for each variable
#'
#' @param s a transformed list of stacks representing GCM data
#' @return a data frame with the summary statistics for each variable
#'
#' @examples
#' s <- list(stack("file1.nc"), stack("file2.nc"))
#' summary_gcms(s)
#'
#' @import raster
#' @import dplyr
#'
#' @export
#'
#' @keywords GCM, summary, raster
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
#' @export
summary_gcms <- function(s){
  s <- lapply(s, function(x) data.frame(raster::values(x)))
  m <- sapply(s, function(y){
                             apply(y, 2, function(x) {
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
