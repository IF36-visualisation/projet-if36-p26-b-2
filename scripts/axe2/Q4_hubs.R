library(tidyverse)
library(scales)
library(ggrepel)

# ─────────────────────────────────────────────────────────────
# Q4 : Quels hubs structurent le reseau aerien mondial ?
# Connectivite des aeroports (degre sortant) - annee 2019
# A executer depuis la racine du projet.
# ─────────────────────────────────────────────────────────────

flights <- read_csv("data/clean/clean_COVID_19_Flightfile_2019.csv")

# Degre sortant : nombre de destinations uniques par aeroport d'origine
hub_connectivity <- flights %>%
  filter(!is.na(origin), origin != "", !is.na(destination), destination != "") %>%
  group_by(origin) %>%
  summarise(
    n_destinations = n_distinct(destination),
    n_flights      = n(),
    .groups        = "drop"
  ) %>%
  arrange(desc(n_destinations))


# ── Graphique 1 : Top 20 des aeroports les plus connectes ─────

top20 <- hub_connectivity %>%
  slice_head(n = 20) %>%
  mutate(origin = fct_reorder(origin, n_destinations))

ggplot(top20, aes(x = origin, y = n_destinations, fill = n_flights)) +
  geom_col() +
  coord_flip() +
  scale_fill_gradient(low = "#9ecae1", high = "#08306b",
                      labels = comma, name = "Nb de vols") +
  scale_y_continuous(labels = comma) +
  labs(
    title    = "Top 20 des aeroports les plus connectes (2019)",
    subtitle = "Nombre de destinations uniques desservies",
    x        = "Aeroport (code OACI)",
    y        = "Destinations uniques",
    caption  = "Source : OpenSky Network COVID-19 Flight Dataset"
  ) +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"),
        panel.grid.major.y = element_blank())

ggsave("q4_top20_hubs.png", width = 9, height = 7, dpi = 150)


# ── Graphique 2 : volume de trafic vs connectivite ────────────

hub_scatter <- hub_connectivity %>% filter(n_flights >= 100)
top10       <- hub_connectivity %>% slice_head(n = 10)

ggplot(hub_scatter, aes(x = n_flights, y = n_destinations)) +
  geom_point(alpha = 0.4, color = "#4C78A8", size = 2) +
  geom_point(data = top10, color = "#d62728", size = 3) +
  geom_text_repel(data = top10, aes(label = origin),
                  size = 3.5, color = "#d62728", max.overlaps = 20, seed = 42) +
  scale_x_continuous(labels = comma) +
  labs(
    title    = "Volume de trafic vs connectivite des aeroports (2019)",
    subtitle = "Chaque point = 1 aeroport (min. 100 vols) - Top 10 en rouge",
    x        = "Nombre de vols (departs)",
    y        = "Destinations uniques",
    caption  = "Source : OpenSky Network COVID-19 Flight Dataset"
  ) +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"))

ggsave("q4_volume_vs_connectivite.png", width = 9, height = 7, dpi = 150)


# ── Graphique 3 : profil geographique des 6 principaux hubs ───

# Region estimee par le premier caractere du code OACI de destination
get_region <- function(code) {
  prefix <- str_sub(code, 1, 1)
  case_when(
    prefix == "K" ~ "Amerique du Nord (US)",
    prefix == "C" ~ "Canada",
    prefix == "E" ~ "Europe du Nord",
    prefix == "L" ~ "Europe du Sud / Med.",
    prefix == "O" ~ "Moyen-Orient / Asie C.",
    prefix %in% c("V", "W", "Z", "R") ~ "Asie / Pacifique",
    prefix %in% c("S", "M", "T") ~ "Amerique latine",
    prefix %in% c("D", "F", "G", "H") ~ "Afrique",
    prefix == "U" ~ "Russie / CEI",
    prefix == "B" ~ "Chine / Taiwan",
    prefix == "Y" ~ "Australie",
    TRUE ~ "Autre"
  )
}

top6 <- hub_connectivity %>% slice_head(n = 6) %>% pull(origin)

hub_dest <- flights %>%
  filter(origin %in% top6, !is.na(destination), destination != "") %>%
  mutate(region_dest = get_region(destination)) %>%
  count(origin, region_dest) %>%
  group_by(origin) %>%
  mutate(pct = n / sum(n) * 100) %>%
  ungroup()

ggplot(hub_dest, aes(x = region_dest, y = pct, fill = region_dest)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ origin, ncol = 3) +
  coord_flip() +
  scale_fill_brewer(palette = "Set3") +
  labs(
    title    = "Profil geographique des destinations depuis les 6 principaux hubs",
    subtitle = "Repartition (%) des vols par region de destination - 2019",
    x        = NULL,
    y        = "Part des vols (%)",
    caption  = "Source : OpenSky Network - Regions estimees par prefixe OACI"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title  = element_text(face = "bold"),
    strip.text  = element_text(face = "bold", size = 11),
    axis.text.y = element_text(size = 8)
  )

ggsave("q4_profil_geographique_hubs.png", width = 11, height = 8, dpi = 150)
