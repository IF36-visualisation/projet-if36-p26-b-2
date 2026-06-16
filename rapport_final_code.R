## ----setup, include=FALSE-----------------------------------------------------
# Tout le code est masqué dans le rapport (echo = FALSE) mais reste exécuté :
# le rapport est donc reproductible. Le fichier de code seul s'obtient avec
#   knitr::purl("rapport_final.Rmd", output = "rapport_final_code.R", documentation = 0)
knitr::opts_chunk$set(
  echo = FALSE, message = FALSE, warning = FALSE,
  fig.align = "center", fig.width = 9, fig.height = 5, dpi = 110
)
library(tidyverse)
library(lubridate)
library(scales)
library(geosphere)
library(ggrepel)
library(ggridges)
library(maps)
library(viridis)


## ----donnees, include=FALSE---------------------------------------------------
# --- Chargement des données (une seule fois) ---
flights_all <- read_csv("data/clean/clean_COVID_19_Flightfile_entier.csv") %>%
  mutate(date = as.Date(day), annee = year(date),
         mois_num = month(date), mois_date = floor_date(date, "month"))

flights_2019 <- read_csv("data/clean/clean_COVID_19_Flightfile_2019.csv")

airports_raw <- read_csv("data/clean/airports.csv")

airports_coord <- airports_raw %>%
  filter(!is.na(icao_code), !is.na(latitude_deg), !is.na(longitude_deg)) %>%
  distinct(icao_code, .keep_all = TRUE) %>%
  select(icao_code, latitude_deg, longitude_deg)

# na = c("") : préserve "NA" (Amérique du Nord) au lieu de le lire comme manquant
airports_cont <- read_csv("data/clean/airports.csv", na = c("")) %>%
  filter(!is.na(icao_code), !is.na(continent), !(continent %in% c("AN", ""))) %>%
  distinct(icao_code, .keep_all = TRUE) %>%
  select(icao_code, continent) %>%
  mutate(continent_label = recode(continent,
    "AF" = "Afrique", "AS" = "Asie", "EU" = "Europe",
    "NA" = "Amérique du Nord", "SA" = "Amérique du Sud", "OC" = "Océanie"))

airlines_clean <- tribble(
  ~icao, ~name,                 ~modele,
  "SWA", "Southwest Airlines",  "Low-cost",
  "RYR", "Ryanair",             "Low-cost",
  "EZY", "easyJet",             "Low-cost",
  "WZZ", "Wizz Air",            "Low-cost",
  "VLG", "Vueling",             "Low-cost",
  "DAL", "Delta Air Lines",     "Major réseau",
  "AAL", "American Airlines",   "Major réseau",
  "UAL", "United Airlines",     "Major réseau",
  "DLH", "Lufthansa",           "Major réseau",
  "AFR", "Air France",          "Major réseau",
  "BAW", "British Airways",     "Major réseau",
  "THY", "Turkish Airlines",    "Major réseau",
  "FDX", "FedEx",               "Cargo",
  "UPS", "UPS Airlines",        "Cargo"
)

world <- map_data("world")


## ----q1-serie-----------------------------------------------------------------
monthly_all <- flights_all %>%
  group_by(mois_date) %>%
  summarise(n_flights = n(), .groups = "drop")

events <- tibble(
  date  = as.Date(c("2020-03-15", "2020-12-01", "2021-07-01", "2022-06-01")),
  label = c("Confinements", "Vaccins", "Reprise", "≈ niveau 2019")
)
ymax <- max(monthly_all$n_flights)

ggplot(monthly_all, aes(mois_date, n_flights)) +
  geom_area(fill = "#08519c", alpha = 0.12) +
  geom_line(color = "#08519c", linewidth = 1.2) +
  geom_point(color = "#08519c", size = 1.6) +
  geom_vline(data = events, aes(xintercept = date),
             linetype = "dashed", color = "#d62728", alpha = 0.55) +
  geom_text(data = events, aes(x = date, y = ymax * 1.07, label = label),
            hjust = 0, nudge_x = 6, size = 3.2, color = "#c0392b", fontface = "bold") +
  scale_y_continuous(labels = comma, limits = c(0, ymax * 1.15)) +
  scale_x_date(date_breaks = "6 months", date_labels = "%b %Y") +
  labs(title = "Volume mensuel de vols — 2019-2022", x = NULL, y = "Vols par mois",
       caption = "Source : OpenSky Network COVID-19 Flight Dataset") +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"), axis.text.x = element_text(angle = 30, hjust = 1))


