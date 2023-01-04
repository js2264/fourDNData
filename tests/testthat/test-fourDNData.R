context("test-fourDNDataFiles")

test_that("fourDNDataFiles function works", {
    expect_equal({
        s <- fourDNDataFiles(id = "4DNFIJTOIGOI")
        isTRUE(nzchar(s, keepNA = TRUE))
    }, TRUE)
})
