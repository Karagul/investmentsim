#' Create a financial path
#'
#' Evaluates the model given in \code{model} by stepping through the
#' given dates and applying transformations as follows: adjust for
#' returns over the preceeding period, apply contributions or
#' withdrawals (transactions), rebalance according to the given
#' allocations.
#'
#' @param model a named list containing \code{transactions},
#'     \code{allocations}, \code{portfolio}, \code{asset_names}, and
#'     \code{dates}
#' @param nonneg whether to disallow a negative balance. Setting this
#'     to \code{FALSE} (allowing a negative balance) can be useful for
#'     understanding shortfalls.
#' @param verbose whether to output diagnostic information. Currently unused.
#' @return a financial path, which is an \code{xts} timeseries
#'     containing balances for each holding and the total balance, as
#'     well as any transactions that occured and the investment return
#'     as a percent change.
#' @examples
#' library(tidyverse)
#' library(zoo)
#' library(lubridate)
#' ## Create a model and financial path
#' 
#' # Time series of returns
#' data(simreturns)
#' 
#' # Historical assets
#' simstock_asset <- make_historical(simreturns)
#' simbond_asset <- make_historical(simreturns)
#' dates <- as_datetime(index(simreturns))
#'
#' # Portfolio with S&P 500 and 10-year T-bonds. Yearly transaction
#' # of $1000. Linear allocation.
#' holdings <- c("stocks", "bonds")
#' port <- make_portfolio(holdings,
#'                        c(simstock_asset,
#'                          simbond_asset),
#'                          c(0,0))
#' alloc <- make_linear_allocation_path(holdings,
#'                                     c(ymd("1990-01-01"), ymd("2000-01-01")),
#'                                     list(c(0.9, 0.1), c(0.6, 0.4)))
#' trans <- make_transactions_on_dates(rep(1000, length(dates)),
#'                                     dates)
#' model <- make_model(port, alloc, trans, dates)
#'
#' # Evaluate the model
#' path <- make_path(model)
#' @importFrom magrittr %>%
#' @export
make_path <- function(model, nonneg=TRUE, verbose=FALSE) {
    transactions <- model$transactions
    allocations <- model$allocations
    portfolio <- model$portfolio
    asset_names <- names(portfolio)
    dates <- model$dates
    ## Allocate an empty path and set its starting values
    path <- xts::xts(matrix(,
                       nrow=length(dates),
                       ncol=length(asset_names) + 3,
                       dimnames=list(c(), c(asset_names, "total", "trans", "return")),
                       ),
                order.by = dates)
    path <- investmentsim::update_path(path, dates[[1]], portfolio, 0, 0)
    ## Step through the list of dates, accumulate returns,
    ## apply transactions, and rebalance
    start_dates <- head(dates, -1)
    end_dates <- tail(dates, -1)
    for( i in 1:length(end_dates) ) {
        start <- start_dates[[i]]
        end <- end_dates[[i]]
        for (name in asset_names) {
            asset <- portfolio[[name]][[1]]
            old_amount <- portfolio[[name]][[2]]
            new_amount <- old_amount*asset(start, end)
            portfolio[[name]][[2]] <- new_amount
        }
        trans <- transactions(end)
        alloc <- allocations(end)
        portfolio <- investmentsim::rebalance(portfolio, alloc, trans, nonneg)
        path <- investmentsim::update_path(path, end, portfolio, trans, 0)
    }
    path
}


#' Sets values in the financial path
#'
#' @export
update_path <- function(path, date, portfolio, trans, return) {
    asset_names <- names(portfolio)
    for (name in asset_names) {
        path[date, name] <- portfolio[[name]][[2]]
    }
    path[date, "total"] <- investmentsim::get_total(portfolio)
    path[date, "trans"] <- trans
    path[date, "return"] <- return
    path
}
