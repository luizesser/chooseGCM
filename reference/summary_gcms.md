# Summarize General Circulation Model (GCM) Data

This function summarizes GCM data by calculating various statistics for
each variable.

## Usage

``` r
summary_gcms(s, var_names = c("bio_1", "bio_12"), study_area = NULL)
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

A data frame containing the summary statistics for each variable.

## See also

[`transform_gcms`](https://luizesser.github.io/chooseGCM/reference/transform_gcms.md)

## Author

Luíz Fernando Esser (luizesser@gmail.com)
https://luizfesser.wordpress.com

## Examples

``` r
var_names <- c("bio_1", "bio_12")
s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)[1:5]
study_area <- terra::ext(c(-80, -70, -50, -40)) |>
  terra::vect(crs="+proj=longlat +datum=WGS84 +no_defs")
summary_gcms(s, var_names, study_area)
#> CRS from s and study_area are not identical. Reprojecting study area.
#> $ae
#>            min quantile_0.25   median      mean quantile_0.75     max
#> bio_1    7.734        9.8545  10.7390  10.23763       11.3395  11.543
#> bio_12 149.629      213.8605 367.1815 379.01250      536.2582 652.387
#>                sd NAs n_cells
#> bio_1    1.554092   0       8
#> bio_12 194.889090   0       8
#> 
#> $cc
#>            min quantile_0.25  median     mean quantile_0.75     max         sd
#> bio_1    9.632      12.14625  13.336  12.7050      14.11125  14.298   1.901372
#> bio_12 157.307     233.37199 389.552 398.5404     542.65027 690.179 202.486461
#>        NAs n_cells
#> bio_1    0       8
#> bio_12   0       8
#> 
#> $ch
#>            min quantile_0.25   median      mean quantile_0.75     max
#> bio_1    9.519      11.50675  12.5290  11.91413      12.88625  13.052
#> bio_12 165.665     248.83649 418.8595 440.43950     585.03526 816.399
#>                sd NAs n_cells
#> bio_1    1.424861   0       8
#> bio_12 240.108269   0       8
#> 
#> $cr
#>            min quantile_0.25   median      mean quantile_0.75     max
#> bio_1    8.963      10.84175  11.8815  11.24463       12.1130  12.378
#> bio_12 158.755     233.62600 394.3315 417.01825      556.8452 766.791
#>                sd NAs n_cells
#> bio_1    1.358478   0       8
#> bio_12 228.173183   0       8
#> 
#> $ev
#>            min quantile_0.25   median      mean quantile_0.75     max
#> bio_1    9.135       11.1355  12.0870  11.43975      12.24975  12.520
#> bio_12 159.130      233.5620 413.5025 422.31275     592.57750 741.645
#>                sd NAs n_cells
#> bio_1    1.371565   0       8
#> bio_12 222.794772   0       8
#> 
```
