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
		"/work/tdmlab/codeathon_resources/ncbi_dataset/data/GCA*.1/"
        output:
		"assembly/{wildcards.samples}_genomic.fna"
		"annotations/{wildcards.samples}_genomic.gbff"
        shell:
		"""
                for /work/tdmlab/codeathon_resources/ncbi_dataset/data/GCA*.1/:
			mv GCA*.1*genomic.fna ~/assembly/{wildcards.samples}_genomic.faa
			mv GCA*.1*genomic.gbff ~/annotations/{wildcards.samples}_genomic.gbff               
		"""
