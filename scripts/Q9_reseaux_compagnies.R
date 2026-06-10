library(tidyverse)
library(maps)
library(viridis)

# ─────────────────────────────────────────────────────────────
# Q9 : Le réseau de chaque compagnie raconte-t-il une
#      stratégie différente ?
# ─────────────────────────────────────────────────────────────

# Chargement des données
flights  <- read_csv("data/clean/clean_COVID_19_Flightfile_2019.csv")
airports <- read_csv("data/clean/airports.csv")

# Dictionnaire code OACI -> compagnie (le même que pour la Q8)
airlines_clean <- tribble(
  ~icao, ~name,           ~modele,
  "SWA", "Southwest Airlines", "Low-cost",
  "RYR", "Ryanair",            "Low-cost",
  "EZY", "easyJet",            "Low-cost",
  "WZZ", "Wizz Air",           "Low-cost",
  "VLG", "Vueling",            "Low-cost",
  "DAL", "Delta Air Lines",    "Major réseau",
  "AAL", "American Airlines",  "Major réseau",
  "UAL", "United Airlines",    "Major réseau",
  "DLH", "Lufthansa",          "Major réseau",
  "AFR", "Air France",         "Major réseau",
  "BAW", "British Airways",    "Major réseau",
  "THY", "Turkish Airlines",   "Major réseau",
  "FDX", "FedEx",              "Cargo",
  "UPS", "UPS Airlines",       "Cargo"
)

# Coordonnées des aéroports
airports_coord <- airports %>%
  filter(
    !is.na(icao_code),
    !is.na(latitude_deg),
    !is.na(longitude_deg)
  ) %>%
  distinct(icao_code, .keep_all = TRUE) %>%
  select(icao_code, latitude_deg, longitude_deg, municipality)

# Vols attribués à une compagnie, avec origine et destination connues
flights_cie <- flights %>%
  mutate(icao = str_to_upper(str_trim(substr(callsign, 1, 3)))) %>%
  inner_join(airlines_clean, by = "icao") %>%
  filter(
    !is.na(origin), !is.na(destination),
    origin != destination
  )

cat("Vols attribués à une compagnie du dictionnaire :",
    nrow(flights_cie), "\n")

# ── Construction des routes (aller/retour fusionnés) ───────────

routes_cie <- flights_cie %>%
  mutate(
    airport1 = pmin(origin, destination),
    airport2 = pmax(origin, destination)
  ) %>%
  count(name, modele, airport1, airport2, sort = TRUE) %>%
  left_join(airports_coord %>% select(-municipality),
            by = c("airport1" = "icao_code")) %>%
  rename(lat_1 = latitude_deg, lon_1 = longitude_deg) %>%
  left_join(airports_coord %>% select(-municipality),
            by = c("airport2" = "icao_code")) %>%
  rename(lat_2 = latitude_deg, lon_2 = longitude_deg) %>%
  filter(
    !is.na(lat_1), !is.na(lon_1),
    !is.na(lat_2), !is.na(lon_2)
  )

# Fond de carte
world <- map_data("world")

# ── Graphique 1 : Air France vs Ryanair sur l'Europe ───────────
# Deux philosophies : l'étoile autour de CDG contre le maillage
# point-à-point

duel_europe <- routes_cie %>%
  filter(name %in% c("Air France", "Ryanair"))

ggplot() +
  geom_polygon(
    data = world,
    aes(x = long, y = lat, group = group),
    fill = "grey95", color = "grey75", linewidth = 0.2
  ) +
  geom_curve(
    data = duel_europe,
    aes(x = lon_1, y = lat_1, xend = lon_2, yend = lat_2, colour = n),
    linewidth = 0.35, curvature = 0.2, alpha = 0.7
  ) +
  # Échelle log : sans elle, les routes peu fréquentées écrasent
  # toute la palette vers le jaune pâle
  scale_colour_viridis_c(option = "inferno", direction = -1,
                         trans = "log10", begin = 0.1, end = 0.85) +
  coord_fixed(1.3, xlim = c(-15, 35), ylim = c(33, 62)) +
  facet_wrap(~ name) +
  theme_void(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    strip.text = element_text(face = "bold", size = 13),
    legend.position = "bottom"
  ) +
  labs(
    title = "Réseaux d'Air France et de Ryanair en Europe (2019)",
    subtitle = "L'étoile concentrée sur Paris contre la toile point-à-point",
    colour = "Nombre de vols",
    caption = "Source : OpenSky Network COVID-19 Flight Dataset + OurAirports"
  )

ggsave("q9_afr_vs_ryr_europe.png", width = 11, height = 6.5, dpi = 150, bg = "white")

# ── Graphique 2 : quatre stratégies à l'échelle mondiale ───────

quatuor <- routes_cie %>%
  filter(name %in% c("Delta Air Lines", "Southwest Airlines",
                     "FedEx", "Turkish Airlines"))

