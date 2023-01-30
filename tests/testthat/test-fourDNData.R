context("test-fourDNData")

test_that("fourDNData function works", {
    s <- fourDNData(experimentSetAccession = "4DNESDP9ECMN", type = 'mcool')
    s2 <- fourDNHiCExperiment("4DNES4JNDDVX")
    expect_no_warning(fourDNData())
    expect_error(fourDNData('sdvsd'))
    expect_true(isTRUE(nzchar(s, keepNA = TRUE)))
    expect_s4_class(s2, 'HiCExperiment')
})
