rule make_blast_db:
    input:
        config["proteins"]
    output:
        expand("data/blastdb/protein_db.{ext}", ext=["pdb","phr","pin","pot","psq","ptf","pto"])
    conda:
        "blast.yml"
    shell:
        """
        makeblastdb -in {input} -dbtype prot -out data/blastdb/protein_db
        """

rule pseudofinder:
	input:
        blastdb=expand("data/blastdb/protein_db.{ext}", ext=["pdb","phr","pin","pot","psq","ptf","pto"]),
		annotation="data/annotations/{sample}.gbff"
	output:
		"data/pseudofinder/{sample}/{sample}_pseudos.fasta"
	conda:
		"../pseudofinder-1.1.0/modules/environment.yml"
    threads: 16
    resources:
        mem=10GB
	shell:
		"""
		python3 ../pseudofinder-1.1.0/pseudofinder.py annotate --threads {threads} --genome {input.annotation} --database data/blastdb/protein_db --outprefix data/pseudofinder/{wildcards.sample}/{wildcards.sample}" 
		"""

rule cluster_pseudogenes:
	input:
		expand("data/pseudofinder_output", sample=all_samples)
	output:
		"data/lof_matrix.tsv"
	conda:
		"envs/cdhit.yml"
	shell:
		"""
		bash scripts/cdhit.sh
		"""
