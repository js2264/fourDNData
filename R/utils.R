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

#' @importFrom utils read.delim2

.parse4DNMetadata <- function() {
    tab <- system.file('extdata', 'aggr_metadata.csv', package = 'fourDNData')
    dat <- utils::read.delim2(tab)
    dat <- dat[dat$Open.Data.URL != 'N/A', ]
    dat <- dat[!grepl('px2', dat$File.Download.URL), ]
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
    dat <- dat[, c(
        2, #experimentSetAccession
        7, #fileType
        5, #size
        12, #organism
        19, #experimentType
        21, #details
        23, #dataset
        24, #condition
        22, #biosource
        11, #biosourceType
        18, #publication
        31  #URL
    )]
    colnames(dat) <- c('experimentSetAccession', 'fileType', 'size', 'organism', 'experimentType', 'details', 'dataset', 'condition', 'biosource', 'biosourceType', 'publication', 'URL')
    dat$size <- as.numeric(dat$size)
    return(dat)
}

.checkEntry <- function(entry, dat, with_ID = FALSE) {
    if (nrow(entry) == 0) {
        if (with_ID) {
            warning('Unknown `experimentSetAccession`.\n  ', 
                'Please check which experimentSetAccession IDs are available \n  ', 
                'from 4DN consortium in the data frame returned by fourDNData().'
            )
        }
        return(dat)
    }
    TRUE
}
