#' Scale a numeric vector
#'
#' @param x numeric vector to scale
#' @param ... additional arguments to be passed to \code{\link{scale}}
#'
#' @return scaled vector
#' @export
#' @examples
#' scale_vec(1:20)
scale_vec <- function(x, ...) {
  # Error if x has more than one dimension
  if(!is.null(dim(x))){
    stop("Input `x` must be a vector", call. = FALSE)
  }
  as.numeric(scale(x, ...))
}

#' Scale numeric variables in a data frame
#'
#' @param data data.frame
#' @param vars variables selected
#'
#' @return data.frame with scaled numeric variables
scale_num_data <- function(data, vars){
  if(!inherits(data, "data.frame")){
    stop("Input `data` must be a data.frame", call. = FALSE)
  }
  if(!is.null(vars) && !all(vars %in% names(data))){
    stop("Input `vars` must be a subset of the column names of `data`", call. = FALSE)
  }

  data <- data[ ,vars, drop = FALSE]
  # scale continuous variables
  cl <- sapply(data, class)
  dataz <- data[,which(cl %in% "numeric"), drop = FALSE]
  dataz <- apply(dataz, 2, scale_vec)
  dataz <- as.data.frame(dataz, check.names = FALSE)
  names(dataz) <- paste0(names(dataz), "z")
  dataz
}
