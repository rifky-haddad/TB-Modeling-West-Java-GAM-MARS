# ============================================================
# 02_spatial_analysis.R
# Spatial Analysis of Tuberculosis Cases in West Java
# ============================================================

# -----------------------------
# 1. Load packages
# -----------------------------
library(readxl)
library(dplyr)
library(sf)
library(ggplot2)
library(ggrepel)

# -----------------------------
# 2. Create output directory
# -----------------------------
if (!dir.exists("outputs")) {
  dir.create("outputs")
}

# -----------------------------
# 3. Load dataset
# -----------------------------
data_raw <- read_excel("data/tb_west_java_2024.xlsx")

data <- data_raw %>%
  select(
    Kabupaten_Kota,
    Y,
    X1:X10
  ) %>%
  drop_na()

# -----------------------------
# 4. Load West Java boundary
# -----------------------------
# IMPORTANT:
# The administrative boundary file is not included
# in this repository.
#
# Replace this section with the spatial data source
# used in the original thesis if needed.

# Example:
# jawa_barat <- st_read("path/to/west_java_boundary.shp")

# -----------------------------
# 5. Spatial visualization
# -----------------------------
# The following section should be completed using
# the West Java administrative boundary data.

# Example structure:
#
# peta_tb <- ggplot() +
#   geom_sf(
#     data = jawa_barat,
#     aes(fill = Y),
#     color = "white"
#   ) +
#   scale_fill_viridis_c(
#     name = "TB Cases"
#   ) +
#   labs(
#     title = "Tuberculosis Cases Across West Java",
#     subtitle = "2024"
#   ) +
#   theme_minimal()

# ggsave(
#   "outputs/tb_distribution_west_java.png",
#   peta_tb,
#   width = 10,
#   height = 8,
#   dpi = 300
# )

cat("\nSpatial analysis script initialized successfully.\n")
