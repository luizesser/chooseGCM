# Flatten General Circulation Models (GCMs)

Scale and flatten a list of GCMs `data.frame`s.

## Usage

``` r
flatten_gcms(s)
```

## Arguments

- s:

  A list of transformed `data.frame`s representing GCMs.

## Value

A `data.frame` with columns as GCMs and rows as values from each cell to
each variable.

## See also

[`transform_gcms`](https://luizesser.github.io/chooseGCM/reference/transform_gcms.md)

## Author

Luíz Fernando Esser (luizesser@gmail.com)
https://luizfesser.wordpress.com

## Examples

``` r
var_names <- c("bio_1", "bio_12")
s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)
study_area <- terra::ext(c(-80, -30, -50, 10)) |>
  terra::vect(crs="+proj=longlat +datum=WGS84 +no_defs")
s_trans <- transform_gcms(s, var_names, study_area)
#> CRS from s and study_area are not identical. Reprojecting study area.
flattened_gcms <- flatten_gcms(s_trans)
```
