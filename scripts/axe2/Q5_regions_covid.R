library(tidyverse)
library(lubridate)
library(scales)

# ─────────────────────────────────────────────────────────────
# Q5 : Toutes les regions ont-elles subi le COVID de la meme maniere ?
# Profils de chute / reprise par continent + biais de couverture OpenSky.
# A executer depuis la racine du projet.
# ─────────────────────────────────────────────────────────────

# Aeroports -> continent.
# na = c("") indispensable : sinon readr lit "NA" (Amerique du Nord)
# comme valeur manquante et ce continent disparait.
airports_cont <- read_csv("data/clean/airports.csv", na = c("")) %>%
  filter(!is.na(icao_code), !is.na(continent), !(continent %in% c("AN", ""))) %>%
  distinct(icao_code, .keep_all = TRUE) %>%
  select(icao_code, continent) %>%
  mutate(continent_label = recode(continent,
    "AF" = "Afrique",
    "AS" = "Asie",
    "EU" = "Europe",
    "NA" = "Amerique du Nord",
    "SA" = "Amerique du Sud",
    "OC" = "Oceanie"
  ))

flights <- read_csv("data/clean/clean_COVID_19_Flightfile_entier.csv")

# Vols mensuels par continent (continent de l'aeroport d'origine)
monthly <- flights %>%
  filter(!is.na(origin)) %>%
  left_join(airports_cont %>% select(icao_code, continent_label),
            by = c("origin" = "icao_code")) %>%
  filter(!is.na(continent_label)) %>%
  mutate(
    mois     = floor_date(as.Date(day), "month"),
    annee    = year(as.Date(day)),
    mois_cal = month(as.Date(day))
  ) %>%
  group_by(mois, annee, mois_cal, continent_label) %>%
  summarise(n_vols = n(), .groups = "drop")


# ── Graphique 1 : evolution base 100 = meme mois 2019 ─────────

base_2019 <- monthly %>%
  filter(annee == 2019) %>%
  group_by(continent_label, mois_cal) %>%
  summarise(base = mean(n_vols), .groups = "drop")

donnees <- monthly %>%
  left_join(base_2019, by = c("continent_label", "mois_cal")) %>%
  filter(!is.na(base), base > 0) %>%
  mutate(indice = n_vols / base * 100)

ggplot(donnees, aes(x = mois, y = indice, color = continent_label)) +
  geom_hline(yintercept = 100, linetype = "dashed", color = "grey60") +
  geom_line(linewidth = 0.9) +
  geom_point(size = 1.3) +
  scale_x_date(date_breaks = "6 months", date_labels = "%b %Y") +
  scale_color_brewer(palette = "Set1") +
  labs(
    title   = "Evolution du trafic par continent (base 100 = meme mois 2019)",
    x       = NULL,
    y       = "Indice (100 = 2019)",
    color   = "Continent",
    caption = "Source : OpenSky Network + OurAirports"
  ) +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"), legend.position = "bottom")

ggsave("q5_evolution_continents.png", width = 10, height = 6, dpi = 150)


# ── Graphique 2 : chute au pic de crise (moy 2019 vs avril 2020) ──

moy_2019 <- monthly %>%
  filter(annee == 2019) %>%
  group_by(continent_label) %>%
  summarise(moy_2019 = mean(n_vols), .groups = "drop")

avril_2020 <- monthly %>%
  filter(annee == 2020, mois_cal == 4) %>%
  select(continent_label, n_avril = n_vols)

chute <- moy_2019 %>%
  left_join(avril_2020, by = "continent_label") %>%
  mutate(
    n_avril   = replace_na(n_avril, 0),
    chute_pct = (n_avril - moy_2019) / moy_2019 * 100,
    continent_label = fct_reorder(continent_label, chute_pct)
  )

ggplot(chute, aes(x = continent_label, y = chute_pct, fill = chute_pct)) +
  geom_col(width = 0.7, show.legend = FALSE) +
  coord_flip() +
  scale_fill_gradient2(low = "#d73027", mid = "#fee090",
                       high = "#4575b4", midpoint = -50) +
  scale_y_continuous(labels = function(x) paste0(x, " %")) +
  labs(
    title   = "Chute du trafic au pic de crise (moy. 2019 vs avril 2020)",
    x       = NULL,
    y       = "Variation (%)",
    caption = "Source : OpenSky Network + OurAirports"
  ) +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"), panel.grid.major.y = element_blank())

ggsave("q5_chute_par_continent.png", width = 9, height = 5, dpi = 150)


# ── Graphique 3 : couverture OpenSky vs realite OurAirports ───

apts_in_data <- flights %>%
  filter(!is.na(origin)) %>%
  distinct(origin) %>%
  pull(origin)

coverage <- airports_cont %>%
  mutate(in_data = icao_code %in% apts_in_data) %>%
  group_by(continent_label) %>%
  summarise(total = n(), couverts = sum(in_data), .groups = "drop") %>%
  mutate(continent_label = fct_reorder(continent_label, couverts / total)) %>%
  pivot_longer(c(total, couverts), names_to = "type", values_to = "n") %>%
  mutate(type = recode(type,
    "total"    = "Aeroports OurAirports (reference)",
    "couverts" = "Detectes dans OpenSky"
  ))

ggplot(coverage, aes(x = continent_label, y = n, fill = type)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  coord_flip() +
  scale_fill_manual(values = c(
    "Aeroports OurAirports (reference)" = "#4C78A8",
    "Detectes dans OpenSky"             = "#f28e2b"
  )) +
  scale_y_continuous(labels = comma) +
  labs(
    title   = "Couverture OpenSky vs realite - Aeroports par continent",
    x       = NULL,
    y       = "Nombre d'aeroports",
    fill    = NULL,
    caption = "Source : OurAirports + OpenSky Network"
  ) +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"),
        panel.grid.major.y = element_blank(),
        legend.position = "bottom")

ggsave("q5_couverture_opensky.png", width = 9, height = 6, dpi = 150)
