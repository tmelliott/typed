#' Typed functions
#' @param f Function to type
#' @param argtypes List of types for each argument
#' @param value Return type
#' @return Typed function
#' @export
typed <- function(f, argtypes, value) {

    if (missing(argtypes)) {
        a <- formals(f)
        a <- a[names(a) != "..."]
        argtypes <- as.list(rep("any", length(a)))
        names(argtypes) <- names(a)
    }

    typed_function <- function(...) {
        mc <- match.call(expand.dots = TRUE)
        args <- as.list(mc[-1])
        result <- do.call(f, args)
        valid <- validate_types(result, value)
        if (!valid) result <- list()

        structure(
            list(
                value = result,
                valid_type = valid,
                expected_type = value
            ),
            class = "typed_result"
        )
    }

    formals(typed_function) <- formals(f)
    attr(typed_function, "_function") <- f
    attr(typed_function, "_argtypes") <- argtypes
    attr(typed_function, "_returntype") <- value
    attr(typed_function, "class") <- c("typed", "function")
    typed_function
}

#' @export
print.typed <- function(x, ...) {
    args <- attr(x, "_argtypes")
    arg_string <- paste(names(args), args,
        sep = ": ", collapse = ", ")

    cat("typed function:",
        paste0("(", arg_string, ")"),
        "=>",
        attr(x, "_returntype"),
        "\n")
    print(attr(x, "_function"))
    cat("\nReturn type: ", attr(x, "_returntype"), "\n")
    invisible(x)
}

#' @export
print.typed_result <- function(x, ...) {
    ok <- isTRUE(x$valid_type)
    print(x$value)

    cat(sprintf("# %s type: %s",
        ifelse(ok, "Valid", "Invalid"),
        x$expected_type
    ))
}
