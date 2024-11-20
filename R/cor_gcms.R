#' Compute and Plot Correlation Matrix for a Set of General Circulation Models
#'
#' This function computes and visualizes the correlation matrix for a set of General Circulation Models (GCMs) based on their variables.
#'
#' @param s A list of stacks of General Circulation Models (GCMs).
#' @param var_names Character. A vector with names of the variables to compare, or 'all' to include all variables.
#' @param study_area An Extent object, or any object from which an Extent object can be extracted. Defines the study area for cropping and masking the rasters.
#' @param scale Logical. Whether to apply centering and scaling to the data. Default is \code{TRUE}.
#' @param method Character. The correlation method to use. Default is "pearson". Possible values are: "pearson", "kendall", or "spearman".
#'
#' @return A list containing two items: \code{cor_matrix} (the calculated correlations between GCMs) and \code{cor_plot} (a plot visualizing the correlation matrix).
#'
#' @seealso \code{\link{transform_gcms}} \code{\link{flatten_gcms}} \code{\link{summary_gcms}}
#'
#' @author Luíz Fernando Esser (luizesser@gmail.com)
#' https://luizfesser.wordpress.com
#'
#' @examples
#' var_names <- c("bio_1", "bio_12")
#' s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)
#' study_area <- terra::ext(c(-80, -30, -50, 10)) |> terra::vect(crs="epsg:4326")
#' cor_gcms(s, var_names, study_area, method = "pearson")
#'
#' @import checkmate
#' @importFrom ggcorrplot ggcorrplot
#' @importFrom ggplot2 scale_fill_viridis_c
#'
#' @export
cor_gcms <- function(s, var_names = c("bio_1", "bio_12"), study_area = NULL, scale = TRUE, method = "pearson") {
  if(is.list(s)){
    if(!is.data.frame(s[[1]])){
      checkmate::assertList(s, types = "SpatRaster")
    }
  }
  checkmate::assertCharacter(var_names, unique = TRUE, any.missing = FALSE)
  checkmate::assertChoice(method, c("pearson", "kendall", "spearman"))

  if ("all" %in% var_names) {
    var_names <- names(s[[1]])
  }

  if(!is.data.frame(s[[1]])){
    x <- transform_gcms(s, var_names, study_area)
  }
  x <- flatten_gcms(x)
  cor_matrix <- stats::cor(as.matrix(x), use = "complete.obs", method = method)
  title <- paste0(method, " Correlation")
  substr(title, 1, 1) <- toupper(substr(title, 1, 1))
  cor_plot <- ggcorrplot::ggcorrplot(cor_matrix,
                         type = "lower",
                         lab = TRUE,
                         lab_size = 3,
                         hc.order = TRUE,
                         hc.method = "ward.D2",
                         show.legend = FALSE,
                         title = title
  ) + ggplot2::scale_fill_viridis_c(limit = c(NA,NA))

  return(list(
    cor_matrix = cor_matrix,
    cor_plot = cor_plot
  ))
}
