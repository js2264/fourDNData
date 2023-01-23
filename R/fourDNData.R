#' @title fourDNData
#' @name fourDNData
#' @aliases fourDNHiCExperiment
#'
#' @description Fetches files from the 4DN data portal and caches them using 
#'   the BiocFileCache system. 
#' @param experimentSetAccession Any 4DN-provided experimentSet Accession number
#' (check https://data.4dnucleome.org/browse/) for a browser-based 
#' explorer.
#' @param type any of c('pairs', 'hic', 'mcool', 'boundaries', 
#'   'insulation', 'compartments')
#' @param .fetch_pairs Whether to also download the associated pairs file
#' 
#' @return `fourDNData()` returns the local path of the queried file
#' cached with BiocFileCache. `fourDNHiCExperiment()` returns a 
#' `HiCExperiment` object with populated metadata and topologicalFeatures (
#' if available). 
#' @importFrom GenomicRanges width
#' @importFrom GenomicRanges GRanges
#' @importFrom IRanges reduce
#' @importFrom S4Vectors metadata
#' @export
#' 
#' @examples
#' ####################################
#' ## Importing individual 4DN files ##
#' ####################################
#' 
#' head(fourDNData())
#' mcf <- fourDNData(experimentSetAccession = '4DNESDP9ECMN', type = 'mcool')
#' mcf
#' 
#' ####################################
#' ## Importing full 4DN experiments ##
#' ####################################
#' 
#' id <- fourDNData() |>
#'   dplyr::filter(
#'      experimentType == 'in situ Hi-C', 
#'      biosource == 'GM12878', 
#'      publication == 'Sanborn AL et al. (2015)'
#'   ) |> 
#'   dplyr::arrange(size) |> 
#'   dplyr::pull(experimentSetAccession) |> 
#'   unique()
#' id[1]
#' x <- fourDNHiCExperiment(id[1])
#' x
#' HiCExperiment::topologicalFeatures(x)
#' S4Vectors::metadata(x)$`4DN_info`
NULL 

#' @export

fourDNData <- function(experimentSetAccession = NULL, type = NULL) {
    dat <- .parse4DNMetadata()
    if (is.null(experimentSetAccession)) return(dat)
    entry <- dat[dat$experimentSetAccession == experimentSetAccession, ]
    if (is.null(type)) return(entry)
    x <- .checkEntry(entry, dat, with_ID = !is.null(experimentSetAccession))
    if(!isTRUE(x)) return(x)
    res <- .get4DNData(experimentSetAccession, type)
    return(res[[1]])
}

#' @export

