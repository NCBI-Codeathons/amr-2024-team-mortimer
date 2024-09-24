rule rename:
	input:
		"/downloads/{genbank_accession}.fastq"
	output:
		"/renamed_downloads/{sample number}.fastq"
	shell:
		"""
		for file in /data/*/.fastq
		
		do
		directory_name=$(dirname $file)
		accession=$(basename $directory_name)
		mv "${file}" "${directory_name}/${accession}_$(basename $file
		""
 
rule annotation:
	input:
		assembly = "data/genome_assembly/contigs.fasta"
	output:
		"data/genome_annotation/samples"
	conda:
		"prokka.yaml"
	resources:
		cpus=8
	shell:
		"prokka --force --genus Neisseria --species gonorrhoeae --outdir data/genome_annotation/{wildcards.samples} --prefix {wildcards.samples} --locustag {wildcards.samples} {input.assembly}"


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
