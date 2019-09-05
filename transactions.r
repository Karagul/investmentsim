### Transactions
## Time -> Amount

## No contributions. No withdrawals
no_transactions <- function(date) 0

## Give a n amounts to be transacted on n dates, one transaction for
## each date.
make_transactions_on_dates <- function (amounts, dates) {
    function (t) {
        pos <- Position(function(d) t == d, dates)
        ifelse(is.na(pos),
               0,
               amounts[[pos]])
    }
}
