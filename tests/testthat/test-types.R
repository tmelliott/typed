test_that("number type", {
  x <- number()
  expect_equal(x$type, "number")
  expect_true(x$valid_type(1))
  expect_false(x$valid_type("a"))
})
