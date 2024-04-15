# Use an official Ubuntu as a parent image
FROM ubuntu:latest

# Set environment variables for R installation
ENV DEBIAN_FRONTEND noninteractive

# Update indices
RUN apt update -qq

# Install two helper packages we need
RUN apt install --no-install-recommends -y software-properties-common dirmngr

# Add the signing key (by Michael Rutter) for these repos
# To verify key, run gpg --show-keys /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc 
# Fingerprint: E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc

# Add the R 4.0 repo from CRAN -- adjust 'focal' to 'groovy' or 'bionic' as needed
RUN add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"

# Update package manager again
RUN apt update

# Install the new version of R
RUN apt install -y r-base r-base-dev

# Install required packages
RUN apt-get install -y \ 
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
    libx11-dev 

# Install Bioconductor
RUN R -e "install.packages('BiocManager')"

# Install devtools and remotes packages
RUN R -e "install.packages('devtools')"

# Install downloader and gson packages
RUN R -e "install.packages(c('downloader', 'gson'))"

# Run R command to install ggtree from GitHub
RUN R -e "devtools::install_github('YuLab-SMU/ggtree')"

# Install R packages using BiocManager with update argument
RUN R -e "BiocManager::install(c('oligo', 'HDO.db', 'GenomicRanges', 'Biostrings', 'SummarizedExperiment', 'clusterProfiler', 'DOSE' , 'HDO.db', 'MatrixGenerics', 'DelayedArray', 'oligoClasses', 'Biobase', 'multiClust', 'limma', 'EnhancedVolcano', 'diffcoexp', 'enrichplot', 'pathview', 'org.Hs.eg.db', 'pheatmap', 'ggplot2', 'amap', 'ggrepel', 'openxlsx', 'readxl', 'ggridges', 'pd.hg.u133.plus.2'), update = TRUE)"

# Create a directory for all the folders and scripts
RUN mkdir /data

# Copy scripts into the /data directory
COPY scripts/ /data/

# Copy required files and datasets into the /data directory
COPY GSE40595_RAW/ /data/GSE40595_RAW/
COPY Required_files/ /data/Required_files/

# Set the working directory to /data
WORKDIR /data/

# Run R scripts
CMD ["Rscript", "GSE40595_Microarray_data_analysis.R"]
