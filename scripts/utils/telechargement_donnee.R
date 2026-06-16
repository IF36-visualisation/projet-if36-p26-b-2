library(tidyverse)
# s'assure qu'on est au bon endroit dans les fichier
setwd("C:/Users/elodie/OneDrive/Bureau/sn2/IF36/projet_if36_2/projet-if36-p26-b-2")

#bloquer la rendome seed pour toujour avoir le meme resultat
set.seed(123)

# je lis en 3 choix le daatset car le dataset est trop gros

#---------------------------------------------------------------------------------------
# 1 er passage l'anner 2019
files <- list.files(
  path = "data/raw/COVID_19_Flight_2019/",
  pattern = "\\.csv$",
  full.names = TRUE
)

flights <- map_dfr(
  files,
  ~ read_csv(.x, show_col_types = FALSE) %>%
    slice_sample(prop = 0.01) %>%
    mutate(file = basename(.x))
)

write_csv(flights, "data/clean/clean_COVID_19_Flightfile_2019.csv")

#---------------------------------------------------------------------------------------

# 2 er passage l'anner 2020
files <- list.files(
  path = "data/raw/COVID_19_Flight_2020/",
  pattern = "\\.csv$",
  full.names = TRUE
)

flights <- map_dfr(
  files,
  ~ read_csv(.x, show_col_types = FALSE) %>%
    slice_sample(prop = 0.01) %>%
    mutate(file = basename(.x))
)

write_csv(flights, "data/clean/clean_COVID_19_Flightfile_2020.csv")



#---------------------------------------------------------------------------------------

# 3 eme passage l'annee 2021
files <- list.files(
  path = "data/raw/COVID_19_Flight_2021/",
  pattern = "\\.csv$",
  full.names = TRUE
)

flights <- map_dfr(
  files,
  ~ read_csv(.x, show_col_types = FALSE) %>%
    slice_sample(prop = 0.01) %>%
    mutate(file = basename(.x))
)

write_csv(flights, "data/clean/clean_COVID_19_Flightfile_2021.csv")


#---------------------------------------------------------------------------------------
# 4 eme passage l'annee 2022
files <- list.files(
  path = "data/raw/COVID_19_Flight_2022/",
  pattern = "\\.csv$",
  full.names = TRUE
)

flights <- map_dfr(
  files,
  ~ read_csv(.x, show_col_types = FALSE) %>%
    slice_sample(prop = 0.01) %>%
    mutate(file = basename(.x))
)

write_csv(flights, "data/clean/clean_COVID_19_Flightfile_2022.csv")




#---------------------------------------------------------------------------------------
# rassemble les 4 dataset en 1

f2019 <- read_csv("data/clean/clean_COVID_19_Flightfile_2019.csv")
f2020 <- read_csv("data/clean/clean_COVID_19_Flightfile_2020.csv")
f2021 <- read_csv("data/clean/clean_COVID_19_Flightfile_2021.csv")
f2022 <- read_csv("data/clean/clean_COVID_19_Flightfile_2022.csv")

flights <- bind_rows(
  f2019,
  f2020,
  f2021,
  f2022
)
# le fichier fait 1 million de ligne c'est trop donc je le reduit par 2 

flights_reduit <- flights %>%
  slice_sample(prop = 0.3)

write_csv(
  flights_reduit,
  "data/clean/clean_COVID_19_Flightfile_entier.csv"
)

dim(flights_reduit)
