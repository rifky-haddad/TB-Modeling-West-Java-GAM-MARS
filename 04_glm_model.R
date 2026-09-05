# ============================================================
# 04_glm_model.R
# Generalized Linear Model for Tuberculosis Cases
# ============================================================

# -----------------------------
# 1. Load packages
# -----------------------------
library(readxl)
library(dplyr)
library(MASS)
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
# 4. Fit Poisson GLM
# -----------------------------
glm_poisson <- glm(
  Y ~ X1 + X2 + X3 + X4 + X5 +
    X6 + X7 + X8 + X9 + X10,
  data = data_model,
  family = poisson(link = "log")
)

cat("\n=== POISSON GLM ===\n")
print(summary(glm_poisson))

# -----------------------------
# 5. Check overdispersion
# -----------------------------
dispersion_ratio <- sum(
  residuals(glm_poisson, type = "pearson")^2
) / df.residual(glm_poisson)

cat("\n=== DISPERSION RATIO ===\n")
print(dispersion_ratio)

# -----------------------------
# 6. Fit Negative Binomial GLM
# -----------------------------
glm_negative_binomial <- MASS::glm.nb(
  Y ~ X1 + X2 + X3 + X4 + X5 +
    X6 + X7 + X8 + X9 + X10,
  data = data_model
)

cat("\n=== NEGATIVE BINOMIAL GLM ===\n")
print(summary(glm_negative_binomial))

# -----------------------------
# 7. Compare AIC
# -----------------------------
aic_comparison <- data.frame(
  Model = c(
    "Poisson GLM",
    "Negative Binomial GLM"
  ),
  AIC = c(
    AIC(glm_poisson),
    AIC(glm_negative_binomial)
  )
)

cat("\n=== AIC COMPARISON ===\n")
print(aic_comparison)

# -----------------------------
# 8. Select GLM model
# -----------------------------
if (AIC(glm_negative_binomial) < AIC(glm_poisson)) {
  glm_final <- glm_negative_binomial
  selected_model <- "Negative Binomial GLM"
} else {
  glm_final <- glm_poisson
  selected_model <- "Poisson GLM"
}

cat("\nSelected GLM model:", selected_model, "\n")

# -----------------------------
# 9. Generate predictions
# -----------------------------
prediction_glm <- predict(
  glm_final,
  newdata = data_model,
  type = "response"
)

# -----------------------------
# 10. Calculate in-sample metrics
# -----------------------------
rmse_glm <- rmse(
  data_model$Y,
  prediction_glm
)

mae_glm <- mae(
  data_model$Y,
  prediction_glm
)

mape_glm <- mean(
  abs(
    (data_model$Y - prediction_glm) /
      data_model$Y
  )
) * 100

r2_glm <- 1 -
  sum((data_model$Y - prediction_glm)^2) /
  sum((data_model$Y - mean(data_model$Y))^2)

glm_metrics <- data.frame(
  Model = selected_model,
  RMSE = rmse_glm,
  MAE = mae_glm,
  MAPE = mape_glm,
  R2 = r2_glm,
  Evaluation = "In-sample"
)

cat("\n=== GLM PERFORMANCE ===\n")
print(glm_metrics)

# -----------------------------
# 11. Save results
# -----------------------------
if (!dir.exists("outputs")) {
  dir.create("outputs")
}

write.csv(
  aic_comparison,
  "outputs/glm_aic_comparison.csv",
  row.names = FALSE
)

write.csv(
  glm_metrics,
  "outputs/glm_metrics.csv",
  row.names = FALSE
)

cat("\nGLM modeling completed successfully.\n")
