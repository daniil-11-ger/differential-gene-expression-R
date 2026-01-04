# =========================================================================
# Title: Differential Gene Expression (DGE) Analysis Pipeline
# Purpose: Identify significant genes between LS and HS conditions
# Author: Daniil Gerassimov


# 1. Environment Setup ----------------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, readxl, writexl, ggrepel)

# 2. Data Loading & Cleaning ----------------------------------------------
# Load data from Excel (handles both .xlsx and .xls)
raw_data <- read_excel("data/gene_exp1.xlsx")

# Function to fix comma-decimal issues common in localized Excel exports
clean_numeric <- function(x) {
  if(is.character(x)) as.numeric(gsub(",", ".", x)) else x
}

# Define sample groups (Adjust names based on your columns)
ls_samples <- c("LS1L1", "LS1L2", "LS1L3")
hs_samples <- c("HS1L1", "HS1L2", "HS1L3")

# Apply cleaning and ensure numeric types
clean_data <- raw_data %>%
  mutate(across(all_of(c(ls_samples, hs_samples)), clean_numeric))

# 3. Statistical Analysis -------------------------------------------------
analysis_results <- clean_data %>%
  rowwise() %>%
  mutate(
    # Paired t-test
    p_value = t.test(c_across(all_of(ls_samples)), 
                     c_across(all_of(hs_samples)), 
                     paired = TRUE)$p.value,
    
    # Calculate means (using na.rm for safety)
    mean_LS = mean(c_across(all_of(ls_samples)), na.rm = TRUE),
    mean_HS = mean(c_across(all_of(hs_samples)), na.rm = TRUE),
    
    # Log2 Fold Change calculation with pseudocount to avoid log(0)
    LFC = log2((mean_HS + 0.01) / (mean_LS + 0.01))
  ) %>%
  ungroup() %>%
  # Categorize genes based on thresholds
  mutate(status = case_when(
    p_value < 0.05 & LFC > 1  ~ "Upregulated",
    p_value < 0.05 & LFC < -1 ~ "Downregulated",
    TRUE ~ "Not significant"
  ))

# 4. Publication-Quality Plotting -----------------------------------------

# Identify top 10 genes for labeling
top_10_genes <- analysis_results %>% 
  filter(status != "Not significant") %>% 
  arrange(p_value) %>% 
  head(10)

# 4.1 Volcano Plot
volcano_plot <- ggplot(analysis_results, aes(x = LFC, y = -log10(p_value), color = status)) +
  geom_point(alpha = 0.4, size = 1.8) +
  scale_color_manual(values = c("Upregulated" = "#CC0000", 
                                "Downregulated" = "#006600", 
                                "Not significant" = "grey70")) +
  geom_text_repel(data = top_10_genes, aes(label = gene), color = "black", size = 3) +
  geom_vline(xintercept = c(-1, 1), linetype = "dashed", alpha = 0.5) +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed", alpha = 0.5) +
  theme_minimal() +
  labs(title = "Differential Gene Expression Analysis",
       subtitle = "Condition HS vs LS",
       x = "Log2 Fold Change", y = "-Log10(p-value)")

# 5. Exporting Results ----------------------------------------------------
dir.create("results", showWarnings = FALSE)
write_xlsx(analysis_results, "results/DGE_Analysis_Report.xlsx")
ggsave("results/volcano_plot.png", plot = volcano_plot, width = 8, height = 6, dpi = 300)

print("Analysis Complete. Results saved in 'results/' folder.")
