test_that("qdec S3 obj", {
  obj <- qdec(mtcars, ~ -1 + cyl)
  expect_s3_class(obj, "qdec")
  expect_s3_class(obj, "data.frame")
  expect_equal(attr(obj, "vars"), "cyl")
  expect_equal(attr(obj, "formula"), ~ -1 + cyl)
  expect_equal(names(attributes(obj)),
               c("names", "class", "row.names", "formula", "vars"))
})

# test qdec plotting
test_that("qdec plot works", {
  expect_error(plot.qdec(mtcars))
  obj <- qdec(mtcars, ~ -1 + cyl)
  expect_error(plot.qdec(obj))
  cars <- mtcars
  cars$cyl <- as.factor(cars$cyl)
  obj <- qdec(cars, ~ -1 + cyl + gear)
  pobj <- plot.qdec(obj)
  expect_equal(class(pobj), "list")
  expect_equal(names(pobj),
               c("rowInd", "colInd", "Rowv", "Colv"))
  unlink("Rplots.pdf")
})

# test make_fs_qdec
test_that("make_fs_qdec works", {
  cars <- mtcars
  cars$cyl <- as.factor(cars$cyl)
  obj <- make_fs_qdec(cars, ~ -1 + cyl + gear)
  expect_equal(names(obj),
               c("cyl4", "cyl6", "cyl8", "gearz"))
  expect_s3_class(obj, "qdec")

  obj <- make_fs_qdec(cars, ~ -1 + cyl + gear,
                      keep = c("mpg", "gear"))
  expect_s3_class(obj, "qdec")
  expect_equal(names(obj),
               c("cyl4", "cyl6", "cyl8", "gearz", "mpg", "gear"))
  expect_equal(obj$mpg, cars$mpg)
  expect_equal(obj$gear, cars$gear)
  expect_equal(obj$gearz, scale_vec(cars$gear))
  expect_equal(unique(obj$cyl4), c(0, 1))

  obj <- make_fs_qdec(cars, mpg ~ -1 + cyl + gear,
                      keep = TRUE)
  expect_s3_class(obj, "qdec")
  expect_equal(names(obj),
               c("cyl4", "cyl6", "cyl8", "mpgz", "gearz", "mpg", "cyl", "gear"
               ))
  expect_equal(obj$mpg, cars$mpg)
  expect_equal(obj$gear, cars$gear)
  expect_equal(obj$gearz, scale_vec(cars$gear))
  expect_equal(unique(obj$cyl4), c(0, 1))

  expect_error(make_fs_qdec(cars, ~ -1 + cyl + gear, keep = ""))

  expect_snapshot(make_fs_qdec(cars, ~ -1 + cyl + gear,
                               path = "test.csv"))
  unlink("test.csv")
})

test_that("qdec_struct works", {
  sobj <- qdec_struct(mtcars, ~ -1 + cyl + gear, c("mpg", "gear", "cyl"))
  expect_s3_class(sobj, "qdec")
  expect_equal(names(sobj),
               names(mtcars))
  expect_equal(sobj$cyl, mtcars$cyl)
  expect_equal(sobj$gear, mtcars$gear)
  expect_equal(attr(sobj, "vars"), c("mpg", "gear", "cyl"))
  expect_equal(attr(sobj, "formula"), ~ -1 + cyl + gear)

  expect_error(qdec_struct(mtcars, ~ -1 + cyl + gear))
  expect_error(qdec_struct(mtcars, ~ -1 + cyl + gear, TRUE))
  expect_error(qdec_struct(mtcars, "hello", c("mpg")))
  expect_error(qdec_struct(1:5, ~ -1 + cyl , c("mpg")))
})
