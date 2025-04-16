library(clusterProfiler)
library(enrichplot)
library(ggplot2)
library(org.Hs.eg.db)
library(readxl)
library(dplyr)

# Set seed for reproducibility
set.seed(123)

organism = "org.Hs.eg.db"

file2 <- "C:/Users/PMLS/Documents/common-DEGs-all-KEGG-GO-input (2).xlsx"
df <- read_excel(file2)
original_gene_list <- df$Average_logFC

# Name the vector
names(original_gene_list) <- df$Gene_Symbol

# Remove NA values and sort the list in decreasing order
gene_list <- na.omit(original_gene_list)
gene_list <- sort(gene_list, decreasing = TRUE)

# Gene Ontology Enrichment Analysis for Biological Process, Cellular Component, and Molecular Function
gseBP <- gseGO(geneList = gene_list, 
               ont = "BP", 
               keyType = "SYMBOL", 
               nPerm = 10000, 
               minGSSize = 3, 
               maxGSSize = 800, 
               pvalueCutoff = 0.05, 
               verbose = TRUE, 
               OrgDb = organism, 
               pAdjustMethod = "none")

gseCC <- gseGO(geneList = gene_list, 
               ont = "CC", 
               keyType = "SYMBOL", 
               nPerm = 10000, 
               minGSSize = 3, 
               maxGSSize = 800, 
               pvalueCutoff = 0.05, 
               verbose = TRUE, 
               OrgDb = organism, 
               pAdjustMethod = "none")

gseMF <- gseGO(geneList = gene_list, 
               ont = "MF", 
               keyType = "SYMBOL", 
               nPerm = 10000, 
               minGSSize = 3, 
               maxGSSize = 800, 
               pvalueCutoff = 0.05, 
               verbose = TRUE, 
               OrgDb = organism, 
               pAdjustMethod = "none")

# Plotting the results
dotplot(gseBP, showCategory = 10) + ggtitle("Biological Process") + theme(plot.title = element_text(hjust = 0.5))
dotplot(gseCC, showCategory = 10) + ggtitle("Cellular Component") + theme(plot.title = element_text(hjust = 0.5))
dotplot(gseMF, showCategory = 10) + ggtitle("Molecular Function") + theme(plot.title = element_text(hjust = 0.5))

# Extracting the genes involved in each process
bp_genes <- unique(unlist(strsplit(as.character(gseBP@result$core_enrichment), "/")))
cc_genes <- unique(unlist(strsplit(as.character(gseCC@result$core_enrichment), "/")))
mf_genes <- unique(unlist(strsplit(as.character(gseMF@result$core_enrichment), "/")))

# Prepare the data for saving
bp_df <- gseBP@result %>% mutate(Gene = sapply(core_enrichment, function(x) paste(unique(unlist(strsplit(x, "/"))), collapse = ", ")))
cc_df <- gseCC@result %>% mutate(Gene = sapply(core_enrichment, function(x) paste(unique(unlist(strsplit(x, "/"))), collapse = ", ")))
mf_df <- gseMF@result %>% mutate(Gene = sapply(core_enrichment, function(x) paste(unique(unlist(strsplit(x, "/"))), collapse = ", ")))

# Combine the data frames and add category column
bp_df <- bp_df %>% mutate(Category = "Biological Process")
cc_df <- cc_df %>% mutate(Category = "Cellular Component")
mf_df <- mf_df %>% mutate(Category = "Molecular Function")

combined_df <- bind_rows(bp_df, cc_df, mf_df)

# Save to CSV
write.csv(combined_df, "GO_Enrichment_Results.csv", row.names = FALSE)

# Save to text file
write.table(combined_df, "GO_Enrichment_Results.txt", sep = "\t", row.names = FALSE, quote = FALSE)

# Display the genes
bp_genes
cc_genes
mf_genes
