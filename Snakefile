import os
SCRIPT_DIR = "hoil1/rules/"

configfile: "config.yml"
workdir: "hoil1"


rule all:
    input: 
        "workflow/calc_stat/HelthyVsHoil.csv",
        "workflow/images/hist.png",
        "workflow/images/boxplot.png",
        "workflow/images/pca.png",

rule calc_stat:
    input:
        "data/GPL6947_HumanHT-12_V3_0_R1_11283641_A.bgx",
        "workflow/get_data/expression_matrix.csv",
        "workflow/get_data/markup.csv",
    output:
        "workflow/calc_stat/HelthyVsHoil.csv"
        "workflow/calc_stat/TopHelthyVsHoil.csv"
    script:
        os.path.join(SCRIPT_DIR, "calc_stat.R")

rule plot_graphs:
    input:
        "workflow/get_data/expression_matrix.csv",
        "workflow/get_data/markup.csv",
    output:
        hist="workflow/images/hist.png",
        boxplot="workflow/images/boxplot.png",
        pca="workflow/images/pca.png",
    script:
        os.path.join(SCRIPT_DIR, "plot_graphs.R")

rule get_data:
    output: 
        "workflow/get_data/expression_matrix.csv",
        "workflow/get_data/markup.csv",
    script:
        os.path.join(SCRIPT_DIR, "get_data.R")