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
s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = var_names)
study_area <- terra::ext(c(-80, -30, -50, 10)) |>
  terra::vect(crs="+proj=longlat +datum=WGS84 +no_defs")
summary_gcms(s, var_names, study_area)
#> CRS from s and study_area are not identical. Reprojecting study area.
#> $ae
#>           min quantile_0.25    median       mean quantile_0.75      max
#> bio_1   7.734      24.38925   30.4245   27.59028      32.15975   36.223
#> bio_12 13.387     865.08324 1282.8990 1307.64099    1661.11371 3153.833
#>                sd NAs n_cells
#> bio_1    6.555202   0     470
#> bio_12 658.375705   0     470
#> 
#> $cc
#>           min quantile_0.25    median       mean quantile_0.75      max
#> bio_1   9.632       27.3485   32.6475   30.03756      34.59025   37.114
#> bio_12 17.049      748.7095 1239.3800 1324.42981    1842.35349 3718.158
#>                sd NAs n_cells
#> bio_1    6.375763   0     470
#> bio_12 736.340840   0     470
#> 
#> $ch
#>           min quantile_0.25   median       mean quantile_0.75      max
#> bio_1   9.519       24.7940   30.745   27.86301      32.00825   33.721
#> bio_12 11.061      953.1217 1582.748 1561.86020    2079.47766 3962.162
#>                sd NAs n_cells
#> bio_1    5.813717   0     470
#> bio_12 800.308736   0     470
#> 
#> $cr
#>           min quantile_0.25    median       mean quantile_0.75      max
#> bio_1   8.963      24.57275   30.8235   27.76396       32.3655   34.225
#> bio_12 10.892     940.39249 1437.9115 1431.00430     1853.5811 3904.810
#>                sd NAs n_cells
#> bio_1    6.226339   0     470
#> bio_12 717.373064   0     470
#> 
#> $ev
#>          min quantile_0.25    median       mean quantile_0.75      max
#> bio_1  9.135      24.09275   29.9925   27.10791      31.32125   33.478
#> bio_12 8.491     927.21727 1518.8020 1495.06446    1995.87979 3329.857
#>                sd NAs n_cells
#> bio_1    5.925051   0     470
#> bio_12 749.026990   0     470
#> 
#> $gg
#>           min quantile_0.25   median       mean quantile_0.75      max
#> bio_1   8.072      23.73725   29.465   26.57517        30.865   32.873
#> bio_12 13.857     983.01001 1629.942 1522.41924      1955.706 3891.572
#>                sd NAs n_cells
#> bio_1    5.928956   0     470
#> bio_12 727.476365   0     470
#> 
#> $hg
#>           min quantile_0.25    median       mean quantile_0.75      max
#> bio_1  10.346      26.00875   32.2665   29.63256      34.93375   37.080
#> bio_12 10.447     899.70450 1414.8480 1423.15330    1762.83701 3694.793
#>               sd NAs n_cells
#> bio_1    6.74503   0     470
#> bio_12 758.12557   0     470
#> 
#> $`in`
#>           min quantile_0.25   median       mean quantile_0.75      max
#> bio_1   7.136       23.0155   28.138   25.25642        29.269   30.790
#> bio_12 14.053      905.7955 1648.554 1642.04464      2330.816 3754.984
#>                sd NAs n_cells
#> bio_1    5.694216   0     470
#> bio_12 872.713168   0     470
#> 
#> $me
#>           min quantile_0.25    median      mean quantile_0.75      max
#> bio_1   6.926       22.8935   28.7935   25.8296       30.1795   32.280
#> bio_12 12.646      924.1427 1524.8660 1549.1119     2004.8098 3736.639
#>                sd NAs n_cells
#> bio_1    5.949899   0     470
#> bio_12 848.705135   0     470
#> 
#> $ml
#>          min quantile_0.25    median       mean quantile_0.75      max
#> bio_1  7.324      23.94325   29.1495   26.45857       30.6025   33.174
#> bio_12 8.940     885.25952 1498.8890 1462.32763     1928.1500 3534.142
#>                sd NAs n_cells
#> bio_1    5.986042   0     470
#> bio_12 749.279630   0     470
#> 
#> $mr
#>           min quantile_0.25    median       mean quantile_0.75      max
#> bio_1   7.992       23.5035   28.8605   26.03051       30.0505   32.220
#> bio_12 12.032      998.1548 1620.2320 1559.82805     2049.5742 3386.632
#>                sd NAs n_cells
#> bio_1    5.666088   0     470
#> bio_12 770.164184   0     470
#> 
```
