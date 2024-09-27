# Loss-of-function alleles in *Neisseria gonorrhoeae* and their impact on antimicrobial susceptibility

List of participants and affiliations:
- Tatum Mortimer, Department of Population Health, University of Georgia (Team Leader)
- Farah Saeed, Franklin College of Arts and Sciences, University of Georgia 
- Shriya Garg, Franklin College of Arts and Sciences, University of Georgia
- Brittany Henry, Department of Population Health, University of Georgia
- Shanita Zaman Smrity, Department of Population Health, University of Georgia

## Project Goals

In *Neisseria gonorrhoeae*, loss-of-function mutations in genes encoding the Mtr efflux pump have been demonstrated to increase susceptibility to multiple antimicrobials ([1](https://doi.org/10.1099/00221287-144-3-621),[2](https://doi.org/10.1038/s41467-020-17980-1)). Loss-of-function of the Mtr repressor, MtrR, leads to increased antimicrobial resistance ([3](https://doi.org/10.1111/j.1365-2958.2008.06424.x)). The *mtr* operon is also regulated by an activator, MtrA, and loss-of-function alleles occur in clinical isolates ([4](https://doi.org/10.1046/j.1365-2958.1999.01517.x)); however, it's unclear what impact these loss-of-function alleles have on prediction of antimicrobial susceptibility. *N. gonorrhoeae* also encodes several other efflux pumps ([5](https://doi.org/10.1007/978-3-319-39658-3_17)), and the contribution of these pumps to antimicrobial susceptibility in clinical isolates is unknown.

Our project has two goals:
1. Develop a pipeline to systematically identify loss-of-function alleles across the pangenome from bacterial genome assemblies and anntotations.
2. Assess the contribution of loss of function alleles in efflux pump associated genes to prediction of antimicrobial susceptibility data in *Neisseria gonorrhoeae*.

## Approach

- Develop a snakemake pipeline to generate a loss of function (LOF) allele presence/absence matrix from bacterial genome assemblies.
    - Download PGAP-annotated genomes from NCBI or annotate assembies with bakta/prokka
    - Identify LOF alleles using pseudofinder
    - Cluster LOF alleles using CD-HIT
- Compare antimicrobial susceptibility prediction with and without efflux pump LOF alleles.
    - Download AMRFinderPlus results for isolates
    - Acquire efflux pump LOF alleles from either snakemake pipeline results or partial hits in AMRFinderPlus --plus output
    - Predict MICs using linear regression from AMRFinderPlus core genes and alleles
    - Predict MICs using linear regression from AMRFinderPlsu core genes and alleles AND efflux pump LOF
    - Compare predictions

## Pipeline Requirements

This pipeline uses the workflow manager Snakemake and Mamba for software installation. The workflow also uses the python packages pandas and biopython. Additionally, the pipeline requires [Pseudofinder](https://github.com/filip-husnik/pseudofinder/), which is not available on conda.

### Resources for installing mamba
Instructions for minimal Mamba installation can be found here: [Miniforge](https://github.com/conda-forge/miniforge)

### Resources for installing Snakemake
Instructions for installing Snakemake can be found here: [Snakemake Installation](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html).

### Resources for installing Pseudofinder
- Download the release from github: `wget https://github.com/filip-husnik/pseudofinder/archive/refs/tags/v1.1.0.tar.gz`
- Uncompress the archive with tar: `tar -xf v1.1.0.tar.gz`

### Resources for installing R, Rtools, and RStudio
-R and Rtools can be downloaded and installed from the CRAN website: `https://cran.r-project.org/`

-Rstudio can be downloaded from the Posit website: `https://posit.co/download/rstudio-desktop/`

-Software versions for this project: R-4.4.1; Rtools4.4; RStudio 2024.09.0+375

## Results

### LOF pipeline

We were able to generate the steps to create a matrix of loss-of-function alleles from a collection of bacterial genomes. Unfortunately, due to impacts of Hurrican Helene on our computing cluster, this pipeline could use some more testing!

### Presence or Absence of AMR genes

R was used to create a matrix showing presence or absence of AMR genes for unique BioSamples with data from amrfinderplus with 0 denoting absence and 1 denoting presence. 

Script: [create_amr_presence_absence.R](https://github.com/NCBI-Codeathons/amr-2024-team-mortimer/blob/main/scripts/create_amr_presence_absence.R)

### Analysis of AMR Genes and Point Mutations in Antimicrobial Resistance

R was used to examine data from amrfinderplus to examine different resistance mechanisms for different genes. 

Script: [create_amr_point_bargraph.R](https://github.com/NCBI-Codeathons/amr-2024-team-mortimer/blob/main/scripts/create_amr_point_bargraph.R)

-AMR refers to antimicrobial resistance genes or elements that confer resistance to antibiotics via gene acquisition.  These are typically whole genes (like resistance genes) or gene variants, such as efflux pumps, beta-lactamases, or other known genes that mediate resistance by producing proteins.

-POINT refers to point mutations in genes, rather than the presence of an entire resistance gene.  Point mutations are single nucleotide changes in specific genes that can alter the function of proteins, leading to resistance.  POINT typically refers to mutations in chromosomal genes that are known to contribute to resistance. These mutations can affect target sites of antibiotics, reduce drug binding, or alter enzyme function.

![barplot_element_subtype](https://github.com/user-attachments/assets/193ed7b3-b846-4c21-9174-07a531e41435)

### BioSample Drug Resistance by Gene

R was used to examine the drug resistance for each gene.  The graph below shows the total number of BioSamples with a given resistance for each gene.  Note, the threshold was for resistances with occurrences in more than 10 BioSamples. 

Script: [create_amr_by_gene.R](https://github.com/NCBI-Codeathons/amr-2024-team-mortimer/blob/main/scripts/create_amr_by_gene.R)

![dot_plot_amr](https://github.com/user-attachments/assets/e05e1614-387c-4f06-96fa-ebdac29cbe3f)


### AST Prediction

Using MICs collected from primary literatue (see `config/mics.txt`) and AMRFinderPlus results from Pathogen Detection, we predicted log-transformed MICs from known resistance-associated loci in *N. gonorrhoeae*.

Script: [predict_mics.R](https://github.com/NCBI-Codeathons/amr-2024-team-mortimer/blob/main/scripts/predict_mics.R)

#### Genetic loci included in models

|Antibiotic|Genetic Loci|
|----------|-------------|
|Azithromycin|23S rRNA, *rplD*, *rplV*, *porB*, *mtr* operon|
|Ciprofloxacin|*gyrA*, *parC*, *norM*, *porB*, *mtr* operon|
|Ceftriaxone|*penA*, *ponA*, *rpoB* R201H, *rpoD*, *porB*, *mtr* operon|
|Penicillin|*bla*TEM, *penA*, *ponA*, *porB*, *mtr* operon|
|Tetracycline|*rpsJ*, *tet(M)*, *porB*, *mtr* operon|

#### Prediction of antimicrobial susceptibility is improved by the addition of loss-of-function variation in the mtr operon


|Antibiotic|Adjusted R-squared core model|Adjusted R-squared plus model|Significant plus loci|
|----------|-----------------------------|-----------------------------|---------------------|
|Azithromycin|0.333|0.432|*mtrC*, *mtrR*|
|Ciprofloxacin|0.917|0.918|*mtrC*, *mtrR*|
|Ceftriaxone|0.611|0.631|*mtrC*, *mtrF*, *mtrR*|
|Penicillin|0.722|0.729|*mtrA*, *mtrC*, *mtrR*|
|Tetracycline|0.812|0.818|*mtrC*, *mtrR*|

## Future Work

We plan to continue testing our loss-of-function calling pipeline, including finishing integration of the clustering step and testing on additional bacterial species.

## NCBI Codeathon Disclaimer
This software was created as part of an NCBI codeathon, a hackathon-style event focused on rapid innovation. While we encourage you to explore and adapt this code, please be aware that NCBI does not provide ongoing support for it.

For general questions about NCBI software and tools, please visit: [NCBI Contact Page](https://www.ncbi.nlm.nih.gov/home/about/contact/)

