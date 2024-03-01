test_that("scale_vec scales single vector", {
  expect_equal(scale(1:20)[,1],
               scale_vec(1:20))
  expect_error(scale_vec(matrix(1:20, nrow = 4)))
})

test_that("scale_num_data scales data.frame", {
  cars <- mtcars
  carssc <- scale_num_data(cars, "mpg")
  expect_equal(names(carssc), "mpgz")
  expect_equal(carssc$mpgz, scale_vec(cars$mpg))
  carssc <- scale_num_data(cars, c("mpg", "cyl"))
  expect_equal(names(carssc), c("mpgz", "cylz"))
  expect_equal(carssc$mpgz, scale_vec(cars$mpg))
  expect_equal(carssc$cylz, scale_vec(cars$cyl))

   expect_error(scale_num_data(cars, "mpg", "cyl"))
   expect_error(scale_num_data(matrix(1:5), "mpg"))
   expect_error(scale_num_data(1:5, "mpg"))
   expect_error(scale_num_data(mtcars, "brat"))
})
