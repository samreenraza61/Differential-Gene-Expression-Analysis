# Affymetrix Microarray Data Analysis:

# Step:01  

# Import microarray expression data as “ExpressionSet”
#Perform Normalization

library(oligo)
library(Biobase)
library(ggplot2)

#Read .CEL files = rawdata

# Set the path to the CEL folder
cel_folder <- "GSE26712_RAW"

# List files in the CEL folder
cel_files <- list.files(cel_folder, full.names = TRUE)

# Read CEL files into rawData
rawData <- read.celfiles(cel_files)

# Define the ExpressionFeatureSet
expression_feature_set <- rawData

# Check the class definition of ExpressionFeatureSet
getClass("ExpressionFeatureSet")

# Access the expression values
exprs(expression_feature_set)

# Find the maximum expression value
max(exprs(expression_feature_set))

# Get the filenames of the samples
filename <- sampleNames(rawData)

# Add filename information to the phenotype data
pData(rawData)$filename <- filename

# Extract sample names from filenames
sampleNames <- sub(".*_sample ", "", filename)  # Extract only the sample number
sampleNames <- sub("\\.CEL\\.gz$", "", sampleNames)  # Remove the file extension

# Set the sample names
sampleNames(rawData) <- sampleNames


# Define groups based on sample names
pData(rawData)$group <- ifelse(grepl("HOSE", filename), "Normal Samples", "Ovarian Cancer")

pData(rawData)

# Check Quality Control = rawdata
exp_raw <- log2(exprs(expression_feature_set))
PCA_raw <- prcomp(t(exp_raw), scale. = FALSE)

percentVar <- round(100*PCA_raw$sdev^2/sum(PCA_raw$sdev^2),1)
sd_ratio <- sqrt(percentVar[2] / percentVar[1])

# Create data frame with additional information
dataGG <- data.frame(PC1 = PCA_raw$x[,1], PC2 = PCA_raw$x[,2],
                     Disease = pData(rawData)$group,
                     Sample = sampleNames(rawData))

# Create the PCA plot
ggplot(dataGG, aes(PC1, PC2)) +
  geom_point(aes(shape = Disease, colour = Disease)) +
  ggtitle("PCA of GSE26712 Before Normalization") +
  xlab(paste0("PC1, VarExp: ", percentVar[1], "%")) +
  ylab(paste0("PC2, VarExp: ", percentVar[2], "%")) +
  theme(plot.title = element_text(hjust = 0.5))+
  coord_fixed(ratio = sd_ratio) +
  scale_shape_manual(values = c(15, 4)) + 
  scale_color_manual(values = c("darkorange2", "dodgerblue4"))

# Define the colors for the samples
sample_colors <- ifelse(pData(rawData)$group == "Normal Samples", "orange", "gray")

# boxplot - rawdata
oligo::boxplot(rawData, target = "core", 
               main = "GSE26712 Before Normalization",
               las=2, #Rotate the labels on the x-axis
               cex.axis=0.5, # Adjust the size of the axis labeL
               col = sample_colors # Set the colors for the samples
   )

# Normalization:
normData <- rma(rawData)
## Background correcting
## Normalizing
## Calculating Expression
boxplot(normData)

# Quality assessment of the calibrated data

exp_palmieri <- exprs(normData)
PCA <- prcomp(t(exp_palmieri), scale = FALSE)

percentVar <- round(100*PCA$sdev^2/sum(PCA$sdev^2),1)
sd_ratio <- sqrt(percentVar[2] / percentVar[1])

# Create data frame for PCA plot
dataGG <- data.frame(PC1 = PCA$x[,1], PC2 = PCA$x[,2],
                     Disease = pData(normData)$group,
                     Sample = sampleNames(normData))

# Create the PCA plot
ggplot(dataGG, aes(PC1, PC2)) +
  geom_point(aes(shape = Disease, colour = Disease)) +
  ggtitle("PCA of GSE26712 After Normalization") +
  xlab(paste0("PC1, VarExp: ", percentVar[1], "%")) +
  ylab(paste0("PC2, VarExp: ", percentVar[2], "%")) +
  theme(plot.title = element_text(hjust = 0.5))+
  coord_fixed(ratio = sd_ratio) +
  scale_shape_manual(values = c(15, 4)) + 
  scale_color_manual(values = c("darkorange2", "dodgerblue4"))

# Define the colors for the samples
sample_colors <- ifelse(pData(normData)$group == "Normal Samples", "orange", "gray")

