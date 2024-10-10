import glob
import pandas as pd
from Bio import SeqIO

configfile: "config/config.yaml"

samples = pd.read_csv(config["samples"], sep="\t")
samples_dict = samples.set_index('sample').to_dict(orient="index")
include: "rules/download.smk"
include: "rules/lof.smk"
include: "rules/predict.smk"

rule all:
    input:
        "data/genomes.zip",
        "data/proteins.faa",
        expand("data/pseudofinder/{sample}/{sample}_pseudos.fasta", sample=samples["sample"]),
        "data/ast_predictions/model_rsquared.txt",
        "data/clustered_pseudo_sequences.fasta",
        "data/lof_presence_absence_matrix.tsv"
