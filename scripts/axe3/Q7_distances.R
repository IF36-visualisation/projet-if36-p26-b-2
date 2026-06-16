library(tidyverse)
library(geosphere)
library(ggridges)

# ─────────────────────────────────────────────────────────────
# Q7 : Peut-on catégoriser les vols en court, moyen et
#      long-courrier, et comment se répartit le trafic ?
# ─────────────────────────────────────────────────────────────

# Chargement des données
flights  <- read_csv("data/clean/clean_COVID_19_Flightfile_2019.csv")
airports <- read_csv("data/clean/airports.csv")

# ── Préparation : distance orthodromique de chaque vol ─────────

# Coordonnées des aéroports (une ligne par code OACI)
airports_coord <- airports %>%
  filter(
    !is.na(icao_code),
    !is.na(latitude_deg),
    !is.na(longitude_deg)
  ) %>%
  distinct(icao_code, .keep_all = TRUE) %>%
  select(icao_code, latitude_deg, longitude_deg)

# On ne garde que les vols avec origine et destination renseignées
# et différentes, puis on joint les coordonnées des deux aéroports
flights_dist <- flights %>%
  filter(
    !is.na(origin), !is.na(destination),
    origin != destination
  ) %>%
  left_join(airports_coord, by = c("origin" = "icao_code")) %>%
  rename(lat_orig = latitude_deg, lon_orig = longitude_deg) %>%
  left_join(airports_coord, by = c("destination" = "icao_code")) %>%
  rename(lat_dest = latitude_deg, lon_dest = longitude_deg) %>%
  filter(
    !is.na(lat_orig), !is.na(lon_orig),
    !is.na(lat_dest), !is.na(lon_dest)
  ) %>%
  mutate(
    # Distance orthodromique (formule de Haversine), en km
    distance_km = distHaversine(
      cbind(lon_orig, lat_orig),
      cbind(lon_dest, lat_dest)
    ) / 1000
  ) %>%
  # On retire les distances quasi nulles (aéroports distincts mais
  # co-localisés : héliports, terrains voisins...) ainsi que les
  # distances physiquement impossibles (> 15 500 km, soit plus que le
  # plus long vol commercial du monde, Singapour-New York ~15 350 km,
  # cf. https://en.wikipedia.org/wiki/Longest_flights :
  # erreurs de codes aéroports)
  filter(distance_km >= 10, distance_km <= 15500)

cat("Vols exploitables pour la distance :",
    nrow(flights_dist), "/", nrow(flights),
    paste0("(", round(nrow(flights_dist) / nrow(flights) * 100, 1), "%)\n"))
cat("Distance médiane :", round(median(flights_dist$distance_km)), "km\n")

# ── Catégorisation court / moyen / long-courrier ───────────────
# Seuils usuels dans l'industrie aérienne :
# court < 1 500 km, moyen 1 500 - 4 000 km, long > 4 000 km
# (cf. https://en.wikipedia.org/wiki/Flight_length)

flights_dist <- flights_dist %>%
  mutate(
    categorie = case_when(
      distance_km < 1500 ~ "Court-courrier (< 1 500 km)",
      distance_km < 4000 ~ "Moyen-courrier (1 500 – 4 000 km)",
      TRUE               ~ "Long-courrier (> 4 000 km)"
    ),
    categorie = factor(categorie, levels = c(
      "Court-courrier (< 1 500 km)",
      "Moyen-courrier (1 500 – 4 000 km)",
      "Long-courrier (> 4 000 km)"
    ))
  )

# Répartition du trafic par catégorie
repartition <- flights_dist %>%
  count(categorie) %>%
  mutate(pct = n / sum(n) * 100)

print(repartition)

# ── Graphique 1 : Distribution des distances de vol ────────────

ggplot(flights_dist, aes(x = distance_km, fill = categorie)) +
  geom_histogram(binwidth = 250, boundary = 0, color = "white",
                 linewidth = 0.1) +
  geom_vline(xintercept = c(1500, 4000),
             linetype = "dashed", color = "grey30") +
  scale_x_continuous(labels = scales::comma) +
  coord_cartesian(xlim = c(0, 15500)) +
  scale_y_continuous(labels = scales::comma) +
  scale_fill_manual(values = c("#9ecae1", "#4292c6", "#08519c")) +
  labs(
    title = "Distribution des distances de vol (2019)",
    subtitle = "Distance orthodromique entre aéroports d'origine et de destination",
    x = "Distance (km)",
    y = "Nombre de vols",
    fill = "Catégorie",
    caption = "Source : OpenSky Network COVID-19 Flight Dataset + OurAirports"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    legend.position = "bottom"
  )

