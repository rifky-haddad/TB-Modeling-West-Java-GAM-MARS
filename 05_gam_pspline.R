# ============================================================
# 05_gam_pspline.R
# Generalized Additive Model with P-Spline
# Tuberculosis Cases in West Java
# ============================================================

# -----------------------------
# 1. Load packages
# -----------------------------
library(readxl)
library(dplyr)
library(mgcv)
library(Metrics)

# -----------------------------
# 2. Load dataset
# -----------------------------
data_raw <- read_excel("data/tb_west_java_2024.xlsx")

data_clean <- data_raw %>%
  select(
    `Kabupaten/Kota`,
    Y,
    X1:X10
  ) %>%
  na.omit() %>%
  rename(
    Kabupaten_Kota = `Kabupaten/Kota`
  ) %>%
  mutate(
    Y = as.integer(Y)
  )

# -----------------------------
# 3. Prepare model data
# -----------------------------
data_model <- data_clean %>%
  select(
    Y,
    X1:X10
  )

# -----------------------------
# 4. Select basis dimension (k)
# -----------------------------
k_values <- 4:10

gam_models <- list()
gam_aic <- numeric(length(k_values))

for (i in seq_along(k_values)) {

  k_value <- k_values[i]

  gam_models[[i]] <- gam(
    Y ~
      s(X1, bs = "ps", k = k_value) +
      s(X2, bs = "ps", k = k_value) +
      s(X3, bs = "ps", k = k_value) +
      s(X4, bs = "ps", k = k_value) +
      s(X5, bs = "ps", k = k_value) +
      s(X6, bs = "ps", k = k_value) +
      s(X7, bs = "ps", k = k_value) +
      s(X8, bs = "ps", k = k_value) +
      s(X9, bs = "ps", k = k_value) +
      s(X10, bs = "ps", k = k_value),
    data = data_model,
    family = Gamma(link = "log"),
    method = "REML"
  )

  gam_aic[i] <- AIC(gam_models[[i]])
}

k_comparison <- data.frame(
  k = k_values,
  AIC = gam_aic
)

cat("\n=== K SELECTION ===\n")
print(k_comparison)

# Based on the thesis analysis, k = 5 was selected
selected_k <- 5

gam_pspline <- gam_models[[which(k_values == selected_k)]]

cat("\nSelected k:", selected_k, "\n")

# -----------------------------
# 5. Model summary
# -----------------------------
cat("\n=== GAM P-SPLINE SUMMARY ===\n")
print(summary(gam_pspline))

# -----------------------------
# 6. Model diagnostics
# -----------------------------
cat("\n=== GAM DIAGNOSTICS ===\n")
gam.check(gam_pspline)

# -----------------------------
# 7. Generate predictions
# -----------------------------
prediction_gam <- predict(
  gam_pspline,
  newdata = data_model,
  type = "response"
)

# -----------------------------
# 8. Calculate in-sample metrics
# -----------------------------
rmse_gam <- rmse(
  data_model$Y,
  prediction_gam
)

mae_gam <- mae(
  data_model$Y,
  prediction_gam
)

mape_gam <- mean(
  abs(
    (data_model$Y - prediction_gam) /
      data_model$Y
  )
) * 100

r2_gam <- 1 -
  sum((data_model$Y - prediction_gam)^2) /
  sum((data_model$Y - mean(data_model$Y))^2)

gam_metrics <- data.frame(
  Model = "GAM P-Spline",
  RMSE = rmse_gam,
  MAE = mae_gam,
  MAPE = mape_gam,
  R2 = r2_gam,
  Evaluation = "In-sample"
)

cat("\n=== GAM PERFORMANCE ===\n")
print(gam_metrics)

# -----------------------------
# 9. Identify significant terms
# -----------------------------
gam_summary <- summary(gam_pspline)

significant_terms <- data.frame(
  Term = rownames(gam_summary$s.table),
  P_Value = gam_summary$s.table[, "p-value"]
) %>%
  filter(P_Value < 0.05)

cat("\n=== SIGNIFICANT NONLINEAR TERMS ===\n")
print(significant_terms)

# -----------------------------
# 10. Save results
# -----------------------------
if (!dir.exists("outputs")) {
  dir.create("outputs")
}

write.csv(
  gam_metrics,
  "outputs/gam_pspline_metrics.csv",
  row.names = FALSE
)

write.csv(
  significant_terms,
  "outputs/gam_significant_terms.csv",
  row.names = FALSE
)

# -----------------------------
# 11. Save model
# -----------------------------
saveRDS(
  gam_pspline,
  "outputs/gam_pspline_model.rds"
)

cat("\nGAM P-Spline modeling completed successfully.\n")

# -----------------------------
# 12. Plot nonlinear effects
# -----------------------------
png(
  "outputs/gam_pspline_effects.png",
  width = 1600,
  height = 1200,
  res = 180
)

par(
  mfrow = c(3, 4),
  mar = c(4, 4, 3, 1)
)

plot(
  gam_pspline,
  shade = TRUE,
  seWithMean = TRUE,
  main = "GAM P-Spline Effects"
)

dev.off()

cat("\nGenerated output:\n")
cat("- outputs/gam_pspline_effects.png\n")
