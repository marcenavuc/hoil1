library(EnhancedVolcano)

pCutoff <- 0.05
FCCutoff <- 0.4

df <- read.csv(snakemake@input[[1]])
df$X <- NULL
png(file=snakemake@output[["volcano"]], width=600 * 2, height=350 * 2)
EnhancedVolcano(df,
                title = snakemake@output[["volcano"]],
                lab = df$Symbol,
                pCutoff = pCutoff,
                FCcutoff = FCCutoff,
                x= 'logFC',
                y = 'adj.P.Val')
dev.off()
idx <- ((abs(df$logFC) > FCCutoff) & (-log10(df$adj.P.Val) >= -log10(pCutoff)))
write.csv(df[idx,],snakemake@output[["out"]])