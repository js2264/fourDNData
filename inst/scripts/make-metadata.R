# -- 4DN data
data(fourDNDataFiles)
fourDNdata <- lapply(seq_len(nrow(fourDNDataFiles)), function(i) {
    Title <- glue::glue(".mcool file of 4DN dataset {fourDNDataFiles$ID}")[i]
    Description <- glue::glue("{fourDNDataFiles$Type}, {fourDNDataFiles$Condition} [{fourDNDataFiles$ID} - {fourDNDataFiles$Ref}]")[i]
    BiocVersion <- 3.17
    Genome <- dplyr::case_when(
        fourDNDataFiles$Organism[i] == 'human' ~ NA,
        fourDNDataFiles$Organism[i] == 'mouse' ~ NA,
        fourDNDataFiles$Organism[i] == 'chicken' ~ NA,
        fourDNDataFiles$Organism[i] == 'zebrafish' ~ NA,
        fourDNDataFiles$Organism[i] == 'fruit fly' ~ NA
    )
    SourceType <- "TXT"
    SourceUrl <- glue::glue("https://data.4dnucleome.org/experiment-set-replicates/{fourDNDataFiles$ID}/")[i]
    SourceVersion <- "Dec 1 2022"
    Species <- dplyr::case_when(
        fourDNDataFiles$Organism[i] == 'human' ~ NA,
        fourDNDataFiles$Organism[i] == 'mouse' ~ NA,
        fourDNDataFiles$Organism[i] == 'chicken' ~ NA,
        fourDNDataFiles$Organism[i] == 'zebrafish' ~ NA,
        fourDNDataFiles$Organism[i] == 'fruit fly' ~ NA
    )
    TaxonomyId <- dplyr::case_when(
        fourDNDataFiles$Organism[i] == 'human' ~ NA,
        fourDNDataFiles$Organism[i] == 'mouse' ~ NA,
        fourDNDataFiles$Organism[i] == 'chicken' ~ NA,
        fourDNDataFiles$Organism[i] == 'zebrafish' ~ NA,
        fourDNDataFiles$Organism[i] == 'fruit fly' ~ NA
    )
    Coordinate_1_based <- FALSE
    DataProvider <- "Jacques Serizay"
    Maintainer <- "Jacques Serizay <jacquesserizay@gmail.com>"
    RDataClass <- "character"
    DispatchClass <- "FilePath"
    RDataPath <- glue::glue("fourDNData/{fourDNDataFiles$ID}.mcool")[i]
    Tags <- "HiCData"
    list(
        Title = Title, 
        Description = Description, 
        BiocVersion = BiocVersion, 
        Genome = Genome, 
        SourceType = SourceType, 
        SourceUrl = SourceUrl, 
        SourceVersion = SourceVersion, 
        Species = Species, 
        TaxonomyId = TaxonomyId, 
        Coordinate_1_based = Coordinate_1_based, 
        DataProvider = DataProvider, 
        Maintainer = Maintainer, 
        RDataClass = RDataClass, 
        DispatchClass = DispatchClass, 
        RDataPath = RDataPath, 
        Tags = Tags
    )
})
fourDNdata <- do.call(rbind, fourDNdata) |> as.data.frame() |> apply(2, unlist) |> as.data.frame()
fourDNdata$BiocVersion <- as.numeric(fourDNdata$BiocVersion)
fourDNdata$TaxonomyId <- as.numeric(fourDNdata$TaxonomyId)

# -- Cat everything
write.csv(fourDNdata, file = "inst/extdata/metadata.csv", row.names = FALSE)
