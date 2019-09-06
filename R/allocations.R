## Allocations
## -----------

#' Check that allocation percents sum to 1.0
#'
#' @export
check_allocation <- function (percents) {
    if (sum(percents) != 1.0) {
        stop(paste("Percents must sum to 1.0:", percents))
    }
}

#' Create a portfolio allocation path
#'
#' @importFrom magrittr %>%
#' @export
make_allocation <- function (asset_names, percents) {
    investmentsim::check_allocation(percents)
    a <- percents
    names(a) <- asset_names
    a %>% unlist
}

#' Create a constant allocation path
#'
#' The same allocation, forever.
#'
#' @export
make_constant_allocation_path <- function (asset_names, percents) {
    a <- investmentsim::make_allocation(asset_names, percents)
    function (t) a
}

#' Creates an allocation path with discrete steps
#' 
#' Give a list of n asset_names, a list of k dates, and k+1 lists of n
#' percents, will return an allocation function that changes stepwise
#' from one percent to the next on the specified dates. The first
#' allocation is the beginning, and should not have a date.
#'
#' @importFrom magrittr %>%
#' @export
make_step_allocation_path <- function(asset_names,
                                      change_dates,
                                      asset_percents) {
    allocations <- purrr::map(asset_percents,
                       function (ps) make_allocation(asset_names, ps))
    function (t) {
        end_p <- investmentsim::find_end_position(change_dates, t)
        ifelse(is.na(end_p),
               last(allocations),
               allocations[end_p]) %>% unlist
    }
}

#' Create an allocation path with linear interpolation
#'
#' Give a list of n asset_names, a list of k dates, and k+1 lists of n
#' percents, will return an allocation function that changes by linear
#' interpolation from one percent to the next on the specified dates.
#' If a date is given before the first change or after the last
#' change, it returns a constant allocation.
#'
#' @importFrom magrittr %>%
#' @export
make_linear_allocation_path <- function(asset_names,
                                        change_dates,
                                        asset_percents) {
    ## the "anchors" through which we interpolate
    allocations <- purrr::map(asset_percents,
                       function (ps) make_allocation(asset_names, ps))
    function (t) {
        begin_p <- investmentsim::find_begin_position(change_dates, t)
        end_p <- investmentsim::find_end_position(change_dates, t)

        if (is.na(begin_p)) {
            dplyr::first(allocations) %>% unlist
        } else if (is.na(end_p)) {
            dplyr::last(allocations) %>% unlist
        } else {
            begin <- investmentsim::find_begin(change_dates, t)
            end <- investmentsim::find_end(change_dates, t)
            p <- investmentsim::proportion_elapsed(begin, t, end)
            begin_alloc <- allocations[begin_p] %>% unlist
            end_alloc <- allocations[end_p] %>% unlist
            begin_alloc * (1 - p) + end_alloc * p
        }
    }
}