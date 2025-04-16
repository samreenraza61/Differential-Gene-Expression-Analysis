library(clusterProfiler)
library(enrichplot)
library(ggplot2)
library(org.Hs.eg.db)
library(readxl)

set.seed(123)

file3 <- "C:/Users/Muzi/Documents/GO_KEGG_INPUT.xlsx"
df1 = read_excel(file3)
original_gene_list1 <- df1$Average_logFC
# name the vector
names(original_gene_list1) <- df1$Entrez_ID

# omit any NA values 
gene_list1<-na.omit(original_gene_list1)

# sort the list in decreasing order (required for clusterProfiler)
gene_list1 = sort(gene_list1, decreasing = TRUE)

kegg_organism = "hsa"
kk2 <- gseKEGG(geneList     = gene_list1,
               organism     = kegg_organism,
               nPerm        = 10000,
               minGSSize    = 3,
               maxGSSize    = 800,
               pvalueCutoff = 0.05,
               pAdjustMethod = "none",
               keyType       = "ncbi-geneid")

# Extract pathway information and store in a data frame
kegg_results <- kk2@result

# Convert gene IDs to gene names
gene_id_list <- unique(unlist(strsplit(kegg_results$core_enrichment, "/")))
gene_id_to_name <- bitr(gene_id_list, fromType="ENTREZID", toType="SYMBOL", OrgDb=org.Hs.eg.db)

# Function to replace gene IDs with gene names
replace_gene_ids_with_names <- function(gene_ids, id_to_name) {
  ids <- unlist(strsplit(gene_ids, "/"))
  names <- id_to_name$SYMBOL[match(ids, id_to_name$ENTREZID)]
  paste(names, collapse = "/")
}

kegg_results$Genes <- sapply(kegg_results$core_enrichment, replace_gene_ids_with_names, id_to_name = gene_id_to_name)

write.csv(kegg_results, "C:/Users/Muzi/Documents/KEGG_results_new.csv", row.names = FALSE)

dotplot(kk2, showCategory = 10) + ggtitle("KEGG Pathway") + theme(plot.title = element_text(hjust = 0.5))

library(pathview)


# Produce the native KEGG plot (PNG)
hsa <- pathview(gene.data=gene_list1, pathway.id="hsa04218", species = kegg_organism)

# Produce a different plot (PDF) (not displayed here)
hsa <- pathview(gene.data=gene_list1, pathway.id="hsa04218", species = kegg_organism, kegg.native = F)
knitr::include_graphics("hsa04218.pathview.png")

# Produce the native KEGG plot (PNG)
hsa <- pathview(gene.data=gene_list1, pathway.id="hsa04110", species = kegg_organism)

# Produce a different plot (PDF) (not displayed here)
hsa <- pathview(gene.data=gene_list1, pathway.id="hsa04110", species = kegg_organism, kegg.native = F)
knitr::include_graphics("hsa04110.pathview.png")

# Produce the native KEGG plot (PNG)
hsa <- pathview(gene.data=gene_list1, pathway.id="hsa04913", species = kegg_organism)

# Produce a different plot (PDF) (not displayed here)
hsa <- pathview(gene.data=gene_list1, pathway.id="hsa04913", species = kegg_organism, kegg.native = F)
knitr::include_graphics("hsa04913.pathview.png")