fourDNHiCExperiment <- function(experimentSetAccession, .fetch_pairs = FALSE) {
    bfc <- fourDNDataCache()
    dat <- .parse4DNMetadata()
    entry <- dat[dat$experimentSetAccession == experimentSetAccession, ]
    url_map <- entry[entry$fileType == 'mcool', 'URL']
    url_compartments <- entry[entry$fileType == 'compartments', 'URL']
    url_insulation <- entry[entry$fileType == 'insulation', 'URL']
    url_borders <- entry[entry$fileType == 'boundaries', 'URL']
    url_pairs <- entry[entry$fileType == 'pairs', 'URL']
    
    # - Fetch contact map, compartments, insulation and borders
    if (!length(url_map)) {
        stop("Contact map not found for the provided experimentSet accession.")
    } else {
        rid_map <- bfcquery(bfc, query = basename(url_map))$rid
        if (!length(rid_map)) {
            message( "Fetching Hi-C contact map from 4DN portal" )
            bfcentry <- bfcadd( 
                bfc, 
                rname = basename(url_map), 
                fpath = url_map 
            )
            rid_map <- names(bfcentry)
        } 
        else {
            message( "Fetching local Hi-C contact map from Bioc cache" )
        }
        fileinfo <- as.list(entry[entry$fileType == 'mcool',])
    }
    if (!length(url_compartments)) {
        message("Compartments not found for the provided experimentSet accession.")
        rid_compartments <- NULL
    } else {
        rid_compartments <- bfcquery(bfc, query = basename(url_compartments))$rid
        if (!length(rid_compartments)) {
            message( "Fetching compartments bigwig file from 4DN portal" )
            bfcentry <- bfcadd( 
                bfc, 
                rname = basename(url_compartments), 
                fpath = url_compartments 
            )
            rid_compartments <- names(bfcentry)
        }
        else {
            message( "Fetching local compartments bigwig file from Bioc cache" )
        }
    }
    if (!length(url_insulation)) {
        message("Insulation not found for the provided experimentSet accession.")
        rid_insulation <- NULL
    } else {
        rid_insulation <- bfcquery(bfc, query = basename(url_insulation))$rid
        if (!length(rid_insulation)) {
            message( "Fetching insulation bigwig file from 4DN portal" )
            bfcentry <- bfcadd( 
                bfc, 
                rname = basename(url_insulation), 
                fpath = url_insulation 
            )
            rid_insulation <- names(bfcentry)
        }
        else {
            message( "Fetching local insulation bigwig file from Bioc cache" )
        }
    }
    if (!length(url_borders)) {
        message("Borders not found for the provided experimentSet accession.")
        rid_borders <- NULL
    } else {
        rid_borders <- bfcquery(bfc, query = basename(url_borders))$rid
        if (!length(rid_borders)) {
            message( "Fetching borders bed file from 4DN portal" )
            bfcentry <- bfcadd( 
                bfc, 
                rname = basename(url_borders), 
                fpath = url_borders 
            )
            rid_borders <- names(bfcentry)
        }
        else {
            message( "Fetching local borders bed file from Bioc cache" )
        }
    }

    # - Import all files in memory
    meta <- list(
        `4DN_info` = fourDNData()[
            fourDNData()$experimentSetAccession == experimentSetAccession,
        ]
    )
    if (!length(url_compartments)) {
        topo_compartments <- GenomicRanges::GRanges()
        res <- HiCExperiment::lsCoolResolutions(bfcrpath(bfc, rids = rid_map))
        res <- res[length(res)]
    } else {
        if (requireNamespace("rtracklayer", quietly = TRUE)) {
            topo_compartments <- rtracklayer::import(bfcrpath(bfc, rids = rid_compartments))
            topo_compartments <- topo_compartments[!is.na(topo_compartments$score)]
            res <- max(GenomicRanges::width(topo_compartments))
            meta$eigens <- topo_compartments
            meta$eigens$eigen <- meta$eigens$score
            A <- IRanges::reduce(topo_compartments[topo_compartments$score > 0])
            A$compartment <- 'A'
            B <- IRanges::reduce(topo_compartments[topo_compartments$score < 0])
            B$compartment <- 'B'
            topo_compartments <- sort(c(A, B))
        }
        else {
            warning('Install `rtracklayer` package (`BiocManager::install("rtracklayer")`)\nto import 4DN eigen vectors stored as bigwig tracks in R.')
            topo_compartments <- GenomicRanges::GRanges()
            res <- HiCExperiment::lsCoolResolutions(bfcrpath(bfc, rids = rid_map))
            res <- res[length(res)]
        }
    }
    if (length(url_insulation)) {
        meta$diamond_insulation <- rtracklayer::import(bfcrpath(bfc, rids = rid_insulation), as = 'Rle')
    }
    if (!length(url_borders)) {
        topo_borders <- GenomicRanges::GRanges()
    } else {
        topo_borders <- rtracklayer::import(bfcrpath(bfc, rids = rid_borders))
    }
    message( "Importing contacts in memory" )
    x <- HiCExperiment::HiCExperiment(
        bfcrpath(bfc, rids = rid_map), 
        resolution = res, 
        metadata = meta, 
        topologicalFeatures = S4Vectors::SimpleList(
            compartments = topo_compartments,
            borders = topo_borders
        )
    )
    
    # - Pairs
    if (length(url_pairs) & .fetch_pairs) {
        rid_pairs <- bfcquery(bfc, query = basename(url_pairs))$rid
        if (!length(rid_pairs)) {
            message( "Fetching pairs file" )
            bfcentry <- bfcadd( 
                bfc, 
                rname = basename(url_pairs), 
                fpath = url_pairs 
            )
            rid_pairs <- names(bfcentry)
        }
        else {
            message( "Fetching pairs file from Bioc cache" )
        }
        HiCExperiment::pairsFile(x) <- rid_pairs
    }

    return(x)
}
