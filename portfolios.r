### Portfolios
## [Name :: (Asset, Amount)]

make_portfolio <- function (asset_names, assets, amounts) {
    portfolio <- map2(assets, amounts, function(x, y) c(x,y))
    names(portfolio) <- asset_names
    portfolio
}

get_assets <- function(portfolio) {
    map(portfolio, function(a) a[[1]])
}

get_amounts <- function(portfolio) {
    map(portfolio, function(a) a[[2]])
}

get_total <- function (portfolio) {
    amounts <- get_amounts(portfolio)
    reduce(amounts, function(total, a) total + a, .init=0)
}

## Update a portfolio from a named list of new_amounts.
change_amounts <- function(portfolio, changed_amounts, nonneg=TRUE) {
    assets <- get_assets(portfolio)
    amounts <- get_amounts(portfolio)
    new_amounts <- replace(amounts, names(changed_amounts), changed_amounts)
    ## Whether we allow negative portfolio amounts.
    if(nonneg) {new_amounts <- map(new_amounts, function(x) max(x, 0))}
    make_portfolio(names(portfolio), assets, new_amounts)
}

## Rebalance a portfolio according to an allocation while applying any
## additional transactions.
rebalance <- function(portfolio, allocation, transaction, nonneg=TRUE) {
    total <- get_total(portfolio) + transaction
    change_amounts(portfolio, total*allocation, nonneg)
}
