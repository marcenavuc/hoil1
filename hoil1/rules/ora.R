library(limma)
library(PPInfer)
library(GOstats)
library(KEGG.db)

data <- read.csv(snakemake@input[[1]])
data$X <- NULL

params <- new("KEGGHyperGParams",
              geneIds = data$Entrez_Gene_ID,
              annotation = "org.Hs.eg.db",
              pvalueCutoff = 0.05,
              testDirection = "over")
(hgOver.KEGG <- hyperGTest(params))

head(summary(hgOver.KEGG))

png(file=snakemake@output[["barplot"]], width=600, height=350)
ORA.barplot(summary(hgOver.KEGG),
            category = "Term",
            top = 10,
            size = "Size",
            count = "Count",
            pvalue = "Pvalue",
            p.adjust.methods = 'fdr')
dev.off()