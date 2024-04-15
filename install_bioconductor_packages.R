# Load BiocManager package
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}

# Install Bioconductor packages
BiocManager::install(c(
  "Biostrings", 
  "GenomicRanges", 
  "SummarizedExperiment", 
  "DelayedArray", 
  "oligo", 
  "oligoClasses", 
  "Biobase", 
  "multiClust", 
  "limma", 
  "EnhancedVolcano", 
  "diffcoexp", 
  "enrichplot", 
  "pathview", 
  "org.Hs.eg.db", 
  "pheatmap", 
  "amap", 
  "ggrepel", 
  "pd.hg.u133.plus.2"
))
