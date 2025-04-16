# Load required libraries
library(readxl)
library(VennDiagram)

# Step : Common coexpressed DEGs between 4 microarray datasets:

# File paths for the Excel sheets
file1<-"C:/Users/PMLS/Documents/DCGs_file_GSE18520.xlsx"
file2<-"C:/Users/PMLS/Documents/DCGs_GSE26712.xlsx"
file3<-"C:/Users/PMLS/Documents/DCGs_GSE40595.xlsx"
file4<-"C:/Users/PMLS/Documents/DCGs_GSE54388.xlsx"
  
file_paths <- c(file1, file2, file3, file4)

# List to store gene sets from each sheet
gene_sets <- list()

# Read genes from the "Gene_Symbol" column of each Excel sheet
for (file_path in file_paths) {
  gene_sets[[file_path]] <- na.omit(read_excel(file_path)$Gene_Symbol)
}

# Find common genes
common_genes <- Reduce(intersect, gene_sets)

# Write common genes to a text file
write.table(common_genes, "common_genes_commonDCGs.txt", row.names = FALSE, col.names = FALSE)

# Create a Venn diagram with colors
venn.plot <- venn.diagram(
  x = list(
    A = gene_sets[[file1]],
    B = gene_sets[[file2]],
    C = gene_sets[[file3]],
    D = gene_sets[[file4]]
  ),
  category.names = c("GSE18520", "GSE26712", "GSE40595", "GSE54388"),
  filename = NULL,
  fill = rainbow(4), # Using rainbow colors for filling
  main = "Venn Diagram of Common DCGs across 4 microarray gene expression profiles",
  main.cex = 1.5,
  cex = 1.2
)

# Save the Venn diagram in TIFF format
tiff("venn_diagram_common_DCGs.tiff", width = 800, height = 800)
grid.newpage()
grid.draw(venn.plot)
dev.off()