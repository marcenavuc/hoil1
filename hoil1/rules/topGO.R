library(ggplot2)
library(topGO)
library(Rgraphviz)
data(geneList)
library(logger)

log_info("Start reading files")
pCutoff <- snakemake@params[["pCutoff"]]
data <- read.csv(snakemake@input[[1]])

allGenes <- data$adj.P.Val
names(allGenes) <- data$Symbol

# If something is went wrong
if (length(allGenes) == 0) {
  log_warn("Couldn't find pvalue of genes")
  png(file=snakemake@output[["process"]], width=600, height=350)
  plot(c(600, 350))
  rect(0, 0, 50, 148, col = "#c00000", border = "transparent")
  dev.off()

  png(file=snakemake@output[["barplot"]], width=600, height=350)
  plot(c(600, 350))
  rect(0, 0, 50, 148, col = "#c00000", border = "transparent")
  dev.off()
  quit()
}


log_info("Generating topGOdata")
sampleGOdata <- new("topGOdata",
                   ontology = "BP",
                   allGenes = allGenes,
                   geneSel = topDiffGenes,
                   description = "topGO analysis",
                   nodeSize = 0,
                   annot = annFUN.org,  
                   ID = "symbol",
                   mapping = "org.Hs.eg")

log_info("Start Fisher statistic analysis")
resultFisher <- runTest(sampleGOdata, algorithm = "classic", statistic = "fisher")
log_info("Start Kolmogorov-Smirnov statistic analysis")
resultKS <- runTest(sampleGOdata, algorithm = "classic", statistic = "ks")
pval <- score(resultKS)

log_info("Saving process graph")
png(file=snakemake@output[["process"]], width=600, height=350)
showSigOfNodes(sampleGOdata,
               pval,
               firstSigNodes = min(10, length(pval)),
               useInfo ='all')
title('Signicicant processes')
dev.off()

log_info("Calculating pvalue")
allRes <- GenTable(sampleGOdata,
                  classicFisher = resultFisher,
                  classicKS = resultKS,
                  orderBy = "classicKS",
                  ranksOf = "classicKS",
                  topNodes = length(pval))
allRes$pvalue <- score(resultKS)

log_info("Saving barplot")
png(file=snakemake@output[["barplot"]], width=600, height=350)
ggplot(allRes[allRes$pvalue < pCutoff,], aes(x = reorder(Term, -log10(pvalue)), y = -log10(pvalue))) +
geom_bar(stat = "identity",  position = "dodge") +
coord_flip() +
xlab("Gene Ontology")
dev.off()