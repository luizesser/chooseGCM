#' Import GCM data to R
#'
#' This function imports GCM stack files from folder to R.
#'
#' @param path A string with the path to GCM files.
#' @param extension Extension of stack files. Standard is ".tif", which is the extension from WorldClim 2.1.
#' @param recursive Logical. Should the function import stacks recursively (i.e. search files from folders within folders)? Standard is TRUE.
#' @param gcm_names A vector with names to be addressed to each GCM. S
#'
#' @return A list of stacks, with each element of the list corresponding to a GCM from given path.
#'
#' @seealso \code{\link{WorldClim_data}}
#'
#' @author Luíz Fernando Esser (luizesser@gmail.com)
#' https://luizfesser.wordpress.com
#'
#' @examples
#' s <- import_gcms(path='input_data/WorldClim_data_future', extension=".tif", recursive=TRUE, gcm_names=NULL)
#' study_area <- extent(c(-57, -22, -48, -33))
#' var_names <- c("bio_1", "bio_12")
#' t <- transform_gcms(s, var_names, study_area)
#'
#' @import checkmate
#' @import raster
#'
#' @export
import_gcms <- function(path="input_data/WorldClim_data_future", extension=".tif", recursive=TRUE, gcm_names=NULL){
  assertCharacter(path, len=1)
  assertCharacter(extension, len=1)
  assertLogical(recursive)
  assertCharacter(gcm_names, null.ok = T)

  l <- list.files(path, pattern = extension, full.names = T, rec=recursive)
  if(length(l)==0){
    stop('Could not find any file matching the parameters!')
  }
  s <- lapply(l, function(x){s <- raster::stack(x)
                           names(s) <- paste0('bio_',1:19) # Rename rasters
                           return(s)})
  if(is.null(gcm_names)){
    gcm_names <- gsub(extension,"",list.files(path, pattern = extension, full.names = F, rec=recursive))
  }
  names(s) <- sort(gcm_names)
  return(s)
}


