# Compare General Circulation Models (GCMs)

This function compares future climate projections from multiple General
Circulation Models (GCMs) based on their similarity in terms of
variables. The function uses three clustering algorithms — k-means,
hierarchical clustering, and closestdist — to group GCMs, and generates
visualizations for the resulting clusters.

## Usage

``` r
compare_gcms(
  s,
  var_names = c("bio_1", "bio_12"),
  study_area = NULL,
  scale = TRUE,
  k = 3,
  clustering_method = "closestdist"
)
```

## Arguments

- s:

  A list of stacks of General Circulation Models (GCMs).

- var_names:

  Character. A vector with the names of the variables to compare, or
  'all' to include all available variables.

- study_area:

  An Extent object, or any object from which an Extent object can be
  extracted. Defines the study area for cropping and masking the
  rasters.

- scale:

  Logical. Whether to apply centering and scaling to the data. Default
  is `TRUE`.

- k:

  Numeric. The number of clusters to use for k-means clustering.

- clustering_method:

  Character. The clustering method to use. One of: "kmeans", "hclust",
  or "closestdist". Default is "closestdist".

## Value

A list with two items: `suggested_gcms` (the names of the GCMs suggested
for further analysis) and `statistics_gcms` (a grid of plots visualizing
the clustering results).

## Author

Luíz Fernando Esser (luizesser@gmail.com)
https://luizfesser.wordpress.com

## Examples

``` r
var_names <- c("bio_1", "bio_12")
s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)
study_area <- terra::ext(c(-80, -30, -50, 10)) |>
  terra::vect(crs="+proj=longlat +datum=WGS84 +no_defs")
compare_gcms(s, var_names, study_area, k = 3, clustering_method = "closestdist")
#> CRS from s and study_area are not identical. Reprojecting study area.
#> Warning: Using `size` aesthetic for lines was deprecated in ggplot2 3.4.0.
#> ℹ Please use `linewidth` instead.
#> ℹ The deprecated feature was likely used in the factoextra package.
#>   Please report the issue at <https://github.com/kassambara/factoextra/issues>.
#> Warning: The `<scale>` argument of `guides()` cannot be `FALSE`. Use "none" instead as
#> of ggplot2 3.3.4.
#> ℹ The deprecated feature was likely used in the factoextra package.
#>   Please report the issue at <https://github.com/kassambara/factoextra/issues>.
#> $suggested_gcms
#> $suggested_gcms$k2
#> [1] "cr" "hg"
#> 
#> $suggested_gcms$k3
#> [1] "ae" "ch" "cr"
#> 
#> $suggested_gcms$k4
#> [1] "cc" "ev" "me" "ml"
#> 
#> $suggested_gcms$k5
#> [1] "ae" "me" "mr" "cr" "in"
#> 
#> $suggested_gcms$k6
#> [1] "ae" "ch" "cr" "ml" "ev" "in"
#> 
#> $suggested_gcms$k7
#> [1] "ch" "mr" "ae" "hg" "ev" "gg" "in"
#> 
#> $suggested_gcms$k8
#> [1] "cc" "ev" "me" "ml" "gg" "in" "hg" "mr"
#> 
#> $suggested_gcms$k9
#> [1] "ae" "cc" "hg" "cr" "ch" "me" "mr" "gg" "ev"
#> 
#> $suggested_gcms$k10
#>  [1] "ae" "cc" "hg" "cr" "ch" "me" "mr" "gg" "ev" "ml"
#> 
#> 
#> $statistics_gcms

#> 
```
