library(topGO)
library(ALL)
library(hgu95av2.db)
library(Rgraphviz)
library(GEOquery)
data(ALL)
library(illuminaio)
data(geneList)
library(illuminaHumanv4.db)
library(ggplot2)
library(logger)

log_info("Start reading files")
data <- read.csv(snakemake@input[['stats']])

df <- data[, 6]
names(df) <- data$Symbol

log_info("Start reading files")
sampleGOdata <- new("topGOdata",
                   ontology = "BP",
                   allGenes = df,
                   geneSel = topDiffGenes,
                   description = "Hoil topGO analysis",
                   nodeSize = 5,
                   annot = annFUN.org,  
                   ID = "symbol",
                   mapping = "org.Hs.eg")

log_info("Start Fisher statistic analysis")
resultFisher <- runTest(sampleGOdata, algorithm = "classic", statistic = "fisher")

log_info("Start Kolmogorov-Smirnov statistic analysis")
resultKS <- runTest(sampleGOdata, algorithm = "classic", statistic = "ks")

resultKS.elim <- runTest(sampleGOdata, algorithm = "elim", statistic = "ks")

png(file=snakemake@output[[1]], width=600, height=350)
showSigOfNodes(sampleGOdata,
               score(resultKS.elim),
               firstSigNodes = 13,
               useInfo ='all')
title('Signicicant processes')
dev.off()
