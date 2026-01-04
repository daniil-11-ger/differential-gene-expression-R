# Title: Differential Gene Expression (DGE) Analysis
# Description: Identifying DEGs between LS (Low Stress) and HS (High Stress) samples
# Author: Daniil Gerasimov

# 1. Setup and Data Loading -----------------------------------------------
library(tidyverse)
library(writexl)

# Load raw expression data
gen <- read.csv("data/gene_exp1.csv")

# Define sample groups
less <- c("LS1L1", "LS1L2", "LS1L3")
hight <- c("HS1L1", "HS1L2", "HS1L3")

# Ensure numeric format
gen[less] <- lapply(gen[less], as.numeric)
gen[hight] <- lapply(gen[hight], as.numeric)

# 2. Statistical Analysis (Paired t-test) ----------------------------------
results <- gen %>%
  rowwise() %>%
  mutate(
    # Calculate p-value via paired t-test
    p_value = t.test(c_across(all_of(less)), c_across(all_of(hight)), paired = TRUE)$p.value,
    
    # Calculate means and differences
    mean_LS = mean(c_across(all_of(less))),
    mean_HS = mean(c_across(all_of(hight))),
    diff = mean_HS - mean_LS,
    
    # Log Fold Change (LFC) for biological significance
    LFC = log2(mean_HS / mean_LS) 
  ) %>%
  ungroup()

# 3. Categorization -------------------------------------------------------
results <- results %>%
  mutate(status = case_when(
    p_value < 0.05 & diff > 0 ~ "Upregulated",
    p_value < 0.05 & diff < 0 ~ "Downregulated",
    TRUE ~ "Not significant"
  ))

# 4. Visualization --------------------------------------------------------

# 4.1 Volcano Plot (Standard for Bioinformatics)
volcano <- ggplot(results, aes(x = LFC, y = -log10(p_value))) +
  geom_point(aes(color = status), alpha = 0.6, size = 1.5) +
  scale_color_manual(values = c("Upregulated" = "#e62565", 
                                "Downregulated" = "#355e3b", 
                                "Not significant" = "grey80")) +
  geom_vline(xintercept = c(-1, 1), linetype = "dashed", color = "blue") +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed", color = "red") +
  labs(title = "Volcano Plot: Gene Expression Changes",
       subtitle = "HS vs LS conditions",
       x = "Log2 Fold Change", y = "-Log10 p-value") +
  theme_minimal()

# 4.2 Expression Boxplot
sig_genes <- results %>% filter(status != "Not significant")
boxplot <- ggplot(sig_genes, aes(x = status, y = log10(mean_HS + 1), fill = status)) +
  geom_boxplot(alpha = 0.7) +
  theme_classic() +
  labs(title = "Expression Distribution of DEGs", y = "Log10(Expression)")

# 5. Export ---------------------------------------------------------------
write_xlsx(results, "results/DGE_final_results.xlsx")
