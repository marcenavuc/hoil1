# Load requireming libraries
library(illuminaio)
library(lumi)
library(GEOquery)

# Download GEO file
eset <- getGEO("GSE40561")

# Read illumina files by limiExpresso
data <- lumiExpresso(eset$GSE40561_series_matrix.txt.gz, normalize = FALSE)

# Get markup from data
markup <- as.factor(pData(data)$group)
# "HOIL dificiency" → "HOIL" for correct working
levels(markup)[3] <- "HOIL"
levels(markup)[3]

# Get matrix expressions
data.eset <- Biobase::exprs(data)

write.csv(data.eset, snakemake@output[[1]])
write.csv(markup, snakemake@output[[2]])