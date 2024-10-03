rule deduplicate_proteins:
    input:
        proteins="data/proteins.faa"
    output:
        fasta_out="data/proteins_unique.faa"
    resources:
        runtime=360
    run:
        unique = []
        ids = []
        for rec in SeqIO.parse(input.proteins, "fasta"):
            if rec.id in ids:
                continue
            else:
                unique.append(rec)
                ids.append(rec.id)
        SeqIO.write(unique, output.fasta_out, "fasta")

rule make_blast_db:
    input:
        "data/proteins_unique.faa"
    output:
        expand("data/blastdb/protein_db.{ext}", ext=["pdb","phr","pin","pot","psq","ptf","pto"])
    conda:
        "../envs/blast.yml"
    resources:
        runtime=120
    shell:
        """
        makeblastdb -in {input} -dbtype prot -out data/blastdb/protein_db
        """

rule pseudofinder:
    input:
        blast=expand("data/blastdb/protein_db.{ext}", ext=["pdb","phr","pin","pot","psq","ptf","pto"]),
        annotation="data/annotations/{sample}.gbff"
    output:
        "data/pseudofinder/{sample}/{sample}_pseudos.fasta"
    conda:
        "../pseudofinder-1.1.0/modules/environment.yml"
    threads: 16
    resources:
        mem=10000,
    shell:
        """
        python3 pseudofinder-1.1.0/pseudofinder.py annotate --threads {threads} --genome {input.annotation} --database data/blastdb/protein_db --outprefix data/pseudofinder/{wildcards.sample}/{wildcards.sample}
        """

rule cluster_pseudogenes:
    input:
        expand("data/pseudofinder/{sample}/{sample}_pseudos.fasta", sample=samples["sample"])
    output:
        "data/lof_matrix.tsv"
    conda:
        "../envs/cdhit.yml"
    shell:
        """
        bash scripts/cdhit.sh
        """
