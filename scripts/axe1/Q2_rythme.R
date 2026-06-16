library(tidyverse)
library(lubridate)
library(scales)

# ─────────────────────────────────────────────────────────────
# Q2 : Le trafic aerien a-t-il un rythme cardiaque ?
# Variations par heure (UTC), jour de la semaine et mois - annee 2019
# A executer depuis la racine du projet.
# ─────────────────────────────────────────────────────────────

flights <- read_csv("data/clean/clean_COVID_19_Flightfile_2019.csv") %>%
  mutate(
    firstseen = ymd_hms(firstseen, tz = "UTC"),
    annee = year(firstseen),
    mois  = month(firstseen),
    jour  = day(firstseen),
    heure = hour(firstseen)
  )


# ── Graphique 1 : trafic moyen par heure (UTC) ────────────────

hour_day  <- flights %>% group_by(jour, heure) %>% summarise(n = n(), .groups = "drop")
mean_hour <- hour_day %>% group_by(heure) %>% summarise(mean_flights = mean(n), .groups = "drop")

ggplot(mean_hour, aes(x = heure, y = mean_flights)) +
  geom_line(color = "#08519c", linewidth = 1) +
  geom_point(color = "#08519c", size = 2) +
  coord_cartesian(ylim = c(250, 600)) +
  labs(
    title    = "Moyenne du trafic aerien par heure (UTC)",
    subtitle = "Echantillon 1% - Annee 2019",
    x        = "Heure (UTC)",
    y        = "Nombre moyen de vols",
    caption  = "Source : OpenSky Network COVID-19 Flight Dataset"
  ) +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"))

ggsave("q2_trafic_par_heure.png", width = 9, height = 5, dpi = 150)


# ── Graphique 2 : trafic moyen par jour de la semaine ─────────

daily <- flights %>%
  filter(!is.na(annee), !is.na(mois), !is.na(jour)) %>%
  mutate(
    date         = make_date(annee, mois, jour),
    jour_semaine = wday(date, label = TRUE, week_start = 1)
  ) %>%
  group_by(date, jour_semaine) %>%
  summarise(n = n(), .groups = "drop")

dow_mean <- daily %>%
  group_by(jour_semaine) %>%
  summarise(mean_flights = mean(n), .groups = "drop")

ggplot(dow_mean, aes(x = jour_semaine, y = mean_flights)) +
  geom_col(fill = "#4C78A8", width = 0.7) +
  geom_text(aes(label = round(mean_flights, 0)), vjust = -0.3, size = 3.5) +
  coord_cartesian(ylim = c(0, 950)) +
  labs(
    title    = "Trafic aerien moyen selon le jour de la semaine",
    subtitle = "Nombre moyen de vols par jour - 2019",
    x        = NULL,
    y        = "Nombre moyen de vols",
    caption  = "Source : OpenSky Network COVID-19 Flight Dataset"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title         = element_text(face = "bold", size = 14),
    panel.grid.major.x = element_blank()
  )

ggsave("q2_trafic_par_jour.png", width = 9, height = 5, dpi = 150)


# ── Graphique 3 : trafic par mois ─────────────────────────────

month_counts <- flights %>%
  filter(!is.na(mois)) %>%
  group_by(mois) %>%
  summarise(n = n(), .groups = "drop") %>%
  mutate(mois = factor(mois, levels = 1:12))

ggplot(month_counts, aes(x = mois, y = n)) +
  geom_col(fill = "#4C78A8") +
  scale_y_continuous(labels = comma) +
  labs(
    title   = "Nombre de vols par mois (2019)",
    x       = "Mois",
    y       = "Nombre de vols",
    caption = "Source : OpenSky Network COVID-19 Flight Dataset"
  ) +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"))

ggsave("q2_trafic_par_mois.png", width = 9, height = 5, dpi = 150)
