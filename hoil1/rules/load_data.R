library(illuminaio)
library(lumi)
library(GEOquery)
library(logger)

log_appender(appender_file(snakemake@log[[1]]))
log_info("Download GEO file")
eset <- getGEO("GSE40561")

log_info("Read illumnia files by lumiExpresso")
data <- lumiExpresso(eset$GSE40561_series_matrix.txt.gz,
                     normalize = snakemake@params[['is_normalize']])

log_info("Get labels from data")
markup <- as.factor(pData(data)$group)
# "HOIL dificiency" -> "HOIL" for correct working
levels(markup)[3] <- "HOIL"
levels(markup)[3]

log_info("Get matrix expreession")
data.eset <- Biobase::exprs(data)
colnames(data.eset) <- markup

log_info("Saving files")
write.csv(data.eset, snakemake@output[[1]])
write.csv(markup, snakemake@output[[2]])