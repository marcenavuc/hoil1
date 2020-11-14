library("CEMiTool")
library(logger)
library(illuminaio)

log_appender(appender_file(snakemake@log[[1]]))
log_info("Start reading files")
bgx <- readBGX(file.path(snakemake@input[['meta']]))

data.eset <- read.csv(snakemake@input[['exprs']])
rownames(data.eset) <- data.eset$X
data.eset$X <- NULL

log_info("Start coexpression analysis")
res <- cemitool(data.eset)

log_info(sprintf("Founded %s clusters", nmodules(res)))

log_info("Generate report")
generate_report(res, directory="workflow/cemi/", force=TRUE)

log_info("Save clusters")
for(i in 1:(nmodules(res) - 1)) {
    module.name <- sprintf("M%s", i)
    cluster <- module_genes(res, module=module.name)
    cluster$Probe_Id <- cluster$genes
    total <- merge(x=cluster, y=bgx$probes, by="Probe_Id")
    write.csv(total, snakemake@output[[i]])
}
