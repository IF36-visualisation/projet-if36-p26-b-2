library(tidyverse)
library(lubridate)
library(gganimate)
library(ggridges)
library(ggbump)
library(ggplot2)

flights <- read.csv("clean_COVID_19_Flightfile.csv")

# Dictionnaire manuel : code OACI -> nom de compagnie
airlines_clean <- tribble(
  ~icao, ~name,
  "SWA", "Southwest Airlines",
  "RYR", "Ryanair",
  "EZY", "easyJet",
  "WZZ", "Wizz Air",
  "VLG", "Vueling",
  "DAL", "Delta Air Lines",
  "AAL", "American Airlines",
  "UAL", "United Airlines",
  "DLH", "Lufthansa",
  "AFR", "Air France",
  "BAW", "British Airways",
  "THY", "Turkish Airlines",
  "FDX", "FedEx",
  "UPS", "UPS Airlines"
)

flights <- flights %>%
  mutate(icao = str_to_upper(str_trim(substr(callsign, 1, 3))))

flights <- flights %>%
  inner_join(airlines_clean, by = "icao")

flights <- flights %>%
  mutate(date = as.Date(day),
         month = floor_date(date, "month"))

monthly_airline <- flights %>%
  filter(!is.na(name)) %>%
  group_by(month, name) %>%
  summarise(n_flights = n(), .groups = "drop")

top_airlines <- monthly_airline %>%
  group_by(name) %>%
  summarise(total = sum(n_flights)) %>%
  slice_max(total, n = 10) %>%
  pull(name)

monthly_airline <- monthly_airline %>%
  filter(name %in% top_airlines)

bump_data <- monthly_airline %>%
  group_by(month) %>%
  mutate(rank = rank(-n_flights)) %>%
  ungroup()

ggplot(bump_data, aes(x = month, y = rank, color = name)) +
  geom_bump(linewidth = 1.2) +
  geom_point(size = 2) +
  scale_y_reverse() +
  labs(
    title = "Évolution du classement des compagnies aériennes",
    x = "Temps",
    y = "Classement",
    color = "Compagnie"
  ) +
  theme_minimal()

race_data <- monthly_airline %>%
  group_by(month) %>%
  mutate(rank = rank(-n_flights)) %>%
  ungroup()

p <- ggplot(race_data, aes(x = reorder(name, n_flights), y = n_flights, fill = name)) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  labs(
    title = "Top compagnies aériennes - {closest_state}",
    x = "",
    y = "Nombre de vols"
  ) +
  transition_states(month, transition_length = 4, state_length = 1) +
  ease_aes("cubic-in-out")

animate(p, nframes = 200, fps = 20)

selected_airlines <- c("Ryanair", "easyJet", "Air France", "Lufthansa", "FedEx", "UPS Airlines")

comparison_data <- monthly_airline %>%
  filter(name %in% selected_airlines)

ggplot(comparison_data, aes(x = month, y = n_flights, color = name)) +
  geom_line(linewidth = 1.2) +
  labs(
    title = "Comparaison des stratégies des compagnies",
    x = "Temps",
    y = "Nombre de vols",
    color = "Compagnie"
  ) +
  theme_minimal()