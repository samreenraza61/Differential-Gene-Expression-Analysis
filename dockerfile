# Use an official Windows Server Core image
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Set environment variables for R installation
ENV R_VERSION 4.1.0

# Install required packages
RUN apt-get update && apt-get install -y \
    r-base \
    r-base-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    pkg-config\
    libharfbuzz-dev \
    libproj-dev \
    libcairo2-dev \
    libfribidi-dev \
    libjpeg-dev \
    wget e

# Install R packages using BiocManager
RUN R.exe -e "install.packages('BiocManager')"
RUN R.exe -e "BiocManager::install(c('oligo', 'GenomicRanges', 'Biostrings', 'SummarizedExperiment', 'MatrixGenerics', 'clusterProfiler', 'DelayedArray', 'oligoClasses', 'Biobase', 'multiClust', 'limma', 'EnhancedVolcano', 'diffcoexp', 'enrichplot', 'pathview', 'org.Hs.eg.db', 'pheatmap', 'ggplot2', 'amap', 'ggrepel', 'openxlsx', 'readxl', 'ggridges','pd.hg.u133.plus.2'))"

# Create a directory for all the folders and scripts
RUN mkdir C:\data

# Copy scripts into the /data directory
COPY scripts/ C:/data/

# Copy required files and datasets into the /data directory
COPY GSE40595_RAW/ C:/data/GSE40595_RAW/
COPY Required_files/ C:/data/Required_files/

# Set the working directory to /data
WORKDIR C:\data

# Run R scripts
CMD ["Rscript", "GSE40595_Microarray_data_analysis.R"]
