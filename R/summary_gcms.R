#' Summarize General Circulation Model (GCM) Data
#'
#' This function summarizes GCM data by calculating various statistics for each variable.
#'
#' @param s A list of stacks of General Circulation Models (GCMs).
#' @param var_names Character. A vector of names of the variables to include, or 'all' to include all variables.
#' @param study_area An Extent object, or any object from which an Extent object can be extracted.
#' Defines the study area for cropping and masking the rasters.
#'
#' @return A data frame containing the summary statistics for each variable.
#'
#' @seealso \code{\link{transform_gcms}}
#'
#' @author Luíz Fernando Esser (luizesser@gmail.com)
#' https://luizfesser.wordpress.com
#'
#' @examples
#' var_names <- c("bio_1", "bio_12")
#' s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)
#' study_area <- terra::ext(c(-80, -30, -50, 10)) |> terra::vect(crs="epsg:4326")
#' summary_gcms(s, var_names, study_area)
#'
#' @import checkmate
#' @importFrom stats quantile median sd
#'
#' @export
summary_gcms <- function(s, var_names = c("bio_1", "bio_12"), study_area = NULL) {
  if(is.list(s)){
    if(!is.data.frame(s[[1]])){
      checkmate::assertList(s, types = "SpatRaster")
    }
  }
  checkmate::assertCharacter(var_names, unique = TRUE, any.missing = FALSE)

  if ("all" %in% var_names) {
    var_names <- names(s[[1]])
  }
  if(!is.data.frame(s[[1]])){
    s2 <- transform_gcms(s, var_names, study_area)
  }
  m <- sapply(s2, function(y) {
    df_m <- apply(y, 2, function(x) {
      data.frame(
        min = min(x, na.rm = TRUE),
        quantile_0.25 = stats::quantile(x, 0.25, na.rm = TRUE),
        median = median(x, na.rm = TRUE),
        mean = mean(x, na.rm = TRUE),
        quantile_0.75 = stats::quantile(x, 0.75, na.rm = TRUE),
        max = max(x, na.rm = TRUE),
        sd = stats::sd(x, na.rm = TRUE),
        NAs = sum(is.na(x)),
        n_cells = length(x)
      )
    })
  },
  USE.NAMES = TRUE, simplify = FALSE
  )
  # m <- m %>% as.data.frame() %>% t()
  m <- lapply(m, function(x) {
    do.call(rbind, x)
  })
  return(m)
}
