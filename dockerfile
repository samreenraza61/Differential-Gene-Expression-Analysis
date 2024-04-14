# Use an official Windows Server Core image
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Set environment variables for R installation
ENV R_VERSION 4.1.0

# Download and install R
RUN curl -o R.exe https://cran.r-project.org/bin/windows/base/R-${R_VERSION}-win.exe && \
    Start-Process -Wait -FilePath .\R.exe -ArgumentList '/SILENT', '/DIR="C:\Program Files\R"', '/COMPONENTS="main,x64"', '/LOG' && \
    del .\R.exe

# Download and install Rtools
RUN curl -o Rtools.exe https://cran.r-project.org/bin/windows/Rtools/rtools40-x86_64.exe && \
    Start-Process -Wait -FilePath .\Rtools.exe -ArgumentList '/SILENT', '/DIR="C:\Rtools"', '/COMPONENTS="main,x64"', '/LOG' && \
    del .\Rtools.exe

# Add R and Rtools to the PATH
RUN setx /M PATH "$($Env:PATH);C:\Program Files\R\R-${R_VERSION}\bin;C:\Rtools\bin;C:\Rtools\mingw64\bin"

# Install devtools and R.utils
RUN R.exe -e "install.packages(c('devtools', 'R.utils'))"

# Install Bioconductor
RUN R.exe -e "install.packages('BiocManager')"

# Install ggtree from GitHub
RUN R.exe -e "devtools::install_github('YuLab-SMU/ggtree')"

# Install R packages using BiocManager
RUN R.exe -e "BiocManager::install(c('oligo', 'GenomicRanges', 'Biostrings', 'SummarizedExperiment', 'MatrixGenerics', 'clusterProfiler', 'DelayedArray', 'oligoClasses', 'Biobase', 'multiClust', 'limma', 'EnhancedVolcano', 'diffcoexp', 'enrichplot', 'pathview', 'org.Hs.eg.db', 'pheatmap', 'ggplot2', 'amap', 'ggrepel', 'openxlsx', 'readxl', 'ggridges','pd.hg.u133.plus.2'))"

# Create a directory for all the folders and scripts
RUN mkdir C:\data

# Copy scripts into the /data directory
COPY scripts/ C:/data/

# Copy required files and datasets into the /data directory
COPY GSE40595_RAW/ C:/data/GSE40595_RAW/
COPY Required_files/ C:/data/Required_files/

# Set the working directory to /data
WORKDIR /data/

# Run R scripts
CMD ["Rscript", "GSE40595_Microarray_data_analysis.R"]
