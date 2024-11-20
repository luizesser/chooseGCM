#' Import GCM Data to R
#'
#' This function imports GCM stack files from a folder into R.
#'
#' @param path Character. A string specifying the path to the GCM files.
#' @param extension Character. The file extension of the stack files. Default is \code{".tif"}, the standard extension for WorldClim 2.1 data.
#' @param recursive Logical. Should the function import stacks recursively (i.e., search for files within subfolders)? Default is \code{TRUE}.
#' @param gcm_names Character. A vector of names to assign to each GCM.
#' @param var_names Character. A vector of names to assign to each variable.
#'
#' @return A list of stacks, where each element corresponds to a GCM from the specified path.

#'
#' @seealso \code{\link{worldclim_data}}
#'
#' @author Luíz Fernando Esser (luizesser@gmail.com)
#' https://luizfesser.wordpress.com
#'
#' @examples
#' s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = c("bio1", "bio12"))
#'
#' @import checkmate
#' @importFrom terra rast
#'
#' @export
import_gcms <- function(path = "input_data/WorldClim_data_gcms", extension = ".tif", recursive = TRUE, gcm_names = NULL, var_names = NULL) {
  checkmate::assertCharacter(path, len = 1)
  checkmate::assertCharacter(extension, len = 1)
  checkmate::assertLogical(recursive)
  checkmate::assertCharacter(gcm_names, null.ok = TRUE)
  checkmate::assertDirectoryExists(path)
  checkmate::assertCharacter(var_names, null.ok = TRUE)

  if (is.null(var_names)) {
    var_names <- paste0("bio", 1:19)
  }

  l <- list.files(path, pattern = extension, full.names = TRUE, recursive = recursive)
  if (length(l) == 0) {
    stop("Could not find any file matching the parameters!")
  }
  s <- lapply(l, function(x) {
    s <- terra::rast(x)
    checkmate::assertCharacter(var_names, len=length(names(s)))
    names(s) <- var_names
    return(s)
  })
  if (is.null(gcm_names)) {
    gcm_names <- gsub(extension, "", list.files(path, pattern = extension, full.names = FALSE, recursive = recursive))
  }
  names(s) <- sort(gcm_names)
  return(s)
}
