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
		"data/pseudofinder/{sample}/{sample}_psuedos.fasta"
	conda:
		"envs/pseudofinder.yml"
	shell:
		"""
		pseudofinder.py annotate --genome {input.annotation} --database data/blastdb/protein_db --outprefix {wildcards.sample}" 
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
