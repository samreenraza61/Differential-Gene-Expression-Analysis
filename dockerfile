# Use official Microsoft Windows Server Core Image (minimal)
FROM mcr.microsoft.com/windows/servercore/iis

# Install Chocolatey
RUN powershell -Command Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install R using Chocolatey
RUN choco install r -y

# Add R to the system PATH
RUN setx /M PATH "%PATH%;C:\Program Files\R\R-4.3.3\bin"

# Set environment variables (consider using docker secrets)
ENV R_HOME C:/R/x86_x64  # Adjust path based on your installation

# Install required R packages during script execution
# Modify the package list and repos as needed
RUN Rscript -e 'install.packages(c("Biostrings", "devtools", "R.utils", "ggplot2", "oligo", "GenomicRanges", "SummarizedExperiment", "DelayedArray", "oligoClasses", "Biobase", "multiClust", "limma", "EnhancedVolcano", "diffcoexp", "enrichplot", "pathview", "org.Hs.eg.db", "pheatmap", "amap", "ggrepel", "openxlsx", "readxl", "ggridges", "pd.hg.u133.plus.2"), repos="https://cran.rstudio.com/")'

# Create a directory for all the folders and scripts
RUN mkdir C:\data

# Consider using docker volume mounts for data persistence
COPY scripts/ C:\data\scripts\
COPY GSE40595_RAW/ C:\data\GSE40595_RAW\
COPY Required_files/ C:\data\Required_files\

# Set the working directory
WORKDIR C:\data\

# Run R scripts (modify the script path if needed)
CMD ["Rscript.exe", "GSE40595_Microarray_data_analysis.R"]