## ----q1-superposition, fig.height=4.5-----------------------------------------
monthly_year <- flights_all %>%
  group_by(annee, mois_num) %>%
  summarise(n_flights = n(), .groups = "drop") %>%
  mutate(annee = factor(annee))

ggplot(monthly_year, aes(mois_num, n_flights, color = annee, group = annee)) +
  geom_line(linewidth = 1.2) + geom_point(size = 2) +
  scale_color_manual(values = c("2019"="#2196F3","2020"="#F44336","2021"="#FF9800","2022"="#4CAF50")) +
  scale_x_continuous(breaks = 1:12,
    labels = c("Jan","Fév","Mar","Avr","Mai","Jun","Jul","Aoû","Sep","Oct","Nov","Déc")) +
  scale_y_continuous(labels = comma) +
  labs(title = "Saisonnalité comparée 2019-2022", x = NULL, y = "Vols", color = "Année",
       caption = "Source : OpenSky Network") +
  theme_minimal(base_size = 13) + theme(plot.title = element_text(face = "bold"), legend.position = "bottom")


## ----q2-prep------------------------------------------------------------------
Q2 <- flights_2019 %>%
  mutate(firstseen = ymd_hms(firstseen, tz = "UTC"),
         annee = year(firstseen), mois = month(firstseen),
         jour = day(firstseen), heure = hour(firstseen))


## ----q2-heure, fig.height=4---------------------------------------------------
Q2 %>% group_by(jour, heure) %>% summarise(n = n(), .groups = "drop") %>%
  group_by(heure) %>% summarise(m = mean(n), .groups = "drop") %>%
  ggplot(aes(heure, m)) +
  geom_line(color = "#08519c", linewidth = 1) + geom_point(color = "#08519c", size = 2) +
  coord_cartesian(ylim = c(250, 600)) +
  labs(title = "Trafic moyen par heure (UTC) — 2019", x = "Heure (UTC)", y = "Vols moyens") +
  theme_minimal(base_size = 12) + theme(plot.title = element_text(face = "bold"))


## ----q2-jour-mois, fig.width=10, fig.height=4---------------------------------
g_jour <- Q2 %>% filter(!is.na(annee), !is.na(mois), !is.na(jour)) %>%
  mutate(date = make_date(annee, mois, jour), js = wday(date, label = TRUE, week_start = 1)) %>%
  group_by(date, js) %>% summarise(n = n(), .groups = "drop") %>%
  group_by(js) %>% summarise(m = mean(n), .groups = "drop") %>%
  ggplot(aes(js, m)) + geom_col(fill = "#4C78A8", width = 0.7) +
  coord_cartesian(ylim = c(0, 950)) +
  labs(title = "Par jour de la semaine", x = NULL, y = "Vols moyens") +
  theme_minimal(base_size = 12) + theme(plot.title = element_text(face = "bold"), panel.grid.major.x = element_blank())

g_mois <- Q2 %>% filter(!is.na(mois)) %>% count(mois) %>% mutate(mois = factor(mois, levels = 1:12)) %>%
  ggplot(aes(mois, n)) + geom_col(fill = "#4C78A8") + scale_y_continuous(labels = comma) +
  labs(title = "Par mois", x = "Mois", y = "Vols") +
  theme_minimal(base_size = 12) + theme(plot.title = element_text(face = "bold"))

gridExtra::grid.arrange(g_jour, g_mois, ncol = 2)


## ----q3-corridors, fig.height=5-----------------------------------------------
corridors <- flights_2019 %>%
  filter(!is.na(origin), !is.na(destination), origin != destination) %>%
  mutate(a1 = pmin(origin, destination), a2 = pmax(origin, destination)) %>%
  count(a1, a2, sort = TRUE) %>%
  left_join(airports_coord, by = c("a1" = "icao_code")) %>%
  rename(lat1 = latitude_deg, lon1 = longitude_deg) %>%
  left_join(airports_coord, by = c("a2" = "icao_code")) %>%
  rename(lat2 = latitude_deg, lon2 = longitude_deg) %>%
  filter(!is.na(lat1), !is.na(lat2)) %>%
  slice_head(n = 300) %>% arrange(n)

ggplot() +
  geom_polygon(data = world, aes(long, lat, group = group),
               fill = "aliceblue", color = "gray70", linewidth = 0.2) +
  geom_curve(data = corridors, aes(lon1, lat1, xend = lon2, yend = lat2, colour = n),
             linewidth = 0.4, curvature = 0.2, alpha = 0.7) +
  scale_colour_viridis_c(option = "inferno", direction = -1, name = "Nb vols") +
  coord_fixed(1.3) + theme_void() +
  labs(title = "Top 300 des corridors aériens mondiaux (2019)")


