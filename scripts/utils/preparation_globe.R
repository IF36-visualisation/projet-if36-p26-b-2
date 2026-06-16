# === Fichier : preparation_globe.R ===
library(tidyverse)

print("Chargement des données... (cela peut prendre quelques secondes)")

# 1. Charger vos vraies données
vols <- read_csv("data/clean/clean_COVID_19_Flightfile_2019.csv", show_col_types = FALSE)

# Charger les aéroports en forçant 'continent' à rester du texte (évite le bug du "NA" = North America)
geo <- read_csv("data/clean/airports.csv", na = character(), show_col_types = FALSE) %>%
  mutate(continent = ifelse(continent == "", "NA", continent)) # Corrige les vides en North America

# Dictionnaire pour traduire les continents en français (pour correspondre à vos couleurs)
traduire_region <- function(cont) {
  case_when(
    cont == "EU" ~ "Europe",
    cont == "AS" ~ "Asie",
    cont == "NA" ~ "Amérique du Nord",
    cont == "SA" ~ "Amérique du Sud",
    cont == "AF" ~ "Afrique",
    cont == "OC" ~ "Océanie",
    TRUE ~ "Autres"
  )
}

print("Calcul des 150 plus grands aéroports mondiaux...")

# 2. Préparer les POINTS (Le top 150)
vrais_airports <- vols %>%
  filter(!is.na(origin)) %>%
  count(origin, name = "vols_2019") %>%
  slice_max(vols_2019, n = 150) %>%
  left_join(geo, by = c("origin" = "ident")) %>%
  mutate(
    region = traduire_region(continent),
    # Ici on fait une simulation pour la démo, 
    # mais vous pourrez plus tard faire le vrai calcul pour 2020/2021/2022 !
    vols_2020 = round(vols_2019 * 0.35), 
    vols_2021 = round(vols_2019 * 0.60),
    vols_2022 = round(vols_2019 * 0.95)
  ) %>%
  select(code = origin, name, lat = latitude_deg, lon = longitude_deg, region, 
         vols_2019, vols_2020, vols_2021, vols_2022) %>%
  drop_na(lat, lon)

print("Calcul des 200 plus grandes routes aériennes...")

# 3. Préparer les ARCS (Les 200 routes les plus fréquentées)
vraies_routes <- vols %>%
  filter(!is.na(origin) & !is.na(destination)) %>%
  # On ne garde que les routes entre nos 150 plus gros aéroports
  filter(origin %in% vrais_airports$code & destination %in% vrais_airports$code) %>%
  count(origin, destination, name = "trajets") %>%
  slice_max(trajets, n = 200) %>%
  mutate(
    from = match(origin, vrais_airports$code),
    to   = match(destination, vrais_airports$code)
  ) %>%
  select(from, to)

# 4. Sauvegarde
saveRDS(vrais_airports, "data/clean/globe_airports.rds")
saveRDS(vraies_routes, "data/clean/globe_routes.rds")

print("✅ Terminé ! Les fichiers globe_airports.rds et globe_routes.rds sont créés.")

