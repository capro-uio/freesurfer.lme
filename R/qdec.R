#' Create a Freesurfer qdec
#'
#' Create a Freesurfer qdec from a model formula,
#' utilising R's robust model formula syntax. The function
#' also scales continuous variables, and can keep the original
#' data in the output.
#'
#' @details
#' The \code{\link{formula}} should in all likelihood also
#' include the \code{-1} to remove the intercept, as this
#' will provide a matrix where all levels of factor variables
#' have their own binary column. This is necessary to follow
#' the steps from the Freesurfer documentation.
#'
#' It is highly recommended to have the base-id's for Freesurfer
#' in their own column, and request to have this remain
#' in the qdec by using the id-column's name in the
#' \code{keep} argument.
#'
#' @param data data.frame, list or environment
#'    containing the data. Neither matrix nor an array
#'    will be accepted.
#' @template formula
#' @param path an option file path to write qdec to csv
#' @param keep logical or vector of column names,
#'    to keep the original data in the output.
#'     Default is \code{FALSE}.
#'
#' @return data.frame with model matrix and
#'    scaled continuous variables.
#' @export
#' @importFrom stats model.matrix
#' @importFrom utils write.csv
#' @importFrom methods is
#'
#' @examples
#' cars <- mtcars
#' cars$cyl <- as.factor(cars$cyl)
#' cars$gear <- as.factor(cars$gear)
#'
#' make_fs_qdec(cars, mpg ~ cyl + hp)
#'
#' # Remove the intercept, necessary to follow
#' # steps from Freesurfer docs
#' make_fs_qdec(cars, mpg ~ -1 + cyl + hp)
#' make_fs_qdec(cars, mpg ~ -1 + cyl + hp + gear)
#'
#' # Keep the original data also in the output
#' make_fs_qdec(cars, mpg ~ -1 + cyl + hp, keep = TRUE)
#'
#' # Keep the original data of specific columns
#' # Use a character vector
#' make_fs_qdec(cars, mpg ~ -1 + cyl + hp, keep = c("mpg", "gear"))
#'
make_fs_qdec <- function(data,
                      formula,
                      path = NULL,
                      keep = FALSE) {
  if(all(
    is(keep, "character") &
    keep == ""
  )){
    stop("`keep` cannot be ''. Use TRUE/FALSE or the names of columns.", call. = FALSE)
  }

  mm <- qdec(data, formula)
  vars <- attr(mm, "vars")

  if(is(keep, "character")){
    vars <- keep
  }
  data <- data[ , vars, drop = FALSE]

  add_orig <- suppressWarnings(
    any(keep, is.character(keep))
  )
  if(add_orig){
    mm <- cbind(mm, data)
  }

  # write to path if requested
  if(!is.null(path)){
    write.csv(mm, path, row.names = FALSE)
  }

  qdec_struct(
    mm,
    formula,
    vars
  )
}

#' Freesurfer qdec constructor
#'
#' Creates a qdec matrix from a model formula.
#'
#' @param data input data.frame
#' @template formula
#'
#' @return qdec with model matrix
#' @export
#'
#' @examples
#' cars <- mtcars
#' cars$cyl <- as.factor(cars$cyl)
#'
#' qdec <- qdec(cars, mpg ~ cyl + hp)
qdec <- function(data, formula){
  # extract variable names from formula
  vars <- all.vars(formula)

  # create model matrix
  mm <- model.matrix(formula, data)
  mm <- as.data.frame(mm)
  mm <- mm[, !names(mm) %in% names(data)]

  # scale continuous variables
  dataz <- scale_num_data(data, vars)

  # combine model matrix and scaled data
  dt <- cbind(mm, dataz)

  qdec_struct(dt, formula, vars)
}

qdec_struct <- function(data, formula, vars){
  if(!is.data.frame(data)){
    stop("Input `data` must be a data.frame", call. = FALSE)
  }
  if(!inherits(formula, "formula")){
    stop("Input `formula` must be a formula", call. = FALSE)
  }
  if(!is.character(vars)){
    stop("Input `vars` must be a character vector", call. = FALSE)
  }
  structure(
    data,
    class   = c("qdec", "data.frame"),
    formula = formula,
    vars    = vars
  )
}

#' Plot qdec matrix
#'
#' Visualise a Freesurfer qdec matrix as returned
#' byt the \code{\link{make_fs_qdec}} function.
#'
#' @param x a qdec object
#' @param col a vector of colors to be used in the heatmap.
#' @param ... arguments to be passed to \code{\link{heatmap}}.
#'     \code{scale}, \code{Rowv}, \code{Colv} already have
#'     custom values that may not be overwritten for the sake
#'     of a better visualisation.
#'
#' @return a heatmap of the qdec matrix
#' @export
#' @importFrom grDevices hcl.colors
#' @importFrom stats heatmap
#' @examples
#' cars <- mtcars
#' cars$cyl <- as.factor(cars$cyl)
#'
#' qdec <- make_fs_qdec(cars, mpg ~ -1 + cyl + hp)
#' plot(qdec)
plot.qdec <- function(x,
                      col = hcl.colors(12, "viridis"),
                      ...) {
  if(!inherits(x, "qdec")){
    stop("Input `x` must be a qdec object", call. = FALSE)
  }
  if(ncol(x) < 2 | nrow(x) < 2){
    stop("qdec must have at least 2 rows and 2 columns", call. = FALSE)
  }
  x <- x[, !names(x) %in% attr(x, "vars"), drop = FALSE]
  x <- as.matrix(x)
  x <- x[dim(x)[1]:1, , drop = FALSE]
  heatmap(x, scale = "none",
          Rowv = NA, Colv = NA,
          col = col,
          ...)
}
