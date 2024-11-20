#' Distance between General Circulation Models (GCMs)
#'
#' This function compares future climate projections from multiple General Circulation Models (GCMs)
#' based on their similarity in terms of bioclimatic variables. It computes distance metrics between
#' GCMs and identifies subsets of GCMs that are similar to the global set.
#'
#' @param s A list of stacks of General Circulation Models (GCMs).
#' @param var_names Character. A vector with names of the bioclimatic variables to compare, or 'all'
#' to include all available variables.
#' @param scale Logical. Whether to apply centering and scaling to the data. Default is \code{TRUE}.
#' @param study_area An Extent object, or any object from which an Extent object can be extracted.
#' Defines the study area for cropping and masking the rasters.
#' @param method The distance method to use. Default is "euclidean". Possible values are: "euclidean",
#' "maximum", "manhattan", "canberra", "binary", "minkowski", "pearson", "spearman", or "kendall". See \code{?dist_gcms}.
#' @param k Numeric. The number of GCMs to include in the subset. If \code{NULL} (default), stopping criteria are applied.
#' @param minimize_difference Logical. If \code{k = NULL}, the function will search for the optimal
#' value of \code{k} by adding GCMs to the subset until the mean distance starts to diverge from the
#' global mean distance. Default is \code{TRUE}.
#' @param max_difference Numeric. A distance threshold to stop searching for the optimal subset.
#' If \code{NULL}, no threshold is set. Default is \code{NULL}.
#'
#' @details
#' The \code{minimize_difference} option searches for the best value of \code{k} by progressively
#' adding GCMs to the subset. The function monitors the mean distance between the subset of GCMs and
#' the global mean distance, stopping when the distance begins to increase.
#' The \code{max_difference} option sets a maximum distance difference. If the mean distance between
#' the subset GCMs exceeds this threshold, the function stops searching and returns the current subset.
#'
#' @return A set of GCMs that have a mean distance closer to the global mean distance of all GCMs provided in \code{s}.
#'
#' @seealso \code{\link{cor_gcms}} \code{\link{dist_gcms}}
#'
#' @author Luíz Fernando Esser (luizesser@gmail.com)
#' https://luizfesser.wordpress.com
#'
#' @examples
#' var_names <- c("bio_1", "bio_12")
#' s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)
#' study_area <- terra::ext(c(-80, -30, -50, 10)) |> terra::vect(crs="epsg:4326")
#' closestdist_gcms(s, var_names, study_area, method = "euclidean")
#'
#' @import checkmate
#' @importFrom factoextra fviz_dist get_dist
#' @importFrom utils combn
#'
#' @export
closestdist_gcms <- function(s, var_names = c("bio_1", "bio_12"), study_area = NULL, scale = TRUE,
                             k = NULL, method = "euclidean",
                             minimize_difference = TRUE, max_difference = NULL) {
  if(is.list(s)){
    if(!is.data.frame(s[[1]])){
      checkmate::assertList(s, types = "SpatRaster")
    }
  }
  checkmate::assertCharacter(var_names, unique = TRUE, any.missing = FALSE)
  checkmate::assertChoice(method, c("euclidean", "maximum", "manhattan", "canberra", "binary",
                                    "minkowski", "pearson", "spearman", "kendall"), null.ok = TRUE)
  checkmate::assertCount(k, positive = TRUE, null.ok = TRUE)
  checkmate::assertLogical(minimize_difference, len=1, null.ok = FALSE, any.missing = FALSE, all.missing = FALSE)
  checkmate::assertNumeric(max_difference, lower=0, upper=1, len = 1, any.missing = FALSE, all.missing = FALSE, null.ok = TRUE)

  dmat <- chooseGCM::dist_gcms(s=s, var_names=var_names, method=method, study_area=study_area, scale = scale)$distances
  dmat <- as.matrix(dmat)

  N <- nrow(dmat)

  if (is.null(k)) {
    kn <- length(s)-1
  } else {
    kn <- k
  }

  # Global mean distance of the entire distance matrix
  global_mean <- mean(dmat[upper.tri(dmat)])

  best_subset <- NULL
  best_mean_diff <- Inf

  gcms_comb <- utils::combn(1:N, 2)
  # Repeat the process for a given number of random initializations
  for (rep in 1:ncol(gcms_comb)) {
    # Start with a random subset of size 2
    subset <- gcms_comb[,rep]

    # Iteratively add GCMs until subset size is k
    while (length(subset) < kn) {
      best_gcm <- NULL
      best_mean_diff_subset <- Inf

      previous_dist <- dmat[subset,subset]
      previous_mean_diff <- abs(mean(previous_dist[upper.tri(previous_dist)])-global_mean)

      # Test each GCM not in the subset
      for (i in setdiff(1:N, subset)) {
        candidate_subset <- c(subset, i)
        candidate_distances <- dmat[candidate_subset, candidate_subset]
        candidate_mean <- mean(candidate_distances[upper.tri(candidate_distances)])

        # Check how close the mean is to the global mean
        mean_diff <- abs(candidate_mean - global_mean)
        if (mean_diff < best_mean_diff_subset) {
          best_gcm <- i
          best_mean_diff_subset <- mean_diff
        }
      }

      if (is.null(k)){
        if (best_mean_diff_subset > previous_mean_diff & minimize_difference ) {
          #message("Stopping because new mean is farther from global mean than previous.")
          break
        }

        # 2. Stop if the difference is lower than the threshold (max_difference)
        if(!is.null(max_difference)){
          if (best_mean_diff_subset < max_difference) {
            #message("Stopping because mean difference is below threshold from max_difference.")
            break
          }
        }

      }
      # Add the best GCM found in this iteration to the subset
      subset <- c(subset, best_gcm)
    }

    # Calculate the mean distance of the final subset
    final_distances <- dmat[subset, subset]
    final_mean <- mean(final_distances[upper.tri(final_distances)])

    # Update the best subset if this one is closer to the global mean
    mean_diff_final <- abs(final_mean - global_mean)
    if (mean_diff_final < best_mean_diff) {
      best_subset <- subset
      best_mean_diff <- mean_diff_final
    }
  }

  #close_plot <- ggplot2::ggplot(r, ggplot2::aes(x = factor(k), y = mean, fill = factor(k))) +
  #  ggplot2::geom_violin() +
  #  ggplot2::geom_boxplot(width = 0.1, fill = "white") +
  #  ggplot2::geom_hline(yintercept = mgcms_all, color = "blue") +
  #  ggplot2::geom_line(data = df, ggplot2::aes(x = k - 1, y = mean, group = 1), linetype = "dashed", color = "red") +
  #  ggplot2::geom_point(data = df, ggplot2::aes(x = k - 1, y = mean, group = 1), color = "red") +
  #  ggplot2::xlab("Number of GCMs/Clusters") +
  #  ggplot2::ylab("Mean Distance") +
  #  ggplot2::theme_minimal() +
  #  ggplot2::theme(legend.position = "none") +
  #  ggplot2::ggtitle(paste0("Monte Carlo Permutations - ", clustering_metzhod))

  # Return the best subset found and its mean distance
  res <- list(
    suggested_gcms = colnames(dmat[best_subset,best_subset]),
    best_mean_diff = best_mean_diff,
    global_mean = global_mean
  )

  return(res)
}
