## Portfolios
## ----------
##
## A portfolio has type:
## [Name :: (Asset, Amount)]

#' Create a portfolio
#'
#' Creates a portfolio of holdings and the amount held.
#'
#' @param asset_names a vector of strings identifying each holding
#' @param assets a vector of \code{asset} objects
#' @param amounts a vector of the dollar amount held for each holding
#' @return a new \code{portfolio} object
#' @export
make_portfolio <- function (asset_names, assets, amounts) {
    portfolio <- purrr::map2(assets, amounts, function(x, y) c(x, y))
    names(portfolio) <- asset_names
    portfolio
}

#' @rdname make_portfolio
#' @param portfolio the portfolio to return information from
#' @export
get_assets <- function(portfolio) {
    purrr::map(portfolio, function(a) a[[1]])
}

#' @rdname make_portfolio
#' @export
get_amounts <- function(portfolio) {
    purrr::map(portfolio, function(a) a[[2]])
}

#' @rdname make_portfolio
#' @export
get_total <- function (portfolio) {
    amounts <- investmentsim::get_amounts(portfolio)
    purrr::reduce(amounts, function(total, a) total + a, .init = 0)
}

#' Update a portfolio
#'
#' Updates a portfolio from a named list of new amounts
#'
#' @param portfolio a portfolio object
#' @param changed_amounts a named list indicating to what the balance
#'     of an asset should be changed
#' @param nonneg a boolean indicating if only nonnegative amounts are
#'     allowed for an asset balance. Use \code{FALSE} to indicate that
#'     negative values are allowed.
#' @return the updated portfolio
#' @export
change_amounts <- function(portfolio, changed_amounts, nonneg=TRUE) {
    assets <- investmentsim::get_assets(portfolio)
    amounts <- investmentsim::get_amounts(portfolio)
    new_amounts <- replace(amounts, names(changed_amounts), changed_amounts)
    ## Whether we allow negative portfolio amounts.
    if (nonneg) new_amounts <- purrr::map(new_amounts, function(x) max(x, 0))
    investmentsim::make_portfolio(names(portfolio), assets, new_amounts)
}

#' Rebalance a portfolio
#' 
#' Rebalance a portfolio according to an allocation while applying any
#' additional transactions.
#'
#' @param portfolio a \code{portfolio} object
#' @param allocation an allocation indicating target percents for rebalancing
#' @param transaction any transaction to be applied before rebalancing
#' @param nonneg a boolean indicating if only nonnegative amounts are
#'     allowed for an asset balance. Use \code{FALSE} to indicate that
#'     negative values are allowed.
#' @return the rebalanced portfolio
#' @export
rebalance <- function(portfolio, allocation, transaction, nonneg=TRUE) {
    total <- investmentsim::get_total(portfolio) + transaction
    investmentsim::change_amounts(portfolio, total * allocation, nonneg)
}
