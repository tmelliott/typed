#' Compile Typescript definitions
#' @param x Typed function to compile
#' @param file File to write to
#' @return NULL - writes a file
#' @export
compile <- function(x, file = sprintf("%s.d.ts", deparse(substitute(x)))) {
    UseMethod("compile")
}

#' @export
compile.typed <- function(x) {
    cat(
        sprintf("export function %s(%s): %s;\n",
            deparse(substitute(x)),
            paste(names(attr(x, "_argtypes")), attr(x, "_argtypes"),
                sep = ": ", collapse = ", "),
            attr(x, "_returntype")
        )
    )
}

#' @export
compile.default <- function(x) {
    stop("Not supported.")
}
