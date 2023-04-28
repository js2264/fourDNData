<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![rworkflows](https://github.com/js2264/fourDNData/actions/workflows/rworkflows.yml/badge.svg)](https://github.com/js2264/fourDNData/actions/workflows/rworkflows.yml)
<!-- badges: end -->

# fourDNData

fourDNData (read *4DN-Data*) is a data package giving programmatic access 
to Hi-C contact files uniformly processed by the 
[4DN consortium](https://www.4dnucleome.org/). 

The `fourDNData()` function provides a gateway to 4DN-hosted Hi-C files, 
including contact matrices (in `.hic` or `.mcool`) and other Hi-C derived 
files such as annotated compartments, domains, insulation scores, or pairs 
files.

The `fourDNHiCExperiment()` function recovers all 4DN-hosted Hi-C files 
associated with a single experimentSet Accession number. 

```r
library(fourDNData)
head(fourDNData())
fourDNData('4DNESDP9ECMN', type = 'compartments')
fourDNHiCExperiment('4DNESDP9ECMN')
```

## HiCExperiment ecosystem

`fourDNData` is integrated within the `HiCExperiment` ecosystem in Bioconductor. 
Read more about the `HiCExperiment` class and handling Hi-C data in R 
[here](https://github.com/js2264/HiCExperiment).

![](https://raw.githubusercontent.com/js2264/HiCExperiment/devel/man/figures/HiCExperiment_ecosystem.png)

- [HiCExperiment](https://github.com/js2264/HiCExperiment): Parsing Hi-C files in R
- [HiCool](https://github.com/js2264/HiCool): End-to-end integrated workflow to process fastq files into .cool and .pairs files
- [HiContacts](https://github.com/js2264/HiContacts): Investigating Hi-C results in R
- [HiContactsData](https://github.com/js2264/HiContactsData): Data companion package
- [fourDNData](https://github.com/js2264/fourDNData): Gateway package to 4DN-hosted Hi-C experiments
