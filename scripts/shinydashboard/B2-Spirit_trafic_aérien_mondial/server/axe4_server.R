library(shiny)
library(tidyverse)
library(plotly)
library(maps)
library(viridis)

# =====================================================
# AXE 4 SERVER — Q9 : le réseau des compagnies
# =====================================================

# Dictionnaire code OACI -> compagnie (le même que pour la Q8)
q9_airlines <- tribble(
  ~icao, ~name,                ~modele,
  "SWA", "Southwest Airlines", "Low-cost",
  "RYR", "Ryanair",            "Low-cost",
  "EZY", "easyJet",            "Low-cost",
  "WZZ", "Wizz Air",           "Low-cost",
  "VLG", "Vueling",            "Low-cost",
  "DAL", "Delta Air Lines",    "Major réseau",
  "AAL", "American Airlines",  "Major réseau",
  "UAL", "United Airlines",    "Major réseau",
  "DLH", "Lufthansa",          "Major réseau",
  "AFR", "Air France",         "Major réseau",
  "BAW", "British Airways",    "Major réseau",
  "THY", "Turkish Airlines",   "Major réseau",
  "FDX", "FedEx",              "Cargo",
  "UPS", "UPS Airlines",       "Cargo"
)

axe4_server <- function(input, output, session) {

  # =================================================
  # 1. CHARGEMENT DES DONNÉES
  # =================================================

  airports_coord_q9 <- read_csv(
    "../../../data/clean/airports.csv",
    show_col_types = FALSE
  ) %>%
    filter(
      !is.na(icao_code),
      !is.na(latitude_deg),
      !is.na(longitude_deg)
    ) %>%
    distinct(icao_code, .keep_all = TRUE) %>%
    select(icao_code, latitude_deg, longitude_deg, municipality)

  world_q9 <- map_data("world")

  q9_flights <- reactive({

    switch(input$q9_dataset_choice,
      data_2019    = read_csv("../../../data/clean/clean_COVID_19_Flightfile_2019.csv"),
      data_2020    = read_csv("../../../data/clean/clean_COVID_19_Flightfile_2020.csv"),
      data_2021    = read_csv("../../../data/clean/clean_COVID_19_Flightfile_2021.csv"),
      data_2022    = read_csv("../../../data/clean/clean_COVID_19_Flightfile_2022.csv"),
      data_general = read_csv("../../../data/clean/clean_COVID_19_Flightfile_entier.csv")
    )
  })

  # Vols attribués à une compagnie, origine/destination connues
  q9_flights_cie <- reactive({

    q9_flights() %>%
      mutate(icao = str_to_upper(str_trim(substr(callsign, 1, 3)))) %>%
      inner_join(q9_airlines, by = "icao") %>%
      filter(
        !is.na(origin), !is.na(destination),
        origin != destination
      )
  })

  # Routes (aller/retour fusionnés) avec coordonnées
  q9_routes <- reactive({

    q9_flights_cie() %>%
      mutate(
        airport1 = pmin(origin, destination),
        airport2 = pmax(origin, destination)
      ) %>%
      count(name, airport1, airport2) %>%
      left_join(
        airports_coord_q9 %>% select(-municipality),
        by = c("airport1" = "icao_code")
      ) %>%
      rename(lat_1 = latitude_deg, lon_1 = longitude_deg) %>%
      left_join(
        airports_coord_q9 %>% select(-municipality),
        by = c("airport2" = "icao_code")
      ) %>%
      rename(lat_2 = latitude_deg, lon_2 = longitude_deg) %>%
      filter(
        !is.na(lat_1), !is.na(lon_1),
        !is.na(lat_2), !is.na(lon_2)
      )
  })

  # =================================================
  # 2. CARTE DU RÉSEAU D'UNE COMPAGNIE
  # =================================================

  q9_carte_reseau <- function(compagnie) {

    routes <- q9_routes() %>%
      filter(name == compagnie)

    validate(need(
      nrow(routes) > 0,
      paste("Aucun vol trouvé pour", compagnie, "sur cette période.")
    ))

    # Cadrage automatique sur le réseau (on écarte les 1 % de
    # routes les plus excentrées pour garder une carte lisible)
    lons <- c(routes$lon_1, routes$lon_2)
    lats <- c(routes$lat_1, routes$lat_2)
    xlim <- quantile(lons, c(0.01, 0.99)) + c(-3, 3)
    ylim <- quantile(lats, c(0.01, 0.99)) + c(-3, 3)

    ggplot() +

      geom_polygon(
        data = world_q9,
        aes(x = long, y = lat, group = group),
        fill = "grey95", color = "grey75", linewidth = 0.2
      ) +

      geom_curve(
        data = routes,
        aes(x = lon_1, y = lat_1, xend = lon_2, yend = lat_2,
            colour = n),
        linewidth = 0.35, curvature = 0.2, alpha = 0.7
      ) +

      # Échelle log : sans elle, les routes peu fréquentées
      # écrasent toute la palette vers le jaune pâle
      scale_colour_viridis_c(option = "inferno", direction = -1,
                             trans = "log10",
                             begin = 0.1, end = 0.85) +

      coord_fixed(1.3, xlim = xlim, ylim = ylim) +

      theme_void(base_size = 13) +
      theme(
        plot.title = element_text(face = "bold"),
        plot.background = element_rect(fill = "white", color = NA),
        legend.position = "bottom"
      ) +

      labs(
        title = paste0(compagnie, " — ",
                       nrow(routes), " routes observées"),
        colour = "Nombre de vols"
      )
  }

  output$Q9MapA <- renderPlot({
    q9_carte_reseau(input$q9_compagnie_a)
  })

  output$Q9MapB <- renderPlot({
    q9_carte_reseau(input$q9_compagnie_b)
  })

  # =================================================
  # 3. CONCENTRATION SUR L'AÉROPORT PIVOT
  # =================================================

  # Mouvements : chaque vol compte un départ + une arrivée
  q9_mouvements <- reactive({

    q9_flights_cie() %>%
      select(name, modele, origin, destination) %>%
      pivot_longer(c(origin, destination),
                   names_to = NULL, values_to = "airport")
  })

  output$Q9Concentration <- renderPlotly({

    hub_top <- q9_mouvements() %>%
      count(name, modele, airport, sort = TRUE) %>%
      group_by(name, modele) %>%
      slice_max(n, n = 1, with_ties = FALSE) %>%
      ungroup() %>%
      rename(hub = airport)

    concentration <- q9_flights_cie() %>%
      inner_join(hub_top %>% select(name, hub), by = "name") %>%
      group_by(name, modele, hub) %>%
      summarise(
        vols_total = n(),
        vols_hub = sum(origin == hub | destination == hub),
        .groups = "drop"
      ) %>%
      mutate(part_hub = vols_hub / vols_total * 100) %>%
      left_join(
        airports_coord_q9 %>% select(icao_code, municipality),
        by = c("hub" = "icao_code")
      ) %>%
      mutate(
        municipality = str_remove(municipality, " ?[(,].*$"),
        hub_label = if_else(
          is.na(municipality),
          hub,
          paste0(hub, " (", municipality, ")")
        ),
        name = fct_reorder(name, part_hub)
      )

    p <- ggplot(
      concentration,
      aes(x = name, y = part_hub, fill = modele,
          text = paste0(name, " — ", hub_label, " : ",
                        round(part_hub, 1), "% de ",
                        vols_total, " vols"))
    ) +

      geom_col(width = 0.7) +
      coord_flip() +

      scale_y_continuous(limits = c(0, 100)) +
      scale_fill_manual(values = c(
        "Low-cost"     = "#fdae61",
        "Major réseau" = "#4C78A8",
        "Cargo"        = "#5e4fa2"
      )) +

      labs(
        title = "Part des vols touchant l'aéroport principal",
        x = NULL,
        y = "Part des vols (%)",
        fill = "Modèle économique"
      ) +

      theme_minimal(base_size = 13) +
      theme(plot.title = element_text(face = "bold"))

    ggplotly(p, tooltip = "text")
  })

  # =================================================
  # 4. COURBE DE CONCENTRATION CUMULÉE (A vs B)
  # =================================================

  output$Q9Courbe <- renderPlotly({

    courbe_data <- q9_mouvements() %>%
      filter(name %in% c(input$q9_compagnie_a,
                         input$q9_compagnie_b)) %>%
      count(name, airport) %>%
      group_by(name) %>%
      arrange(desc(n), .by_group = TRUE) %>%
      mutate(
        rang = row_number(),
        part_cumulee = cumsum(n) / sum(n) * 100
      ) %>%
      ungroup() %>%
      filter(rang <= 20)

    p <- ggplot(
      courbe_data,
      aes(x = rang, y = part_cumulee, color = name,
          text = paste0(name, " — top ", rang, " : ",
                        round(part_cumulee, 1), "% (", airport, ")"))
    ) +

      geom_line(aes(group = name), linewidth = 1.1) +
      geom_point(size = 1.8) +

      scale_x_continuous(breaks = seq(0, 20, 5)) +
      scale_color_brewer(palette = "Dark2") +

      labs(
        title = "Part cumulée des mouvements par rang d'aéroport",
        x = "Rang de l'aéroport (du plus au moins fréquenté)",
        y = "Part cumulée des mouvements (%)",
        color = "Compagnie"
      ) +

      theme_minimal(base_size = 13) +
      theme(plot.title = element_text(face = "bold"))

    ggplotly(p, tooltip = "text")
  })
}
