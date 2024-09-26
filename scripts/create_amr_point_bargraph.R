#see current working directory 
getwd()

rm(list = ls())

#set working directory 
setwd("your_working_directory")

#Download packages 
library(readr)
library(knitr)
library(DT)
library(dplyr)
library(writexl)
library(ggplot2)
library(forcats)
library(tidyr)
library(patchwork)
library(stringr)
library(ggtext)

# Import Dataframe --------------------------------------------------------

DF <- read_tsv("amrfinderplus_v2.tsv", col_names = TRUE, show_col_types = FALSE)




# Replace the spaces with "_" in the column names  ------------------------

# Get the current column names
col_names <- colnames(DF)

# Replace spaces with underscores
col_names <- gsub(" ", "_", col_names)

# Assign the modified names back to the data frame
colnames(DF) <- col_names

# Remove '#' from column names
colnames(DF) <- gsub("#", "", colnames(DF))

# Filter out rows with the specified terms in the Method column
DF <- DF %>%
  filter(!grepl("INTERNAL_STOP|PARTIALX|PARTIALP", Method))



# compare Element_symbol to Subtype  -------------------------------------------------------------

# Summarize the data
summary_df <- DF %>%
  group_by(Element_symbol, Subtype) %>%
  summarise(count = n(), .groups = 'drop') %>%
  arrange(desc(count))

# Remove rows where Subtype contains "BIOCIDE"
summary_df <- summary_df %>% 
  filter(!grepl("BIOCIDE", Subtype, ignore.case = TRUE))

# Extract part before the underscore and replace blaTEM variants
summary_df <- summary_df %>%
  mutate(Element_symbol = ifelse(str_detect(Element_symbol, "blaTEM"), "blaTEM", str_split_fixed(Element_symbol, "_", 2)[, 1]))


# Ensure the count column is numeric
summary_df <- summary_df %>%
  mutate(count = as.numeric(count))

# Group by Element_symbol and Subtype, then sum the count
summary_df <- summary_df %>%
  group_by(Element_symbol, Subtype) %>%
  summarise(count = sum(count), .groups = 'drop')


# Calculate maximum values per Subtype for y-axis limit
max_vals <- summary_df %>%
  group_by(Subtype) %>%
  summarise(max_count = max(count) * 1.2,
            Element_symbol = Element_symbol[which.max(count)])  # Ensure there's a matching Element_symbol

# Identify terms that appear in more than one Subtype
highlight_terms <- summary_df %>%
  group_by(Element_symbol) %>%
  summarise(subtype_count = n_distinct(Subtype)) %>%
  filter(subtype_count > 1) %>%
  pull(Element_symbol)

summary_df <- summary_df %>%
  mutate(Element_symbol = as.character(Element_symbol)) %>%
  mutate(Element_symbol_label = ifelse(Element_symbol %in% highlight_terms, 
                                       paste0("<span style='color:red;'>", Element_symbol, "</span>"), 
                                       Element_symbol))
# Filter out entries with count less than 10
summary_df <- summary_df %>%
  filter(count >= 10)

# Create the bar plot with facets for amr and point
barplot_element_subtype <- ggplot(summary_df, aes(x = reorder(Element_symbol_label, count), y = count, fill = Subtype)) +
  geom_bar(stat = "identity", position = position_dodge2(preserve = "single")) +
  geom_text(aes(label = count), vjust = -0.5, size = 4, position = position_dodge2(width = 0.9, preserve = "single")) +
  geom_hline(yintercept = 0, color = "black", size = 0.5) +
  theme(axis.text.x = element_markdown(angle = 90, hjust = 1, size = 14),  # Increase x-axis text size
        axis.text.y = element_text(size = 14),  # Increase y-axis text size
        axis.title.x = element_text(size = 16, face = "bold"),  # Increase x-axis title size
        axis.title.y = element_text(size = 16, face = "bold"),  # Increase y-axis title size
        legend.text = element_text(size = 12),  # Increase legend text size
        legend.title = element_text(size = 14, face = "bold"),  # Increase legend title size
        plot.title = element_text(size = 18, face = "bold", hjust = 0.5),  # Increase graph title size and center it
        plot.caption = element_text(size = 12, face = "italic"),  # Increase caption size
        strip.text = element_text(size = 14, face = "bold"),  # Increase facet label text size
        panel.background = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.line = element_line(color = "black")) +
  labs(title = "Comparison of Gene Symbols and Element Subtypes", 
       x = "Gene Symbol", 
       y = "Count",
       caption = "Note: Red labels indicate genes present in both AMR and POINT categories.\nEntries with a count less than 10 were excluded from the graph.") +  # Two lines in the caption
  facet_wrap(~Subtype, ncol = 2, scales = "free") +
  guides(fill = guide_legend(title = "Element Subtype", nrow = 2, ncol = 2)) +
  theme(legend.position = "bottom", 
        legend.box = "horizontal",  
        legend.key.size = unit(0.5, "cm"),
        panel.spacing = unit(2, "lines"))

print(barplot_element_subtype)

ggsave("barplot_element_subtype.png", plot = barplot_element_subtype, width = 14, height = 8)
