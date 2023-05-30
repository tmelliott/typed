#' Check object x has valid type
#' @param x Object to check
#' @param type Type to check against
#' @return logical indicating if x has valid type
#' @export
validate_types <- function(x, type = any()) {
    if (missing(x)) stop("Missing x")

    if (!inherits(type, "type")) stop("type must be a type object. See ?types")

    type$valid(x)
}
