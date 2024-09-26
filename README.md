# Loss of function alleles in *Neisseria gonorrhoeae* and their impact on antimicrobial susceptibility

List of participants and affiliations:
- Tatum Mortimer, Department of Population Health, University of Georgia (Team Leader)
- Farah Saeed, Franklin College of Arts and Sciences, University of Georgia 
- Shriya Garg, Franklin College of Arts and Sciences, University of Georgia
- Brittany Henry, Department of Population Health, University of Georgia
- Shanita Zaman Smrity, Department of Population Health, University of Georgia

## Project Goals

Our project has two goals:
1. Develop a pipeline to identify loss of function alleles across the pangenome from bacterial genome assemblies and anntotations.
2. Assess the contribution of loss of function alleles in efflux pump associated genes to prediction of antimicrobial susceptibility data in *Neisseria gonorrhoeae*.

## Approach

- Develop a snakemake pipeline to generate a loss of function (LOF) allele presence/absence matrix from bacterial genome assemblies.
    - Either download PGAP-annotated genomes from NCBI or annotate assembies with bakta/prokka
    - Identify LOF alleles using pseudofinder
    - Cluster LOF alleles using CD-HIT
- Compare antimicrobial susceptibility prediction with and without efflux pump LOF alleles.
    - Download AMRFinderPlus results for isolates
    - Acquire efflux pump LOF alleles from either snakemake pipeline results or partial hits in AMRFinderPlus --plus output
    - Predict MICs using linear regression from AMRFinderPlus core genes and alleles
    - Predict MICs using linear regression from AMRFinderPlsu core genes and alleles AND efflux pump LOF
    - Compare predictions

## Pipeline Requirements

This pipeline uses the workflow manager Snakemake and Mamba for software installation. Additionally, the pipeline requires [Pseudofinder](https://github.com/filip-husnik/pseudofinder/), which is not available on conda.

### Resources for installing mamba
Instructions for minimal Mamba installation can be found here: [Miniforge](https://github.com/conda-forge/miniforge)

### Resources for installing Snakemake
Instructions for installing Snakemake can be found here: [Snakemake Installation](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html).

### Resources for installing Pseudofinder
- Download the release from github: `wget https://github.com/filip-husnik/pseudofinder/archive/refs/tags/v1.1.0.tar.gz`
- Uncompress the archive with tar: `tar -xf v1.1.0.tar.gz`

## TO DO
- test pseudofinder rule
- create rule for cdhit
- write rule to run script that reformats AMRFinder output
- write script to compare linear models with and without LOF mutations

## Results

## Future Work

## NCBI Codeathon Disclaimer
This software was created as part of an NCBI codeathon, a hackathon-style event focused on rapid innovation. While we encourage you to explore and adapt this code, please be aware that NCBI does not provide ongoing support for it.

For general questions about NCBI software and tools, please visit: [NCBI Contact Page](https://www.ncbi.nlm.nih.gov/home/about/contact/)

