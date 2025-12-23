# Download WorldClim v2.1 Bioclimatic Data

This function allows downloading data from WorldClim v2.1
(https://www.worldclim.org/data/index.html) for multiple GCMs, time
periods, and SSPs.

## Usage

``` r
worldclim_data(period = 'current', variable = 'bioc', year = '2030',
gcm = 'mi', ssp = '126', resolution = 10, path = NULL)
```

## Arguments

- period:

  Character. Can be 'current' or 'future'.

- variable:

  Character. Specifies which variables to retrieve. Possible entries
  are: 'tmax', 'tmin', 'prec', and/or 'bioc'.

- year:

  Character or vector. Specifies the year(s) to retrieve data for.
  Possible entries are: '2030', '2050', '2070', and/or '2090'.

- gcm:

  Character or vector. Specifies the GCM(s) to consider for future
  scenarios. See the table below for available options.

- ssp:

  Character or vector. SSP(s) for future data. Possible entries are:
  '126', '245', '370', and/or '585'.

- resolution:

  Numeric. Specifies the resolution. Possible values are 10, 5, 2.5, or
  30 arcseconds.

- path:

  Character. Directory path to save the downloaded files. Default is
  NULL.

## Value

This function does not return any value.

## Details

This function creates a folder in `path`. All downloaded data will be
stored in this folder. Note: While it is possible to retrieve a large
volume of data, it is not recommended to do so due to the large file
sizes. For example, datasets at 30 arcseconds resolution can exceed 4
GB. If the function fails to retrieve large datasets, consider
increasing the timeout by setting `options(timeout = 600)`. This will
increase the timeout to 10 minutes.

Available GCMs to be used in the `gcm` argument:

|          |                  |
|----------|------------------|
| **CODE** | **GCM**          |
| ac       | ACCESS-CM2       |
| ae       | ACCESS-ESM1-5    |
| bc       | BCC-CSM2-MR      |
| ca       | CanESM5          |
| cc       | CanESM5-CanOE    |
| ce       | CMCC-ESM2        |
| cn       | CNRM-CM6-1       |
| ch       | CNRM-CM6-1-HR    |
| cr       | CNRM-ESM2-1      |
| ec       | EC-Earth3-Veg    |
| ev       | EC-Earth3-Veg-LR |
| fi       | FIO-ESM-2-0      |
| gf       | GFDL-ESM4        |
| gg       | GISS-E2-1-G      |
| gh       | GISS-E2-1-H      |
| hg       | HadGEM3-GC31-LL  |
| in       | INM-CM4-8        |
| ic       | INM-CM5-0        |
| ip       | IPSL-CM6A-LR     |
| me       | MIROC-ES2L       |
| mi       | MIROC6           |
| mp       | MPI-ESM1-2-HR    |
| ml       | MPI-ESM1-2-LR    |
| mr       | MRI-ESM2-0       |
| uk       | UKESM1-0-LL      |

## References

https://www.worldclim.org/data/index.html

## Author

Luíz Fernando Esser (luizesser@gmail.com)
https://luizfesser.wordpress.com

## Examples

``` r
# \donttest{
# download data from multiple periods:
year <- c("2050", "2090")
worldclim_data(period = "future",
               variable = "bioc",
               year = year,
               gcm = "mi",
               ssp = "126",
               resolution = 10)
#> Error in worldclim_data(period = "future", variable = "bioc", year = year,     gcm = "mi", ssp = "126", resolution = 10): Assertion on 'path' failed: Must be of type 'character', not 'NULL'.

# download data from one specific period
worldclim_data(period = "future",
               variable = "bioc",
               year = "2070",
               gcm = "mi",
               ssp = "585",
               resolution = 10)
#> Error in worldclim_data(period = "future", variable = "bioc", year = "2070",     gcm = "mi", ssp = "585", resolution = 10): Assertion on 'path' failed: Must be of type 'character', not 'NULL'.
# }
```
