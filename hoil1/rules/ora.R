library(limma)
library(PPInfer)
library(GOstats)
library(KEGG.db)
library(logger)

log_appender(appender_file(snakemake@log[[1]]))
log_info("Start reading files")
data <- read.csv(snakemake@input[[1]])
data$X <- NULL

log_info("Start ORA")
params <- new("KEGGHyperGParams",
              geneIds = data$Entrez_Gene_ID,
              annotation = "org.Hs.eg.db",
              pvalueCutoff = snakemake@params[["pCutoff"]],
              testDirection = "over")
(hgOver.KEGG <- hyperGTest(params))

#log_info(head(summary(hgOver.KEGG)))

log_info("Start make barplot")
png(file=snakemake@output[["barplot"]], width=600, height=350)
ORA.barplot(summary(hgOver.KEGG),
            category = "Term",
            top = 10,
            size = "Size",
            count = "Count",
            pvalue = "Pvalue",
            p.adjust.methods = 'fdr')
dev.off()