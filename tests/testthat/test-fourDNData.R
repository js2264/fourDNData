context("test-fourDNData")

test_that("fourDNData function works", {
    expect_equal({
        s <- fourDNData(id = "4DNFIJTOIGOI")
        isTRUE(nzchar(s, keepNA = TRUE))
    }, TRUE)
})