ggsave("q7_distribution_distances.png", width = 9, height = 5.5, dpi = 150)

# ── Graphique 2 : Distance selon le type d'aéronef ─────────────
# Vérification de cohérence : les appareils régionaux doivent voler
# court, les gros-porteurs long

types_selection <- c(
  "DH8D", "AT76", "CRJ9", "E75L",          # régionaux
  "A319", "A320", "B738", "A321",          # monocouloirs
  "B763", "A332", "A333", "B772",          # bicouloirs
  "B789", "A359", "B77W", "A388"           # long-courriers
)

flights_types <- flights_dist %>%
  filter(typecode %in% types_selection) %>%
  mutate(typecode = factor(typecode, levels = types_selection))

# Médianes par type : contrôle de cohérence imprimé
flights_types %>%
  group_by(typecode) %>%
  summarise(mediane_km = round(median(distance_km)), .groups = "drop") %>%
  print(n = 16)

ggplot(flights_types,
       aes(x = distance_km, y = typecode, fill = after_stat(x))) +
  geom_density_ridges_gradient(scale = 1.8, rel_min_height = 0.01,
                               color = "grey30", linewidth = 0.3) +
  scale_x_continuous(labels = scales::comma) +
  # zoom sans suppression de données (les densités utilisent tout)
  coord_cartesian(xlim = c(0, 14000)) +
  scale_fill_viridis_c(option = "mako", direction = -1, guide = "none") +
  labs(
    title = "Distribution des distances selon le type d'aéronef (2019)",
    subtitle = "Des turbopropulseurs régionaux (bas) aux gros-porteurs longs-courriers (haut)",
    x = "Distance de vol (km)",
    y = "Type d'aéronef (code OACI)",
    caption = "Source : OpenSky Network COVID-19 Flight Dataset + OurAirports"
  ) +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"))

ggsave("q7_distances_par_type.png", width = 9, height = 7, dpi = 150)

# ── Graphique 3 : Parts des vols, des km parcourus et du CO2 ───
# Estimation volontairement simple : émissions ~ distance x facteur
# par catégorie, avec des facteurs décroissants avec la distance pour
# refléter le poids des phases de décollage sur les vols courts.
# HYPOTHÈSES SIMPLIFICATRICES (discutées dans le rapport) :
#  - facteurs indicatifs choisis par nous, du même ordre de grandeur
#    que les facteurs publiés par passager-km (DEFRA 2023, ~0,15 à
#    0,25 kg CO2e/pax-km selon la bande de distance :
#    https://www.gov.uk/government/publications/greenhouse-gas-reporting-conversion-factors-2023)
#    mais SANS reprendre leurs bandes exactes ni leur classement ;
#  - pas de pondération par la capacité des appareils : un gros-porteur
#    long-courrier emporte 3 à 5 fois plus de passagers qu'un appareil
#    régional, la part du long-courrier est donc sous-estimée.
# Les parts obtenues sont des ordres de grandeur, pas un bilan carbone.
facteurs_co2 <- c(
  "Court-courrier (< 1 500 km)"       = 0.25,
  "Moyen-courrier (1 500 – 4 000 km)" = 0.19,
  "Long-courrier (> 4 000 km)"        = 0.15
)

parts <- flights_dist %>%
  mutate(facteur = facteurs_co2[as.character(categorie)]) %>%
  group_by(categorie) %>%
  summarise(
    vols = n(),
    km   = sum(distance_km),
    co2  = sum(distance_km * facteur),
    .groups = "drop"
  ) %>%
  mutate(
    `Part des vols`        = vols / sum(vols) * 100,
    `Part des km parcourus`= km / sum(km) * 100,
    `Part du CO2 estimé`   = co2 / sum(co2) * 100
  ) %>%
  pivot_longer(
    cols = starts_with("Part"),
    names_to = "indicateur",
    values_to = "pct"
  ) %>%
  mutate(indicateur = factor(indicateur, levels = c(
    "Part des vols", "Part des km parcourus", "Part du CO2 estimé"
  )))

