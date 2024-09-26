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




# compare Element_symbol to Subclass  -------------------------------------------------------------

# Summarize the data
summary_df_subclass <- DF %>%
  group_by(Element_symbol, Subclass) %>%
  summarise(count = n(), .groups = 'drop') %>%
  arrange(desc(count))

# Extract part before the underscore and replace blaTEM variants
summary_df_subclass <- summary_df_subclass %>%
  mutate(Element_symbol = ifelse(str_detect(Element_symbol, "blaTEM"), "blaTEM", str_split_fixed(Element_symbol, "_", 2)[, 1]))

# Ensure the count column is numeric
summary_df_subclass <- summary_df_subclass %>%
  mutate(count = as.numeric(count))

# Summing counts for each subclass with respect to each unique element symbol
summary_df_subclass <- summary_df_subclass %>%
  group_by(Element_symbol, Subclass) %>%
  summarize(count = sum(count, na.rm = TRUE), .groups = 'drop')

# Convert count to numeric if it's not already
summary_df_subclass$count <- as.numeric(summary_df_subclass$count)

# Reorder the Element_symbol factor based on the count values
summary_df_subclass <- summary_df_subclass %>%
  arrange(desc(count)) %>%
  mutate(Element_symbol = fct_reorder(Element_symbol, count, .desc = TRUE))


# Filter the dataframe
summary_df_subclass <- summary_df_subclass %>%
  filter(!is.na(count) & count >= 10)

#Make a dot plot
# Define the shapes and colors
shapes <- c(15, 16, 17, 15, 16, 17, 15, 16, 17, 15, 16)
colors <- c(rep("#6885d0", 3), rep("#b75fb3", 3), rep("#4aac88", 3), rep("black", 2))


# Identify genes with more than one dot
genes_with_multiple_dots <- summary_df_subclass %>%
  group_by(Element_symbol) %>%
  filter(n() > 1) %>%
  pull(Element_symbol) %>%
  unique()

# Create the dot plot with custom shapes and colors
dot_plot <- ggplot(summary_df_subclass, aes(x = Element_symbol, y = count, shape = Subclass, color = Subclass)) +
  geom_point(size = 3, stroke = 1.5) +  # Increase point size
  scale_shape_manual(values = shapes) +
  scale_color_manual(values = colors) +
  labs(title = "Subclass count by Element Symbol",
       x = "Element Symbol",
       y = "Total Count") +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 14, color = ifelse(levels(summary_df_subclass$Element_symbol) %in% genes_with_multiple_dots, "red", "black")),
    axis.text.y = element_text(size = 14),  # Increase Y-axis text size
    axis.title.x = element_text(size = 16),  # Increase X-axis title size
    axis.title.y = element_text(size = 16),  # Increase Y-axis title size
    legend.text = element_text(size = 12),   # Increase legend text size
    legend.title = element_text(size = 16),   # Increase legend title size
    legend.position = "bottom",
    legend.margin = margin(t = 10),          # Move legend down by increasing top margin
    legend.key = element_blank(),              # Remove the background for individual legend keys
    legend.spacing.y = unit(0.5, "cm"),        # Increase space between legend items
    legend.box.margin = margin(10, 10, 10, 10), # Add margin around the entire legend box
    legend.background = element_rect(fill = "white", colour = "black", size = 0.5),  # Box around the entire legend
    panel.background = element_rect(fill = "white"),
    plot.background = element_rect(fill = "white"),
    plot.title = element_text(size = 18)      # Increase plot title size
  )

print(dot_plot)

# Save the plot
#ggsave("dot_plot_amr.png", plot = dot_plot, width = 14, height = 10)
