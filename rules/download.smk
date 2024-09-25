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
    resources:
    	runtime=120
    shell:
        """
        mkdir -p data
        datasets download genome accession --inputfile {input} --filename {output} --no-progressbar --include genome,gbff
        """

checkpoint unzip:
    input:
        "data/genomes.zip"
    output:
        directory("data/ncbi_dataset/data/{accession}/"),
    shell:
        """
        unzip data/genomes.zip
        """

def match_assemblies_annotations(wildcards):
    demultiplex_output = checkpoints.demultiplex.get(experiment=wildcards.unzip).output[0]
    accession = samples['genbank_accession'][samples['sample'] == wildcards.sample].values[0]
    assembly = glob.glob(f"data/ncbi_dataset/data/{accession}/*.fna")[0]
    annotation = f"data/ncbi_dataset/data/{accession}/genomic.gbff"
    return {"assembly":assembly, "annotation":annotation}

rule rename:
	input:
		unpack(match_assemblies_annotations)
	output:
		"output/assembly/{wildcards.samples}_genomic.fna"
		"output/annotations/{wildcards.samples}_genomic.gbff"
        shell:
		"""
		mv {input.assembly} /output/assembly/{wildcards.samples}_genomic.fna
		mv {input.annotation} /output/annotation/{wildcards.samples}_genomic.gbff
		"""
