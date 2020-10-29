import os
from itertools import permutations

SCRIPT_DIR = "hoil1/rules/"
CLASSES = ["Healthy", "HOIL", "CINCA", "MWS", "MVK"]
# all_pairs = map(lambda x, y: f"{x}vs{y}.csv", permutations(CLASSES))

configfile: "config.yml"
workdir: "hoil1"


rule all:
    input: 
        # "workflow/calc_stat/TopHelthyVsHoil.csv",
        "workflow/calc_stat/HelthyVsHoil.csv",
        "workflow/images/hist.png",
        "workflow/images/boxplot.png",
        "workflow/images/pca.png",

rule calc_stat: # Эта штука должна работать через wildcards. Мб разбить ее на несколько rule
    input:
        "data/GPL6947_HumanHT-12_V3_0_R1_11283641_A.bgx",
        "workflow/load_data/expression_matrix.csv",
        "workflow/load_data/markup.csv",
    output:
        "workflow/calc_stat/HelthyVsHoil.csv"
        # "workflow/calc_stat/TopHelthyVsHoil.csv"
    script:
        os.path.join(SCRIPT_DIR, "calc_stat.R")

rule plot_graphs:
    input:
        "workflow/load_data/expression_matrix.csv",
        "workflow/load_data/markup.csv",
    output:
        hist="workflow/images/hist.png",
        boxplot="workflow/images/boxplot.png",
        pca="workflow/images/pca.png",
    script:
        os.path.join(SCRIPT_DIR, "plot_graphs.R")


rule load_data:
    output: 
        "workflow/load_data/expression_matrix.csv",
        "workflow/load_data/markup.csv",
    script:
        os.path.join(SCRIPT_DIR, "load_data.R")