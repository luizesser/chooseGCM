#' Compute and plot correlation matrix for a set of General Circulation Models.
#'
#' @param s A list of stacks of General Circulation Models.
#' @param var_names Character. The names of the bioclimatic variables to compare.
#' @param study_area Extent object, or any object from which an Extent object can be extracted. A object that defines the study area for cropping and masking the rasters.
#' @param method The correlation method to use. Default is "pearson". Possible values are "pearson", "kendall" and "spearman".
#'
#' @return A correlation matrix plot.
#'
#' @seealso \code{\link{transform_gcms}} \code{\link{flatten_gcms}} \code{\link{summary_gcms}}
#'
#' @author Luíz Fernando Esser (luizesser@gmail.com)
#' https://luizfesser.wordpress.com
#'
#' @import ggcorrplot
#' @importFrom stringr str_to_title
#'
#' @examples
#' s <- list(stack("gcm1.tif"), stack("gcm2.tif"), stack("gcm3.tif"))
#' study_area <- extent(c(-57, -22, -48, -33))
#' var_names <- c("bio_1", "bio_12")
#' s <- transform_gcms(s, var_names, study_area)
#' flattened_gcms <- flatten_gcms(s)
#' cor_gcms(quick_example, method = "spearman")
#'
#' @export
cor_gcms <- function(s, var_names, study_area=NULL, method = "pearson"){
  assertList(s, types='RasterStack')
  assertCharacter(var_names, unique=T, any.missing=F)
  assertChoice(method, c("pearson", "kendall", "spearman"))

  x <- transform_gcms(s, var_names, study_area)
  x <- flatten_gcms(x)
  cor_matrix <- cor(as.matrix(x), use='complete.obs', method = method)
  cor_plot <- ggcorrplot(cor_matrix,
                         method='circle',
                         type='lower',
                         lab=T,
                         lab_size = 3,
                         hc.order=T,
                         hc.method = 'ward.D2',
                         show.legend = F,
                         title=paste0(stringr::str_to_title(method),' Correlation'))
}
