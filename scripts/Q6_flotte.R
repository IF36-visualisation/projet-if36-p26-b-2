library(tidyverse)

# Chargement des données
flights <- read_csv("data/clean/clean_COVID_19_Flightfile.csv")

# ─────────────────────────────────────────────────────────────
# Q6 : Quels avions dominent le ciel ?
# ─────────────────────────────────────────────────────────────

# Nettoyage : on retire les typecodes manquants
flights_clean <- flights %>%
  filter(!is.na(typecode), typecode != "NA", typecode != "")

# ── Graphique 1 : Top 15 des avions les plus fréquents ─────────

top15 <- flights_clean %>%
  count(typecode, sort = TRUE) %>%
  slice_head(n = 15) %>%
  mutate(typecode = fct_reorder(typecode, n))

ggplot(top15, aes(x = typecode, y = n, fill = n)) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  scale_fill_gradient(low = "#9ecae1", high = "#08519c") +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Top 15 des types d'aéronefs les plus fréquents (2019)",
    subtitle = "Basé sur 1% du dataset OpenSky — 312 177 vols",
    x = "Type d'aéronef (code OACI)",
    y = "Nombre de vols",
    caption = "Source : OpenSky Network COVID-19 Flight Dataset"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.major.y = element_blank()
  )

ggsave("top15_typecodes.png", width = 8, height = 6, dpi = 150)

# ── Graphique 2 : Familles d'avions (Boeing vs Airbus vs autres) ─

# Catégorisation par famille
flights_famille <- flights_clean %>%
  mutate(famille = case_when(
    str_starts(typecode, "A3") | str_starts(typecode, "A2") |
      str_starts(typecode, "A1") ~ "Airbus",
    str_starts(typecode, "B7") | str_starts(typecode, "B7") ~ "Boeing",
    str_starts(typecode, "E") ~ "Embraer",
    str_starts(typecode, "CRJ") ~ "Bombardier CRJ",
    str_starts(typecode, "AT") ~ "ATR",
    str_starts(typecode, "DH") ~ "De Havilland",
    TRUE ~ "Autres"
  ))

famille_count <- flights_famille %>%
  count(famille, sort = TRUE) %>%
  mutate(
    pct = n / sum(n) * 100,
    famille = fct_reorder(famille, n)
  )

ggplot(famille_count, aes(x = famille, y = n, fill = famille)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label = paste0(round(pct, 1), "%")),
            hjust = -0.1, size = 4) +
  coord_flip() +
  scale_y_continuous(
    labels = scales::comma,
    expand = expansion(mult = c(0, 0.15))
  ) +
  scale_fill_brewer(palette = "Set2") +
  labs(
    title = "Répartition des vols par famille de constructeur (2019)",
    subtitle = "Airbus et Boeing dominent largement le marché",
    x = "Famille d'aéronef",
    y = "Nombre de vols",
    caption = "Source : OpenSky Network COVID-19 Flight Dataset"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.major.y = element_blank()
  )

ggsave("familles_constructeurs.png", width = 8, height = 5, dpi = 150)

# ── Graphique 3 : Évolution mensuelle par famille ──────────────

flights_mensuel <- flights_famille %>%
  mutate(mois = month(as.Date(day), label = TRUE, abbr = TRUE)) %>%
  filter(famille %in% c("Airbus", "Boeing", "Embraer",
                        "Bombardier CRJ", "ATR")) %>%
  count(mois, famille)

ggplot(flights_mensuel, aes(x = mois, y = n,
                            color = famille, group = famille)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.5) +
  scale_color_brewer(palette = "Set1") +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Évolution mensuelle des vols par famille d'aéronef (2019)",
    subtitle = "Saisonnalité estivale visible pour toutes les familles",
    x = "Mois",
    y = "Nombre de vols",
    color = "Constructeur",
    caption = "Source : OpenSky Network COVID-19 Flight Dataset"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    legend.position = "bottom"
  )

ggsave("evolution_mensuelle_familles.png", width = 9, height = 5, dpi = 150)