# Set CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org/"))

# Install BiocManager
install.packages("BiocManager")

# Use BiocManager to install Bioconductor packages
BiocManager::install(c(
  "Biostrings", "GenomicRanges", "SummarizedExperiment", "DelayedArray", 
  "oligo", "oligoClasses", "Biobase", "multiClust", "limma", 
  "EnhancedVolcano", "diffcoexp", "enrichplot", "pathview", 
  "org.Hs.eg.db", "pheatmap", "amap", "ggrepel", "pd.hg.u133.plus.2"
), ask = FALSE)
