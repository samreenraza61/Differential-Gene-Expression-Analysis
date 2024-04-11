# Use an official Ubuntu as a parent image
FROM ubuntu:latest

# Set environment variables for R installation
ENV DEBIAN_FRONTEND noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    r-base \
    r-base-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev

# Install Bioconductor package
RUN R -e "install.packages('BiocManager')"

# Install R packages using BiocManager
RUN R -e "BiocManager::install(c('oligo', 'GenomicRanges', 'Biostrings', 'SummarizedExperiment', 'MatrixGenerics', 'DelayedArray', 'oligoClasses', 'Biobase', 'multiClust', 'limma', 'EnhancedVolcano', 'diffcoexp', 'clusterProfiler', 'enrichplot', 'pathview', 'org.Hs.eg.db', 'pheatmap', 'ggplot2', 'amap', 'ggrepel', 'openxlsx', 'readxl', 'ggridges'))"

# Copy scripts into the container
COPY scripts/ /scripts/


# Copy required files and datasets
COPY Required_files/ /Required_files/
COPY GSE18520_RAW /GSE18520_RAW/
COPY GSE26712_RAW /GSE26712_RAW/
COPY GSE40595_RAW /GSE40595_RAW/
COPY GSE54388_RAW /GSE54388_RAW/

# Set the working directory
WORKDIR /scripts/
WORKDIR /GSE18520_RAW/
WORKDIR /GSE26712_RAW/
WORKDIR /GSE40595_RAW/
WORKDIR /GSE54388_RAW/
WORKDIR /Required_files/

# Run R scripts
CMD ["Rscript", "GSE40595_Microarray_data_analysis.R"]
CMD ["Rscript", "GSE26712_Microarraydataanalysis.R"]
CMD ["Rscript", "GSE54388_Microarray-dataanalysis.R"]
CMD ["Rscript", "GSE18520_Microarraydataanalysis.R"]
