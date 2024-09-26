rule reformat_amrfinderplus:
    input:
        config["amrfinder"]
    output:
        "data/biosample_gene.csv"
    conda:
        "../envs/tidyverse.yml"
    shell:
        """
        Rscript create_amr_presence_absence.R
        """

rule predictions:
    input:
        "data/biosample_gene.csv"
    output:
        core_results=expand("data/ast_predictions/{antibiotic}_core.tsv", antibiotic = ["azithromycin", "ceftriaxone", "ciprofloxacin", "penicillin", "tetracycline"]),
        plus_results=expand("data/ast_predictions/{antibiotic}_plus.tsv", antibiotic = ["azithromycin", "ceftriaxone", "ciprofloxacin", "penicillin", "tetracycline"]),
        rsquared="data/ast_predictions/model_rsquared.txt"
    conda:
        "../envs/tidyverse.yml"
    shell:
        """
        Rscript scripts/predict_mics.R > {output.rsquared}
        """
