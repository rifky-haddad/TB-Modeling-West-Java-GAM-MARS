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
library(geodata)
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
# 4. Download West Java
#    administrative boundaries
# -----------------------------
gadm_idn <- geodata::gadm(
  country = "IDN",
  level = 2,
  path = "data",
  version = "latest"
)

gadm_sf <- sf::st_as_sf(gadm_idn)

# -----------------------------
# 5. Filter West Java
# -----------------------------
west_java <- gadm_sf %>%
  filter(NAME_1 == "Jawa Barat") %>%
  filter(NAME_2 != "Waduk Cirata")

# -----------------------------
# 6. Harmonize region names
# -----------------------------
west_java <- west_java %>%
  mutate(
    Kabupaten_Kota = case_when(
      NAME_2 == "Bandung"          ~ "Bandung",
      NAME_2 == "Bandung Barat"    ~ "Bandung Barat",
      NAME_2 == "Banjar"           ~ "Kota Banjar",
      NAME_2 == "Bekasi"           ~ "Bekasi",
      NAME_2 == "Bogor"            ~ "Bogor",
      NAME_2 == "Ciamis"           ~ "Ciamis",
      NAME_2 == "Cianjur"           ~ "Cianjur",
      NAME_2 == "Cimahi"           ~ "Kota Cimahi",
      NAME_2 == "Cirebon"          ~ "Cirebon",
      NAME_2 == "Depok"            ~ "Depok",
      NAME_2 == "Garut"             ~ "Garut",
      NAME_2 == "Indramayu"        ~ "Indramayu",
      NAME_2 == "Karawang"         ~ "Karawang",
      NAME_2 == "Kota Bandung"     ~ "Kota Bandung",
      NAME_2 == "Kota Bekasi"      ~ "Kota Bekasi",
      NAME_2 == "Kota Bogor"       ~ "Kota Bogor",
      NAME_2 == "Kota Cirebon"     ~ "Kota Cirebon",
      NAME_2 == "Kota Sukabumi"    ~ "Kota Sukabumi",
      NAME_2 == "Kota Tasikmalaya" ~ "Kota Tasikmalaya",
      NAME_2 == "Kuningan"         ~ "Kuningan",
      NAME_2 == "Majalengka"       ~ "Majalengka",
      NAME_2 == "Purwakarta"       ~ "Purwakarta",
      NAME_2 == "Subang"           ~ "Subang",
      NAME_2 == "Sukabumi"         ~ "Sukabumi",
      NAME_2 == "Sumedang"         ~ "Sumedang",
      NAME_2 == "Tasikmalaya"      ~ "Tasikmalaya",
      TRUE                         ~ NAME_2
    )
  )

# -----------------------------
# 7. Harmonize dataset region names
# -----------------------------
data_clean <- data_clean %>%
  mutate(
    Kabupaten_Kota = case_when(
      Kabupaten_Kota == "KABUPATEN BOGOR"         ~ "Bogor",
      Kabupaten_Kota == "KABUPATEN SUKABUMI"      ~ "Sukabumi",
      Kabupaten_Kota == "KABUPATEN CIANJUR"       ~ "Cianjur",
      Kabupaten_Kota == "KABUPATEN BANDUNG"       ~ "Bandung",
      Kabupaten_Kota == "KABUPATEN GARUT"         ~ "Garut",
      Kabupaten_Kota == "KABUPATEN TASIKMALAYA"   ~ "Tasikmalaya",
      Kabupaten_Kota == "KABUPATEN CIAMIS"        ~ "Ciamis",
      Kabupaten_Kota == "KABUPATEN KUNINGAN"      ~ "Kuningan",
      Kabupaten_Kota == "KABUPATEN CIREBON"       ~ "Cirebon",
      Kabupaten_Kota == "KABUPATEN MAJALENGKA"    ~ "Majalengka",
      Kabupaten_Kota == "KABUPATEN SUMEDANG"      ~ "Sumedang",
      Kabupaten_Kota == "KABUPATEN INDRAMAYU"     ~ "Indramayu",
      Kabupaten_Kota == "KABUPATEN SUBANG"        ~ "Subang",
      Kabupaten_Kota == "KABUPATEN PURWAKARTA"    ~ "Purwakarta",
      Kabupaten_Kota == "KABUPATEN KARAWANG"      ~ "Karawang",
      Kabupaten_Kota == "KABUPATEN BEKASI"        ~ "Bekasi",
      Kabupaten_Kota == "KABUPATEN BANDUNG BARAT" ~ "Bandung Barat",
      Kabupaten_Kota == "KABUPATEN PANGANDARAN"   ~ "Pangandaran",
      Kabupaten_Kota == "KOTA BOGOR"              ~ "Kota Bogor",
      Kabupaten_Kota == "KOTA SUKABUMI"           ~ "Kota Sukabumi",
      Kabupaten_Kota == "KOTA BANDUNG"            ~ "Kota Bandung",
      Kabupaten_Kota == "KOTA CIREBON"            ~ "Kota Cirebon",
      Kabupaten_Kota == "KOTA BEKASI"             ~ "Kota Bekasi",
      Kabupaten_Kota == "KOTA DEPOK"              ~ "Depok",
      Kabupaten_Kota == "KOTA CIMAHI"             ~ "Kota Cimahi",
      Kabupaten_Kota == "KOTA TASIKMALAYA"        ~ "Kota Tasikmalaya",
      Kabupaten_Kota == "KOTA BANJAR"             ~ "Kota Banjar",
      TRUE                                        ~ Kabupaten_Kota
    )
  )

# -----------------------------
# 8. Join spatial and TB data
# -----------------------------
map_data <- west_java %>%
  left_join(
    data_clean %>%
      select(Kabupaten_Kota, Y),
    by = "Kabupaten_Kota"
  ) %>%
  filter(!is.na(Y))

# -----------------------------
# 9. Create map labels
# -----------------------------
label_data <- map_data %>%
  mutate(
    geometry_label = st_centroid(geometry)
  )

coordinates <- st_coordinates(label_data$geometry_label)

label_data <- label_data %>%
  mutate(
    X_lon = coordinates[, 1],
    Y_lat = coordinates[, 2]
  )

# -----------------------------
# 10. Plot TB distribution
# -----------------------------
p_map <- ggplot(map_data) +
  geom_sf(
    aes(fill = Y),
    color = "gray50",
    linewidth = 0.3
  ) +
  geom_text_repel(
    data = label_data,
    aes(
      x = X_lon,
      y = Y_lat,
      label = Kabupaten_Kota
    ),
    size = 2.2,
    fontface = "bold",
    box.padding = 0.5,
    point.padding = 0.2,
    max.overlaps = Inf
  ) +
  scale_fill_fermenter(
    palette = "YlOrRd",
    direction = 1,
    name = "TB Cases"
  ) +
  labs(
    title = "Distribution of Tuberculosis Cases in West Java",
    subtitle = "2024"
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    plot.title = element_text(
      face = "bold",
      hjust = 0.5
    ),
    plot.subtitle = element_text(
      hjust = 0.5
    )
  )

print(p_map)

# -----------------------------
# 11. Save map
# -----------------------------
ggsave(
  "outputs/tb_distribution_west_java.png",
  p_map,
  width = 10,
  height = 8,
  dpi = 300
)

cat("\nSpatial analysis completed successfully.\n")
cat("Generated output:\n")
cat("- outputs/tb_distribution_west_java.png\n")