## ----q4-prep------------------------------------------------------------------
hub <- flights_2019 %>%
  filter(!is.na(origin), origin != "", !is.na(destination), destination != "") %>%
  group_by(origin) %>%
  summarise(n_destinations = n_distinct(destination), n_flights = n(), .groups = "drop") %>%
  arrange(desc(n_destinations))


## ----q4-top20, fig.height=6---------------------------------------------------
hub %>% slice_head(n = 20) %>% mutate(origin = fct_reorder(origin, n_destinations)) %>%
  ggplot(aes(origin, n_destinations, fill = n_flights)) +
  geom_col() + coord_flip() +
  scale_fill_gradient(low = "#9ecae1", high = "#08306b", labels = comma, name = "Nb vols") +
  labs(title = "Top 20 des aéroports les plus connectés (2019)",
       x = "Aéroport (OACI)", y = "Destinations uniques", caption = "Source : OpenSky Network") +
  theme_minimal(base_size = 12) + theme(plot.title = element_text(face = "bold"), panel.grid.major.y = element_blank())


## ----q4-profil, fig.width=10, fig.height=7------------------------------------
get_region <- function(code) {
  p <- str_sub(code, 1, 1)
  case_when(
    p == "K" ~ "Amérique du Nord (US)", p == "C" ~ "Canada",
    p == "E" ~ "Europe du Nord", p == "L" ~ "Europe du Sud / Méd.",
    p == "O" ~ "Moyen-Orient / Asie C.",
    p %in% c("V","W","Z","R") ~ "Asie / Pacifique",
    p %in% c("S","M","T") ~ "Amérique latine",
    p %in% c("D","F","G","H") ~ "Afrique",
    p == "U" ~ "Russie / CEI", p == "B" ~ "Chine / Taiwan",
    p == "Y" ~ "Australie", TRUE ~ "Autre")
}
top6 <- hub %>% slice_head(n = 6) %>% pull(origin)
flights_2019 %>%
  filter(origin %in% top6, !is.na(destination), destination != "") %>%
  mutate(region_dest = get_region(destination)) %>%
  count(origin, region_dest) %>% group_by(origin) %>% mutate(pct = n / sum(n) * 100) %>% ungroup() %>%
  ggplot(aes(region_dest, pct, fill = region_dest)) +
  geom_col(show.legend = FALSE) + facet_wrap(~ origin, ncol = 3) + coord_flip() +
  scale_fill_brewer(palette = "Set3") +
  labs(title = "Profil géographique des 6 principaux hubs (2019)",
       x = NULL, y = "Part des vols (%)", caption = "Régions estimées par préfixe OACI") +
  theme_minimal(base_size = 11) +
  theme(plot.title = element_text(face = "bold"), strip.text = element_text(face = "bold"), axis.text.y = element_text(size = 8))


## ----q5-prep------------------------------------------------------------------
monthly_cont <- flights_all %>%
  filter(!is.na(origin)) %>%
  left_join(airports_cont %>% select(icao_code, continent_label), by = c("origin" = "icao_code")) %>%
  filter(!is.na(continent_label)) %>%
  group_by(mois = mois_date, annee, mois_cal = mois_num, continent_label) %>%
  summarise(n_vols = n(), .groups = "drop")


## ----q5-evolution, fig.height=5-----------------------------------------------
base19 <- monthly_cont %>% filter(annee == 2019) %>%
  group_by(continent_label, mois_cal) %>% summarise(base = mean(n_vols), .groups = "drop")
monthly_cont %>% left_join(base19, by = c("continent_label", "mois_cal")) %>%
  filter(!is.na(base), base > 0) %>% mutate(indice = n_vols / base * 100) %>%
  ggplot(aes(mois, indice, color = continent_label)) +
  geom_hline(yintercept = 100, linetype = "dashed", color = "grey60") +
  geom_line(linewidth = 0.9) +
  scale_x_date(date_breaks = "6 months", date_labels = "%b %Y") +
  scale_color_brewer(palette = "Set1") +
  labs(title = "Évolution du trafic par continent (base 100 = même mois 2019)",
       x = NULL, y = "Indice", color = "Continent", caption = "Source : OpenSky + OurAirports") +
  theme_minimal(base_size = 12) + theme(plot.title = element_text(face = "bold"), legend.position = "bottom")


