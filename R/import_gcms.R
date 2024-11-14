#' Import GCM data to R
#'
#' This function imports GCM stack files from folder to R.
#'
#' @param path A string with the path to GCM files.
#' @param extension Extension of stack files. Standard is ".tif", which is the extension from WorldClim 2.1.
#' @param recursive Logical. Should the function import stacks recursively (i.e. search files from folders within folders)? Standard is TRUE.
#' @param gcm_names A vector with names to be addressed to each GCM.
#' @param var_names A vector with names to be addressed to each variable.
#'
#' @return A list of stacks, with each element of the list corresponding to a GCM from given path.
#'
#' @seealso \code{\link{worldclim_data}}
#'
#' @author Luíz Fernando Esser (luizesser@gmail.com)
#' https://luizfesser.wordpress.com
#'
#' @examples
#' \dontrun{
#' s <- import_gcms(
#'   path = "input_data/WorldClim_data_future", extension = ".tif",
#'   recursive = TRUE, gcm_names = NULL
#' )
#' }
#'
#' @import checkmate
#' @importFrom terra rast
#'
#' @export
import_gcms <- function(path = "input_data/WorldClim_data_gcms", extension = ".tif", recursive = TRUE, gcm_names = NULL, var_names = NULL) {
  checkmate::assertCharacter(path, len = 1)
  checkmate::assertCharacter(extension, len = 1)
  checkmate::assertLogical(recursive)
  checkmate::assertCharacter(gcm_names, null.ok = T)
  checkmate::assertDirectoryExists(path)

  if (is.null(var_names)) {
    var_names <- paste0("bio", 1:19)
  }

  l <- list.files(path, pattern = extension, full.names = T, recursive = recursive)
  if (length(l) == 0) {
    stop("Could not find any file matching the parameters!")
  }
  s <- lapply(l, function(x) {
    s <- terra::rast(x)
    names(s) <- var_names
      return(s)
  })
  if (is.null(gcm_names)) {
    gcm_names <- gsub(extension, "", list.files(path, pattern = extension, full.names = F, recursive = recursive))
  }
  names(s) <- sort(gcm_names)
  return(s)
}
