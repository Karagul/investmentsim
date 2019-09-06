## Transactions
## ------------
##
## A transaction has type:
## Time -> Amount

#' A non-transaction
#' 
#' A transaction that does nothing.
#'
#' @param date a date
#' @export
no_transactions <- function(date) 0

#' Create a transaction path
#' 
#' Creates a transaction path the applies each transaction on a given date.
#'
#' @param amounts a vector of dollar amounts; positive numbers are
#'     contributions and negative numbers are withdrawals
#' @param dates a vector of the dates on which each transaction occurs
#' @export
make_transactions_on_dates <- function (amounts, dates) {
    function (t) {
        pos <- Position(function(d) t == d, dates)
        ifelse(is.na(pos),
               0,
               amounts[[pos]])
    }
}
