library(readxl)
library(VennDiagram)
library(grid)

# File paths for the Excel sheets
file1 <- "C:/Users/PMLS/Documents/GSE18520_DEGs.xlsx"
file2 <- "C:/Users/PMLS/Documents/GSE26712_DEGS.xlsx"
file3 <- "C:/Users/PMLS/Documents/GSE40595_DEGs.xlsx"
file4 <- "C:/Users/PMLS/Documents/GSE54388_DEG.xlsx"

file_paths <- c(file1, file2, file3, file4)

# Lists to store gene sets for upregulated and downregulated genes from each sheet
upregulated_sets <- list()
downregulated_sets <- list()

# Read genes and their status from each Excel sheet
for (file_path in file_paths) {
  data <- na.omit(read_excel(file_path))
  upregulated_sets[[file_path]] <- data$Gene_Symbol[data$status == "Upregulated"]
  downregulated_sets[[file_path]] <- data$Gene_Symbol[data$status == "Downregulated"]
}

# Find common upregulated genes
common_upregulated <- Reduce(intersect, upregulated_sets)
# Find common downregulated genes
common_downregulated <- Reduce(intersect, downregulated_sets)

# Write common genes to text files
write.table(common_upregulated, "common_upregulated_genes-microarray.txt", row.names = FALSE, col.names = FALSE)
write.table(common_downregulated, "common_downregulated_genes-microarray.txt", row.names = FALSE, col.names = FALSE)

# Create a Venn diagram for upregulated genes
venn.plot.up <- venn.diagram(
  x = list(
    A = upregulated_sets[[1]],
    B = upregulated_sets[[2]],
    C = upregulated_sets[[3]],
    D = upregulated_sets[[4]]
  ),
  category.names = c("GSE18520 UP", "GSE26712 UP", "GSE40595 UP", "GSE54388 UP"),
  filename = NULL,
  fill = rainbow(4),
  main = "Venn Diagram of Common Upregulated DEGs across 4 microarray gene expression profiles",
  main.cex = 1.5,
  cex = 1.2,
  position = "center"
)

# Save the Venn diagram for upregulated genes in TIFF format
tiff("venn_diagram_upregulated_genes.tiff", width = 800, height = 800)
grid.newpage()
grid.draw(venn.plot.up)
dev.off()

# Create a Venn diagram for downregulated genes
venn.plot.down <- venn.diagram(
  x = list(
    A = downregulated_sets[[1]],
    B = downregulated_sets[[2]],
    C = downregulated_sets[[3]],
    D = downregulated_sets[[4]]
  ),
  category.names = c("GSE18520 DOWN", "GSE26712 DOWN", "GSE40595 DOWN", "GSE54388 DOWN"),
  filename = NULL,
  fill = rainbow(4),
  main = "Venn Diagram of Common Downregulated DEGs across 4 microarray gene expression profiles",
  main.cex = 1.5,
  cex = 1.2,
  position = "center"
)

# Save the Venn diagram for downregulated genes in TIFF format
tiff("venn_diagram_downregulated_genes.tiff", width = 800, height = 800)
grid.newpage()
grid.draw(venn.plot.down)
dev.off()