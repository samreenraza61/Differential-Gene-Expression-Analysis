FROM rocker/verse:latest  # Replace with a minimal R image if preferred

# Install R packages
RUN R -e 'install.packages(c("BiocManager", "oligo", "GenomicRanges", "Biostrings", "SummarizedExperiment", "MatrixGenerics", "DelayedArray", "oligoClasses", "Biobase", "multiClust", "limma", "EnhancedVolcano", "diffcoexp", "clusterProfiler", "enrichplot", "pathview", "org.Hs.eg.db", "pheatmap", "ggplot2", "amap", "ggrepel", "openxlsx", "readxl", "ggridges"))'

# Copy R scripts
COPY scripts /scripts

# Copy required additional files
COPY Required_files /Required_files

# Set the working directory
WORKDIR /scripts

# Run R scripts
CMD ["R", "-e", "source('GSE40595_Microarray_data_analysis.R'); source('GSE26712_Microarraydataanalysis.R'); source('GSE54388_Microarray-dataanalysis.R'); source('GSE18520_Microarraydataanalysis.R')"]
