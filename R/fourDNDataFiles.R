#' fourDNData
#'
#' @description Fetches files from the 4DN data portal and cache them using 
#'   the BiocFileCache system. 
#' @param experimentSetAccession  
#' @param type any of c('pairs', 'hic', 'mcool', 'boundaries', 
#'   'insulation', 'compartments')
#' @param .fetch_pairs Whether to also download the associated pairs file
#' 
#' @return Local path of the queried file cached with BiocFileCache.
#' @export
#' 
#' @examples
#' ####################################
#' ## Importing individual 4DN files ##
#' ####################################
#' 
#' head(fourDNDataFiles())
#' mcf <- fourDNDataFiles(experimentSetAccession = '4DNESDP9ECMN', type = 'mcool')
#' mcf
#' 
#' ####################################
#' ## Importing full 4DN experiments ##
#' ####################################
#' 
#' id <- fourDNDataFiles() |>
#'   dplyr::filter(
#'      Experiment.Type == 'in situ Hi-C', 
#'      Biosource == 'GM12878', 
#'      Publication == 'Sanborn AL et al. (2015)'
#'   ) |> 
#'   dplyr::arrange(Size..MB.) |> 
#'   dplyr::pull(Experiment.Set.Accession) |> 
#'   unique()
#' id[1]
#' x <- fourDNHiCExperiment(id[1])
#' x
#' topologicalFeatures(x)
#' metadata(x)$`4DN_info`
NULL 

#' @export

fourDNDataFiles <- function(experimentSetAccession = NULL, type = "mcool") {
    dat <- .parse4DNMetadata()
    entry <- dat[dat$Experiment.Set.Accession == experimentSetAccession, ]
    x <- .checkEntry(entry, dat, with_ID = !is.null(experimentSetAccession))
    if(!isTRUE(x)) return(x)
    res <- .get4DNData(experimentSetAccession, type)
    return(res[[1]])
}

#' @export

fourDNHiCExperiment <- function(experimentSetAccession, .fetch_pairs = FALSE) {
    bfc <- fourDNDataCache()
    dat <- .parse4DNMetadata()
    entry <- dat[dat$Experiment.Set.Accession == experimentSetAccession, ]
    url_map <- entry[entry$File.Format == 'mcool', 'Open.Data.URL']
    url_compartments <- entry[entry$File.Type == 'compartments', 'Open.Data.URL']
    url_insulation <- entry[entry$File.Type == 'insulation score-diamond', 'Open.Data.URL']
    url_borders <- entry[entry$File.Type == 'boundaries', 'Open.Data.URL']
    url_pairs <- entry[entry$File.Format == 'pairs', 'Open.Data.URL']
    
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
        fileinfo <- as.list(entry[entry$File.Format == 'mcool',])
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
        `4DN_info` = fileinfo[c(2, 11, 12, 18, 19, 21, 22, 23, 24)]
    )
    if (!length(url_compartments)) {
        topo_compartments <- GenomicRanges::GRanges()
        res <- HiCExperiment::lsCoolResolutions(bfcrpath(bfc, rids = rid_map))
        res <- res[length(res)]
    } else {
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
        pairsFile(x) <- rid_pairs
    }

    return(x)
}
