import pandas as pd

configfile: "config/config.yaml"

samples = pd.read_csv(config["samples"], sep="\t")
samples_dict = samples.set_index('sample').to_dict(orient="index")

include: "rules/download.smk"

rule all:
    input:
        "data/proteins.faa",
        expand("data/assemblies/{sample}.fna", sample=samples["sample"])
