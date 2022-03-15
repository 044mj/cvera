
<!-- README.md is generated from README.Rmd. Please edit that file -->

# cvera

<!-- badges: start -->
<!-- badges: end -->

------------------------------------------------------------------------

`cvera` is an R package with a collection of utility R functions that
can be useful to explore Irish bTB datasets collated in CVERA.

------------------------------------------------------------------------

## Installation

You can install the development version of cvera from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("044mj/cvera")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(cvera)
## basic example code
bd_test <- bd_during(bd_test, "2017-02-27")
```

``` r
library(tidyverse)
# if using readr::read_csv() they use first 1000 rows to guess type. 
# If the first 1,000 are missing, it will default to logical. GIF variables are missing in the first 1000
#because it only came in during May 2019 so include col_types for these variables:
master_tb <- read_csv("N:\\data\\tb\\master_tb_data_jamie_m\\year_2021\\master_tb_14_Apr_2021.csv", 
                          col_types = cols(.default = "?", 
                                           gif8d_actual_date = col_date(), 
                                           gif_cases = col_number()))
```

, primarily `master_tb`.
