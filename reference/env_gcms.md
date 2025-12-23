# General Circulation Model (GCM) Environmental Distribution

This function visualizes GCM data in environmental space, with options
to highlight clusters or specific GCMs.

## Usage

``` r
env_gcms(
  s,
  var_names = c("bio_1", "bio_12"),
  study_area = NULL,
  highlight = "sum",
  resolution = 25,
  title = NULL
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

- highlight:

  Character. A vector of GCM names to be highlighted. All other GCMs
  will appear in grey.

- resolution:

  Numeric. The resolution to be used in the plot. Default is `25`.

- title:

  Character. The title of the plot.

## Value

A plot displaying the environmental space for the specified GCMs.

## See also

[`summary_gcms`](https://luizesser.github.io/chooseGCM/reference/summary_gcms.md)

## Author

Luíz Fernando Esser (luizesser@gmail.com)
https://luizfesser.wordpress.com

## Examples

``` r
var_names <- c("bio_1", "bio_12")
s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)
study_area <- terra::ext(c(-80, -30, -50, 10)) |>
  terra::vect(crs="+proj=longlat +datum=WGS84 +no_defs")
env_gcms(s, var_names, study_area, highlight = "sum")

env_gcms(s, var_names, study_area, highlight = c("ae", "ch", "cr"))

```
