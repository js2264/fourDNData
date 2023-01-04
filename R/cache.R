#' @name fourDNDataCache
#'
#' @title Manage cache / download files from the 4DN data portal
#'
#' @description Managing 4DN data downloads via the integrated
#' `BiocFileCache` system.
#'
#' @param ... For `fourDNDataCache`, arguments passed to `.setFourDNDataCache`
#'
#' @examples
#' getOption("fourDNDataCache")
#' fourDNDataCache()
#'
#' @import BiocFileCache
#' @importFrom tools R_user_dir
#' @export

fourDNDataCache <- function(...) {
    cache <- getOption("fourDNDataCache", .setFourDNDataCache(..., verbose = FALSE))
    BiocFileCache::BiocFileCache(cache)
}

#' @rdname fourDNDataCache

.setFourDNDataCache <- function(
    directory = tools::R_user_dir("fourDNData", "cache"),
    verbose = TRUE,
    ask = interactive()
) {
    stopifnot(
        is.character(directory), length(directory) == 1L, !is.na(directory)
    )

    if (!dir.exists(directory)) {
        if (ask) {
            qtxt <- sprintf(
                "Create fourDNData cache at \n    %s? [y/n]: ",
                directory
            )
            answer <- .getAnswer(qtxt, allowed = c("y", "Y", "n", "N"))
            if ("n" == answer)
                stop("'fourDNData' directory not created. Use 'setCache'")
        }
        dir.create(directory, recursive = TRUE, showWarnings = FALSE)
    }
    options("fourDNData" = directory)

    if (verbose)
        message("fourDNData cache directory set to:\n    ", directory)
    invisible(directory)
}

#' @rdname fourDNDataCache

.get4DNData <- function(expSetAccession, type = 'mcool', verbose = FALSE) {
    dat <- .parse4DNMetadata()
    subdat <- dat[dat$Experiment.Set.Accession == expSetAccession, ]
    fileinfo <- NULL
    if (type %in% c('boundaries', 'insulation', 'compartments')) {
        fileinfo <- as.list(subdat[grepl(type, subdat$File.Type), ])
    }
    else if (type %in% c('pairs', 'hic', 'mcool')) {
        fileinfo <- as.list(subdat[which(subdat$File.Format == type), ])
    }
    if (is.null(fileinfo)) stop("No matching file type.")
    bfc <- fourDNDataCache()
    rid <- bfcquery(bfc, query = basename(fileinfo$Open.Data.URL))$rid
    if (!length(rid)) {
        if( verbose ) message( "Fetching Hi-C data from 4DN" )
        bfcentry <- bfcadd( 
            bfc, 
            rname = basename(fileinfo$Open.Data.URL), 
            fpath = fileinfo$Open.Data.URL 
        )
        rid <- names(bfcentry)
    }
    bfcrpath(bfc, rids = rid)
}
