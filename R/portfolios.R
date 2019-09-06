## Portfolios
## ----------
##
## A portfolio has type:
## [Name :: (Asset, Amount)]

#' Create a portfolio
#'
#' Creates a portfolio of holdings and the amount held.
#'
#' @param asset_names A vector of strings identifying each holding
#' @param assets A vector of \code{asset} objects
#' @param amounts A vector of the dollar amount held for each holding
#' @export
make_portfolio <- function (asset_names, assets, amounts) {
    portfolio <- purrr::map2(assets, amounts, function(x, y) c(x, y))
    names(portfolio) <- asset_names
    portfolio
}

#' @rdname make_portfolio
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

#' Update a portfolio from a named list of new_amounts
#'
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
#' @export
rebalance <- function(portfolio, allocation, transaction, nonneg=TRUE) {
    total <- investmentsim::get_total(portfolio) + transaction
    investmentsim::change_amounts(portfolio, total * allocation, nonneg)
}
