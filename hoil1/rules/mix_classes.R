library(logger)

logger.info("Packages loaded")
markup <- read.csv(snakemake@input[[3]])
markup <- as.factor(markup$x)
logger.info("markup loaded")

logger.info(snakemake@params[["classes"]])