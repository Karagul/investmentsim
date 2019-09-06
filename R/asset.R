#' @importFrom magrittr %>%
NULL

#' Assets
#' ------
#' An Asset has type: Time -> Time -> Return
#' 
#' An asset is identified with an accumulator. It takes an increment and
#' returns the asset's percent change over that increment.
#'
#' An asset should in addition have as an attribute 'dates' the vector
#' of dates over which it is defined. If left as 'NULL' it is assumed
#' to be valid for any date.

## TODO
## time series models - GARCH, GBM
## randomized historical assets - assets generated from random samples
## of historical assets

### Functions for computing returns from other data
## From prices of a security

#' Compute absolute returns of an asset
#'
#' Computes the absolute returns of an asset given its prices over
#' some regular period, that is \eqn{ \frac{x_k - x_{k-1}}{x_{k-1}}}.
#'
#' @param x A time-series of prices
#' @export
make_returns <- function(x) diff(x) / x[-length(x)]

#' Compute relative returns of an asset
#'
#' Computes the relative returns of an asset given its prices over
#' some regular period, that is \eqn{ \log{\frac{x_k}{x_{k-1}}}}.
#'
#' @param x A vector of prices
#' @export
make_relative_returns <- function(x) diff(log(x))

## From the interest rates on a 10-year Treasury note
## Computes the change in price of the note due to the change in
## interest rate, based on the present-value valuation.
note_return <- function(r1, r2) {
    coupon <- r1
    numpd <- 10
    yield <- r2 / 100
    cf <- c(rep(coupon, numpd - 1), 100 + coupon)
    pv <- sum(cf * (1 + yield) ^ (-(1:numpd)))
    coupon + (pv - 100)
}

## TODO - vectorized note_return
make_note_returns <- function(x) stop("TODO")


### Assets
get_start <- function(asset) first(index(asset))

### Historical Assets

#' Make an asset from a time series of absolute (ordinary) returns
#'
#' @param ts an \code{xts} time-series of absolute returns
#' @importFrom magrittr %>%
#' @export
make_historical <- function (ts) {
    f <- function(s, e) {
        returns <- ts[paste0(s, "::", e)] %>% tail(-1)
        prod(1 + returns)
    }
    attributes(f)$dates <- zoo::index(ts)
    f
}

#' Make an asset from a time series of relative (log) returns
#'
#' @param ts an \code{xts} time-series of relative returns
#' @export
make_relative_historical <- function (ts) {
    f <- function(s, e) exp(sum(ts[paste0(s, "::", e)]))
    attributes(f)$dates <- zoo::index(ts)
    f
}

#' Make a bootstrap-sampled series of returns
#'
#' Creates a time-series of returns sampled from historical data, with
#' the sampling respecting time dependence.
#' 
#' @param ts an \code{xts} time-series of absolute returns
#' @export
make_bootstrap_historical <- function(ts, block_size=5) {
    bts <- investmentsim::make_geom_block_sample(ts, block_size, 1)
    bts <- xts::xts(bts, order.by = zoo::index(ts))
    investmentsim::make_historical(bts)
}
