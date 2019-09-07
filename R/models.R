## Models
## ------
##
## A model has type:
##
## Model
## { initial_portfolio :: Portfolio
## , allocation_trajectory :: Allocations
## , transaction_trajectory :: Transactions
## , dates :: Dates
## }

#' Create a model object
#'
#' Creates a model object for use in financial paths.
#'
#' @param portfolio a \code{portfolio} object
#' @param allocations an \code{allocation} object
#' @param transactions a \code{transaction} object
#' @param dates A vector of dates over which the model should be
#'     simulated.
#' @export
make_model <- function (portfolio, allocations, transactions, dates) {
    model <- list(portfolio, allocations, transactions, dates)
    names(model) <- c("portfolio", "allocations", "transactions", "dates")
    model
}

#' An empty model
#'
#' Creates a model containing only a portfolio and an allocation.
#' Useful for setting up subsimulations with varying transaction paths
#' and dates.
#'
#' @param portfolio a \code{portfolio} object
#' @param allocations an \code{allocation} object
#' @export
make_empty_model <- function(portfolio, allocations) {
    investmentsim::make_model(portfolio, allocations, NA, NA)
}
