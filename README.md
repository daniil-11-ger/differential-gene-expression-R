# differential-gene-expression-R
Gene expression profiling (LS vs HS samples) using Tidyverse. Includes paired t-tests, fold change calculation, and visualization via Volcano plots and Boxplots.

# Differential Gene Expression Analysis (DGE)

This project identifies genes that are significantly up- or down-regulated under different stress conditions (Low Stress vs. High Stress).

## Methodology
1. **Data Normalization:** Converting raw expression data to numeric formats and handling missing values.
2. **Statistical Sieve:** Applying **paired t-tests** to calculate significance (p-value).
3. **Biological Significance:** Calculating **Log Fold Change (LFC)** to determine the magnitude of change.
4. **Classification:** Genes are categorized into `Upregulated`, `Downregulated`, or `Not Significant` (p < 0.05).

<p align="center">
  <img src="Снимок экрана 2026-01-05 220651.png" width="800" alt="App Interface Main">
</p>
## 📊 Data Visualization & Analysis

In addition to sequence tools, this project includes modules for visualizing gene expression data:

<p align="center">
  <img src="volcano_plot.png" width="400" title="Volcano Plot - Differential Expression">
  <img src="expression_boxplot.png" width="400" title="Expression Boxplot">
</p>

<p align="center">
  <img src="Rplot.png" width="400" title="Statistical Analysis R Plot">
  <img src="94907507-94f8-4c81-8306-c1217ba2a8de.png" width="400" title="Analysis Chart">
</p>
### 🧬 Genetic Mapping
<p align="center">
  <img src="gen1.png" width="350">
  <img src="gen2.png" width="350">
</p>

<details>
<summary>📂 Нажми, чтобы увидеть все графики анализа</summary>

![Volcano](volcano_plot.png)
![Boxplot](expression_boxplot.png)
![Rplot](Rplot.png)

</details>
##  Visualizations
### Volcano Plot
The "Volcano" visualization allows for immediate identification of the most statistically significant genes with the largest fold changes.
![Volcano Plot](plots/volcano_plot.png)

### Expression Distribution
Comparison of log-transformed expression levels across identified gene categories.
![Boxplot](plots/expression_boxplot.png)



##  Tech Stack
* **R / Tidyverse** (dplyr, ggplot2, tidyr)
* **Statistical Methods:** Paired t-test, Log transformation.

Data Preprocessing: The pipeline includes a specialized step to handle raw CSV files with placeholder columns (double-comma delimiters), ensuring clean data mapping before statistical computation.
