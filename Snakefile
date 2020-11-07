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
        expand("workflow/calc_stat/{pair[0]}Vs{pair[1]}.csv", pair=all_pairs),  # calcstat
        expand("workflow/topGO/{pair[0]}Vs{pair[1]}", pair=all_pairs)
        # expand("workflow/gsea/{pair[0]}Vs{pair[1]}/", pair=all_pairs),  # gsea
        # "workflow/images/hist.png",
        # "workflow/images/boxplot.png",
        # "workflow/images/pca.png",

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

rule mix_markup:
    input:
        "workflow/load_data/markup.csv",
    output:
        "workflow/mix_markup/{pair0}Vs{pair1}",
    run:
        for file_path in output:
            file = open(file_path, "w")
            file.close()

rule load_data:
    output:
        "workflow/load_data/expression_matrix.csv",
        "workflow/load_data/markup.csv",
    script:
        os.path.join(SCRIPT_DIR, "load_data.R")