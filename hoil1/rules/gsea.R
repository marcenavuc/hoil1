library(logger)
library(gage)
library(pathview)
library(rlist)

log_info("Start reading files")
data.eset <- read.csv(snakemake@input[[1]])
rownames(data.eset) <- data.eset$X
data.eset$X <- NULL

all.pathways <- list.unserialize("allpathways.json")


data.kegg.p <- gage(exprs(data.entrez),
                    gsets = all.pathways,
                    ref = compSamples,
                    samp = refSamples,
                    compare='unpaired')