library(ggplot2)
library(Biobase)
library(gplots)

# Load data
expressionData <- read.csv(snakemake@input[[1]])
rownames(expressionData) <- expressionData$X
expressionData$X <- NULL

markup <- read.csv(snakemake@input[[2]])
markup <- as.factor(markup$x)

assayData <- as.matrix(expressionData)
dim(assayData) <- dim(expressionData)
data <- ExpressionSet(assayData=as.matrix(expressionData))

# Make hist
png(file=snakemake@output[["hist"]], width=600, height=350)
hist(exprs(data))
dev.off()

# Make boxplot
png(file=snakemake@output[["boxplot"]], width=600, height=350)
boxplot(exprs(data))
dev.off()


# Make pca
PCA_raw <- stats::prcomp(t(exprs(data)), scale. = TRUE)
percentVar <- summary(PCA_raw)$importance[2,]
percentVar[1:6]
dataGG <- data.frame(PC1 = PCA_raw$x[,1], PC2 = PCA_raw$x[,2])

png(file=snakemake@output[["pca"]], width=600, height=350)

ggplot(dataGG, aes(PC1, PC2)) +
geom_point(aes(colour = markup)) +
# geom_text(label = colnames(eset.norm)) +
ggtitle("PCA plot") + 
xlab(paste0("PC1, VarExp: ", percentVar[1])) + 
ylab(paste0("PC2, VarExp: ", percentVar[2])) +
coord_fixed(ratio = 4)

dev.off()


# Make heatmap
exprs.matrix <- data.matrix(expressionData)
exprs.matrix <- exprs.matrix[c(TRUE, FALSE, FALSE, FALSE), 1:ncol(exprs.matrix)]
colnames(exprs.matrix) <- markup
png(file=snakemake@output[["heatmap"]], width=600, height=350)
heatmap.2(data.matrix(exprs.matrix), scale='row', trace='none')
dev.off()