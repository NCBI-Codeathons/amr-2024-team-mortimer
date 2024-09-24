configfile: "config/config.yaml"

include: "rules/download.smk"

rule all:
    input:
        "data/genomes.zip"
