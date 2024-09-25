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
## Installation of Pseudofinder Software
- Load the modules-Python (Latest Version) and Anaconda3/2024
- Installation code
  1. git clone https://github.com/filip-husnik/pseudofinder.git
  2. cd pseudofinder
  3. bash setup.sh
  4. conda init
  5. conda activate pseudofinder

## TO DO
- finish testing download and renaming rules
- create appropriate conda environment for pseudofinder
- test pseudofinder rule
- create rule for cdhit
- write rule to run script that reformats AMRFinder output
- write script to compare linear models with and without LOF mutations

## Results

## Future Work

## NCBI Codeathon Disclaimer
This software was created as part of an NCBI codeathon, a hackathon-style event focused on rapid innovation. While we encourage you to explore and adapt this code, please be aware that NCBI does not provide ongoing support for it.

For general questions about NCBI software and tools, please visit: [NCBI Contact Page](https://www.ncbi.nlm.nih.gov/home/about/contact/)

