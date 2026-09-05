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
# 4. Fit GAM P-Spline
# -----------------------------
gam_pspline <- gam(
  Y ~
    s(X1, bs = "ps") +
    s(X2, bs = "ps") +
    s(X3, bs = "ps") +
    s(X4, bs = "ps") +
    s(X5, bs = "ps") +
    s(X6, bs = "ps") +
    s(X7, bs = "ps") +
    s(X8, bs = "ps") +
    s(X9, bs = "ps") +
    s(X10, bs = "ps"),
  data = data_model,
  family = Gamma(link = "log"),
  method = "REML"
)

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
