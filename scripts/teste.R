library(tidyverse)
library(maps)
library(geosphere)
library(viridis)

# =========================================================
# Chargement des données
# =========================================================

setwd("C:/Users/elodie/OneDrive/Bureau/sn2/IF36/projet_if36_2/projet-if36-p26-b-2")

flights <- read_csv("data/clean/clean_COVID_19_Flightfile_2019.csv")
airports <- read_csv("data/clean/airports.csv")

# =========================================================
# Paramètres
# =========================================================

corridor_bidirectionnel <- TRUE
nb_corridors <- 500

# =========================================================
# Nettoyage des aéroports
# =========================================================

airports <- airports %>%
  filter(
    !is.na(icao_code),
    !is.na(latitude_deg),
    !is.na(longitude_deg)
  ) %>%
  distinct(icao_code, .keep_all = TRUE)

# =========================================================
# Nettoyage des vols
# =========================================================

flights_clean <- flights %>%
  filter(
    !is.na(origin),
    !is.na(destination),
    origin != destination
  )

# =========================================================
# Création des corridors
# =========================================================

if (corridor_bidirectionnel) {
  
  corridors <- flights_clean %>%
    
    mutate(
      airport1 = pmin(origin, destination),
      airport2 = pmax(origin, destination)
    ) %>%
    
    count(airport1, airport2, sort = TRUE)
  
} else {
  
  corridors <- flights_clean %>%
    
    count(
      origin,
      destination,
      sort = TRUE
    ) %>%
    
    rename(
      airport1 = origin,
      airport2 = destination
    )
}

# =========================================================
# Ajout coordonnées aéroport 1
# =========================================================

corridors <- corridors %>%
  
  left_join(
    airports %>%
      select(
        icao_code,
        latitude_deg,
        longitude_deg
      ),
    by = c("airport1" = "icao_code")
  ) %>%
  
  rename(
    latitude_1 = latitude_deg,
    longitude_1 = longitude_deg
  )

# =========================================================
# Ajout coordonnées aéroport 2
# =========================================================

corridors <- corridors %>%
  
  left_join(
    airports %>%
      select(
        icao_code,
        latitude_deg,
        longitude_deg
      ),
    by = c("airport2" = "icao_code")
  ) %>%
  
  rename(
    latitude_2 = latitude_deg,
    longitude_2 = longitude_deg
  )

# =========================================================
# Suppression des lignes problématiques
# =========================================================

corridors <- corridors %>%
  
  filter(
    !is.na(latitude_1),
    !is.na(longitude_1),
    !is.na(latitude_2),
    !is.na(longitude_2)
  ) %>%
  
  filter(
    !(latitude_1 == latitude_2 &
        longitude_1 == longitude_2)
  )

# =========================================================
# Sélection des corridors principaux
# =========================================================

corridors <- corridors %>%
  arrange(desc(n)) %>%
  slice_head(n = nb_corridors)%>%
  arrange(n)


# =========================================================
# Carte du monde
# =========================================================

world <- map_data("world")

# =========================================================
# Visualisation
# =========================================================

ggplot() +
  
  # Fond de carte
  geom_polygon(
    data = world,
    aes(
      x = long,
      y = lat,
      group = group
    ),
    fill = "aliceblue",
    color = "gray70",
    linewidth = 0.2
  ) +
  
  # Corridors aériens
  geom_curve(
    data = corridors,
    aes(
      x = longitude_1,
      y = latitude_1,
      xend = longitude_2,
      yend = latitude_2,
      colour = n
    ),
    linewidth = 0.4,
    curvature = 0.2,
    alpha = 0.7
  ) +
  
  # Palette couleurs
  scale_colour_viridis_c(
    option = "inferno",
    direction = -1,
    begin = 0.2,
    end = 1,
    limits = c(0, max(corridors$n))
  ) +
  
  # Projection
  coord_fixed(1.3) +
  
  # Style
  theme_void() +
  
  # Titres
  labs(
    title = "Principaux corridors aériens mondiaux",
    subtitle = paste("Top", nb_corridors, "des routes aériennes les plus fréquentées"),
    colour = "Nombre de vols"
  )