library(tidyverse)
library(lubridate)

# liste fichiers
files <- list.files(
  path = "data/raw/",
  pattern = "\\.csv$",
  full.names = TRUE
)

# fusion dataset
set.seed(123)
flights <- map_dfr(files, ~ read_csv(.x) %>%
                     mutate(file = basename(.x))) %>%
  sample_frac(0.01)

# ne PAS toucher a tout ce qui est au dessu


flights <- read_csv("data/clean/clean_COVID_19_Flightfile.csv")

# ggplot heure

# variables temporelles
Q2 <- flights %>%
  mutate(
    firstseen = ymd_hms(firstseen, tz = "UTC"),
    annee = year(firstseen),
    mois = month(firstseen),
    jour = day(firstseen),
    heure = hour(firstseen)
  )

# trafic par jour + heure
hour_day <- Q2  %>%
  group_by(jour, heure) %>%
  summarise(n = n(), .groups = "drop")

hour_day

# moyenne par heure
mean_hour <- hour_day %>%
  group_by(heure) %>%
  summarise(mean_flights = mean(n), .groups = "drop")

mean_hour

# plot
ggplot(mean_hour, aes(x = heure, y = mean_flights)) +
  geom_line() +
  geom_point() +
  coord_cartesian(ylim = c(250, 600))+
  labs(
    title = "Moyenne du trafic aérien par heure (UTC)",
    x = "Heure",
    y = "Nombre moyen de vols"
  ) +
  theme_minimal()






# pour les mois
month_counts <- Q2 %>%
  group_by(mois) %>%
  summarise(n = n(), .groups = "drop") %>%
  mutate(mois = factor(mois, levels = 1:12))

ggplot(month_counts, aes(x = mois, y = n)) +
  geom_col() +
  #coord_cartesian(ylim = c(15000, 30000))+
  labs(
    title = "Nombre de vols par mois",
    x = "Mois",
    y = "Nombre de vols"
  ) +
  theme_minimal(base_size = 12)




# par semaine 
Q2 <- Q2 %>%
  mutate(
    date = make_date(annee, mois, jour),
    jour_semaine = wday(date, label = TRUE, week_start = 1)
  )

daily <- Q2 %>%
  mutate(
    date = make_date(annee, mois, jour),
    jour_semaine = wday(date, label = TRUE, week_start = 1)
  ) %>%
  group_by(date, jour_semaine) %>%
  summarise(n = n(), .groups = "drop")

dow_mean <- daily %>%
  group_by(jour_semaine) %>%
  summarise(mean_flights = mean(n), .groups = "drop")


ggplot(dow_mean, aes(x = jour_semaine, y = mean_flights)) +
  geom_col(fill = "#4C78A8", width = 0.7) +
  
  geom_text(aes(label = round(mean_flights, 0)),
            vjust = -0.3,
            size = 3.5) +
  coord_cartesian(ylim = c(600, 950))+
  
  labs(
    title = "Trafic aérien moyen selon le jour de la semaine",
    subtitle = "Nombre moyen de vols par jour",
    x = NULL,
    y = "Nombre moyen de vols"
  ) +
  
  theme_minimal(base_size = 12) +
  
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 11, color = "grey40"),
    axis.text.x = element_text(angle = 30, hjust = 1),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank()
  )


