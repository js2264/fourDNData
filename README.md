# fourDNData

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![rworkflows](https://github.com/js2264/fourDNData/actions/workflows/rworkflows.yml/badge.svg)](https://github.com/js2264/fourDNData/actions/workflows/rworkflows.yml)
<!-- badges: end -->

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
