#' Check object x has valid type
#' @param x Object to check
#' @param type Type to check against
#' @return logical indicating if x has valid type
#' @export
validate_types <- function(x, type = "any") {
    if (missing(x)) stop("Missing x")

    check_fun <- switch(type,
        "number" = \(x) is.numeric(x) && length(x) == 1,
        "number[]" = is.numeric,
        "string" = \(x) is.character(x) && length(x) == 1,
        "string[]" = is.character,
        "boolean" = \(x) is.logical(x) && length(x) == 1,
        "boolean[]" = is.logical,
        "any" = ,
        \(x) TRUE
    )

    check_fun(x)
}