# Boxplot of normalized data
boxplot(normData, main = "GSE26712 After Normalization",
        las=2, #Rotate the labels on the x-axis
        cex.axis=0.5, # Adjust the size of the axis label 
        col = sample_colors # Set the colors for the samples
        
        )

# Step: Filtering based on intensity

# Calculate median intensity per gene
palmieri_medians <- rowMedians(Biobase::exprs(normData))

# Generate histogram of median intensities (optional)
hist_res <- hist(palmieri_medians, 100, col = "cornsilk1", freq = FALSE,
                 main = "Histogram of the median intensities of (GSE26712 Normalized Data)",
                 border = "antiquewhite4",
                 xlab = "Median intensities")

# Set intensity threshold (adjust as needed)
man_threshold <- 5

# Generate histogram with threshold line (optional)
hist_res <- hist(palmieri_medians, 100, col = "cornsilk", freq = FALSE,
                 main = "Histogram of the median intensities showing threshold (GSE26712 Normalized Data)",
                 border = "antiquewhite4",
                 xlab = "Median intensities")
abline(v = man_threshold, col = "coral4", lwd = 2)
text(x = man_threshold, y = max(hist_res$density) * 0.8, labels = paste("Threshold =", man_threshold), col = "coral4", pos = 4)

# Get number of samples per group
no_of_samples <- table(paste0(pData(normData)$Factor.Value.disease., "_",
                              pData(normData)$Factor.Value.phenotype.))
samples_cutoff <- min(no_of_samples)

# Filter genes based on intensity and minimum samples
idx_man_threshold <- apply(Biobase::exprs(normData), 1,
                           function(x) sum(x > man_threshold) >= samples_cutoff)

# Summarize filtering results
table(idx_man_threshold)

# Filter expression data based on the function results
palmieri_manfiltered <- normData[idx_man_threshold, ]

# Step: 02  Feature Selection:

# Load necessary libraries for feature selection
library(amap)
library(multiClust)

# Extract expression data from the ExpressionFeatureSet
expr_data <- exprs(normData)

# Write the expression data to a text file
exp_file <- "expression_data.txt"
write.table(expr_data, file = exp_file, sep = "\t", quote = FALSE, col.names = NA)

# Using percent to specify the percentage of probes to select 
probe_num <- number_probes(input = exp_file, expr_data, Fixed = NULL, Percent = 10, Poly = NULL,
                           Adaptive = NULL, cutoff = NULL)
#probe_num

# Perform feature selection
ranked_cv <- probe_ranking(input = exp_file, 
                           probe_number = probe_num,  # Number of probes to select
                           probe_num_selection = "Percent_Probe_Num",
                           data.exp = expr_data, 
                           method = "CV_Guided")

ranked_cv 

#Step:03 Differential Gene Expression Analysis

# Load required packages
library(limma)
library(pheatmap)
library(ggplot2)

# Define Groups
Groups <- ifelse(grepl("HOSE", colnames(ranked_cv)), "Normal", "Ovarian")

# Create design matrix
design <- model.matrix(~factor(Groups))

# Fit linear model
fit <- lmFit(ranked_cv, design)

# Empirical Bayes moderation
fit <- eBayes(fit)

# Get topTable results
result <- topTable(fit, number = Inf, adjust.method = "BH", coef = 1)


# Add a column indicating gene status
result$status <- ifelse(result$logFC >= 2 & result$adj.P.Val < 0.05, "Upregulated",
                        ifelse(result$logFC <= 2 & result$adj.P.Val  < 0.05, "Downregulated",
                               "Not significant"))

# Write results to a file
write.table(result, "Diff1_exps_GSE26712.txt", sep = "\t")

#Volcano plot:
library(ggplot2)
library(ggrepel)
library(EnhancedVolcano)

file1<-"GSE26712_DEGS.xlsx"
library(readxl)
data <- read_excel(file1)

toptable <- topTable(fit, n = Inf)
#toptable
#names(toptable)
EnhancedVolcano(toptable ,
                lab = data$Gene_Symbol,
                x = 'logFC',
                y = 'P.Value')+
  ggtitle("DEGs of GSE26712 dataset") +
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5))

# Step: 04  Identify Differentially Co-expressed genes 

library(GenomicRanges)
library(diffcoexp)

Normal <- ranked_cv[, 1:10]
Ovarian <- ranked_cv[, 11:195] 

allowWGCNAThreads()
res=diffcoexp(exprs.1 = Normal, exprs.2 = Ovarian, r.method = "spearman" )

DCGs <- res$DCGs

library(openxlsx)

# Write the DCGs data frame to the Excel file
write.xlsx(DCGs, "DCGs_GSE26712.xlsx", rowNames = FALSE)
