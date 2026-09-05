# Nonlinear Modeling of Tuberculosis Cases in West Java

## Overview

This project presents an undergraduate thesis on nonlinear statistical modeling of tuberculosis (TB) case counts across 27 regencies/cities in West Java, Indonesia.

The analysis uses 2024 secondary data and evaluates nonlinear relationships between TB case counts and 10 explanatory variables related to healthcare capacity, environmental conditions, housing, and socioeconomic factors.

Two nonlinear modeling approaches were compared:

- Generalized Additive Model (GAM) with Penalized Splines
- Multivariate Adaptive Regression Splines (MARS)

A Generalized Linear Model (GLM) was also included as a baseline model for performance comparison.

## Research Objective

The objective of this study is to identify important factors associated with tuberculosis case patterns and evaluate whether nonlinear models provide better performance than a conventional linear modeling approach.

## Methodology

The analysis workflow includes:

1. Data cleaning and exploratory data analysis
2. Descriptive statistics
3. Spatial visualization of TB case distribution across West Java
4. Assessment of nonlinear relationships using LOESS
5. Distribution and goodness-of-fit testing
6. GLM modeling
7. GAM Penalized Spline modeling
8. MARS modeling
9. Model comparison using RMSE, MAE, MAPE, and R²

## Key Findings

The GAM Penalized Spline model achieved the best overall performance among the evaluated models.

| Model | RMSE | MAE | MAPE | R² |
|---|---:|---:|---:|---:|
| GLM | 2340.12 | 1573.81 | 21.53% | 0.854 |
| GAM P-Spline | 705.24 | 525.43 | 8.71% | 0.987 |
| MARS | 759.24 | 634.19 | 11.48% | 0.985 |

The GAM P-Spline model identified four variables with significant nonlinear effects:

- Number of hospitals
- Number of primary health centers (Puskesmas)
- Access to proper sanitation
- Adequate housing

The MARS model identified similar factors and additionally captured an interaction effect involving poverty.

Overall, the results indicate that healthcare capacity and environmental and housing conditions are important factors associated with TB case patterns across West Java.

## Tools & Technologies

- R
- Generalized Additive Models (GAM)
- Penalized Splines
- MARS
- GLM
- Statistical Modeling
- Data Visualization
- Spatial Data Analysis

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
├── outputs/
│
└── portfolio/
    └── TB_Modeling_West_Java_GAM_MARS.pdf
