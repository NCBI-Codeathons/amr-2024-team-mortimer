import glob
import pandas as pd

configfile: "config/config.yaml"

samples = pd.read_csv(config["samples"], sep="\t")
samples_dict = samples.set_index('sample').to_dict(orient="index")
print(samples_dict)
include: "rules/download.smk", "rules/lof.smk"

rule all:
    input:
        expand("data/pseudofinder/{sample}/{sample}_pseudos.fasta", sample=samples["sample"])
