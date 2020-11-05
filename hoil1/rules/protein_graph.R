library(STRINGdb)
library(logger)
log_info("Initializing stringdb")
string_db <- STRINGdb$new(species=9606, version="11")
log_info("Reading files")
df <- read.csv(snakemake@input[[1]])
df$X <- NULL
log_info("Searching proteins")
mapped_proteins <- string_db$map(df, "Entrez_Gene_ID", removeUnmappedRows = TRUE)

log_info("Amount of proteins is:")
log_info(length(mapped_proteins$STRING_id))

log_info("Take first 200 proteins")
featured_proteins <- mapped_proteins$STRING_id[1:200]

log_info("Making image")
png(file=snakemake@params[["img"]], width=1024, height=1024)
try(string_db$plot_network(featured_proteins))
dev.off()

log_info("Saving results")
write.csv(string_db$get_interactions(featured_proteins),
          snakemake@output[["out"]])
