#' Compile Typescript definitions
#' @param x Typed function to compile
#' @param file File to write to
#' @return NULL - writes a file
#' @export
compile <- function(x, file = sprintf("%s.d.ts", deparse(substitute(x)))) {
    UseMethod("compile")
}

#' @export
compile.typed <- function(x, file = sprintf("%s.d.ts", fun_name)) {
    fun_name <- deparse(substitute(x))
    FunName <- snakecase::to_upper_camel_case(fun_name)
    cat(
        sprintf("type %s_result = %s;",
            FunName,
            attr(x, "_returntype")
        ),
        sprintf("export function %s(%s): {\n  result: %sResult | undefined;\n  valid_type: boolean;\n  expected_type: string;\n};\n",
            fun_name,
            paste(names(attr(x, "_argtypes")), attr(x, "_argtypes"),
                sep = ": ", collapse = ", "),
            FunName
        ),
        sep = "\n"
    )
}

#' @export
compile.default <- function(x) {
    stop("Not supported.")
}
