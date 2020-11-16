import os
from itertools import combinations

SCRIPT_DIR = "hoil1/rules/"
CLASSES = ["Healthy", "HOIL", "CINCA", "MWS", "MVK"]
CEMI_CLASSES = list(map(lambda x: f"M{x}", range(1, 7)))
all_cemi = list(zip(CEMI_CLASSES, CEMI_CLASSES))
all_pairs = list(combinations(CLASSES, 2))
BGX_PATH = "data/GPL6947_HumanHT-12_V3_0_R1_11283641_A.bgx"

configfile: "config.yml"
workdir: "hoil1"

rule all:
    input:
        expand("workflow/calc_stat/{pair[0]}Vs{pair[1]}.csv", pair=all_pairs),  # calcstat
        expand("workflow/topGO/{pair[0]}Vs{pair[1]}", pair=all_pairs)  
        expand("workflow/gsea/{pair[0]}Vs{pair[1]}/", pair=all_pairs),  # gsea
        expand("workflow/top_genes/top{pair[0]}Vs{pair[1]}.csv", pair=all_pairs),  # top_genes
        expand("workflow/string_db/proteins_top_genes_{pair[0]}Vs{pair[1]}.csv", pair=all_pairs),  # string_db
        expand("workflow/ora/bar_top_genes_{pair[0]}Vs{pair[1]}.png", pair=all_pairs),  # ora
        expand("workflow/string_db/proteins_cemi_{pair[0]}Vs{pair[1]}.csv", pair=all_cemi),  # string_db cemi
        expand("workflow/ora/bar_cemi_{pair[0]}Vs{pair[1]}.png", pair=all_cemi),  # ora cemi
        expand("workflow/cemi/top{pair[0]}Vs{pair[1]}.csv", pair=all_cemi),  # cemi
        "workflow/images/hist.png",
        "workflow/images/boxplot.png",
        "workflow/images/pca.png",
        "workflow/images/heatmap.png",

rule ora:
    input:
        "workflow/{somedir}/top{pair0}Vs{pair1}.csv"
    output:
        barplot="workflow/ora/bar_{somedir}_{pair0}Vs{pair1}.png"
    log: "logs/ora_{somedir}_{pair0}Vs{pair1}.txt"
    params:
        pCutoff = config['ora']['pCutoff'],
    script:
        os.path.join(SCRIPT_DIR, "ora.R")

rule string_db:
    input:
        "workflow/{somedir}/top{pair0}Vs{pair1}.csv"
    params:
        img="workflow/string_db/protein_graph{somedir}_{pair0}Vs{pair1}.png"
    output:
        out="workflow/string_db/proteins_{somedir}_{pair0}Vs{pair1}.csv"
    log: "logs/string_db_{somedir}_{pair0}Vs{pair1}.txt"
    script:
        os.path.join(SCRIPT_DIR, "protein_graph.R")

rule top_genes:
    input:
        "workflow/calc_stat/{pair0}Vs{pair1}.csv"
    output:
        volcano="workflow/top_genes/volcano{pair0}Vs{pair1}.png",
        out="workflow/top_genes/top{pair0}Vs{pair1}.csv"
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
        expand("workflow/cemi/top{pair[0]}Vs{pair[1]}.csv", pair=all_cemi)
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

rule topGO:
    input:
        meta=BGX_PATH,
        pathways="allpathways.json",
        pairs="workflow/mix_markup/{pair0}Vs{pair1}",
        stats="workflow/calc_stat/{pair0}Vs{pair1}.csv"
    output:
        "workflow/topGO/{pair0}Vs{pair1}"
    script:
        os.path.join(SCRIPT_DIR, "topGO.R")

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