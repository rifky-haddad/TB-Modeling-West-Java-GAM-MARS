# ============================================================
# 03_distribution_testing.R
# Distribution Testing for Tuberculosis Case Counts
# ============================================================

# -----------------------------
# 1. Load packages
# -----------------------------
library(readxl)
library(dplyr)
library(gamlss)
library(fitdistrplus)
library(vcd)
library(goftest)

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
# 3. Response variable
# -----------------------------
y <- data_clean$Y

# Check for invalid values
if (any(y < 0)) {
  stop("Negative TB case counts detected.")
}

# -----------------------------
# 4. Compare distribution AIC
# -----------------------------
model_normal <- gamlss(
  Y ~ 1,
  data = data_clean,
  family = NO,
  trace = FALSE
)

model_lognormal <- gamlss(
  Y ~ 1,
  data = data_clean,
  family = LOGNO,
  trace = FALSE
)

model_gamma <- gamlss(
  Y ~ 1,
  data = data_clean,
  family = GA,
  trace = FALSE
)

model_poisson <- gamlss(
  Y ~ 1,
  data = data_clean,
  family = PO,
  trace = FALSE
)

model_negative_binomial <- gamlss(
  Y ~ 1,
  data = data_clean,
  family = NBI,
  trace = FALSE
)

aic_distribution <- GAIC(
  model_normal,
  model_lognormal,
  model_gamma,
  model_poisson,
  model_negative_binomial,
  k = 2
)

cat("\n=== DISTRIBUTION AIC COMPARISON ===\n")
print(aic_distribution)

# -----------------------------
# 5. Continuous distributions
# -----------------------------

# Lognormal
fit_lognormal <- fitdist(
  y,
  "lnorm",
  method = "mle"
)

ks_lognormal <- ks.test(
  y,
  "plnorm",
  meanlog = fit_lognormal$estimate["meanlog"],
  sdlog = fit_lognormal$estimate["sdlog"]
)

ad_lognormal <- goftest::ad.test(
  y,
  "plnorm",
  meanlog = fit_lognormal$estimate["meanlog"],
  sdlog = fit_lognormal$estimate["sdlog"]
)

# Gamma
fit_gamma <- tryCatch(
  {
    fitdist(
      y,
      "gamma",
      method = "mle"
    )
  },
  error = function(e) {
    fitdist(
      y,
      "gamma",
      method = "mme"
    )
  }
)

ks_gamma <- ks.test(
  y,
  "pgamma",
  shape = fit_gamma$estimate["shape"],
  rate = fit_gamma$estimate["rate"]
)

ad_gamma <- goftest::ad.test(
  y,
  "pgamma",
  shape = fit_gamma$estimate["shape"],
  rate = fit_gamma$estimate["rate"]
)

# -----------------------------
# 6. Discrete distributions
# -----------------------------

# Poisson
fit_poisson <- vcd::goodfit(
  y,
  type = "poisson"
)

summary_poisson <- summary(
  fit_poisson
)

# Negative Binomial
fit_negative_binomial <- vcd::goodfit(
  y,
  type = "nbinomial"
)

summary_negative_binomial <- summary(
  fit_negative_binomial
)

# -----------------------------
# 7. Extract GOF statistics
# -----------------------------
stat_poisson <- summary_poisson[1, 1]
pval_poisson <- summary_poisson[1, 3]

stat_negative_binomial <- summary_negative_binomial[1, 1]
pval_negative_binomial <- summary_negative_binomial[1, 3]

# -----------------------------
# 8. Create GOF summary table
# -----------------------------
gof_results <- data.frame(
  Distribution = c(
    "Lognormal",
    "Gamma",
    "Poisson",
    "Negative Binomial"
  ),

  Data_Type = c(
    "Continuous",
    "Continuous",
    "Discrete",
    "Discrete"
  ),

  Test = c(
    "Kolmogorov-Smirnov",
    "Kolmogorov-Smirnov",
    "Chi-Square GOF",
    "Chi-Square GOF"
  ),

  Test_Statistic = c(
    round(ks_lognormal$statistic, 4),
    round(ks_gamma$statistic, 4),
    round(stat_poisson, 4),
    round(stat_negative_binomial, 4)
  ),

  P_Value = c(
    ks_lognormal$p.value,
    ks_gamma$p.value,
    pval_poisson,
    pval_negative_binomial
  )
)

cat("\n=== GOODNESS-OF-FIT RESULTS ===\n")
print(gof_results)

# -----------------------------
# 9. Print parameter estimates
# -----------------------------
cat("\n=== LOGNORMAL PARAMETERS ===\n")
print(fit_lognormal$estimate)

cat("\n=== GAMMA PARAMETERS ===\n")
print(fit_gamma$estimate)

# -----------------------------
# 10. Save results
# -----------------------------
if (!dir.exists("outputs")) {
  dir.create("outputs")
}

write.csv(
  gof_results,
  "outputs/distribution_gof_results.csv",
  row.names = FALSE
)

cat("\nDistribution testing completed successfully.\n")
