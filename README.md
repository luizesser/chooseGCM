
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `chooseGCM`: an R package with a toolkit to select General Circulation Models

<!-- badges: start -->

[![R-CMD-check](https://github.com/luizesser/chooseGCM/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/luizesser/chooseGCM/actions/workflows/R-CMD-check.yaml)
[![CRAN
status](https://www.r-pkg.org/badges/version/chooseGCM)](https://CRAN.R-project.org/package=chooseGCM)
[![codecov](https://app.codecov.io/gh/luizesser/chooseGCM/graph/badge.svg?token=61X1LOBFPH)](https://app.codecov.io/gh/luizesser/chooseGCM)

<!-- badges: end -->

# chooseGCM <a href="https://luizesser.github.io/chooseGCM/"><img src="man/figures/logo.png" alt="chooseGCM website" align="right" height="138"/></a>

The goal of `chooseGCM` is to help researchers aiming to project Species
Distribution Models and Ecological Niche Models to future scenarios by
applying a selection routine to the General Circulation Models.

## Installation

You can install the development version of `chooseGCM` from
[GitHub](https://github.com/luizesser/chooseGCM) with:

``` r
install.packages("devtools")
devtools::install_github("luizesser/chooseGCM")
```

The package is also available on CRAN. Users are able to install it
using the following code:

``` r
install.packages("chooseGCM")
```

## Other packages

If you liked `chooseGCM`, get to know our other packages. Currently, we
have also the [`caretSDM`](https://github.com/luizesser/caretSDM)
package, a package to run Species Distribution Modeling, which is also
used in the article

> Esser, L.F., Bailly, D., Lima, M.R., Ré, R. 2025. chooseGCM: A Toolkit
> to Select General Circulation Models in R. Global Change Biology ,
> 31(1), e70008. Available at: <https://doi.org/10.1111/gcb.70008>.

to test `chooseGCM` using SDMs.

Three breakthroughs distinguish `caretSDM`:

1.  The strong geoprocessing background that allows for automation on
    spatial data handling by rescaling data to a common grid, with the
    possibility to model distributions using river networks (via
    segmented lines), overcoming limitations for aquatic species, while
    also enabling interactive data viewing without the use of an
    external GIS software;

2.  The underlying ML tools that allows for the integration of 115+
    classification algorithms with automated workflows, from
    hyperparameter tuning to ensemble prediction, eliminating coding
    barriers for advanced techniques, while allowing flexibility for
    experienced users;

3.  The use of recyclable objects, designed to track all analysis steps
    within a single class, enhancing transparency and scientific rigor.

`caretSDM` is available on both GitHub and CRAN:

``` r
install.packages("devtools")
devtools::install_github("luizesser/caretSDM")
```

``` r
install.packages("caretSDM")
```
