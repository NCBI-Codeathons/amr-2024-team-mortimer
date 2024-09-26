
# Empty my environment  ---------------------------------------------------
rm(list = ls())

# Load packages -----------------------------------------------------------

library(readr)
library(tidyr)
library(dplyr)




# see current working directory  -----------------------------------------
getwd()





# set working directory  --------------------------------------------------
setwd("your_working_directory")


# Import Dataframe --------------------------------------------------------

DF <- read_tsv("amrfinder.tsv", col_names = TRUE, show_col_types = FALSE)





# Replace the spaces with "_" in the column names  ------------------------

# Get the current column names
col_names <- colnames(DF)

# Replace spaces with underscores
col_names <- gsub(" ", "_", col_names)

# Assign the modified names back to the data frame
colnames(DF) <- col_names



# Restructure the DF and assign 1 for present and 0 for absent  -----------

new_DF <- DF %>%
  select(BioSample, Element_symbol) %>%
  distinct() %>%
  mutate(present = 1) %>%
  pivot_wider(names_from = Element_symbol, values_from = present, values_fill = list(present = 0))



# Function to check to make sure this working as expected  ----------------

count_ones_zeros <- function(df, sample_id) {
  # Filter the dataframe for the specific BioSample
  sample_row <- df[df$BioSample == sample_id, -which(names(df) == "BioSample")]
  
  # Return counts of ones and zeros
  ones_count <- sum(sample_row == 1, na.rm = TRUE)
  zeros_count <- sum(sample_row == 0, na.rm = TRUE)
  
  return(list(ones = ones_count, zeros = zeros_count))
}

# Apply the function to a specific BioSample to check for accuracy 
result <- count_ones_zeros(new_DF, "SAMD00089756")
print(result)

# Save the tibble to a CSV file
#write.csv(new_DF, file = "antibiotic_resistance_data_0-1.csv", row.names = FALSE)

