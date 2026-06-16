# =============================================================================
# FICHIER : global.R
# =============================================================================
library(shiny)
library(shinydashboard)
library(echarts4r)
library(tidyverse)
library(scales)
library(lubridate)
library(base64enc)
library(shinycssloaders)
library(plotly)
library(geosphere)
library(ggridges)
library(ggrepel)
library(maps)
library(viridis)

# --- DONNÉES GLOBE ---
airports <- readRDS("../data/clean/globe_airports.rds")
routes   <- readRDS("../data/clean/globe_routes.rds")

regions_disponibles <- c("Toutes", sort(unique(airports$region)))
couleurs_region <- c(
  "Europe"           = "#00d8ff", "Moyen-Orient"     = "#ffaa00",
  "Asie"             = "#00ff55", "Amérique du Nord" = "#b76eff",
  "Amérique du Sud"  = "#ff477e", "Afrique"          = "#ffdd00",
  "Océanie"          = "#ff6b35", "Autres"           = "#ffffff"
)

preparer_donnees <- function(annee, region_filtre) {
  df <- airports
  df$vols <- df[[paste0("vols_", annee)]]
  if (region_filtre != "Toutes") df <- df %>% filter(region == region_filtre)
  df
}

# --- DONNÉES AXES ---

# Fichier entier 2019-2022 (Q1)
flights_q1 <- tryCatch({
  read_csv("../data/clean/clean_COVID_19_Flightfile_entier.csv", show_col_types = FALSE) %>%
    mutate(
      date      = as.Date(day),
      mois_date = floor_date(date, "month"),
      annee     = year(date),
      mois_num  = month(date)
    )
}, error = function(e) NULL)

# Fichiers annuels (Q2, Q6, Axe2)
flights_2019 <- tryCatch({
  read_csv("../data/clean/clean_COVID_19_Flightfile_2019.csv", show_col_types = FALSE)
}, error = function(e) NULL)

flights_2020 <- tryCatch({
  read_csv("../data/clean/clean_COVID_19_Flightfile_2020.csv", show_col_types = FALSE)
}, error = function(e) NULL)

flights_2021 <- tryCatch({
  read_csv("../data/clean/clean_COVID_19_Flightfile_2021.csv", show_col_types = FALSE)
}, error = function(e) NULL)

flights_2022 <- tryCatch({
  read_csv("../data/clean/clean_COVID_19_Flightfile_2022.csv", show_col_types = FALSE)
}, error = function(e) NULL)

# Alias pour compatibilite avec axe1 et axe3
flights_q6 <- flights_2019

# Aeroports pour la carte Q3 (different du globe_airports.rds)
airports_map <- tryCatch({
  read_csv("../data/clean/airports.csv", show_col_types = FALSE)
}, error = function(e) NULL)

donnees_q1_ok   <- !is.null(flights_q1)
donnees_q6_ok   <- !is.null(flights_q6)
donnees_axe2_ok <- !is.null(flights_2019) && !is.null(airports_map)

# Coordonnees aeroports (Q4, Q7, Q9)
airports_coord <- if (!is.null(airports_map)) {
  airports_map %>%
    filter(!is.na(icao_code), !is.na(latitude_deg), !is.na(longitude_deg)) %>%
    distinct(icao_code, .keep_all = TRUE) %>%
    select(icao_code, latitude_deg, longitude_deg, any_of("municipality"))
} else NULL

# Dictionnaire compagnies (Q8 et Q9)
airlines_clean <- tribble(
  ~icao, ~name,                 ~modele,
  "SWA", "Southwest Airlines",  "Low-cost",
  "RYR", "Ryanair",             "Low-cost",
  "EZY", "easyJet",             "Low-cost",
  "WZZ", "Wizz Air",            "Low-cost",
  "VLG", "Vueling",             "Low-cost",
  "DAL", "Delta Air Lines",     "Major reseau",
  "AAL", "American Airlines",   "Major reseau",
  "UAL", "United Airlines",     "Major reseau",
  "DLH", "Lufthansa",           "Major reseau",
  "AFR", "Air France",          "Major reseau",
  "BAW", "British Airways",     "Major reseau",
  "THY", "Turkish Airlines",    "Major reseau",
  "FDX", "FedEx",               "Cargo",
  "UPS", "UPS Airlines",        "Cargo"
)

