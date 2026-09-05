# ============================================================
# 07_model_comparison.R
# Model Performance Comparison
# GLM vs GAM P-Spline vs MARS
# ============================================================

# -----------------------------
# 1. Load packages
# -----------------------------
library(readr)
library(dplyr)
library(ggplot2)

# -----------------------------
# 2. Create output directory
# -----------------------------
if (!dir.exists("outputs")) {
  dir.create("outputs")
}

# -----------------------------
# 3. Load model metrics
# -----------------------------
glm_metrics <- read.csv(
  "outputs/glm_metrics.csv"
)

gam_metrics <- read.csv(
  "outputs/gam_pspline_metrics.csv"
)

mars_metrics <- read.csv(
  "outputs/mars_metrics.csv"
)

# -----------------------------
# 4. Combine model results
# -----------------------------
model_comparison <- bind_rows(
  glm_metrics,
  gam_metrics,
  mars_metrics
)

cat("\n=== MODEL COMPARISON ===\n")
print(model_comparison)

# -----------------------------
# 5. Save comparison table
# -----------------------------
write.csv(
  model_comparison,
  "outputs/model_comparison.csv",
  row.names = FALSE
)

# -----------------------------
# 6. Reshape metrics
# -----------------------------
metrics_long <- model_comparison %>%
  select(
    Model,
    RMSE,
    MAE,
    MAPE
  ) %>%
  tidyr::pivot_longer(
    cols = c(RMSE, MAE, MAPE),
    names_to = "Metric",
    values_to = "Value"
  )

# -----------------------------
# 7. Plot error comparison
# -----------------------------
p_error <- ggplot(
  metrics_long,
  aes(
    x = Model,
    y = Value
  )
) +
  geom_col() +
  facet_wrap(
    ~ Metric,
    scales = "free_y"
  ) +
  labs(
    title = "Model Error Comparison",
    x = NULL,
    y = "Value"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(
      angle = 20,
      hjust = 1
    ),
    plot.title = element_text(
      face = "bold",
      hjust = 0.5
    )
  )

print(p_error)

ggsave(
  "outputs/model_error_comparison.png",
  p_error,
  width = 10,
  height = 6,
  dpi = 300
)

# -----------------------------
# 8. Plot R-squared comparison
# -----------------------------
p_r2 <- ggplot(
  model_comparison,
  aes(
    x = Model,
    y = R2
  )
) +
  geom_col() +
  labs(
    title = "Model R-Squared Comparison",
    x = NULL,
    y = "R²"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(
      angle = 20,
      hjust = 1
    ),
    plot.title = element_text(
      face = "bold",
      hjust = 0.5
    )
  )

print(p_r2)

ggsave(
  "outputs/model_r2_comparison.png",
  p_r2,
  width = 8,
  height = 6,
  dpi = 300
)

# -----------------------------
# 9. Identify best model
# -----------------------------
best_model <- model_comparison %>%
  arrange(RMSE) %>%
  slice(1)

cat("\n=== BEST MODEL ===\n")
print(best_model)

# -----------------------------
# 10. Save best model summary
# -----------------------------
write.csv(
  best_model,
  "outputs/best_model.csv",
  row.names = FALSE
)

cat("\nModel comparison completed successfully.\n")
cat("Generated outputs:\n")
cat("- outputs/model_comparison.csv\n")
cat("- outputs/model_error_comparison.png\n")
cat("- outputs/model_r2_comparison.png\n")
cat("- outputs/best_model.csv\n")
