test_that("return types verified", {

  mean_double <- typed(mean,
    list(x = "number[]"), value = "number")
  x <- mean_double(1:5)
  expect_true(x$valid_type)

  mean_char <- typed(mean, value = "string")
  x <- mean_char(1:5)
  expect_false(x$valid_type)
  expect_equal(x$value, list())
})
