library(tidyverse)
library(broom)
library(glue)

target_antibiotics <- c("azithromycin", "ceftriaxone", "ciprofloxacin", "penicillin", "tetracycline")
amr_loci <- read_csv("data/biosample_gene.csv")
mics <- read_tsv("config/mics.tsv")
samples <- read_tsv("config/samples.tsv")
mics <- mics %>% rename(sample = accession)
amr_loci <- amr_loci %>% rename(biosample_acc = BioSample)

# separate core and plus loci
amr_loci_plus <- amr_loci %>% select(biosample_acc, farB, mtrA, mtrC, mtrF, mtrR, norM)
amr_loci_core <- amr_loci %>% select(-farB, -mtrA, -mtrC, -mtrF, -mtrR, -norM)


mics <- mics %>% mutate(mic_log = log2(mic_numeric))

create_models <- function(target_antibiotic){
  mics_abx <- mics %>% filter(antibiotic == target_antibiotic)
  if (target_antibiotic == "azithromycin"){
    amr_loci_core_antimicrobial <- amr_loci_core %>% select(biosample_acc, starts_with("23S"), starts_with("rpl"), starts_with("mtr"), starts_with("porB"))
  }
  if (target_antibiotic == "ceftriaxone"){
    amr_loci_core_antimicrobial <- amr_loci_core %>% select(biosample_acc, starts_with("rpo"), starts_with("penA"), starts_with("mtr"), starts_with("porB"))
  }
  if (target_antibiotic == "ciprofloxacin"){
    amr_loci_core_antimicrobial <- amr_loci_core %>% select(biosample_acc, starts_with("gyr"), starts_with("par"), starts_with("nor"), starts_with("mtr"), starts_with("porB"))
  }
  if (target_antibiotic == "penicillin"){
    amr_loci_core_antimicrobial <- amr_loci_core %>% select(biosample_acc, starts_with("bla"), starts_with("pen"), starts_with("mtr"), starts_with("porB"))
  }
  if (target_antibiotic == "tetracycline"){
    amr_loci_core_antimicrobial <- amr_loci_core %>% select(biosample_acc, starts_with("tet"), starts_with("rpsJ"), starts_with("mtr"), starts_with("porB"))
  }
  amr_loci_core_antimicrobial <- amr_loci_core_antimicrobial %>% left_join(samples) %>% left_join(mics_abx %>% select(sample, mic_log))
  amr_loci_core_antimicrobial <- amr_loci_core_antimicrobial %>% 
    select(-sample, -disposition, -genbank_accession) %>% 
    filter(!is.na(mic_log), is.finite(mic_log))

  model1 <- lm(mic_log ~ .-biosample_acc, data=amr_loci_core_antimicrobial, x=TRUE, y=TRUE)
  write_tsv(tidy(model1) %>% select('term', 'std.error', 'estimate', 'p.value'), glue('data/ast_predictions/{target_antibiotic}_core.tsv'))
  print(glue("Adjusted R-squared for {target_antibiotic} with only core genes: {summary(model1)$adj.r.squared}"))
  plus <- amr_loci_core_antimicrobial %>% left_join(amr_loci_plus)
  model2 <- lm(mic_log ~ .-biosample_acc, data=plus, x=TRUE, y=TRUE)
  write_tsv(tidy(model2) %>% select('term', 'std.error', 'estimate', 'p.value'), glue('data/ast_predictions/{target_antibiotic}_plus.tsv'))
  print(glue("Adjusted R-squared for {target_antibiotic} with plus genes: {summary(model2)$adj.r.squared}"))
  }

for (t in target_antibiotics){
  create_models(t)
}