ggplot(parts, aes(x = categorie, y = pct, fill = indicateur)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  geom_text(aes(label = paste0(round(pct, 1), "%")),
            position = position_dodge(width = 0.8),
            vjust = -0.4, size = 3.5) +
  scale_fill_brewer(palette = "Blues") +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 18)) +
  labs(
    title = "Vols, kilomètres parcourus et CO2 estimé par catégorie (2019)",
    subtitle = "Le long-courrier : 9 % des vols mais 38 % des kilomètres parcourus",
    x = NULL,
    y = "Part (%)",
    fill = NULL,
    caption = "CO2 : ordre de grandeur non pondéré par la capacité des appareils — Source : OpenSky Network COVID-19 Flight Dataset + OurAirports"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    legend.position = "bottom",
    panel.grid.major.x = element_blank()
  )

ggsave("q7_parts_vols_km_co2.png", width = 9, height = 5.5, dpi = 150)

# ── Graphique 4 : Évolution des catégories pendant le COVID ────
# On utilise le dataset 2019-2022 pour voir si la crise a frappé
# les trois segments de la même manière

flights_entier <- read_csv("data/clean/clean_COVID_19_Flightfile_entier.csv")

flights_entier_dist <- flights_entier %>%
  filter(
    !is.na(origin), !is.na(destination),
    origin != destination
  ) %>%
  left_join(airports_coord, by = c("origin" = "icao_code")) %>%
  rename(lat_orig = latitude_deg, lon_orig = longitude_deg) %>%
  left_join(airports_coord, by = c("destination" = "icao_code")) %>%
  rename(lat_dest = latitude_deg, lon_dest = longitude_deg) %>%
  filter(
    !is.na(lat_orig), !is.na(lon_orig),
    !is.na(lat_dest), !is.na(lon_dest)
  ) %>%
  mutate(
    distance_km = distHaversine(
      cbind(lon_orig, lat_orig),
      cbind(lon_dest, lat_dest)
    ) / 1000
  ) %>%
  filter(distance_km >= 10, distance_km <= 15500) %>%
  mutate(
    categorie = case_when(
      distance_km < 1500 ~ "Court-courrier (< 1 500 km)",
      distance_km < 4000 ~ "Moyen-courrier (1 500 – 4 000 km)",
      TRUE               ~ "Long-courrier (> 4 000 km)"
    ),
    categorie = factor(categorie, levels = c(
      "Court-courrier (< 1 500 km)",
      "Moyen-courrier (1 500 – 4 000 km)",
      "Long-courrier (> 4 000 km)"
    )),
    mois = floor_date(as.Date(day), "month")
  )

evolution <- flights_entier_dist %>%
  count(mois, categorie) %>%
  mutate(
    annee = year(mois),
    mois_calendaire = month(mois)
  ) %>%
  # base 100 : MÊME MOIS de 2019, pour ne pas confondre la
  # saisonnalité (été plus chargé) avec la reprise post-COVID
  group_by(categorie, mois_calendaire) %>%
  mutate(base_2019 = n[annee == 2019][1],
         indice = n / base_2019 * 100) %>%
  ungroup()

ggplot(evolution, aes(x = mois, y = indice, color = categorie)) +
  geom_hline(yintercept = 100, linetype = "dashed", color = "grey50") +
  geom_line(linewidth = 1.1) +
  scale_color_manual(values = c("#9ecae1", "#4292c6", "#08519c")) +
  scale_x_date(date_breaks = "6 months", date_labels = "%b %Y") +
  labs(
    title = "Évolution mensuelle des vols par catégorie de distance (2019-2022)",
    subtitle = "Indice base 100 = même mois de 2019 — le long-courrier chute plus fort et repart plus lentement",
    x = NULL,
    y = "Indice (100 = même mois de 2019)",
    color = "Catégorie",
    caption = "Source : OpenSky Network COVID-19 Flight Dataset + OurAirports"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    legend.position = "bottom"
  )

ggsave("q7_evolution_categories_covid.png", width = 10, height = 5.5, dpi = 150)
