import os
from itertools import combinations

configfile: "config.yml"
workdir: "hoil1"

def pair_labels(labels):
    return list(map(lambda pairs: f"{pairs[0]}Vs{pairs[1]}", labels))

#TODO: put this constants to config.yml
SCRIPT_DIR = "hoil1/rules/"
CLASSES = ["Healthy", "HOIL", "CINCA", "MWS", "MVK"]
FC = ["up", "down"]
BGX_PATH = "data/GPL6947_HumanHT-12_V3_0_R1_11283641_A.bgx"
CEMI_CLASSES = list(map(lambda x: f"M{x}", range(1, 7)))


all_cemi = pair_labels(zip(CEMI_CLASSES, CEMI_CLASSES))
all_pairs = pair_labels(combinations(CLASSES, 2))


rule all:
    input:
        expand("workflow/calc_stat/{pair}.csv", pair=all_pairs),  # calcstat
        expand("workflow/gsea/{pair}/", pair=all_pairs),  # gsea
        expand("workflow/top_genes/up{pair}.csv", pair=all_pairs),  # top_genes
        expand("workflow/top_genes/down{pair}.csv", pair=all_pairs),  # top_genes
        expand("workflow/string_db/proteins_top_genes_{logFC}{pair}.csv", pair=all_pairs, logFC=FC),  # string_db
        expand("workflow/ora/bar_top_genes_{logFC}{pair}.png", pair=all_pairs, logFC=FC),  # ora
        expand("workflow/kegg_graph/heatplot_top_genes_{logFC}{pair}.png", pair=all_pairs, logFC=FC),  # kegg_heatplot
        expand("workflow/kegg_graph/graph_top_genes_{logFC}{pair}.png", pair=all_pairs, logFC=FC),  # kegg_graph
        expand("workflow/topGO/bar_top_genes_{logFC}{pair}.png", pair=all_pairs, logFC=FC), # topGO
        expand("workflow/string_db/proteins_cemi_{pair}.csv", pair=all_cemi),  # string_db cemi
        expand("workflow/ora/bar_cemi_{pair}.png", pair=all_cemi),  # ora cemi
        # expand("workflow/topGO/bar_cemi_{pair}.png", pair=all_cemi), # topGO cemi
        expand("workflow/cemi/{pair}.csv", pair=all_cemi),  # cemi
        expand("workflow/kegg_graph/heatplot_cemi_{pair}.png", pair=all_cemi),  # kegg_heatplot cemi
        expand("workflow/kegg_graph/graph_cemi_{pair}.png", pair=all_cemi),  # kegg_graph cemi
        "workflow/images/hist.png",
        "workflow/images/boxplot.png",
        "workflow/images/pca.png",
        "workflow/images/heatmap.png",

rule kegg_graph:
    input:
        "workflow/{dir}/{pair}.csv"
    output:
        heatplot="workflow/kegg_graph/heatplot_{dir}_{pair}.png",
        graph = "workflow/kegg_graph/graph_{dir}_{pair}.png",
    script:
        os.path.join(SCRIPT_DIR, "kegg_graph.R")


rule topGO:
    input:
        "workflow/{dir}/{pair}.csv"
    output:
        barplot="workflow/topGO/bar_{dir}_{pair}.png",
        process="workflow/topGO/process_{dir}_{pair}.png",
    params:
        pCutoff = config['topgo']['pCutoff'],
    script:
        os.path.join(SCRIPT_DIR, "topGO.R")

rule ora:
    input:
        "workflow/{dir}/{pair}.csv"
    output:
        barplot="workflow/ora/bar_{dir}_{pair}.png"
    log: "logs/ora_{dir}_{pair}.txt"
    params:
        pCutoff = config['ora']['pCutoff'],
    script:
        os.path.join(SCRIPT_DIR, "ora.R")

rule string_db:
    input:
        "workflow/{dir}/{pair}.csv"
    params:
        img="workflow/string_db/protein_graph{dir}_{pair}.png"
    output:
        out="workflow/string_db/proteins_{dir}_{pair}.csv"
    log: "logs/string_db_{dir}_{pair}.txt"
    script:
        os.path.join(SCRIPT_DIR, "protein_graph.R")

rule top_genes:
    input:
        "workflow/calc_stat/{pair0}Vs{pair1}.csv"
    output:
        volcano="workflow/top_genes/volcano{pair0}Vs{pair1}.png",
        up="workflow/top_genes/up{pair0}Vs{pair1}.csv",
        down="workflow/top_genes/down{pair0}Vs{pair1}.csv"
    log: "logs/top_genes{pair0}Vs{pair1}.txt"
    params:
        pCutoff = config['top_genes']['pCutoff'],
        FCcutoff = config['top_genes']['FCCutoff'],
    script:
        os.path.join(SCRIPT_DIR, "top_genes.R")


rule cemi:
    input:
        meta=BGX_PATH,
        exprs="workflow/load_data/expression_matrix.csv",
    output:
        expand("workflow/cemi/{pair}.csv", pair=all_cemi)
    log: "logs/cemi.txt"
    script:
        os.path.join(SCRIPT_DIR, "cemi.R")

rule calc_stat:
    input:
        meta=BGX_PATH,
        exprs="workflow/load_data/expression_matrix.csv",
        markup="workflow/load_data/markup.csv",
        pairs="workflow/mix_markup/{pair0}Vs{pair1}"
    output:
        "workflow/calc_stat/{pair0}Vs{pair1}.csv"
    log: "logs/calc_stat_{pair0}Vs{pair1}.txt"
    script:
        os.path.join(SCRIPT_DIR, "calc_stat.R")

rule gsea:
    input:
        meta=BGX_PATH,
        exprs="workflow/load_data/expression_matrix.csv",
        markup="workflow/load_data/markup.csv",
        pathways="allpathways.json",
        pairs="workflow/mix_markup/{pair0}Vs{pair1}",
    output:
        directory("workflow/gsea/{pair0}Vs{pair1}/")
    log: "logs/gsea_{pair0}Vs{pair1}.txt"
    script:
        os.path.join(SCRIPT_DIR, "gsea.R")
        
rule mix_markup:
    input:
        "workflow/load_data/markup.csv",
    output:
        expand("workflow/mix_markup/{pair}", pair=all_pairs)
    run:
        for file_path in output:
            file = open(file_path, "w")
            file.close()
       
rule plot_graphs:
    input:
        "workflow/load_data/expression_matrix.csv",
        "workflow/load_data/markup.csv",
    output:
        hist="workflow/images/hist.png",
        boxplot="workflow/images/boxplot.png",
        pca="workflow/images/pca.png",
        heatmap="workflow/images/heatmap.png",
    log: "logs/plot_graphs.txt"
    script:
        os.path.join(SCRIPT_DIR, "plot_graphs.R")

rule load_data:
    output:
        "workflow/load_data/expression_matrix.csv",
        "workflow/load_data/markup.csv",
    log: "logs/load_data.txt"
    params:
        is_normalize = config["load_data"]["is_normalize"],
    script:
        os.path.join(SCRIPT_DIR, "load_data.R")