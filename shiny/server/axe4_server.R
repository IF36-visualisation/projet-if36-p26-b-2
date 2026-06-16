library(shiny)
library(tidyverse)
library(lubridate)
library(maps)
library(viridis)
library(plotly)

# Donnees chargees dans global.R :
# flights_q1, flights_2019..2022, airports_coord, airlines_clean
#
# Q8 et Q9 identifient la compagnie par les 3 premiers caracteres du
# callsign (code OACI de l'operateur), rapproches du dictionnaire
# airlines_clean (icao -> nom -> modele economique).

# Fond de carte mondial (utilise par les cartes Q9)
world <- map_data("world")

# =====================================================
# SERVER AXE 4
# =====================================================

axe4_server <- function(input, output, session) {

  # =================================================
  # Q8 - donnees reactives
  # =================================================

  q8_data <- reactive({
    req(!is.null(flights_q1))

    flights_q1 %>%
      mutate(icao = str_to_upper(str_trim(substr(callsign, 1, 3))),
             date  = as.Date(day),
             mois  = floor_date(date, "month"),
             annee = as.character(year(date))) %>%
      inner_join(airlines_clean %>% select(icao, name, modele), by = "icao") %>%
      filter(annee %in% input$q8_years) %>%
      group_by(mois, annee, name, modele) %>%
      summarise(n_vols = n(), .groups = "drop")
  })

  # =================================================
  # Q8 - GRAPHE 1 : ligne base 100 = jan 2019
  # =================================================

  output$q8_line_chart <- renderPlotly({
    req(q8_data(), !is.null(flights_q1))

    # Base de reference : moyenne mensuelle 2019 par compagnie
    ref_2019 <- flights_q1 %>%
      mutate(icao  = str_to_upper(str_trim(substr(callsign, 1, 3))),
             date  = as.Date(day),
             mois  = floor_date(date, "month"),
             annee = year(date)) %>%
      inner_join(airlines_clean %>% select(icao, name), by = "icao") %>%
      filter(annee == 2019) %>%
      group_by(name, mois) %>%
      summarise(n_2019 = n(), .groups = "drop") %>%
      group_by(name) %>%
      summarise(ref = mean(n_2019), .groups = "drop")

    donnees <- q8_data() %>%
      left_join(ref_2019, by = "name") %>%
      mutate(indice = n_vols / ref * 100)

    p <- ggplot(donnees, aes(x = mois, y = indice,
                             color = name, group = name,
                             text = paste0(name, "<br>",
                                           format(mois, "%b %Y"),
                                           "<br>Indice : ", round(indice, 1)))) +
      geom_hline(yintercept = 100, linetype = "dashed",
                 color = "grey60", linewidth = 0.7) +
      geom_line(linewidth = 0.9) +
      geom_point(size = 1.5) +
      scale_x_date(date_breaks = "6 months", date_labels = "%b %Y") +
      scale_color_brewer(palette = "Paired") +
      labs(title = "Evolution du trafic par compagnie (base 100 = moyenne mensuelle 2019)",
           x = NULL, y = "Indice (100 = ref. 2019)", color = "Compagnie",
           caption = "Source : OpenSky Network COVID-19 Flight Dataset") +
      theme_minimal(base_size = 12) +
      theme(plot.title = element_text(face = "bold"),
            legend.position = "bottom")

    ggplotly(p, tooltip = "text") %>%
      layout(legend = list(orientation = "h", y = -0.2))
  })

  # =================================================
  # Q8 - GRAPHE 2 : chute au pic de crise
  # =================================================

  output$q8_bar_chute <- renderPlotly({
    req(!is.null(flights_q1))

    prep <- flights_q1 %>%
      mutate(icao  = str_to_upper(str_trim(substr(callsign, 1, 3))),
             date  = as.Date(day),
             mois  = floor_date(date, "month"),
             annee = year(date),
             mois_cal = month(date)) %>%
      inner_join(airlines_clean %>% select(icao, name, modele), by = "icao") %>%
      group_by(name, modele, annee, mois_cal) %>%
      summarise(n_vols = n(), .groups = "drop")

    # Moyenne mensuelle 2019 par compagnie
    base_2019 <- prep %>%
      filter(annee == 2019) %>%
      group_by(name) %>%
      summarise(moy_2019 = mean(n_vols), .groups = "drop")

    # Vols avril 2020 (mois 4)
    avril_2020 <- prep %>%
      filter(annee == 2020, mois_cal == 4) %>%
      select(name, modele, n_avril_2020 = n_vols)

    chute <- base_2019 %>%
      left_join(airlines_clean %>% select(name, modele), by = "name") %>%
      left_join(avril_2020 %>% select(name, n_avril_2020), by = "name") %>%
      mutate(
        n_avril_2020 = replace_na(n_avril_2020, 0),
        chute_pct = (n_avril_2020 - moy_2019) / moy_2019 * 100,
        name = fct_reorder(name, chute_pct)
      )

    p <- ggplot(chute, aes(x = name, y = chute_pct, fill = modele,
                           text = paste0(name, "<br>",
                                         round(chute_pct, 1), " %"))) +
      geom_col(width = 0.7) +
      coord_flip() +
      scale_fill_manual(values = c(
        "Low-cost"    = "#fdae61",
        "Major reseau" = "#4C78A8",
        "Cargo"       = "#5e4fa2"
      )) +
      scale_y_continuous(labels = function(x) paste0(x, " %")) +
      labs(title = "Chute du trafic : moyenne 2019 vs avril 2020 (pic de crise)",
           x = NULL, y = "Variation (%)", fill = "Modele",
           caption = "Source : OpenSky Network COVID-19 Flight Dataset") +
      theme_minimal(base_size = 12) +
      theme(plot.title = element_text(face = "bold"),
            panel.grid.major.y = element_blank(),
            legend.position = "bottom")

    ggplotly(p, tooltip = "text")
  })

  # =================================================
  # Q8 - GRAPHE 3 : reprise fin 2021
  # =================================================

  output$q8_bar_reprise <- renderPlotly({
    req(!is.null(flights_q1))

    prep <- flights_q1 %>%
      mutate(icao     = str_to_upper(str_trim(substr(callsign, 1, 3))),
             date     = as.Date(day),
             annee    = year(date),
             mois_cal = month(date)) %>%
      inner_join(airlines_clean %>% select(icao, name, modele), by = "icao") %>%
      group_by(name, modele, annee, mois_cal) %>%
      summarise(n_vols = n(), .groups = "drop")

    base_2019 <- prep %>%
      filter(annee == 2019) %>%
      group_by(name) %>%
      summarise(moy_2019 = mean(n_vols), .groups = "drop")

    reprise_2021 <- prep %>%
      filter(annee == 2021, mois_cal %in% 10:12) %>%
      group_by(name, modele) %>%
      summarise(moy_fin2021 = mean(n_vols), .groups = "drop")

    reprise <- base_2019 %>%
      left_join(airlines_clean %>% select(name, modele), by = "name") %>%
      left_join(reprise_2021 %>% select(name, moy_fin2021), by = "name") %>%
      mutate(
        moy_fin2021 = replace_na(moy_fin2021, 0),
        indice_reprise = moy_fin2021 / moy_2019 * 100,
        name = fct_reorder(name, indice_reprise)
      )

    p <- ggplot(reprise, aes(x = name, y = indice_reprise, fill = modele,
                             text = paste0(name, "<br>Indice : ",
                                           round(indice_reprise, 1)))) +
      geom_col(width = 0.7) +
      geom_hline(yintercept = 100, linetype = "dashed",
                 color = "grey40", linewidth = 0.7) +
      coord_flip() +
      scale_fill_manual(values = c(
        "Low-cost"    = "#fdae61",
        "Major reseau" = "#4C78A8",
        "Cargo"       = "#5e4fa2"
      ), na.value = "#aaaaaa") +
      labs(title = "Indice de reprise : trafic oct-dec 2021 vs moyenne 2019",
           subtitle = "100 = niveau retrouve ; > 100 = au-dessus du niveau pre-COVID",
           x = NULL, y = "Indice de reprise (100 = 2019)", fill = "Modele",
           caption = "Source : OpenSky Network COVID-19 Flight Dataset") +
      theme_minimal(base_size = 12) +
      theme(plot.title = element_text(face = "bold"),
            panel.grid.major.y = element_blank(),
            legend.position = "bottom")

    ggplotly(p, tooltip = "text")
  })

  # =================================================
  # Q9 - Donnees reactives dataset selectionne
  # =================================================

  q9_df <- reactive({
    switch(input$q9_dataset_choice,
      data_2019    = flights_2019,
      data_2020    = flights_2020,
      data_2021    = flights_2021,
      data_2022    = flights_2022,
      data_general = flights_q1
    )
  })

  # Routes enrichies de coordonnees (toutes compagnies)
  q9_routes_all <- reactive({
    df <- q9_df()
    req(!is.null(df), !is.null(airports_coord))

    df %>%
      mutate(icao = str_to_upper(str_trim(substr(callsign, 1, 3)))) %>%
      inner_join(airlines_clean %>% select(icao, name, modele), by = "icao") %>%
      filter(!is.na(origin), !is.na(destination), origin != destination) %>%
      mutate(airport1 = pmin(origin, destination),
             airport2 = pmax(origin, destination)) %>%
      count(name, modele, airport1, airport2, sort = TRUE) %>%
      left_join(airports_coord %>% select(icao_code, latitude_deg, longitude_deg),
                by = c("airport1" = "icao_code")) %>%
      rename(lat_1 = latitude_deg, lon_1 = longitude_deg) %>%
      left_join(airports_coord %>% select(icao_code, latitude_deg, longitude_deg),
                by = c("airport2" = "icao_code")) %>%
      rename(lat_2 = latitude_deg, lon_2 = longitude_deg) %>%
      filter(!is.na(lat_1), !is.na(lon_1), !is.na(lat_2), !is.na(lon_2))
  })

  # Mouvements (origine + destination) pour concentration
  q9_mouvements_all <- reactive({
    df <- q9_df()
    req(!is.null(df))

    df %>%
      mutate(icao = str_to_upper(str_trim(substr(callsign, 1, 3)))) %>%
      inner_join(airlines_clean %>% select(icao, name, modele), by = "icao") %>%
      filter(!is.na(origin), !is.na(destination), origin != destination) %>%
      select(name, modele, origin, destination) %>%
      pivot_longer(c(origin, destination),
                   names_to = NULL, values_to = "airport")
  })

  # =================================================
  # Q9 - GRAPHE 1 & 2 : cartes compagnies A et B
  # =================================================

  make_map <- function(routes_all, nom_compagnie) {
    routes <- routes_all %>% filter(name == nom_compagnie)
    req(nrow(routes) > 0)

    ggplot() +
      geom_polygon(data = world,
                   aes(x = long, y = lat, group = group),
                   fill = "grey15", color = "grey35", linewidth = 0.2) +
      geom_curve(data = routes,
                 aes(x = lon_1, y = lat_1, xend = lon_2, yend = lat_2,
                     colour = n),
                 linewidth = 0.3, curvature = 0.2, alpha = 0.7) +
      scale_colour_viridis_c(option = "inferno", direction = -1,
                             trans = "log10", begin = 0.1, end = 0.85,
                             guide = guide_colorbar(title = "Vols",
                                                    barwidth = 6)) +
      coord_fixed(1.3, xlim = c(-170, 145), ylim = c(-55, 75)) +
      theme_void(base_size = 12) +
      theme(plot.title = element_text(face = "bold", color = "white"),
            plot.background = element_rect(fill = "#0d1b2a", color = NA),
            panel.background = element_rect(fill = "#0d1b2a", color = NA),
            legend.text  = element_text(color = "#c8d8e8"),
            legend.title = element_text(color = "#c8d8e8"),
            legend.position = "bottom") +
      labs(title = nom_compagnie,
           caption = "Source : OpenSky Network + OurAirports")
  }

  output$Q9MapA <- renderPlot({
    req(q9_routes_all())
    make_map(q9_routes_all(), input$q9_compagnie_a)
  })

  output$Q9MapB <- renderPlot({
    req(q9_routes_all())
    make_map(q9_routes_all(), input$q9_compagnie_b)
  })

  # =================================================
  # Q9 - GRAPHE 3 : concentration sur l'aeroport pivot
  # =================================================

  output$Q9Concentration <- renderPlotly({
    req(q9_mouvements_all(), q9_df())
    df    <- q9_df()
    movts <- q9_mouvements_all()

    hub_top <- movts %>%
      count(name, modele, airport, sort = TRUE) %>%
      group_by(name, modele) %>%
      slice_max(n, n = 1, with_ties = FALSE) %>%
      ungroup() %>%
      rename(hub = airport)

    flights_cie <- df %>%
      mutate(icao = str_to_upper(str_trim(substr(callsign, 1, 3)))) %>%
      inner_join(airlines_clean %>% select(icao, name, modele), by = "icao") %>%
      filter(!is.na(origin), !is.na(destination), origin != destination)

    concentration <- flights_cie %>%
      inner_join(hub_top %>% select(name, hub), by = "name") %>%
      group_by(name, modele, hub) %>%
      summarise(
        vols_total = n(),
        vols_hub   = sum(origin == hub | destination == hub),
        .groups    = "drop"
      ) %>%
      mutate(part_hub = vols_hub / vols_total * 100)

    if (!is.null(airports_coord) && "municipality" %in% names(airports_coord)) {
      hub_names <- airports_coord %>%
        select(icao_code, municipality) %>%
        mutate(municipality = str_remove(municipality, " ?[(,].*$"))
      concentration <- concentration %>%
        left_join(hub_names, by = c("hub" = "icao_code")) %>%
        mutate(hub_label = if_else(is.na(municipality), hub,
                                   paste0(hub, " (", municipality, ")")))
    } else {
      concentration <- concentration %>% mutate(hub_label = hub)
    }

    concentration <- concentration %>%
      mutate(name = fct_reorder(name, part_hub))

    p <- ggplot(concentration,
                aes(x = name, y = part_hub, fill = modele,
                    text = paste0(name, "<br>",
                                  hub, "<br>",
                                  round(part_hub, 1), " %"))) +
      geom_col(width = 0.7) +
      geom_hline(yintercept = c(25, 50, 75),
                 linetype = "dotted", color = "grey60", linewidth = 0.4) +
      coord_flip() +
      scale_fill_manual(values = c(
        "Low-cost"    = "#fdae61",
        "Major reseau" = "#4C78A8",
        "Cargo"       = "#5e4fa2"
      )) +
      scale_y_continuous(limits = c(0, 105),
                         labels = function(x) paste0(x, " %")) +
      labs(title = "Concentration du reseau sur l'aeroport principal",
           subtitle = "Part des vols touchant l'aeroport le plus frequente",
           x = NULL, y = "Part des vols (%)", fill = "Modele",
           caption = "Source : OpenSky Network + OurAirports") +
      theme_minimal(base_size = 12) +
      theme(plot.title = element_text(face = "bold"),
            panel.grid.major.y = element_blank(),
            legend.position = "bottom")

    ggplotly(p, tooltip = "text")
  })

  # =================================================
  # Q9 - GRAPHE 4 : courbe de concentration cumulee
  # =================================================

  output$Q9Courbe <- renderPlotly({
    req(q9_mouvements_all())

    cie_a <- input$q9_compagnie_a
    cie_b <- input$q9_compagnie_b

    courbe_data <- q9_mouvements_all() %>%
      filter(name %in% c(cie_a, cie_b)) %>%
      count(name, airport) %>%
      group_by(name) %>%
      arrange(desc(n), .by_group = TRUE) %>%
      mutate(
        rang         = row_number(),
        part_cumulee = cumsum(n) / sum(n) * 100
      ) %>%
      ungroup() %>%
      filter(rang <= 25)

    req(nrow(courbe_data) > 0)

    p <- ggplot(courbe_data,
                aes(x = rang, y = part_cumulee, color = name,
                    group = name,
                    text = paste0(name, " | rang ", rang,
                                  " | ", round(part_cumulee, 1), " %"))) +
      geom_line(linewidth = 1.2) +
      geom_point(size = 2) +
      scale_x_continuous(breaks = seq(0, 25, 5)) +
      scale_y_continuous(labels = function(x) paste0(x, " %")) +
      scale_color_manual(values = c("#4aa3ff", "#ff6b6b")) +
      labs(title = paste0("Courbe de concentration : ", cie_a, " vs ", cie_b),
           subtitle = "Plus la courbe monte vite, plus le reseau est centralise en etoile",
           x = "Rang de l'aeroport (du + au - frequente)",
           y = "Part cumulee des mouvements (%)",
           color = "Compagnie",
           caption = "Un mouvement = un depart ou une arrivee — Source : OpenSky Network + OurAirports") +
      theme_minimal(base_size = 12) +
      theme(plot.title = element_text(face = "bold"),
            legend.position = "bottom")

    ggplotly(p, tooltip = "text")
  })
}
