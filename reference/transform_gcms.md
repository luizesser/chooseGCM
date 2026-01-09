# Transform General Circulation Model (GCM) Stacks

This function transforms a list of GCM stacks by subsetting it to
include only the variables specified in `var_names`, reprojecting it to
match the CRS of `study_area`, cropping and masking it to `study_area`,
and returning a list of data frames.

## Usage

``` r
transform_gcms(s, var_names = c("bio_1", "bio_12"), study_area = NULL)
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

## Value

A list of data frames, where each element corresponds to a GCM in the
input list.

## See also

[`summary_gcms`](https://luizesser.github.io/chooseGCM/reference/summary_gcms.md)

## Author

Luíz Fernando Esser (luizesser@gmail.com)
https://luizfesser.wordpress.com

## Examples

``` r
var_names <- c("bio_1", "bio_12")
s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)[1:5]
study_area <- terra::ext(c(-80, -70, -50, -40)) |>
  terra::vect(crs="+proj=longlat +datum=WGS84 +no_defs")
transform_gcms(s, var_names, study_area)
#> CRS from s and study_area are not identical. Reprojecting study area.
#> $ae
#>     bio_1  bio_12
#> 6  11.293 518.881
#> 12 11.543 408.790
#> 18 10.787 325.573
#> 24 11.479 233.496
#> 29  7.852 652.387
#> 30 10.691 154.954
#> 35  7.734 588.390
#> 36 10.522 149.629
#> 
#> $cc
#>     bio_1  bio_12
#> 6  14.214 514.546
#> 12 14.298 425.775
#> 18 13.489 353.329
#> 24 14.077 256.632
#> 29  9.828 690.179
#> 30 13.183 163.592
#> 35  9.632 626.963
#> 36 12.919 157.307
#> 
#> $ch
#>     bio_1  bio_12
#> 6  12.378 542.395
#> 12 12.680 455.871
#> 18 12.071 381.848
#> 24 13.052 273.482
#> 29  9.519 816.399
#> 30 12.926 174.900
#> 35  9.814 712.956
#> 36 12.873 165.665
#> 
#> $cr
#>     bio_1  bio_12
#> 6  11.793 513.440
#> 12 11.970 431.966
#> 18 11.378 356.697
#> 24 12.378 256.534
#> 29  8.963 766.791
#> 30 12.137 164.902
#> 35  9.233 687.061
#> 36 12.105 158.755
#> 
#> $ev
#>     bio_1  bio_12
#> 6  12.002 570.354
#> 12 12.390 458.798
#> 18 11.723 368.207
#> 24 12.520 256.564
#> 29  9.135 741.645
#> 30 12.172 164.556
#> 35  9.373 659.248
#> 36 12.203 159.130
#> 
```
