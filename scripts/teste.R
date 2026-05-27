library(tidyverse)
library(lubridate)
library(ggplot2)

setwd("C:/Users/elodie/OneDrive/Bureau/sn2/IF36/projet_if36_2/projet-if36-p26-b-2")


flights_19 <- read_csv("data/clean/clean_COVID_19_Flightfile_2022.csv")




Q2 <- flights_19 %>%
  mutate(
    firstseen = ymd_hms(firstseen, tz = "UTC"),
    annee = year(firstseen),
    mois = month(firstseen),
    jour = day(firstseen),
    heure = hour(firstseen)
  )



month_counts <- Q2 %>%
  filter(!is.na(mois)) %>%
  group_by(mois) %>%
  summarise(n = n(), .groups = "drop") %>%
  mutate(mois = factor(mois, levels = 1:12))

ggplot(month_counts, aes(x = mois, y = n)) +
  geom_col(fill = "#4C78A8") +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Nombre de vols par mois (2019)",
    x = "Mois",
    y = "Nombre de vols"
  ) +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"))