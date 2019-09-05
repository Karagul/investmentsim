library(tidyverse)
library(lubridate)
library(xts)

source("~/MEGA/Programming/retirement/investmentsim/util.r")
source("~/MEGA/Programming/retirement/investmentsim/asset.r")
source("~/MEGA/Programming/retirement/investmentsim/allocations.r")
source("~/MEGA/Programming/retirement/investmentsim/transactions.r")
source("~/MEGA/Programming/retirement/investmentsim/portfolios.r")
source("~/MEGA/Programming/retirement/investmentsim/models.r")

## Financial Paths
make_path <- function(model, nonneg=TRUE, noisy=FALSE) {
    transactions <- model$transactions
    allocations <- model$allocations
    portfolio <- model$portfolio
    asset_names <- names(portfolio)
    dates <- model$dates
    ## Allocate an empty path and set its starting values
    path <- xts(matrix(,
                       nrow=length(dates),
                       ncol=length(asset_names) + 3,
                       dimnames=list(c(), c(asset_names, "total", "trans", "return")),
                       ),
                order.by = dates)
    path <- update_path(path, dates[[1]], portfolio, 0, 0)
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
        portfolio <- rebalance(portfolio, alloc, trans, nonneg)
        path <- update_path(path, end, portfolio, trans, 0)
    }
    path
}

update_path <- function(path, date, portfolio, trans, return) {
    asset_names <- names(portfolio)
    for (name in asset_names) {
        path[date, name] <- portfolio[[name]][[2]]
    }
    path[date, "total"] <- get_total(portfolio)
    path[date, "trans"] <- trans
    path[date, "return"] <- return
    path
}