# --- THÈME GLOBAL GGPLOT (Pour ta camarade) ---
theme_b2 <- function() {
  theme_minimal(base_size = 12) +
    theme(
      plot.background   = element_rect(fill = "#0d1b2a", color = NA),
      panel.background  = element_rect(fill = "#0d1b2a", color = NA),
      panel.grid        = element_line(color = "#1a3a5c"),
      panel.grid.minor  = element_blank(),
      text              = element_text(color = "#c8d8e8"),
      plot.title        = element_text(color = "#ffffff", face = "bold", size = 13),
      plot.subtitle     = element_text(color = "#5a7a9a", size = 11),
      axis.text         = element_text(color = "#aec6e8"),
      plot.caption      = element_text(color = "#3a5a7a", size = 9),
      legend.background = element_rect(fill = "#0d1b2a", color = NA),
      legend.text       = element_text(color = "#c8d8e8")
    )
}

# --- CSS GLOBAL (Ton design spatial) ---
css_global <- "
  body, .content-wrapper, .right-side { background-color: #050d1a !important; }
  .skin-blue .main-sidebar  { background-color: #0d1b2a !important; }
  .skin-blue .sidebar a     { color: #c8d8e8 !important; }
  .sidebar-menu > li > a    { border-left: 3px solid transparent; }
  .sidebar-menu > li.active > a { border-left: 3px solid #4aa3ff !important; }
  .box { background:#0d1b2a; border-top:3px solid #1a3a5c; border-radius:8px; margin-bottom:16px; }
  .box.box-primary  { border-top-color: #08519c !important; }
  .box.box-info     { border-top-color: #4aa3ff !important; }
  .box-header { color:#c8d8e8 !important; background:#0d1b2a !important; }
  .box-body   { color:#c8d8e8; }
  .nav-tabs-custom { background:#0d1b2a; border-bottom:1px solid #1a3a5c; }
  .nav-tabs-custom > .nav-tabs > li.active { border-top-color:#4aa3ff; }
  .nav-tabs-custom > .nav-tabs > li > a   { color:#aec6e8 !important; background:transparent; }
  .nav-tabs-custom > .nav-tabs > li.active > a { color:#fff !important; }
  .nav-tabs-custom > .tab-content { background:transparent; padding:0; }
  select, .selectize-input { background:#1a2d40 !important; color:#fff !important; border-color:#2a4a6a !important; }
  .selectize-dropdown { background:#1a2d40; color:#fff; border-color:#2a4a6a; }
  .irs--shiny .irs-bar, .irs--shiny .irs-bar--single { background:#08519c; border-color:#08519c; }
  .irs--shiny .irs-handle { background:#4aa3ff; border-color:#4aa3ff; }
  .irs--shiny .irs-from, .irs--shiny .irs-to, .irs--shiny .irs-single { background:#08519c; }
  .stat-badge { display:inline-block; padding:4px 10px; border-radius:20px; font-size:12px; font-weight:600; margin:2px; }
  .stat-red   { background:rgba(214,39,40,0.2);  color:#ff6b6b; border:1px solid rgba(214,39,40,0.4); }
  .stat-green { background:rgba(38,222,129,0.2); color:#26de81; border:1px solid rgba(38,222,129,0.4); }
  .stat-blue  { background:rgba(74,163,255,0.2); color:#4aa3ff; border:1px solid rgba(74,163,255,0.4); }
  .modal-content { background-color: #0d1b2a; color: #c8d8e8; border: 2px solid #4aa3ff; border-radius: 10px; }
  .modal-header { border-bottom: 1px solid #1a3a5c; background-color: #08519c; border-radius: 8px 8px 0 0; }
  .modal-title { color: #ffffff; font-weight: bold; }
  .modal-footer { border-top: 1px solid #1a3a5c; }
  .close { color: #ffffff; opacity: 0.8; text-shadow: none; font-size: 24px; }
  .close:hover { color: #ff477e; opacity: 1; }
"