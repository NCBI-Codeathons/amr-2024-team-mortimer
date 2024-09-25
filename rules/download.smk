rule generate_ncbi_datasets_input:
    input:
        config["samples"]
    output:
        temp("data/assembly_accessions.txt")
    shell:
        """
        tail -n +2 {input} | cut -f3 > {output}
        """

rule download_proteins:
    output:
        temp("data/proteins.zip"),
        temp("data/proteins.faa")
    params:
        species=config["species"]
    conda:
        "../envs/ncbi_datasets.yml"
    resources:
        runtime=30
    shell:
        """
        mkdir -p data
        datasets download genome taxon {params.species} --assembly-level complete --include protein --filename proteins.zip
	unzip -o proteins.zip
	cat ncbi_dataset/data/*/*.faa > data/proteins.faa
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
        directory(expand("ncbi_dataset/data/{accession}/", accession=samples["genbank_accession"]))
    shell:
        """
        unzip data/genomes.zip
        """

def match_assemblies_annotations(wildcards):
    demultiplex_output = checkpoints.unzip.get(**wildcards).output[0]
    accession = samples_dict[wildcards.sample]["genbank_accession"]
    assembly = glob.glob(f"ncbi_dataset/data/{accession}/*.fna")[0]
    annotation = f"ncbi_dataset/data/{accession}/genomic.gbff"
    return {"assembly":assembly, "annotation":annotation}

rule rename:
    input:
        unpack(match_assemblies_annotations)
    output:
        "data/assemblies/{sample}.fna",
        "data/annotations/{sample}.gbff"
    shell:
        """
        mv {input.assembly} data/assembly/{wildcards.samples}_genomic.fna
        mv {input.annotation} data/annotation/{wildcards.samples}_genomic.gbff
        """
