# Use official Microsoft Windows Server Core Image (minimal)
FROM mcr.microsoft.com/windows:servercore-ltsc2022

# Install R for Windows
# (Download the installer URL based on your architecture)
RUN powershell -ExecutionPolicy Bypass -Command Invoke-WebRequest -Uri 'https://cran.r-project.org/bin/windows/x86-64/base/R-4.2.1-x86_64.exe' -OutFile RInstaller.exe && Start-Process RInstaller.exe -Wait -ArgumentList '/quiet /norestart' -FilePath .; Remove-Item RInstaller.exe

# Set environment variables (consider using docker secrets)
ENV R_HOME C:/R/x86_x64  # Adjust path based on your installation

# Install required R packages (use slightly different syntax)
RUN Rscript -e 'install.packages(c("BiocManager", "devtools", "R.utils", "ggtree", "oligo", "GenomicRanges", 
"Biostrings", "SummarizedExperiment", "MatrixGenerics", "DelayedArray", "oligoClasses", "Biobase", "multiClust", "limma", 
"EnhancedVolcano", "diffcoexp", "enrichplot", "pathview", "org.Hs.eg.db", "pheatmap", "ggplot2", "amap", "ggrepel", 
"openxlsx", "readxl", "ggridges", "pd.hg.u133.plus.2"), repos="https://cran.rstudio.com/")'

# Create a directory for all the folders and scripts
RUN mkdir C:\data

# Consider using docker volume mounts for data persistence
COPY scripts\ C:\data\scripts\
COPY GSE40595_RAW\ C:\data\GSE40595_RAW\
COPY Required_files\ C:\data\Required_files\

# Set the working directory
WORKDIR C:\data\

# Run R scripts (modify the script path if needed)
CMD ["Rscript.exe", "GSE40595_Microarray_data_analysis.R"]
