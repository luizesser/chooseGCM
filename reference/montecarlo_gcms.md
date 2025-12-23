# Perform Monte Carlo Permutations on GCMs

This function performs Monte Carlo permutations on a distance matrix and
produces a violin plot showing the mean distance between subsets of the
distance matrix.

## Usage

``` r
montecarlo_gcms(
  s,
  var_names = c("bio_1", "bio_12"),
  study_area = NULL,
  scale = TRUE,
  perm = 10000,
  dist_method = "euclidean",
  clustering_method = "closestdist",
  ...
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

- perm:

  Integer. The number of permutations to perform.

- dist_method:

  Character. The method for distance matrix computation. Default is
  "euclidean." Possible values are: "euclidean," "maximum," "manhattan,"
  "canberra," "binary," or "minkowski." If `NULL`, clustering will be
  performed on the raw variable data.

- clustering_method:

  Character. The method for clustering. Default is "closestdist."
  Possible values are: "kmeans," "hclust," or "closestdist."

- ...:

  Additional arguments to pass to the clustering function.

## Value

A violin plot showing the results. The dashed red line and red dots
represent the mean absolute distance between subsets of GCMs using the
clustering approach. The violin plot is generated from Monte Carlo
permutations, selecting random subsets of GCMs from the provided set.

## See also

[`hclust_gcms`](https://luizesser.github.io/chooseGCM/reference/hclust_gcms.md)
[`env_gcms`](https://luizesser.github.io/chooseGCM/reference/env_gcms.md)
[`kmeans_gcms`](https://luizesser.github.io/chooseGCM/reference/kmeans_gcms.md)

## Author

Luíz Fernando Esser (luizesser@gmail.com)
https://luizfesser.wordpress.com

## Examples

``` r
var_names <- c("bio_1", "bio_12")
s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)
study_area <- terra::ext(c(-80, -30, -50, 10)) |>
  terra::vect(crs="+proj=longlat +datum=WGS84 +no_defs")
montecarlo_gcms(s, var_names, study_area)
#> $montecarlo_plot

#> 
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
```