ggplot() +
  geom_polygon(
    data = world,
    aes(x = long, y = lat, group = group),
    fill = "grey95", color = "grey75", linewidth = 0.2
  ) +
  geom_curve(
    data = quatuor,
    aes(x = lon_1, y = lat_1, xend = lon_2, yend = lat_2, colour = n),
    linewidth = 0.3, curvature = 0.2, alpha = 0.7
  ) +
  scale_colour_viridis_c(option = "inferno", direction = -1,
                         trans = "log10", begin = 0.1, end = 0.85) +
  coord_fixed(1.3, xlim = c(-170, 145), ylim = c(-45, 75)) +
  facet_wrap(~ name, ncol = 2) +
  theme_void(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    strip.text = element_text(face = "bold", size = 12),
    legend.position = "bottom"
  ) +
  labs(
    title = "Réseaux de quatre compagnies à l'échelle mondiale (2019)",
    subtitle = "Multi-hubs (Delta), point-à-point (Southwest), cargo mondial (FedEx), hub intercontinental (Turkish)",
    colour = "Nombre de vols",
    caption = "Source : OpenSky Network COVID-19 Flight Dataset + OurAirports"
  )

ggsave("q9_quatre_strategies_monde.png", width = 11, height = 8, dpi = 150, bg = "white")

# ── Graphique 3 : concentration du réseau sur l'aéroport pivot ─
# Pour chaque compagnie : part de ses vols qui touchent son
# aéroport le plus fréquenté (départ ou arrivée)

mouvements <- flights_cie %>%
  select(name, modele, origin, destination) %>%
  pivot_longer(c(origin, destination),
               names_to = NULL, values_to = "airport")

hub_top <- mouvements %>%
  count(name, modele, airport, sort = TRUE) %>%
  group_by(name, modele) %>%
  slice_max(n, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  rename(hub = airport)

concentration <- flights_cie %>%
  inner_join(hub_top %>% select(name, hub), by = "name") %>%
  group_by(name, modele, hub) %>%
  summarise(
    vols_total = n(),
    vols_hub = sum(origin == hub | destination == hub),
    .groups = "drop"
  ) %>%
  mutate(part_hub = vols_hub / vols_total * 100) %>%
  left_join(airports_coord %>% select(icao_code, municipality),
            by = c("hub" = "icao_code")) %>%
  mutate(
    # On simplifie les noms de villes ("Paris (Roissy-en-France...)" -> "Paris")
    municipality = str_remove(municipality, " ?[(,].*$"),
    hub_label = if_else(
      is.na(municipality),
      hub,
      paste0(hub, " (", municipality, ")")
    ),
    name = fct_reorder(name, part_hub)
  )

print(concentration %>% arrange(desc(part_hub)) %>%
        select(name, hub_label, vols_total, part_hub))

ggplot(concentration, aes(x = name, y = part_hub, fill = modele)) +
  geom_col(width = 0.7) +
  geom_text(aes(label = hub_label), hjust = -0.05, size = 3.3) +
  coord_flip() +
  scale_y_continuous(limits = c(0, 100),
                     expand = expansion(mult = c(0, 0.02))) +
  scale_fill_manual(values = c(
    "Low-cost" = "#fdae61", "Major réseau" = "#4C78A8", "Cargo" = "#5e4fa2"
  )) +
  labs(
    title = "Part des vols touchant l'aéroport principal (2019)",
    subtitle = "Plus la part est élevée, plus le réseau est organisé en étoile autour d'un hub",
    x = NULL,
    y = "Part des vols touchant l'aéroport principal (%)",
    fill = "Modèle économique",
    caption = "Source : OpenSky Network COVID-19 Flight Dataset + OurAirports"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.major.y = element_blank(),
    legend.position = "bottom"
  )

ggsave("q9_concentration_hub.png", width = 9, height = 6.5, dpi = 150, bg = "white")

# ── Graphique 4 : courbe de concentration cumulée ──────────────
# Part cumulée des mouvements captée par les N premiers aéroports
# de chaque compagnie : plus la courbe monte vite, plus le réseau
# est centralisé

courbe_data <- mouvements %>%
  filter(name %in% c("Air France", "Lufthansa", "Ryanair",
                     "easyJet", "Southwest Airlines", "FedEx")) %>%
  count(name, airport) %>%
  group_by(name) %>%
  arrange(desc(n), .by_group = TRUE) %>%
  mutate(
    rang = row_number(),
    part_cumulee = cumsum(n) / sum(n) * 100
  ) %>%
  ungroup() %>%
  filter(rang <= 20)

ggplot(courbe_data, aes(x = rang, y = part_cumulee, color = name)) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 1.8) +
  scale_x_continuous(breaks = seq(0, 20, 5)) +
  scale_color_brewer(palette = "Dark2") +
  labs(
    title = "Part cumulée des mouvements par rang d'aéroport (2019)",
    subtitle = "Plus la courbe grimpe vite, plus le réseau est centralisé en étoile",
    x = "Rang de l'aéroport (du plus au moins fréquenté)",
    y = "Part cumulée des mouvements (%)",
    color = "Compagnie",
    caption = "Un mouvement = un départ ou une arrivée — Source : OpenSky Network COVID-19 Flight Dataset + OurAirports"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    legend.position = "bottom"
  )

ggsave("q9_courbe_concentration.png", width = 9.5, height = 6, dpi = 150, bg = "white")
