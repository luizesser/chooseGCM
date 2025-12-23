# Perform K-Means Clustering on GCMs

This function performs k-means clustering on a distance matrix and
produces a scatter plot of the resulting clusters.

## Usage

``` r
kmeans_gcms(
  s,
  var_names = c("bio_1", "bio_12"),
  study_area = NULL,
  scale = TRUE,
  k = 3,
  method = NULL
)
```

## Arguments

- s:

  A list of stacks of General Circulation Models (GCMs).

- var_names:

  Character. A vector of names of the variables to include, or 'all' to
  include all variables.

- study_area:

  An Extent object, or any object from which an Extent object can be
  extracted. Defines the study area for cropping and masking the
  rasters.

- scale:

  Logical. Should the data be centered and scaled? Default is `TRUE`.

- k:

  Integer. The number of clusters to create.

- method:

  Character. The method for distance matrix computation. Default is
  "euclidean." Possible values are: "euclidean," "maximum," "manhattan,"
  "canberra," "binary," or "minkowski." If `NULL`, clustering will be
  performed on the raw variable data.

## Value

A scatter plot showing the resulting clusters and the suggested GCMs.

## See also

[`transform_gcms`](https://luizesser.github.io/chooseGCM/reference/transform_gcms.md)
[`flatten_gcms`](https://luizesser.github.io/chooseGCM/reference/flatten_gcms.md)

## Author

Luíz Fernando Esser (luizesser@gmail.com)
https://luizfesser.wordpress.com

## Examples

``` r
var_names <- c("bio_1", "bio_12")
s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)
study_area <- terra::ext(c(-80, -30, -50, 10)) |>
  terra::vect(crs="+proj=longlat +datum=WGS84 +no_defs")
kmeans_gcms(s, var_names, study_area, k = 3)
#> CRS from s and study_area are not identical. Reprojecting study area.
#> $suggested_gcms
#> [1] "ev" "ch" "in"
#> 
#> $kmeans_plot

#> 
```
