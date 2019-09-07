test_that("absolute returns give expected value", {
    expect_equal(mean(make_returns(c(1, 1, 1, 1, 1))), 0)
})

test_that("relative returns give expected value", {
    expect_equal(mean(make_relative_returns(c(1, 1, 1, 1, 1))), 0)
})
