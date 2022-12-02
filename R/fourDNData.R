#' fourDNData
#'
#' @description Downloads .mcool files of 
#'   4DN experiments and returns the path of the cached file. 
#' @param id An ID corresponding to a 4DN experiment, matching one from the 
#'   `fourDNDataFiles$ID` column. 
#' 
#' @return Local path of the queried file cached with BiocFileCache.
#' @import ExperimentHub
#' @import AnnotationHub
#' @import BiocFileCache
#' @export
#' 
#' @examples
#' fourDNData(id = '4DNFI6CTC527')

fourDNData <- function(id = NULL) {
    
    data(fourDNDataFiles)
    ehub_entry <- fourDNDataFiles[
        which(fourDNDataFiles$ID == id), 
        "EHID"
    ]
    if (length(ehub_entry) == 0 | is.na(ehub_entry)) {
        if (!is.null(id)) {
            stop('Unknown `id`.\n  ', 
                'Please check which IDs are available from 4DN consortium in ', 
                'the `fourDNDataFiles` data frame.',
                '\n  Hint: load `fourDNDataFiles` with `data(fourDNDataFiles)`'
            )
        }
        else {
            return()
        }
    }
    ehub <- ExperimentHub::ExperimentHub()
    res <- ehub[[ehub_entry]]
    return(res)

}

