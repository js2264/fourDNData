#' @name fourDNDataCache
#'
#' @title Manage cache / download files from the 4DN data portal
#'
#' @description Managing 4DN data downloads via the integrated
#' `BiocFileCache` system.
#'
#' @param ... Arguments passed to internal `.setFourDNDataCache` function
#'
#' @import BiocFileCache
#' @importFrom tools R_user_dir
#' @export 
#' @examples
#' bfc <- fourDNDataCache()
#' bfc
#' BiocFileCache::bfcinfo(bfc)
#'

fourDNDataCache <- function(...) {
    cache <- getOption("fourDNDataCache", .setFourDNDataCache(..., verbose = FALSE))
    BiocFileCache::BiocFileCache(cache)
}

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

.get4DNData <- function(expSetAccession, type = 'mcool', verbose = FALSE) {
    dat <- .parse4DNMetadata()
    subdat <- dat[dat$experimentSetAccession == expSetAccession, ]
    if (nrow(subdat[grepl(type, subdat$fileType), ]) == 0) stop("No matching file type.")
    fileinfo <- as.list(subdat[grepl(type, subdat$fileType), ])
    bfc <- fourDNDataCache()
    rid <- bfcquery(bfc, query = basename(fileinfo$URL))$rid
    if (!length(rid)) {
        if( verbose ) message( "Fetching Hi-C data from 4DN" )
        bfcentry <- bfcadd( 
            bfc, 
            rname = basename(fileinfo$URL), 
            fpath = fileinfo$URL 
        )
        rid <- names(bfcentry)
    }
    bfcrpath(bfc, rids = rid)
}