## ----q5-couverture, fig.height=4.5--------------------------------------------
apts_in <- flights_all %>% filter(!is.na(origin)) %>% distinct(origin) %>% pull(origin)
airports_cont %>%
  mutate(in_data = icao_code %in% apts_in) %>%
  group_by(continent_label) %>% summarise(total = n(), couverts = sum(in_data), .groups = "drop") %>%
  mutate(continent_label = fct_reorder(continent_label, couverts / total)) %>%
  pivot_longer(c(total, couverts), names_to = "type", values_to = "n") %>%
  mutate(type = recode(type, total = "OurAirports (référence)", couverts = "Détectés dans OpenSky")) %>%
  ggplot(aes(continent_label, n, fill = type)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) + coord_flip() +
  scale_fill_manual(values = c("OurAirports (référence)" = "#4C78A8", "Détectés dans OpenSky" = "#f28e2b")) +
  scale_y_continuous(labels = comma) +
  labs(title = "Couverture OpenSky vs réalité — aéroports par continent",
       x = NULL, y = "Nombre d'aéroports", fill = NULL) +
  theme_minimal(base_size = 12) + theme(plot.title = element_text(face = "bold"), panel.grid.major.y = element_blank(), legend.position = "bottom")


## ----q6-prep------------------------------------------------------------------
flotte <- flights_2019 %>% filter(!is.na(typecode), typecode != "NA", typecode != "")


## ----q6-top15, fig.width=10, fig.height=5-------------------------------------
g_top <- flotte %>% count(typecode, sort = TRUE) %>% slice_head(n = 15) %>%
  mutate(typecode = fct_reorder(typecode, n)) %>%
  ggplot(aes(typecode, n, fill = n)) + geom_col(show.legend = FALSE) + coord_flip() +
  scale_fill_gradient(low = "#9ecae1", high = "#08519c") + scale_y_continuous(labels = comma) +
  labs(title = "Top 15 des types d'aéronefs", x = NULL, y = "Vols") +
  theme_minimal(base_size = 11) + theme(plot.title = element_text(face = "bold"), panel.grid.major.y = element_blank())

g_fam <- flotte %>%
  mutate(famille = case_when(
    str_starts(typecode, "A3") | str_starts(typecode, "A2") | str_starts(typecode, "A1") ~ "Airbus",
    str_starts(typecode, "B7") ~ "Boeing", str_starts(typecode, "E") ~ "Embraer",
    str_starts(typecode, "CRJ") ~ "Bombardier", str_starts(typecode, "AT") ~ "ATR",
    str_starts(typecode, "DH") ~ "De Havilland", TRUE ~ "Autres")) %>%
  count(famille, sort = TRUE) %>% mutate(pct = n / sum(n) * 100, famille = fct_reorder(famille, n)) %>%
  ggplot(aes(famille, n, fill = famille)) + geom_col(show.legend = FALSE) +
  geom_text(aes(label = paste0(round(pct, 1), "%")), hjust = -0.1, size = 3.5) + coord_flip() +
  scale_y_continuous(labels = comma, expand = expansion(mult = c(0, 0.15))) +
  scale_fill_brewer(palette = "Set2") +
  labs(title = "Répartition par constructeur", x = NULL, y = "Vols") +
  theme_minimal(base_size = 11) + theme(plot.title = element_text(face = "bold"), panel.grid.major.y = element_blank())

gridExtra::grid.arrange(g_top, g_fam, ncol = 2)


## ----q7-prep------------------------------------------------------------------
dist_q7 <- flights_2019 %>%
  filter(!is.na(origin), !is.na(destination), origin != destination) %>%
  left_join(airports_coord, by = c("origin" = "icao_code")) %>%
  rename(lo = longitude_deg, la = latitude_deg) %>%
  left_join(airports_coord, by = c("destination" = "icao_code")) %>%
  rename(lo2 = longitude_deg, la2 = latitude_deg) %>%
  filter(!is.na(la), !is.na(la2)) %>%
  mutate(distance_km = distHaversine(cbind(lo, la), cbind(lo2, la2)) / 1000) %>%
  filter(distance_km >= 10, distance_km <= 15500) %>%
  mutate(categorie = factor(case_when(
    distance_km < 1500 ~ "Court (< 1 500 km)",
    distance_km < 4000 ~ "Moyen (1 500-4 000 km)",
    TRUE ~ "Long (> 4 000 km)"),
    levels = c("Court (< 1 500 km)", "Moyen (1 500-4 000 km)", "Long (> 4 000 km)")))


