library(logger)
library(illuminaio)
library(limma)

log_info("Start reading files")
bgx <- readBGX(file.path(snakemake@input[[1]]))

data.eset <- read.csv(snakemake@input[[2]])
rownames(data.eset) <- data.eset$X
data.eset$X <- NULL

markup <- read.csv(snakemake@input[[3]])
markup <- as.factor(markup$x)

log_info("Creating design of research")
design <- model.matrix(~ 0 + markup)
colnames(design) <- levels(markup)

log_info("Using voom normalization on dataset")
v <- limma::voom(data.eset, design, plot = FALSE)

log_info("Fitting linear model")
fit <- limma::lmFit(v)

log_info("Making contrasts matrix")
cont.matrix <- limma::makeContrasts(HealthVsHoil=Healthy - HOIL, levels=design)

log_info("Fitting contrasts")
fit.cont <- limma::contrasts.fit(fit, cont.matrix)

log_info("Calculating statistics")
fit.cont <- limma::eBayes(fit.cont)
stat <- limma::topTable(fit.cont,
                        coef=colnames(cont.matrix),
                        sort.by="p")
stat

results_HealthyVSHoil <- limma::topTable(fit.cont,
                coef=colnames(cont.matrix),
                sort.by="p",
                number=48803)


log_info("Saving results")
new_res <- results_HealthyVSHoil
new_res$Probe_Id <- rownames(results_HealthyVSHoil)
total <- merge(x = new_res, y = bgx$probes, by="Probe_Id")
write.csv(total, snakemake@output[[1]])