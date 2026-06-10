library(tidyverse)
library(lubridate)
library(scales)

# ─────────────────────────────────────────────────────────────
# Q1 : Comment le volume de vols a-t-il pulse entre 2019 et 2022 ?
# ─────────────────────────────────────────────────────────────

flights_all <- read_csv("data/clean/clean_COVID_19_Flightfile_entier.csv") %>%
  mutate(
    date      = as.Date(day),
    annee     = year(date),
    mois_num  = month(date),
    mois_date = floor_date(date, "month")
  )


# ── Graphique 1 : Serie temporelle mensuelle 2019-2022 ────────

monthly_all <- flights_all %>%
  group_by(mois_date) %>%
  summarise(n_flights = n(), .groups = "drop")

events <- tibble(
  date  = as.Date(c("2020-03-15", "2020-12-01", "2021-07-01", "2022-06-01")),
  label = c("Confinements\nmondiaux", "Vaccins\ndeployes",
            "Reprise\npartielle", "Retour\nniveau 2019")
)

ggplot(monthly_all, aes(x = mois_date, y = n_flights)) +
  geom_area(fill = "#08519c", alpha = 0.12) +
  geom_line(color = "#08519c", linewidth = 1.2) +
  geom_point(color = "#08519c", size = 2) +
  geom_vline(
    data = events,
    aes(xintercept = date),
    linetype = "dashed", color = "#d62728", alpha = 0.7
  ) +
  geom_label(
    data = events,
    aes(x = date, y = 400, label = label),
    hjust = 0, size = 2.8, color = "#d62728",
    fill = "white", label.size = 0.3,
    lineheight = 0.9, label.padding = unit(0.15, "lines")
  ) +
  scale_y_continuous(labels = comma, limits = c(0, NA)) +
  scale_x_date(date_breaks = "6 months", date_labels = "%b %Y") +
  labs(
    title    = "Volume mensuel de vols - Trafic aerien mondial 2019-2022",
    subtitle = "Effondrement COVID-19 (avril 2020) et reprise progressive - Echantillon OpenSky",
    x        = NULL,
    y        = "Nombre de vols",
    caption  = "Source : OpenSky Network COVID-19 Flight Dataset"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title  = element_text(face = "bold"),
    axis.text.x = element_text(angle = 30, hjust = 1)
  )

ggsave("serie_temporelle_2019_2022.png", width = 10, height = 6, dpi = 150)


# ── Graphique 2 : Superposition des courbes par annee ─────────

monthly_year <- flights_all %>%
  group_by(annee, mois_num) %>%
  summarise(n_flights = n(), .groups = "drop") %>%
  mutate(annee = factor(annee))

ggplot(monthly_year, aes(x = mois_num, y = n_flights,
                          color = annee, group = annee)) +
  geom_line(linewidth = 1.3) +
  geom_point(size = 2.5) +
  scale_color_manual(values = c(
    "2019" = "#2196F3",
    "2020" = "#F44336",
    "2021" = "#FF9800",
    "2022" = "#4CAF50"
  )) +
  scale_x_continuous(
    breaks = 1:12,
    labels = c("Jan","Fev","Mar","Avr","Mai","Jun",
               "Jul","Aou","Sep","Oct","Nov","Dec")
  ) +
  scale_y_continuous(labels = comma) +
  labs(
    title    = "Saisonnalite du trafic aerien : comparaison 2019-2022",
    subtitle = "Chaque courbe represente une annee - meme axe de mois",
    x        = NULL,
    y        = "Nombre de vols",
    color    = "Annee",
    caption  = "Source : OpenSky Network COVID-19 Flight Dataset"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title      = element_text(face = "bold"),
    legend.position = "bottom"
  )

ggsave("superposition_annees.png", width = 10, height = 5, dpi = 150)


# ── Graphique 3 : Indice de reprise (base 100 = 2019) ─────────

base_2019 <- monthly_year %>%
  filter(annee == 2019) %>%
  select(mois_num, base = n_flights)

reprise <- monthly_year %>%
  filter(annee != 2019) %>%
  left_join(base_2019, by = "mois_num") %>%
  mutate(indice = n_flights / base * 100)

ggplot(reprise, aes(x = mois_num, y = indice,
                     color = annee, group = annee)) +
  geom_hline(yintercept = 100, linetype = "dashed",
             color = "gray50", linewidth = 0.8) +
  geom_ribbon(
    data = reprise %>% filter(annee == "2020"),
    aes(ymin = indice, ymax = 100),
    fill = "#F44336", alpha = 0.1, color = NA
  ) +
  geom_line(linewidth = 1.3) +
  geom_point(size = 2.5) +
  annotate("text", x = 11.8, y = 102, label = "Niveau 2019",
           hjust = 1, size = 3.5, color = "gray40") +
  scale_color_manual(values = c(
    "2020" = "#F44336",
    "2021" = "#FF9800",
    "2022" = "#4CAF50"
  )) +
  scale_x_continuous(
    breaks = 1:12,
    labels = c("Jan","Fev","Mar","Avr","Mai","Jun",
               "Jul","Aou","Sep","Oct","Nov","Dec")
  ) +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  labs(
    title    = "Indice de reprise du trafic aerien (base 100 = niveau 2019)",
    subtitle = "Zone rouge = deficit par rapport a 2019 / Au-dessus de 100 = depassement",
    x        = NULL,
    y        = "Indice de reprise (%)",
    color    = "Annee",
    caption  = "Source : OpenSky Network COVID-19 Flight Dataset"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title      = element_text(face = "bold"),
    legend.position = "bottom"
  )

ggsave("indice_reprise.png", width = 10, height = 5, dpi = 150)
