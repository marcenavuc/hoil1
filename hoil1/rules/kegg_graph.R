library(limma)
library(DOSE)
library(clusterProfiler)
library(logger)

log_info("Start reading files")
data <- read.csv(snakemake@input[[1]])

log_info("Start enrichment analysis")
kegg_res <- enrichKEGG(data$Entrez_Gene_ID)

log_info("Save heatplot")
png(file=snakemake@output[["heatplot"]], width=600, height=350)
if (!is.null(kegg_res)) {
    if (nrow(kegg_res) > 0) {  #  if we founded important genes
      heatplot(kegg_res)
  } else {
      plot(c(600, 350))
      rect(0, 0, 50, 148, col = "#c00000", border = "transparent")
  }
} else {
  plot(c(600, 350))
  rect(0, 0, 50, 148, col = "#c00000", border = "transparent")
}

log_info("Save kegg graph")
png(file=snakemake@output[["graph"]], width=600, height=350)
if (!is.null(kegg_res)) {
    if (nrow(kegg_res) > 0) {  #  if we founded important genes
      heatplot(kegg_res)
  } else {
      plot(c(600, 350))
      rect(0, 0, 50, 148, col = "#c00000", border = "transparent")
  }
} else {
  plot(c(600, 350))
  rect(0, 0, 50, 148, col = "#c00000", border = "transparent")
}
dev.off()
