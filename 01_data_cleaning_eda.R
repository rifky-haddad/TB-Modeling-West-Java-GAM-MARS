# ============================================================
# 01_data_cleaning_eda.R
# Nonlinear Modeling of Tuberculosis Cases in West Java
# ============================================================

# -----------------------------
# 1. Load packages
# -----------------------------
library(readxl)
library(dplyr)
library(ggplot2)
library(patchwork)

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

# -----------------------------
# 4. Data cleaning
# -----------------------------
data <- data_raw %>%
  select(
    Kabupaten_Kota,
    Y,
    X1:X10
  ) %>%
  drop_na()

# Ensure TB case counts are numeric integers
data$Y <- as.numeric(data$Y)

# Remove invalid negative case counts
data <- data %>%
  filter(Y >= 0)

# -----------------------------
# 5. Dataset overview
# -----------------------------
cat("Number of observations:", nrow(data), "\n")
cat("Number of variables:", ncol(data), "\n\n")

cat("Missing values:\n")
print(colSums(is.na(data)))

# -----------------------------
# 6. Descriptive statistics
# -----------------------------
descriptive_stats <- data %>%
  summarise(
    Mean = mean(Y),
    Median = median(Y),
    SD = sd(Y),
    Minimum = min(Y),
    Maximum = max(Y)
  )

print(descriptive_stats)

# -----------------------------
# 7. Distribution of TB cases
# -----------------------------
p_distribution <- ggplot(data, aes(x = Y)) +
  geom_histogram(
    bins = 15,
    color = "black"
  ) +
  labs(
    title = "Distribution of Tuberculosis Cases",
    x = "TB Case Counts",
    y = "Frequency"
  ) +
  theme_minimal()

ggsave(
  "outputs/tb_case_distribution.png",
  p_distribution,
  width = 8,
  height = 5,
  dpi = 300
)

# -----------------------------
# 8. Explore nonlinear relationships
# -----------------------------
plot_list <- lapply(
  paste0("X", 1:10),
  function(var) {

    ggplot(data, aes_string(x = var, y = "Y")) +
      geom_point() +
      geom_smooth(
        method = "loess",
        se = FALSE
      ) +
      geom_smooth(
        method = "lm",
        se = FALSE,
        linetype = "dashed"
      ) +
      labs(
        title = paste("TB Cases vs", var),
        x = var,
        y = "TB Case Counts"
      ) +
      theme_minimal()
  }
)

p_nonlinear <- wrap_plots(
  plot_list,
  ncol = 2
)

ggsave(
  "outputs/nonlinear_relationships.png",
  p_nonlinear,
  width = 12,
  height = 20,
  dpi = 300
)

# -----------------------------
# 9. Completion message
# -----------------------------
cat("\nEDA completed successfully.\n")
cat("Generated outputs:\n")
cat("- outputs/tb_case_distribution.png\n")
cat("- outputs/nonlinear_relationships.png\n")
