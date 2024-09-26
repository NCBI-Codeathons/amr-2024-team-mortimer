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
        directory("ncbi_dataset/data/")
    shell:
        """
        unzip data/genomes.zip
        """

def match_assemblies_annotations(wildcards):
    unzip_output = checkpoints.unzip.get(**wildcards).output[0]
    accession = samples_dict[wildcards.sample]["genbank_accession"]
    assembly_files = glob.glob(f"{unzip_output}/{accession}/*.fna")
    if assembly_files:
        assembly = assembly_files[0]
    else:
        raise FileNotFoundError(f"No .fna file found for accession {accession}")
    annotation = f"{unzip_output}/{accession}/genomic.gbff"
    if not os.path.exists(annotation):
        raise FileNotFoundError(f"No genomic.gbff file found for accession {accession}")
    return {"assembly":assembly, "annotation":annotation}

rule rename:
    input:
        unpack(match_assemblies_annotations)
    output:
        assembly="data/assemblies/{sample}.fna",
        annotation="data/annotations/{sample}.gbff"
    shell:
        """
        cp {input.assembly} {output.assembly}
        cp {input.annotation} {output.annotation}
        """
