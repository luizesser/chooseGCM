#' General Circulation Model (GCM) environmental distribution
#'
#' This function plots GCMs data in environmental space, possibly highlighting clusters or specific GCMs.
#'
#' @param s A list of stacks of General Circulation Models.
#' @param var_names Character. A vector with names of the bioclimatic variables to compare OR 'all'.
#' @param study_area Extent object, or any object from which an Extent object can be extracted. A object that defines the study area for cropping and masking the rasters.
#' @param highlight Character. A vector with names of gcms to be highlighted. In this case, the sum of all but chosen GCMs will appear in grey.
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
#' env_gcms(s, var_names, study_area, highlight='sum')
#' env_gcms(s, var_names, study_area, highlight=c("cr", "ml", "uk"))
#'
#' @import checkmate
#' @import dplyr
#' @import raster
#' @import ggplot2
#' @importFrom data.table melt
#'
#' @export
env_gcms <- function(s, var_names=c('bio_1','bio_12'), study_area=NULL, highlight='sum', resolution=25){
  assertList(s, types='RasterStack')
  assertCharacter(var_names, unique=T, any.missing=F)
  if(!is.null(highlight) & !all(highlight %in% c('sum', names(s)))){stop('highlight GCMs not found')}
  if(length(highlight)>1 & 'sum' %in% highlight){
    highlight <- 'sum'
    print('"sum" detected in highlights. Ploting the sum of GCMs.')
  }

  if('all' %in% var_names){
    var_names <- names(s[[1]])
  }

  s2 <- sapply(s, function(x){
    r <- stack(mask(crop(x[[c(var_names)]], study_area), study_area))
  }, simplify = FALSE, USE.NAMES = TRUE)

  createGrid <- function(x, y, x_bins, y_bins, resolution, sum=FALSE) {
    x <- na.omit(x)
    y <- na.omit(y)
    counts <- matrix(0, nrow = resolution, ncol = resolution)
    for (i in 1:length(x)) {
      x_index <- findInterval(x[i], x_bins)
      y_index <- findInterval(y[i], y_bins)
      if(sum){
        counts[x_index, y_index] <- ifelse(counts[x_index, y_index]>=0,1,0)
      } else{
        counts[x_index, y_index] <- ifelse(counts[x_index, y_index]>=0,1,0)
      }
    }
    return(counts)
  }

  x_bins <- seq(min(unlist(lapply(s2, function(x){min(x[[var_names[1]]][], na.rm=T)}))),
                max(unlist(lapply(s2, function(x){max(x[[var_names[1]]][], na.rm=T)}))),
                length.out = resolution )
  y_bins <- seq(min(unlist(lapply(s2, function(x){min(x[[var_names[2]]][], na.rm=T)}))),
                max(unlist(lapply(s2, function(x){max(x[[var_names[2]]][], na.rm=T)}))),
                length.out = resolution )

  if(is.null(highlight)){
    for (i in 1:length(s2)) {
      x <- s2[[i]][[var_names[1]]][]
      y <- s2[[i]][[var_names[2]]][]
      grid <- createGrid(x,y, x_bins,y_bins, resolution)
      grid <- ifelse(grid==0,NA,1)
      image(x_bins, y_bins, grid, col = colors[i], add = TRUE)
    }
    legend("topright",inset=c(-0.15,0), legend = names(s2), fill =  colors, cex = 0.8)

  } else if(all(highlight %in% names(s))){
    background <- do.call(rbind,lapply(s2, as.data.frame))
    x <- background[[var_names[1]]][]
    y <- background[[var_names[2]]][]
    grid_back <- createGrid(x,y, x_bins, y_bins, resolution)
    grid_back <- ifelse(grid_back==0,NA,1)
    colnames(grid_back) <- y_bins
    rownames(grid_back) <- x_bins
    grid_back <- suppressWarnings(data.table::melt(grid_back))
    colnames(grid_back) <- c('x', 'y','GCMs')
    grid_back$GCMs <- ifelse(grid_back$GCMs==1,'All', NA)
    s3 <- s2[highlight]
    for (i in 1:length(s3)) {
      x <- s3[[i]][[var_names[1]]][]
      y <- s3[[i]][[var_names[2]]][]
      grid <- createGrid(x,y, x_bins, y_bins, resolution)
      grid <- ifelse(grid==0,NA,1)
      colnames(grid) <- y_bins
      rownames(grid) <- x_bins
      suppressWarnings(grid <- data.table::melt(grid))
      colnames(grid) <- c('x', 'y','GCMs')
      grid$GCMs <- ifelse(grid$GCMs==1,names(s3)[i], NA)
      grid_back <- rbind(grid_back, grid)
    }
    res_plot <- ggplot(na.omit(grid_back), aes(x, y, fill = GCMs)) +
      geom_tile() +
      scale_fill_viridis_d(alpha=0.5) +
      labs(x = var_names[1], y = var_names[2], title = paste0("Selected GCMs coverage")) +
      theme_minimal()
  } else if(highlight == "sum"){
    for (i in 1:length(s2)) {
      x <- s2[[i]][[var_names[1]]][]
      y <- s2[[i]][[var_names[2]]][]
      grid <- createGrid(x,y, x_bins, y_bins, resolution)
      if(i==1){grid_sum <- grid} else {grid_sum <- grid_sum+grid}
    }
    grid_sum <- ifelse(grid_sum==0,NA,grid_sum[])
    colnames(grid_sum) <- y_bins
    rownames(grid_sum) <- x_bins
    grid_sum <- suppressWarnings(data.table::melt(grid_sum))
    colnames(grid_sum) <- c('x', 'y','GCMs')
    res_plot <- ggplot(na.omit(grid_sum), aes(x, y, fill = GCMs)) +
      geom_tile() +
      scale_fill_viridis_c() +
      labs(x = var_names[1], y = var_names[2], title = paste0("Sum of GCMs in Environmental Space")) +
      theme_minimal()
  }
  return(res_plot)
}
