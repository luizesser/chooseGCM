# Import GCM Data to R

This function imports GCM stack files from a folder into R.

## Usage

``` r
import_gcms(
  path = "input_data/WorldClim_data_gcms",
  extension = ".tif",
  recursive = TRUE,
  gcm_names = NULL,
  var_names = NULL
)
```

## Arguments

- path:

  Character. A string specifying the path to the GCM files.

- extension:

  Character. The file extension of the stack files. Default is `".tif"`,
  the standard extension for WorldClim 2.1 data.

- recursive:

  Logical. Should the function import stacks recursively (i.e., search
  for files within subfolders)? Default is `TRUE`.

- gcm_names:

  Character. A vector of names to assign to each GCM.

- var_names:

  Character. A vector of names to assign to each variable.

## Value

A list of stacks, where each element corresponds to a GCM from the
specified path.

## See also

`worldclim_data`

## Author

Luíz Fernando Esser (luizesser@gmail.com)
https://luizfesser.wordpress.com

## Examples

``` r
s <- import_gcms(system.file("extdata", package = "chooseGCM"), var_names = c("bio1", "bio12"))
```
