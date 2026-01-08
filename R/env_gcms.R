#' General Circulation Model (GCM) Environmental Distribution
#'
#' This function visualizes GCM data in environmental space, with options to highlight clusters or specific GCMs.
#'
#' @param s A list of stacks of General Circulation Models (GCMs).
#' @param var_names Character. A vector of names of the variables to include, or 'all' to include all variables.
#' @param study_area An Extent object, or any object from which an Extent object can be extracted. Defines the study area for cropping and masking the rasters.
#' @param highlight Character. A vector of GCM names to be highlighted. All other GCMs will appear in grey.
#' @param resolution Numeric. The resolution to be used in the plot. Default is \code{25}.
#' @param title Character. The title of the plot.
#'
#' @return A plot displaying the environmental space for the specified GCMs.
#'
#' @seealso \code{\link{summary_gcms}}
#'
#' @author Luíz Fernando Esser (luizesser@gmail.com)
#' https://luizfesser.wordpress.com
#'
#' @examples
#' var_names <- c("bio_1", "bio_12")
#' s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)[1:5]
#' study_area <- terra::ext(c(-80, -70, -50, -40)) |>
#'   terra::vect(crs="+proj=longlat +datum=WGS84 +no_defs")
#' env_gcms(s, var_names, study_area, highlight = c("ae", "ch", "cr"))
#'
#' @import checkmate
#' @import ggplot2
#' @importFrom reshape2 melt
#' @importFrom terra rast ext crs project mask crop vect
#' @importFrom methods is as
#' @importFrom graphics image
#'
#' @export
env_gcms <- function(s, var_names = c("bio_1", "bio_12"), study_area = NULL, highlight = "sum", resolution = 25, title = NULL) {
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
                    x <- terra::rast(x)
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

  if(is.list(s)){
    if(!is.data.frame(s[[1]])){
      checkmate::assertList(s, types = "SpatRaster")
    }
  }
  checkmate::assertCharacter(var_names, unique = TRUE, any.missing = FALSE)
  checkmate::assertSubset(var_names, c(names(s[[1]]), "all"))

  if (!is.null(highlight) & !all(highlight %in% c("sum", names(s)))) {
    stop("highlight GCMs not found")
  }
  if (length(highlight) > 1 & "sum" %in% highlight) {
    highlight <- "sum"
  }

  if ("all" %in% var_names) {
    var_names <- names(s[[1]])
  }

  if(!is.null(study_area)){
    if(!terra::crs(s[[1]]) == terra::crs(study_area)) {
      study_area <- terra::project(study_area, terra::crs(s[[1]]))
    }
  }

  s2 <- sapply(s, function(x){
    x <- x[[var_names]]
    if(!is.null(study_area)){
      x <- terra::mask(terra::crop(x, study_area), study_area)
    }
    return(x)
  }, USE.NAMES = TRUE, simplify = FALSE)

  createGrid <- function(x, y, x_bins, y_bins, resolution, sum = FALSE) {
    x <- stats::na.omit(x)
    y <- stats::na.omit(y)
    counts <- matrix(0, nrow = resolution, ncol = resolution)
    for (i in 1:length(x)) {
      x_index <- findInterval(x[i], x_bins)
      y_index <- findInterval(y[i], y_bins)
      if (sum) {
        counts[x_index, y_index] <- ifelse(counts[x_index, y_index] >= 0, 1, 0)
      } else {
        counts[x_index, y_index] <- ifelse(counts[x_index, y_index] >= 0, 1, 0)
      }
    }
    return(counts)
  }

  x_bins <- seq(
    min(unlist(lapply(s2, function(x) {
      min(x[[var_names[1]]][], na.rm = TRUE)
    }))),
    max(unlist(lapply(s2, function(x) {
      max(x[[var_names[1]]][], na.rm = TRUE)
    }))),
    length.out = resolution
  )
  y_bins <- seq(
    min(unlist(lapply(s2, function(x) {
      min(x[[var_names[2]]][], na.rm = TRUE)
    }))),
    max(unlist(lapply(s2, function(x) {
      max(x[[var_names[2]]][], na.rm = TRUE)
    }))),
    length.out = resolution
  )

  if (is.null(highlight)) {
    for (i in 1:length(s2)) {
      x <- s2[[i]][[var_names[1]]][]
      y <- s2[[i]][[var_names[2]]][]
      grid <- createGrid(x, y, x_bins, y_bins, resolution)
      grid <- ifelse(grid == 0, NA, 1)
      graphics::image(x_bins, y_bins, grid, col = .data$colors[i], add = TRUE)
    }
    graphics::legend("topright", inset = c(-0.15, 0), legend = names(s2), fill = .data$colors, cex = 0.8)
  } else if (all(highlight %in% names(s))) {
    if(is.null(title)){
      title <- paste0("Selected GCMs coverage")
    }
    background <- do.call(rbind, lapply(s2, as.data.frame))
    x <- background[[var_names[1]]][]
    y <- background[[var_names[2]]][]
    grid_back <- createGrid(x, y, x_bins, y_bins, resolution)
    grid_back <- ifelse(grid_back == 0, NA, 1)
    colnames(grid_back) <- y_bins
    rownames(grid_back) <- x_bins
    grid_back <- suppressWarnings(reshape2::melt(grid_back))
    colnames(grid_back) <- c("x", "y", "GCMs")
    grid_back$GCMs <- ifelse(grid_back$GCMs == 1, "All", NA)
    s3 <- s2[highlight]
    for (i in 1:length(s3)) {
      x <- s3[[i]][[var_names[1]]][]
      y <- s3[[i]][[var_names[2]]][]
      grid <- createGrid(x, y, x_bins, y_bins, resolution)
      grid <- ifelse(grid == 0, NA, 1)
      colnames(grid) <- y_bins
      rownames(grid) <- x_bins
      suppressWarnings(grid <- reshape2::melt(grid))
      colnames(grid) <- c("x", "y", "GCMs")
      grid$GCMs <- ifelse(grid$GCMs == 1, names(s3)[i], NA)
      grid_back <- rbind(grid_back, grid)
    }
    grid_back$GCMs <- factor(grid_back$GCMs, levels = c("All", highlight))
    res_plot <- ggplot2::ggplot(stats::na.omit(grid_back), ggplot2::aes(x, y, fill = .data$GCMs)) +
      ggplot2::geom_tile() +
      ggplot2::scale_fill_viridis_d(alpha = 0.5) +
      ggplot2::labs(x = var_names[1], y = var_names[2], title = title) +
      ggplot2::theme_minimal()
  } else if (highlight == "sum") {
    if(is.null(title)){
      title <- paste0("Sum of GCMs in Environmental Space")
    }
    for (i in 1:length(s2)) {
      x <- s2[[i]][[var_names[1]]][]
      y <- s2[[i]][[var_names[2]]][]
      grid <- createGrid(x, y, x_bins, y_bins, resolution)
      if (i == 1) {
        grid_sum <- grid
      } else {
        grid_sum <- grid_sum + grid
      }
    }
    grid_sum <- ifelse(grid_sum == 0, NA, grid_sum[])
    colnames(grid_sum) <- y_bins
    rownames(grid_sum) <- x_bins
    grid_sum <- suppressWarnings(reshape2::melt(grid_sum))
    colnames(grid_sum) <- c("x", "y", "GCMs")

    res_plot <- ggplot2::ggplot(stats::na.omit(grid_sum), ggplot2::aes(x, y, fill = .data$GCMs)) +
      ggplot2::geom_tile() +
      ggplot2::scale_fill_viridis_c() +
      ggplot2::labs(x = var_names[1], y = var_names[2], title = title) +
      ggplot2::theme_minimal()
  }
  return(res_plot)
}
