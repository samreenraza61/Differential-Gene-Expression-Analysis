# Use official Microsoft Windows Server Core Image (minimal)
FROM mcr.microsoft.com/windows/nanoserver:1809

# Download and install R for Windows
# Modify the URL based on the desired R version
RUN powershell -ExecutionPolicy Bypass -Command Invoke-WebRequest -Uri 'https://cran.r-project.org/bin/windows/x86-64/base/R-4.2.1-x86_64.exe' -OutFile RInstaller.exe && Start-Process RInstaller.exe -Wait -ArgumentList '/quiet /norestart' -FilePath .; Remove-Item RInstaller.exe

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
