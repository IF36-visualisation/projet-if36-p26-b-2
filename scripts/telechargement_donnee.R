library(tidyverse)

files <- list.files(
  path = "data/raw/COVID_19_Flight/",
  pattern = "\\.csv$",
  full.names = TRUE
)

set.seed(123)

flights <- map_dfr(
  files,
  ~ read_csv(.x, show_col_types = FALSE) %>%
    slice_sample(prop = 0.01) %>%
    mutate(file = basename(.x))
)

write_csv(flights, "data/clean/clean_COVID_19_Flightfile.csv")