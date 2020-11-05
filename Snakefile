import os
from itertools import combinations

SCRIPT_DIR = "hoil1/rules/"
CLASSES = ["Healthy", "HOIL", "CINCA", "MWS", "MVK"]
all_pairs = list(combinations(CLASSES, 2))
BGX_PATH = "data/GPL6947_HumanHT-12_V3_0_R1_11283641_A.bgx"

configfile: "config.yml"
workdir: "hoil1"


rule all:
    input:
        expand("workflow/gsea/{pair[0]}Vs{pair[1]}/", pair=all_pairs),  # gsea
        # expand("workflow/top_genes/top{pair[0]}Vs{pair[1]}.csv", pair=all_pairs),  # top_genes
        # expand("workflow/string_db/proteins{pair[0]}Vs{pair[1]}.csv", pair=all_pairs),  # string_db
        "workflow/images/hist.png",
        "workflow/images/boxplot.png",
        "workflow/images/pca.png",
        "workflow/images/heatmap.png",

rule string_db:
    input:
        "workflow/top_genes/top{pair0}Vs{pair1}.csv"
    params:
        img="workflow/string_db/protein_graph{pair0}Vs{pair1}.png"
    output:
        out="workflow/string_db/proteins{pair0}Vs{pair1}.csv"
    script:
        os.path.join(SCRIPT_DIR, "protein_graph.R")

rule top_genes:
    input:
        "workflow/calc_stat/{pair0}Vs{pair1}.csv"
    output:
        volcano="workflow/top_genes/volcano{pair0}Vs{pair1}.png",
        out="workflow/top_genes/top{pair0}Vs{pair1}.csv"
    script:
        os.path.join(SCRIPT_DIR, "top_genes.R")

rule calc_stat:
    input:
        meta=BGX_PATH,
        exprs="workflow/load_data/expression_matrix.csv",
        markup="workflow/load_data/markup.csv",
        pairs="workflow/mix_markup/{pair0}Vs{pair1}"
    output:
        "workflow/calc_stat/{pair0}Vs{pair1}.csv"
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
    script:
        os.path.join(SCRIPT_DIR, "gsea.R")

rule mix_markup:
    input:
        "workflow/load_data/markup.csv",
    output:
        "workflow/mix_markup/{pair0}Vs{pair1}",
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
    script:
        os.path.join(SCRIPT_DIR, "plot_graphs.R")


rule load_data:
    output:
        "workflow/load_data/expression_matrix.csv",
        "workflow/load_data/markup.csv",
    script:
        os.path.join(SCRIPT_DIR, "load_data.R")