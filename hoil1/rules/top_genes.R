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
idx <- ((abs(df$logFC) > FCCutoff) & (-log10(df$adj.P.Val) >= -log10(pCutoff)))

log_info("Saving results")
write.csv(df[idx,],snakemake@output[["out"]])