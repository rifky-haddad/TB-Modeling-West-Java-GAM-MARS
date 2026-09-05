# ============================================================
# 06_mars_model.R
# Multivariate Adaptive Regression Splines (MARS)
# Tuberculosis Cases in West Java
# ============================================================

# -----------------------------
# 1. Load packages
# -----------------------------
library(readxl)
library(dplyr)
library(earth)
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
# 4. Define parameter grid
# -----------------------------
mars_grid <- expand.grid(
  nk = c(20, 30, 40),
  degree = c(1, 2),
  minspan = c(0, 1, 2, 3)
)

# -----------------------------
# 5. Grid search
# -----------------------------
mars_results <- data.frame()

mars_models <- list()

for (i in seq_len(nrow(mars_grid))) {

  nk_value <- mars_grid$nk[i]
  degree_value <- mars_grid$degree[i]
  minspan_value <- mars_grid$minspan[i]

  mars_model <- earth(
    Y ~ .,
    data = data_model,
    nk = nk_value,
    degree = degree_value,
    minspan = minspan_value,
    pmethod = "backward"
  )

  prediction <- predict(
    mars_model,
    newdata = data_model
  )

  rmse_value <- rmse(
    data_model$Y,
    prediction
  )

  mae_value <- mae(
    data_model$Y,
    prediction
  )

  r2_value <- 1 -
    sum((data_model$Y - prediction)^2) /
    sum((data_model$Y - mean(data_model$Y))^2)

  mars_results <- rbind(
    mars_results,
    data.frame(
      nk = nk_value,
      degree = degree_value,
      minspan = minspan_value,
      RMSE = rmse_value,
      MAE = mae_value,
      R2 = r2_value
    )
  )

  mars_models[[i]] <- mars_model
}

# -----------------------------
# 6. Select best model
# -----------------------------
best_index <- which.min(mars_results$RMSE)

best_parameters <- mars_results[best_index, ]

mars_final <- mars_models[[best_index]]

cat("\n=== BEST MARS PARAMETERS ===\n")
print(best_parameters)

# -----------------------------
# 7. Final model summary
# -----------------------------
cat("\n=== MARS MODEL SUMMARY ===\n")
print(summary(mars_final))

# -----------------------------
# 8. Variable importance
# -----------------------------
cat("\n=== VARIABLE IMPORTANCE ===\n")
print(evimp(mars_final))

# -----------------------------
# 9. Generate predictions
# -----------------------------
prediction_mars <- predict(
  mars_final,
  newdata = data_model
)

# -----------------------------
# 10. Calculate in-sample metrics
# -----------------------------
rmse_mars <- rmse(
  data_model$Y,
  prediction_mars
)

mae_mars <- mae(
  data_model$Y,
  prediction_mars
)

mape_mars <- mean(
  abs(
    (data_model$Y - prediction_mars) /
      data_model$Y
  )
) * 100

r2_mars <- 1 -
  sum((data_model$Y - prediction_mars)^2) /
  sum((data_model$Y - mean(data_model$Y))^2)

mars_metrics <- data.frame(
  Model = "MARS",
  RMSE = rmse_mars,
  MAE = mae_mars,
  MAPE = mape_mars,
  R2 = r2_mars,
  Evaluation = "In-sample"
)

cat("\n=== MARS PERFORMANCE ===\n")
print(mars_metrics)

# -----------------------------
# 11. Save results
# -----------------------------
if (!dir.exists("outputs")) {
  dir.create("outputs")
}

write.csv(
  mars_results,
  "outputs/mars_grid_search_results.csv",
  row.names = FALSE
)

write.csv(
  best_parameters,
  "outputs/mars_best_parameters.csv",
  row.names = FALSE
)

write.csv(
  mars_metrics,
  "outputs/mars_metrics.csv",
  row.names = FALSE
)

# -----------------------------
# 12. Save model
# -----------------------------
saveRDS(
  mars_final,
  "outputs/mars_model.rds"
)

cat("\nMARS modeling completed successfully.\n")
