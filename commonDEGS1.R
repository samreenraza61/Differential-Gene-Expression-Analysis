library(readxl)
library(VennDiagram)
library(grid)

# File paths for the Excel sheets
file1 <- "C:/Users/PMLS/Documents/GSE1852_DEGs.xlsx"
file2 <- "C:/Users/PMLS/Documents/GSE26712_DEGS.xlsx"
file3 <- "C:/Users/PMLS/Documents/GSE40595_DEG.xlsx"
file4 <- "C:/Users/PMLS/Documents/GSE54388_DEG.xlsx"

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

# Extract the first 5 common genes
num_common_genes <- 5
common_genes <- common_genes[1:min(length(common_genes), num_common_genes)]

# Create a Venn diagram
venn.plot <- venn.diagram(
  x = list(
    A = gene_sets[[1]],
    B = gene_sets[[2]],
    C = gene_sets[[3]],
    D = gene_sets[[4]]
  ),
  category.names = c("GSE54388", "GSE18520", "GSE26712", "GSE40595"),
  filename = NULL,
  fill = rainbow(4),  # Using rainbow colors for filling
  main = "Venn Diagram of Common DEGs",
  main.cex = 1.5,
  cex = 1.2,
  position = "center" # Positions symbols inside the diagram
)

# Plot the Venn diagram
png("venn_diagram_common_genes.png", width = 800, height = 800)  # Adjust the dimensions as needed
grid.newpage()
grid.draw(venn.plot)

dev.off()
