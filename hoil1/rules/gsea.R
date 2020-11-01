library(logger)
library(gage)
library(pathview)
library(illuminaio)
library(rlist)

log_info("Start reading files")
bgx <- readBGX(file.path(snakemake@input[['meta']]))

data.eset <- read.csv(snakemake@input[['exprs']])
rownames(data.eset) <- data.eset$X
data.eset$X <- NULL

markup <- read.csv(snakemake@input[['markup']])
markup <- as.factor(markup$x)

all.pathways <- list.unserialize(snakemake@input[['pathways']])

log_info("Filter matrix for ENTREZID")
new_table <- data.frame(list(PROBEID=bgx$probes$Probe_Id,
                             ENTREZID=bgx$probes$Entrez_Gene_ID))

idx <- !is.na(new_table$ENTREZID) & !duplicated(new_table$ENTREZID)
data.entrez <- data.eset[rownames(data.eset)[idx],]
rownames(data.entrez) <- new_table$ENTREZID[idx]

log_info("Get compSamples and refSamples")
refSamples <- grep(snakemake@wildcards[[1]], markup)
compSamples <- grep(snakemake@wildcards[[2]], markup)

log_info("Start gage")
data.kegg.p <- gage(data.entrez,
                    gsets = all.pathways,
                    ref = compSamples,
                    samp = refSamples,
                    compare='unpaired')
log_info("gage complited")

sel <- data.kegg.p$greater[, "q.val"] < 0.05 & !is.na(data.kegg.p$greater[,"q.val"])
names(sel) <- sapply(strsplit(names(sel), ":"), function(x) x[2])
table(sel)


log_info("Saving results")
# data.entrez.d <- data.entrez[, compSamples] - data.entrez[, refSamples]
old_dir <- getwd()
dir.create(snakemake@output[[1]])
setwd(snakemake@output[[1]])
try(for (each_process in names(sel)){
    if (sel[each_process])
        # pathview(gene.data = rowMeans(data.entrez.d),
        #     pathway.id = each_process, 
        #     species = "hsa")
        pathview(gene.data = rowMeans(data.entrez),
            pathway.id = each_process, 
            species = "hsa")
})
setwd(old_dir)