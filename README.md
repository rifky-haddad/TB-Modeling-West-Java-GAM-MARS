# Nonlinear Modeling of Tuberculosis Cases in West Java

## Project Overview

This project presents an undergraduate thesis analysis on nonlinear statistical modeling of tuberculosis (TB) case counts across 27 regencies/cities in West Java, Indonesia.

The analysis uses 2024 secondary data and evaluates the relationship between TB case counts and 10 potential explanatory variables.

Two nonlinear modeling approaches were evaluated:

- Generalized Additive Model with P-Spline (GAM P-Spline)
- Multivariate Adaptive Regression Splines (MARS)

A Generalized Linear Model (GLM) was used as a baseline model.

---

## Research Objective

The objective of this study is to:

1. Explore the distribution and spatial variation of TB case counts across West Java.
2. Examine potential nonlinear relationships between TB cases and explanatory variables.
3. Develop GLM, GAM P-Spline, and MARS models.
4. Compare model performance using RMSE, MAE, MAPE, and R².
5. Identify variables associated with nonlinear patterns in TB case counts.

---

## Dataset

The dataset contains observations for 27 regencies/cities in West Java for 2024.

- Observation unit: Regencies/cities in West Java
- Response variable: TB case count (`Y`)
- Predictors: `X1`–`X10`
- Number of observations: 27

The dataset is included in:

`data/tb_west_java_2024.xlsx`

---
## Tools

- R
- RStudio
- `readxl` for data import
- `dplyr` for data manipulation
- `ggplot2` and `ggrepel` for visualization
- `sf` and `geodata` for spatial analysis
- `mgcv` for GAM P-Spline
- `earth` for MARS
- `Metrics` for model evaluation

---
## Methodology

### 1. Data Cleaning & Exploratory Analysis

The analysis begins with:

- Data selection and cleaning
- Missing-value handling
- Descriptive statistics
- Distribution analysis
- Exploration of potential nonlinear relationships using LOESS curves

Script:

`01_data_cleaning_eda.R`

---

### 2. Spatial Analysis

A spatial visualization was created to examine the geographic distribution of TB case counts across West Java.

Script:

`02_spatial_analysis.R`

Output:

`outputs/tb_distribution_west_java.png`

---

### 3. Distribution Testing

Several probability distributions were evaluated to identify an appropriate distributional assumption for the response variable.

The analysis considered:

- Normal
- Lognormal
- Gamma
- Poisson
- Negative Binomial

Goodness-of-fit procedures and AIC comparisons were used to evaluate the candidate distributions.

Script:

`03_distribution_testing.R`

---

### 4. Generalized Linear Model

Poisson and Negative Binomial GLMs were evaluated as baseline models.

Model selection was performed using AIC, followed by evaluation using:

- RMSE
- MAE
- MAPE
- R²

Script:

`04_glm_model.R`

---

### 5. GAM P-Spline

A Generalized Additive Model using P-Spline smooth terms was developed to capture nonlinear relationships between predictors and TB case counts.

The analysis evaluated basis dimensions (`k`) from 4 to 10, with the final model using `k = 5`.

The model used a Gamma distribution with a log link and was estimated using REML.

Script:

`05_gam_pspline.R`

---

### 6. MARS

Multivariate Adaptive Regression Splines (MARS) was applied as an alternative nonlinear modeling approach.

A grid search evaluated combinations of:

- `nk`: 20, 30, 40
- `degree`: 1, 2
- `minspan`: 0, 1, 2, 3

The models were fitted using backward pruning, with `endspan` set equal to `minspan` and a penalty of 2. The final model was selected based on the lowest Generalized Cross-Validation (GCV) score.

Script:

`06_mars_model.R`

---

### 7. Model Comparison

The final GLM, GAM P-Spline, and MARS models were compared using:

- RMSE
- MAE
- MAPE
- R²

Script:

`07_model_comparison.R`

---

## Model Performance

The final analysis produced the following in-sample performance:

| Model | RMSE | MAE | MAPE | R² |
|---|---:|---:|---:|---:|
| Negative Binomial GLM | 2340.12 | 1573.81 | 21.53% | 0.854 |
| GAM P-Spline | 705.24 | 525.43 | 8.71% | 0.987 |
| MARS | 759.24 | 634.19 | 11.48% | 0.985 |

GAM P-Spline achieved the best overall in-sample performance based on the lowest RMSE, MAE, and MAPE, as well as the highest R².

---

## Key Findings

The GAM P-Spline analysis identified four predictors with significant nonlinear effects:

- Number of hospitals
- Number of primary health centers (puskesmas)
- Access to proper sanitation
- Adequate housing

The MARS model identified a similar set of important variables and additionally captured an interaction involving poverty.

Overall, the findings suggest that TB case patterns are associated with a combination of healthcare capacity and environmental or housing-related conditions.

---
## Key Outputs

The repository includes reproducible outputs from the analysis, including:

- TB case distribution across West Java
- Nonlinear relationship diagnostics using LOESS
- GAM P-Spline smooth-effect plots
- Model performance comparison
- Distribution goodness-of-fit results

All generated outputs are stored in:

`outputs/`

---
## Repository Structure

```text
TB-Modeling-West-Java-GAM-MARS/
│
├── README.md
├── 01_data_cleaning_eda.R
├── 02_spatial_analysis.R
├── 03_distribution_testing.R
├── 04_glm_model.R
├── 05_gam_pspline.R
├── 06_mars_model.R
├── 07_model_comparison.R
│
├── data/
│   └── tb_west_java_2024.xlsx
│
└── outputs/
    ├── tb_case_distribution.png
    ├── nonlinear_relationships.png
    ├── tb_distribution_west_java.png
    ├── distribution_gof_results.csv
    ├── glm_aic_comparison.csv
    ├── glm_metrics.csv
    ├── gam_pspline_effects.png
    ├── gam_pspline_metrics.csv
    ├── gam_significant_terms.csv
    ├── mars_grid_search_results.csv
    ├── mars_best_parameters.csv
    ├── mars_metrics.csv
    ├── model_comparison.csv
    ├── model_comparison_errors.png
    └── model_comparison_r2.png

---
## Reproducibility

The analysis is organized into sequential R scripts:

1. `01_data_cleaning_eda.R`
2. `02_spatial_analysis.R`
3. `03_distribution_testing.R`
4. `04_glm_model.R`
5. `05_gam_pspline.R`
6. `06_mars_model.R`
7. `07_model_comparison.R`

Run the scripts sequentially from the project root directory.

The dataset is provided in the `data/` directory and generated analysis outputs are saved to `outputs/`.
