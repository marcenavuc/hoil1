library(EnhancedVolcano)
library(logger)

log_appender(appender_file(snakemake@log[[1]]))

log_info("Start read files")
df <- read.csv(snakemake@input[[1]])
df$X <- NULL

log_info("Start make volcanoplot")
png(file=snakemake@output[["volcano"]], width=600 * 2, height=350 * 2)
EnhancedVolcano(df,
                title = snakemake@output[["volcano"]],
                lab = df$Symbol,
                pCutoff = snakemake@params[["pCutoff"]],
                FCcutoff = snakemake@params[["FCcutoff"]],
                x= 'logFC',
                y = 'adj.P.Val')
dev.off()

log_info("Start cut off not impact genes")
idx.pval <- -log10(df$adj.P.Val) >= -log10(snakemake@params[["pCutoff"]])
idx.up <- (df$logFC > snakemake@params[["FCcutoff"]]) & idx.pval
idx.down <- (df$logFC < -1 * snakemake@params[["FCcutoff"]]) & idx.pval

log_info("Saving results")
write.csv(df[idx.up,],snakemake@output[["up"]])
write.csv(df[idx.down,],snakemake@output[["down"]])