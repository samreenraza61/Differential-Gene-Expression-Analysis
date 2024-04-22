# Load required libraries
library(readxl)
library(VennDiagram)

# Step : Common coexpressed DEGs between 4 microarray datasets:

# File paths for the Excel sheets
file1<-"C:/Users/PMLS/Documents/GO-input1.xlsx"
file2<-"C:/Users/PMLS/Documents/GOinput2.xlsx"
file3<-"C:/Users/PMLS/Documents/Go--input3.xlsx"
file4<-"C:/Users/PMLS/Documents/GOinput4.xlsx"
  
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
write.table(common_genes, "common_genes.txt", row.names = FALSE, col.names = FALSE)

# Create a Venn diagram with colors
venn.plot <- venn.diagram(
  x = list(
    A = gene_sets[[1]],
    B = gene_sets[[2]],
    C = gene_sets[[3]],
    D = gene_sets[[4]]
  ),
  category.names = c("GSE54388", "GSE18520", "GSE26712", "GSE40595"),
  filename = NULL,
  fill = rainbow(4) # Using rainbow colors for filling
)

# Plot the Venn diagram with labels on the console
grid.draw(venn.plot)

# Label common genes
grid.text(
  label = paste(common_genes, collapse = ", "),
  x = 0.5,
  y = 0.5,
  just = "center",
  gp = gpar(col = "black")
)












































