
<!-- README.md is generated from README.Rmd. Please edit that file -->

# typed

<!-- badges: start -->

<!-- badges: end -->

The goal of typed is to provide wrappers that allow developers to create
‘type-safe’ functions. This *does not* make functions typesafe, rather
it returns a result that is checked at runtime and flagged as valid or
not.

The main purpose of this package is for integration with typesafe APIs,
such as TypeScript. Typed functions will (eventually) gain capabilities
to generate TypeScript definitions that can be used, for example by
rserve-js or similar.

## Installation

You can install the development version of typed like so:

``` r
remotes::install_github('tmelliott/typed')
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(typed)

mean_double <- typed(mean,
    list(x = "number[]"), value = "number")
mean_double
#> typed function: (x: number[]) => number 
#> function (x, ...) 
#> UseMethod("mean")
#> <bytecode: 0x557da8cd5670>
#> <environment: namespace:base>
#> 
#> Return type:  number
mean_double(1:5)
#> [1] 3
#> # Valid type: number

mean_char <- typed(mean, value = "string")
mean_char
#> typed function: (x: any) => string 
#> function (x, ...) 
#> UseMethod("mean")
#> <bytecode: 0x557da8cd5670>
#> <environment: namespace:base>
#> 
#> Return type:  string
mean_char(1:5)
#> [1] 3
#> # Invalid type: string
```