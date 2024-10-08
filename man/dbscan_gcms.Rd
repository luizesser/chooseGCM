% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dbscan_gcms.R
\name{dbscan_gcms}
\alias{dbscan_gcms}
\title{Perform DBScan clustering on GCMs}
\usage{
dbscan_gcms(
  s,
  var_names = c("bio_1", "bio_12"),
  study_area = NULL,
  scale = TRUE,
  eps = length(s) - 1,
  MinPts = 3,
  ...
)
}
\arguments{
\item{s}{A list of stacks of General Circulation Models.}

\item{var_names}{Character. A vector with names of the bioclimatic variables to compare OR 'all'.}

\item{study_area}{Extent object, or any object from which an Extent object can be extracted. A object that defines the study area for cropping and masking the rasters.}

\item{scale}{Boolean. Apply center and scale in data? Default is TRUE.}

\item{eps}{Size (radius) of the epsilon neighborhood.}

\item{MinPts}{Number of minimum points required in the eps neighborhood for core points (including the point itself).}

\item{...}{Arguments to pass to fpc::dbscan().}
}
\value{
A scatter plot of the resulting clusters and the suggested GCMs.
}
\description{
This function performs DBScan clustering and produces a scatter plot of the resulting clusters.
}
\examples{

\dontrun{
s <- list(stack("gcm1.tif"), stack("gcm2.tif"), stack("gcm3.tif"))
study_area <- extent(c(-57, -22, -48, -33))
var_names <- c("bio_1", "bio_12")

dbscan_gcms(s, k = 3)
}

}
\seealso{
\code{\link{transform_gcms}} \code{\link{flatten_gcms}}
}
\author{
Luíz Fernando Esser (luizesser@gmail.com)
https://luizfesser.wordpress.com
}
