# Download WorldClim v.2.1 bioclimatic data

This function allows to download data from WorldClim v.2.1
(https://www.worldclim.org/data/index.html) considering multiple GCMs,
time periods and SSPs.

## Usage

``` r
WorldClim_data(path = NULL,
               period = "current",
               variable = "bioc",
               year = "2090",
               gcm = "mi",
               ssp = "585",
               resolution = 10)
```

## Arguments

- path:

  Directory path to save downloads.

- period:

  Can be "current" or "future".

- variable:

  Allows to specify which variables you want to retrieve Possible
  entries are: "tmax","tmin","prec" and/or "bioc".

- year:

  Specify the year you want to retrieve data. Possible entries are:
  "2030", "2050", "2070" and/or "2090". You can use a vector to provide
  more than one entry.

- gcm:

  GCMs to be considered in future scenarios. You can use a vector to
  provide more than one entry.

- ssp:

  SSPs for future data. Possible entries are: "126", "245", "370" and/or
  "585". You can use a vector to provide more than one entry.

- resolution:

  You can select one resolution from the following alternatives: 10, 5,
  2.5 OR 30.

## Value

If data is not downloaded, the function downloads the data and has no
return value.

## Details

This function will create a folder. All the data downloaded will be
stored in this folder. Note that, despite being possible to retrieve a
lot of data at once, it is not recommended to do so, since the data is
very heavy.

## References

\[https://www.worldclim.org/data/index.html\](https://www.worldclim.org/data/index.html)

## Author

Luíz Fernando Esser (luizesser@gmail.com)
\[https://luizfesser.wordpress.com\](https://luizfesser.wordpress.com)

## Examples

``` r
# \donttest{
# download data from multiple periods:
year <- c("2050", "2090")
WorldClim_data(period = "future",
               variable = "bioc",
               year = year,
               gcm = "mi",
               ssp = "126",
               resolution = 10)
#> Error in assert_character_cli(period): could not find function "assert_character_cli"

# download data from one specific period
WorldClim_data(period = "future",
               variable = "bioc",
               year = "2070",
               gcm = "mi",
               ssp = "585",
               resolution = 10)
#> Error in assert_character_cli(period): could not find function "assert_character_cli"
# }
```
