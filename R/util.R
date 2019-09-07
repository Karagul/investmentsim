### Internal utility functions

### Dates
#' Find a Date's Position in a List
#' 
#' The position of the first date in the list before the given date
#'
#' @param dates a list of dates
#' @param d the reference date
#' @param right whether to check from the right of the given date
#' @return the position of the date found
#' @export
find_begin_position <- function (dates, d, right=FALSE) {
    Position(function(x) d > x, dates, right)
}

#' Find a Date in a List
#'
#' The first date in the list before the given date
#'
#' @param dates a list of dates
#' @param d the reference date
#' @param right whether to check from the right of the given date
#' @return the date found
#' @export
find_begin <- function (dates, d, right=FALSE) {
    dates[[investmentsim::find_begin_position(dates, d, right)]]
}

#' Find a Date's Position in a List
#'
#' The position of the first date in the list after the given date
#'
#' @param dates a list of dates
#' @param d the reference date
#' @param right whether to check from the right of the given date
#' @return the position of the date found
#' @export
find_end_position <- function (dates, d, right=FALSE) {
    Position(function(x) d < x, dates, right)
}

#' Find a Date
#'
#' The first date in the list after the given date
#'
#' @param dates a list of dates
#' @param d the reference date
#' @param right whether to check from the right of the given date
#' @return the position of the date found
#' @export
find_end <- function (dates, d, right=FALSE) {
    dates[[investmentsim::find_end_position(dates, d, right)]]
}

#' Find the Proportion of Elapsed Time
#'
#' The proportion of time elapsed to current in the interval (start, end)
#'
#' @param start the stating date
#' @param current the current date
#' @param end the ending date
#' @return a proportion
#' @export
proportion_elapsed <- function(start, current, end) {
    lubridate::as.duration(lubridate::interval(start, current)) / as.duration(interval(start, end))
}


### Diagnostics
## Prints something if bool is true
print_if <- function(bool, ...) {
    if (bool) {
        cat(..., "\n")
    }
}


#' Stationary bootstrap with geometric block size
#'
#' A function for sampling time-dependent data.
#'
#' source: https://eranraviv.com/bootstrapping-time-series-r-code/
#' 
#' @param ts a time series to sample from
#' @param R the number of samples
#' @param block_size is mean block size for sampling
#' @export
make_geom_block_sample <- function(ts, block_size, R) {
    p <- 1 / (block_size + 1) # probability of new block
    n <- length(ts)
    ts_star <- matrix(nrow=n, ncol=R)
    for (r in 1:R) {
        idx <- round(runif(n=1, min=1, max=n)) # choose starting index
        for (i in 1:n){
            p1 <- runif(1, 0, 1)
            ## In probability p, we take next observation, otherwise
            ## start a new block
            if (p1 > p) idx <- idx + 1 else idx <- round(runif(1, 1, n))
            if (idx > n) idx <- idx - n # wrap the series
            ts_star[i, r] <- ts[idx]
        }
    }
    ts_star
}


### Returns

#' Convert Relative Returns
#'
#' Convert relative returns to absolute returns.
#'
#' @param r_log a logarithmic (relative) return
#' @param n the number of time periods over which to compute the
#'     absolute return.
#' @return an absolute percent return
#' @export
relative_to_absolute <- function(r_log, n) n * exp(r_log / n) - n

#' Convert Absolute Returns
#'
#' Convert absolute returns to relative (log) returns.
#'
#' @param r_n an absolute return over a single time period
#' @param n the number of time periods over which to compute the
#'     logarithmic return
#' @return a relative (log) percent return
#' @export
absolute_to_relative <- function(r_n, n) n * log(1 + r_n / n)


### Numerics

## If a number in a vector is negative, set it to 0
trunc_neg <- function (xs) purrr::map(xs, function(x) max(x, 0))
