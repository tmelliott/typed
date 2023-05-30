#' Type functions
#'
#' Use these functions to construct complex types.
#'
#' @name types
NULL

#' @describeIn types Number type
#' @export
number <- function() {
    structure(
        list(
            type = "number",
            valid = function(x) is.numeric(x) && length(x) == 1L
        ),
        class = "type"
    )
}

#' @describeIn types String type
#' @export
string <- function() {
    structure(
        list(
            type = "string",
            valid = function(x) is.character(x) && length(x) == 1L
        ),
        class = "type"
    )
}

#' @describeIn types Boolean type
#' @export
boolean <- function() {
    structure(
        list(
            type = "boolean",
            valid = function(x) is.logical(x) && length(x) == 1L
        ),
        class = "type"
    )
}

#' @describeIn types Void type
#' @export
void <- function() {
    structure(
        list(
            type = "void",
            valid = function(x) is.null(x)
        ),
        class = "type"
    )
}

#' @describeIn types Any type
#' @export
any_type <- function() {
    structure(
        list(
            type = "any",
            valid = function() TRUE
        ),
        class = "type"
    )
}

#' @describeIn types Litteral type
#' @param x Litteral value
#' @export
litteral <- function(x) {
    structure(
        list(
            type = x,
            valid = function(y) identical(x, y)
        ),
        class = "type"
    )
}

#' @describeIn types Array type
#' @param type A type to be an array of
#' @export
array_type <- function(type) {
    # if the type is complex, we need to wrap it in parens
    t <- type$type
    if (inherits(type, "complex_type"))
        t <- sprintf("(%s)", t)

    structure(
        list(
            type = sprintf("%s[]", t),
            valid = function(x) all(sapply(x, function(y) type$valid(y)))
        ),
        class = "type"
    )
}

#' @describeIn types Composite type
#' @param ... Types to compose
#' @export
union <- function(...) {
    types <- list(...)
    type_strings <- sapply(types, function(x) as.character(x))
    structure(
        list(
            type = paste0(
                type_strings,
                collapse = " | "
            ),
            valid = function(x) any(sapply(types, function(t) t$valid(x)))
        ),
        class = c("complex_type", "type")
    )
}

#' @describeIn types Optional types
#' @param type Type to make optional
#' @export
optional <- function(type) {
    type$optional <- TRUE
    type
}

#' @describeIn types Object type
#' @param ... Object components
#' @export
object <- function(...) {
    components <- list(...)
    component_strings <- sapply(components, function(x) as.character(x))
    structure(
        list(
            type = sprintf(
                "{\n%s\n}",
                paste0(
                    names(components),
                    ifelse(
                        sapply(components, function(x) isTRUE(x$optional)),
                        "?: ",
                        ": "
                    ),
                    component_strings,
                    ";",
                    collapse = "\n"
                )
            ),
            valid = function(x) {
                if (!is.list(x)) return(FALSE)

                if (any(!names(x) %in% names(components)))
                    return(FALSE)

                is_optional <- sapply(components,
                    function(x) isTRUE(x$optional))
                required_components <- components[!is_optional]
                optional_components <- components[is_optional]

                if (any(!names(required_components) %in% names(x)))
                    return(FALSE)

                comps <- components[names(components) %in% names(x)]

                all(sapply(seq_along(comps), function(i) {
                    comps[[i]]$valid(x[[i]])
                }))
            }
        ),
        class = c("object_type", "type")
    )
}

#' @export
print.type <- function(x, ...) {
    cat(as.character(x))
    invisible(x)
}

#' @export
as.character.type <- function(x, ...) {
    if (!is.null(x$string)) return(x$string)
    x$type
}
