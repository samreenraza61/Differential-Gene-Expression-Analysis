# Use the bioconductor/bioconductor_docker image as the base image
FROM bioconductor/bioconductor_docker:latest

# Copy your R script and data files to the container
COPY Microarray_Differential_Gene_Expression_Analysis_R_scripts/GSE54388_Microarray-dataanalysis.R /app/
COPY GSE54388_RAW /app/data
COPY GOinput_GSE54388.xlsx /app/
COPY GSE54388_DEG.xlsx /app/
COPY kegg_input_GSE54388.xlsx /app/

# Set the working directory
WORKDIR /app

# Entrypoint to run the R script
CMD ["Rscript", "GSE54388_Microarray-dataanalysis.R"]
