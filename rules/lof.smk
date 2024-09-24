rule annotation:
	input:
		"data/genome_assembly"
    output:
        "data/genome_annotation"
    conda:
        "envs/conda_environment.yml"
    shell:
        """
        annotation command
        """

rule pseudofinder:
    input:
        "data/genome_annotation"
    output:
        "data/pseudofinder_output"
    conda:
        "envs/pseudofinder.yml"
    shell:
        """
        pseudofinder command
        """

rule cluster_pseudogenes:
    input:
        expand("data/pseudofinder_output", sample=all_samples)
    output:
        "data/lof_matrix.tsv"
    conda:
        "envs/conda_environment.yml"
    shell:
        """
        command to cluster pseudogene sequences
        """
