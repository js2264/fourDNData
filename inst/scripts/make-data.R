### ----------  Fetch 4DN HiC datasets

# Download metadata csv files from 4DN data portal (access = MBL*****, key = gpotorjy******)
# Run curL commands to fetch files:
#        cut -f 1 ../metadata_2022-12-01-15h-29m.tsv | tail -n +3 | grep -v ^# | grep ".mcool" | xargs -n 1 curl -O -L --speed-limit 1048576 --speed-time 60 --user ...
#        cut -f 1 ../metadata_2022-12-01-15h-24m.tsv | tail -n +3 | grep -v ^# | grep ".mcool" | xargs -n 1 curl -O -L --speed-limit 1048576 --speed-time 60 --user ...
#        cut -f 1 ../metadata_2022-12-01-15h-30m.tsv | tail -n +3 | grep -v ^# | grep ".mcool" | xargs -n 1 curl -O -L --speed-limit 1048576 --speed-time 60 --user ...
#        cut -f 1 ../metadata_2022-12-01-15h-32m.tsv | tail -n +3 | grep -v ^# | grep ".mcool" | xargs -n 1 curl -O -L --speed-limit 1048576 --speed-time 60 --user ...
# metadata_files <- list.files('inst/extdata/', pattern = 'metadata_', full.names = TRUE)
# dfs <- lapply(metadata_files, vroom::vroom, comment = '#', col_names = TRUE, .name_repair = 'universal') |> 
#     dplyr::bind_rows() |> 
#     dplyr::filter(File.Format == 'mcool')
# dfs <- dplyr::select(dfs, 
#    File.Accession, 
#    Publication, 
#    Experimental.Lab,
#    Experiment.Type, 
#    Biosource, 
#    Biosource.Type, 
#    Organism, 
#    Condition, 
#    Assay.Details
# )
# colnames(dfs) <- c(
#    'ID', 
#    'Ref', 
#    'Lab', 
#    'Type', 
#    'Biosource', 
#    'Biosource_type', 
#    'Organism', 
#    'Condition', 
#    'Details'
# )
# fourDNDataFiles <- dfs
# fourDNDataFiles$EHID <- ..............................................
# fourDNDataFiles <- as.data.frame(fourDNDataFiles)
# usethis::use_data(fourDNDataFiles)
