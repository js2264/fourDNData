.getAnswer <- function(msg, allowed)
{
    if (interactive()) {
        repeat {
            cat(msg)
            answer <- readLines(n = 1)
            if (answer %in% allowed)
                break
        }
        tolower(answer)
    } else {
        "n"
    }
}

.parse4DNMetadata <- function() {
    tab <- system.file('extdata', 'aggr_metadata.csv', package = 'fourDNData')
    dat <- read.delim2(tab)
    dat <- dat[dat$Open.Data.URL != 'N/A', ]
    dat <- dat[!grepl('px2', dat$File.Download.URL), ]
    return(dat)
}

.checkEntry <- function(entry, dat, with_ID = FALSE) {
    if (nrow(entry) == 0) {
        dat <- dat[, c(2, 7, 8, 11, 12, 18, 19, 21, 22, 23, 24, 5)]
        dat$File.Type <- ifelse(
            dat$File.Format %in% c('pairs', 'hic', 'mcool'), 
            dat$File.Format, 
            ifelse(
                dat$File.Type %in% c('boundaries', 'compartments'), 
                dat$File.Type, 
                ifelse(
                    dat$File.Type == 'insulation score-diamond', 
                    'insulation', 
                    NA
                )
            )
        )
        dat$File.Format <- NULL
        if (with_ID) {
            warning('Unknown `experimentSetAccession`.\n  ', 
                'Please check which experimentSet accession IDs are available \n  ', 
                'from 4DN consortium in the data frame returned here.'
            )
        }
        return(dat)
    }
    TRUE
}
