
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
    list(x = "number[]"),
    value = number()
)
mean_double
#> typed function (x: number[]) => number;
#> function (x, ...) 
#> UseMethod("mean")
#> <bytecode: 0x55d5f4f4eca8>
#> <environment: namespace:base>
mean_double(1:5)
#> [1] 3
#> # Valid type

mean_char <- typed(mean, value = string())
mean_char
#> typed function (x: any) => string;
#> function (x, ...) 
#> UseMethod("mean")
#> <bytecode: 0x55d5f4f4eca8>
#> <environment: namespace:base>
mean_char(1:5)
#> list()
#> # Invalid type
```

TypeScript definitions can be generated:

``` r
compile(mean_double)
#> type MeanDoubleResult = number;
#> export function mean_double(x: number[]): {
#>   result: MeanDoubleResult | undefined;
#>   valid_type: boolean;
#>   expected_type: string;
#> };
compile(mean_char)
#> type MeanCharResult = string;
#> export function mean_char(x: any): {
#>   result: MeanCharResult | undefined;
#>   valid_type: boolean;
#>   expected_type: string;
#> };
```

## Advanced demo

Create array types using the `array_type()` function:

``` r
random_numbers <- typed(runif,
    list(n = "number"),
    value = array_type(number())
)
random_numbers
#> typed function (n: number) => number[];
#> function (n, min = 0, max = 1) 
#> .Call(C_runif, n, min, max)
#> <bytecode: 0x55d5f65f7238>
#> <environment: namespace:stats>
random_numbers(10)
#>  [1] 0.97467381 0.35086728 0.29635671 0.79228153 0.22502061 0.23889197
#>  [7] 0.50846276 0.61925204 0.08634518 0.17519657
#> # Valid type
```

Create union types using the `union()` function:

``` r
flip_coins <- function(n) ifelse(runif(n) > 0.5, "heads", "tails")
coin_tosses <- typed(flip_coins,
  value = array_type(union(litteral("heads"), litteral("tails")))
)
coin_tosses
#> typed function (n: any) => (heads | tails)[];
#> function(n) ifelse(runif(n) > 0.5, "heads", "tails")
coin_tosses(10)
#>  [1] "tails" "heads" "tails" "tails" "tails" "tails" "heads" "heads" "heads"
#> [10] "heads"
#> # Valid type
```

Finally, complex object types can be defined using the `object()`
function:

``` r
person <- typed(
  function(name, age, employed, gender) {
    p <- list(name = name, age = age, employed = employed)
    if (!missing(gender))
      p$gender <- gender
    p
  },
  value = object(
    name = string(),
    age = number(),
    employed = boolean(),
    gender = union(
      litteral("male"),
      litteral("female"),
      litteral("other")
    ) |> optional()
  )
)
person
#> typed function (name: any, age: any, employed: any, gender: any) => {
#> name: string;
#> age: number;
#> employed: boolean;
#> gender?: male | female | other;
#> };
#> function(name, age, employed, gender) {
#>     p <- list(name = name, age = age, employed = employed)
#>     if (!missing(gender))
#>       p$gender <- gender
#>     p
#>   }
person("Joe", round(runif(1, 20, 50)), TRUE)
#> $name
#> [1] "Joe"
#> 
#> $age
#> [1] 44
#> 
#> $employed
#> [1] TRUE
#> 
#> # Valid type
```

It might be easier to define types for later use, or extension.

``` r
date_type <- object(
  year = number(),
  month = number(),
  day = number()
)
event_type <- object(
  name = string(),
  date = date_type,
  attendees = optional(array_type(string()))
)

get_events <- typed(
  function() {
    list(
      list(
        name = "Birthday",
        date = list(year = 2020, month = 1, day = 1),
        attendees = c("Joe", "Jane")
      ),
      list(
        name = "Christmas",
        date = list(year = 2020, month = 12, day = 25),
        attendees = c("Joe", "Jane", "Santa")
      )
    )
  },
  value = array_type(event_type)
)
get_events
#> typed function () => {
#> name: string;
#> date: {
#> year: number;
#> month: number;
#> day: number;
#> };
#> attendees?: string[];
#> }[];
#> function() {
#>     list(
#>       list(
#>         name = "Birthday",
#>         date = list(year = 2020, month = 1, day = 1),
#>         attendees = c("Joe", "Jane")
#>       ),
#>       list(
#>         name = "Christmas",
#>         date = list(year = 2020, month = 12, day = 25),
#>         attendees = c("Joe", "Jane", "Santa")
#>       )
#>     )
#>   }
get_events()
#> [[1]]
#> [[1]]$name
#> [1] "Birthday"
#> 
#> [[1]]$date
#> [[1]]$date$year
#> [1] 2020
#> 
#> [[1]]$date$month
#> [1] 1
#> 
#> [[1]]$date$day
#> [1] 1
#> 
#> 
#> [[1]]$attendees
#> [1] "Joe"  "Jane"
#> 
#> 
#> [[2]]
#> [[2]]$name
#> [1] "Christmas"
#> 
#> [[2]]$date
#> [[2]]$date$year
#> [1] 2020
#> 
#> [[2]]$date$month
#> [1] 12
#> 
#> [[2]]$date$day
#> [1] 25
#> 
#> 
#> [[2]]$attendees
#> [1] "Joe"   "Jane"  "Santa"
#> 
#> 
#> # Valid type
```
