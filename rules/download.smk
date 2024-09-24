rule generate_ncbi_datasets_input:
    input:
        config["samples"]
    output:
        temp("data/assembly_accessions.txt")
    shell:
        """
        tail -n +2 {input} | cut -f3 > {output}
        """


rule download_assemblies:
    input:
	"data/assembly_accessions.txt"
    output:
        "data/genomes.zip"
    conda:
        "../envs/ncbi_datasets.yml"
    shell:
        """
        mkdir -p data
        datasets download genome accession --inputfile {input} --filename {output} --no-progressbar --include genome,gbff
        """

rule rename:
	input:
		"data/genomes.zip"
        output:
		"renamed_data/{sample number}.fastq"
        shell:
		"""
                for file in /data/*:
			write some code to navigate to the file we need
			mv this file into the renamed_data folder
			rename this file including (wildcards.samples)
		"""
