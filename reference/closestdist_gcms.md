# Distance between General Circulation Models (GCMs)

This function compares future climate projections from multiple General
Circulation Models (GCMs) based on their similarity in terms of
bioclimatic variables. It computes distance metrics between GCMs and
identifies subsets of GCMs that are similar to the global set.

## Usage

``` r
closestdist_gcms(
  s,
  var_names = c("bio_1", "bio_12"),
  study_area = NULL,
  scale = TRUE,
  k = NULL,
  method = "euclidean",
  minimize_difference = TRUE,
  max_difference = NULL
)
```

## Arguments

- s:

  A list of stacks of General Circulation Models (GCMs).

- var_names:

  Character. A vector with names of the bioclimatic variables to
  compare, or 'all' to include all available variables.

- study_area:

  An Extent object, or any object from which an Extent object can be
  extracted. Defines the study area for cropping and masking the
  rasters.

- scale:

  Logical. Whether to apply centering and scaling to the data. Default
  is `TRUE`.

- k:

  Numeric. The number of GCMs to include in the subset. If `NULL`
  (default), stopping criteria are applied.

- method:

  The distance method to use. Default is "euclidean". Possible values
  are: "euclidean", "maximum", "manhattan", "canberra", "binary",
  "minkowski", "pearson", "spearman", or "kendall". See
  [`?dist_gcms`](https://luizesser.github.io/chooseGCM/reference/dist_gcms.md).

- minimize_difference:

  Logical. If `k = NULL`, the function will search for the optimal value
  of `k` by adding GCMs to the subset until the mean distance starts to
  diverge from the global mean distance. Default is `TRUE`.

- max_difference:

  Numeric. A distance threshold to stop searching for the optimal
  subset. If `NULL`, no threshold is set. Default is `NULL`.

## Value

A set of GCMs that have a mean distance closer to the global mean
distance of all GCMs provided in `s`.

## Details

The `minimize_difference` option searches for the best value of `k` by
progressively adding GCMs to the subset. The function monitors the mean
distance between the subset of GCMs and the global mean distance,
stopping when the distance begins to increase. The `max_difference`
option sets a maximum distance difference. If the mean distance between
the subset GCMs exceeds this threshold, the function stops searching and
returns the current subset.

## See also

[`cor_gcms`](https://luizesser.github.io/chooseGCM/reference/cor_gcms.md)
[`dist_gcms`](https://luizesser.github.io/chooseGCM/reference/dist_gcms.md)

## Author

Luíz Fernando Esser (luizesser@gmail.com)
https://luizfesser.wordpress.com

## Examples

``` r
var_names <- c("bio_1", "bio_12")
s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)
study_area <- terra::ext(c(-80, -30, -50, 10)) |>
  terra::vect(crs="+proj=longlat +datum=WGS84 +no_defs")
closestdist_gcms(s, var_names, study_area, method = "euclidean")
#> CRS from s and study_area are not identical. Reprojecting study area.
#> Warning: `aes_string()` was deprecated in ggplot2 3.0.0.
#> ℹ Please use tidy evaluation idioms with `aes()`.
#> ℹ See also `vignette("ggplot2-in-packages")` for more information.
#> ℹ The deprecated feature was likely used in the factoextra package.
#>   Please report the issue at <https://github.com/kassambara/factoextra/issues>.
#> $suggested_gcms
#> [1] "ae" "ch" "cr"
#> 
#> $best_mean_diff
#> [1] 0.0001577513
#> 
#> $global_mean
#> [1] 7.190363
#> 
```