## ----q7-hist, fig.height=4.5--------------------------------------------------
ggplot(dist_q7, aes(distance_km, fill = categorie)) +
  geom_histogram(binwidth = 250, boundary = 0, color = "white", linewidth = 0.1) +
  geom_vline(xintercept = c(1500, 4000), linetype = "dashed", color = "grey30") +
  scale_x_continuous(labels = comma) +
  scale_fill_manual(values = c("#9ecae1", "#4292c6", "#08519c")) +
  labs(title = "Distribution des distances de vol (2019)",
       x = "Distance (km)", y = "Nombre de vols", fill = "Catégorie") +
  theme_minimal(base_size = 12) + theme(plot.title = element_text(face = "bold"), legend.position = "bottom")


## ----q7-parts, fig.height=4.5-------------------------------------------------
facteurs <- c("Court (< 1 500 km)" = 0.25, "Moyen (1 500-4 000 km)" = 0.19, "Long (> 4 000 km)" = 0.15)
dist_q7 %>%
  mutate(f = facteurs[as.character(categorie)]) %>%
  group_by(categorie) %>%
  summarise(vols = n(), km = sum(distance_km), co2 = sum(distance_km * f), .groups = "drop") %>%
  mutate(`Part des vols` = vols / sum(vols) * 100,
         `Part des km` = km / sum(km) * 100,
         `Part du CO2 estimé` = co2 / sum(co2) * 100) %>%
  pivot_longer(starts_with("Part"), names_to = "ind", values_to = "pct") %>%
  ggplot(aes(categorie, pct, fill = ind)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  geom_text(aes(label = paste0(round(pct), "%")), position = position_dodge(width = 0.8), vjust = -0.4, size = 3) +
  scale_fill_brewer(palette = "Blues") +
  labs(title = "Vols, kilomètres et CO2 estimé par catégorie",
       x = NULL, y = "Part (%)", fill = NULL,
       caption = "CO2 : ordre de grandeur, non pondéré par la capacité") +
  theme_minimal(base_size = 12) + theme(plot.title = element_text(face = "bold"), legend.position = "bottom")


## ----q8-prep------------------------------------------------------------------
q8 <- flights_all %>%
  mutate(icao = str_to_upper(str_trim(substr(callsign, 1, 3)))) %>%
  inner_join(airlines_clean, by = "icao") %>%
  group_by(name, modele, annee, mois_cal = mois_num) %>%
  summarise(n_vols = n(), .groups = "drop")
base_cie <- q8 %>% filter(annee == 2019) %>% group_by(name) %>% summarise(moy19 = mean(n_vols), .groups = "drop")


## ----q8-chute, fig.height=5---------------------------------------------------
avr20 <- q8 %>% filter(annee == 2020, mois_cal == 4) %>% select(name, n_avr = n_vols)
base_cie %>%
  left_join(airlines_clean %>% select(name, modele), by = "name") %>%
  left_join(avr20, by = "name") %>%
  mutate(n_avr = replace_na(n_avr, 0), chute = (n_avr - moy19) / moy19 * 100,
         name = fct_reorder(name, chute)) %>%
  ggplot(aes(name, chute, fill = modele)) + geom_col(width = 0.7) + coord_flip() +
  scale_fill_manual(values = c("Low-cost" = "#fdae61", "Major réseau" = "#4C78A8", "Cargo" = "#5e4fa2")) +
  scale_y_continuous(labels = function(x) paste0(x, " %")) +
  labs(title = "Chute du trafic : moyenne 2019 vs avril 2020", x = NULL, y = "Variation (%)", fill = "Modèle") +
  theme_minimal(base_size = 12) + theme(plot.title = element_text(face = "bold"), panel.grid.major.y = element_blank(), legend.position = "bottom")


## ----q8-reprise, fig.height=5-------------------------------------------------
rep21 <- q8 %>% filter(annee == 2021, mois_cal %in% 10:12) %>% group_by(name) %>% summarise(moy = mean(n_vols), .groups = "drop")
base_cie %>%
  left_join(airlines_clean %>% select(name, modele), by = "name") %>%
  left_join(rep21, by = "name") %>%
  mutate(moy = replace_na(moy, 0), indice = moy / moy19 * 100, name = fct_reorder(name, indice)) %>%
  ggplot(aes(name, indice, fill = modele)) + geom_col(width = 0.7) +
  geom_hline(yintercept = 100, linetype = "dashed", color = "grey40") + coord_flip() +
  scale_fill_manual(values = c("Low-cost" = "#fdae61", "Major réseau" = "#4C78A8", "Cargo" = "#5e4fa2")) +
  labs(title = "Indice de reprise (oct-déc 2021 vs moyenne 2019)",
       subtitle = "100 = niveau retrouvé ; > 100 = au-dessus du pré-COVID",
       x = NULL, y = "Indice", fill = "Modèle") +
  theme_minimal(base_size = 12) + theme(plot.title = element_text(face = "bold"), panel.grid.major.y = element_blank(), legend.position = "bottom")


## ----q9-prep------------------------------------------------------------------
routes_cie <- flights_2019 %>%
  mutate(icao = str_to_upper(str_trim(substr(callsign, 1, 3)))) %>%
  inner_join(airlines_clean, by = "icao") %>%
  filter(!is.na(origin), !is.na(destination), origin != destination) %>%
  mutate(a1 = pmin(origin, destination), a2 = pmax(origin, destination)) %>%
  count(name, modele, a1, a2, sort = TRUE) %>%
  left_join(airports_coord, by = c("a1" = "icao_code")) %>% rename(lo1 = longitude_deg, la1 = latitude_deg) %>%
  left_join(airports_coord, by = c("a2" = "icao_code")) %>% rename(lo2 = longitude_deg, la2 = latitude_deg) %>%
  filter(!is.na(la1), !is.na(la2))


## ----q9-cartes, fig.width=10, fig.height=6------------------------------------
quatuor <- routes_cie %>% filter(name %in% c("Air France", "Ryanair", "Delta Air Lines", "FedEx"))
ggplot() +
  geom_polygon(data = world, aes(long, lat, group = group), fill = "grey95", color = "grey75", linewidth = 0.2) +
  geom_curve(data = quatuor, aes(lo1, la1, xend = lo2, yend = la2, colour = n),
             linewidth = 0.3, curvature = 0.2, alpha = 0.7) +
  scale_colour_viridis_c(option = "inferno", direction = -1, trans = "log10", begin = 0.1, end = 0.85, name = "Vols") +
  coord_fixed(1.3, xlim = c(-130, 40), ylim = c(20, 70)) +
  facet_wrap(~ name, ncol = 2) + theme_void(base_size = 12) +
  theme(plot.title = element_text(face = "bold"), strip.text = element_text(face = "bold"), legend.position = "bottom") +
  labs(title = "Réseaux de quatre compagnies (2019)")


## ----q9-concentration, fig.height=5-------------------------------------------
mouvements <- flights_2019 %>%
  mutate(icao = str_to_upper(str_trim(substr(callsign, 1, 3)))) %>%
  inner_join(airlines_clean, by = "icao") %>%
  filter(!is.na(origin), !is.na(destination), origin != destination) %>%
  select(name, modele, origin, destination) %>%
  pivot_longer(c(origin, destination), names_to = NULL, values_to = "airport")
hub_top <- mouvements %>% count(name, modele, airport, sort = TRUE) %>%
  group_by(name, modele) %>% slice_max(n, n = 1, with_ties = FALSE) %>% ungroup() %>% rename(hub = airport)
flights_2019 %>%
  mutate(icao = str_to_upper(str_trim(substr(callsign, 1, 3)))) %>%
  inner_join(airlines_clean, by = "icao") %>%
  filter(!is.na(origin), !is.na(destination), origin != destination) %>%
  inner_join(hub_top %>% select(name, hub), by = "name") %>%
  group_by(name, modele, hub) %>%
  summarise(part = sum(origin == hub | destination == hub) / n() * 100, .groups = "drop") %>%
  mutate(name = fct_reorder(name, part)) %>%
  ggplot(aes(name, part, fill = modele)) + geom_col(width = 0.7) + coord_flip() +
  scale_fill_manual(values = c("Low-cost" = "#fdae61", "Major réseau" = "#4C78A8", "Cargo" = "#5e4fa2")) +
  scale_y_continuous(limits = c(0, 100)) +
  labs(title = "Part des vols touchant l'aéroport principal (2019)",
       subtitle = "Plus la part est élevée, plus le réseau est en étoile",
       x = NULL, y = "Part (%)", fill = "Modèle") +
  theme_minimal(base_size = 12) + theme(plot.title = element_text(face = "bold"), panel.grid.major.y = element_blank(), legend.position = "bottom")

