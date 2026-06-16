library(shiny)
library(shinydashboard)
library(plotly)
library(tidyverse)
library(lubridate)
library(geosphere)
library(ggridges)

# Donnees chargees dans global.R :
# flights_2019, flights_q1, airports_coord, flights_q6

# =====================================================
# Preparation Q6
# =====================================================

flights_clean_q6 <- flights_2019 %>%
  filter(!is.na(typecode), typecode != "NA", typecode != "")

flights_famille_q6 <- flights_clean_q6 %>%
  mutate(famille = case_when(
    str_starts(typecode, "A3") | str_starts(typecode, "A2") |
      str_starts(typecode, "A1") ~ "Airbus",
    str_starts(typecode, "B7")   ~ "Boeing",
    str_starts(typecode, "E")    ~ "Embraer",
    str_starts(typecode, "CRJ")  ~ "Bombardier CRJ",
    str_starts(typecode, "AT")   ~ "ATR",
    str_starts(typecode, "DH")   ~ "De Havilland",
    TRUE ~ "Autres"
  ))

# =====================================================
# SERVER AXE 3
# =====================================================

axe3_server <- function(input, output, session) {

  # =================================================
  # Q6 - GRAPHE 1 : Top 15 typecodes
  # =================================================

  output$q6_top15 <- renderPlotly({
    top15 <- flights_clean_q6 %>%
      count(typecode, sort = TRUE) %>%
      slice_head(n = 15) %>%
      mutate(typecode = fct_reorder(typecode, n))

    p <- ggplot(top15, aes(x = typecode, y = n, fill = n)) +
      geom_col(show.legend = FALSE) +
      coord_flip() +
      scale_fill_gradient(low = "#9ecae1", high = "#08519c") +
      scale_y_continuous(labels = scales::comma) +
      labs(title = "Top 15 des types d'aeronefs les plus frequents (2019)",
           subtitle = "Base sur 1% du dataset OpenSky",
           x = "Type d'aeronef (code OACI)", y = "Nombre de vols",
           caption = "Source : OpenSky Network COVID-19 Flight Dataset") +
      theme_minimal(base_size = 13) +
      theme(plot.title = element_text(face = "bold"),
            panel.grid.major.y = element_blank())
    ggplotly(p)
  })

  # =================================================
  # Q6 - GRAPHE 2 : Familles constructeurs
  # =================================================

  output$q6_familles <- renderPlotly({
    famille_count <- flights_famille_q6 %>%
      count(famille, sort = TRUE) %>%
      mutate(pct = n / sum(n) * 100,
             famille = fct_reorder(famille, n))

    p <- ggplot(famille_count, aes(x = famille, y = n, fill = famille)) +
      geom_col(show.legend = FALSE) +
      geom_text(aes(label = paste0(round(pct, 1), "%")),
                hjust = -0.1, size = 4) +
      coord_flip() +
      scale_y_continuous(labels = scales::comma,
                         expand = expansion(mult = c(0, 0.15))) +
      scale_fill_brewer(palette = "Set2") +
      labs(title = "Repartition des vols par famille de constructeur (2019)",
           x = "Famille d'aeronef", y = "Nombre de vols",
           caption = "Source : OpenSky Network COVID-19 Flight Dataset") +
      theme_minimal(base_size = 13) +
      theme(plot.title = element_text(face = "bold"),
            panel.grid.major.y = element_blank())
    ggplotly(p)
  })

  # =================================================
  # Q6 - GRAPHE 3 : Evolution mensuelle
  # =================================================

  output$q6_mensuel <- renderPlotly({
    flights_mensuel <- flights_famille_q6 %>%
      mutate(mois = month(as.Date(day), label = TRUE, abbr = TRUE)) %>%
      filter(famille %in% c("Airbus","Boeing","Embraer","Bombardier CRJ","ATR")) %>%
      count(mois, famille)

    p <- ggplot(flights_mensuel,
                aes(x = mois, y = n, color = famille, group = famille)) +
      geom_line(linewidth = 1.2) +
      geom_point(size = 2.5) +
      scale_color_brewer(palette = "Set1") +
      scale_y_continuous(labels = scales::comma) +
      labs(title = "Evolution mensuelle des vols par famille d'aeronef (2019)",
           x = "Mois", y = "Nombre de vols", color = "Constructeur",
           caption = "Source : OpenSky Network COVID-19 Flight Dataset") +
      theme_minimal(base_size = 13) +
      theme(plot.title = element_text(face = "bold"),
            legend.position = "bottom")
    ggplotly(p)
  })

  # =================================================
  # Q7 - Donnees reactives avec distances Haversine
  # =================================================

  flights_dist_q7 <- reactive({
    df <- switch(input$q7_dataset_choice,
      data_2019    = flights_2019,
      data_2020    = flights_2020,
      data_2021    = flights_2021,
      data_2022    = flights_2022,
      data_general = flights_q1
    )
    req(!is.null(df), !is.null(airports_coord))

    df %>%
      filter(!is.na(origin), !is.na(destination), origin != destination) %>%
      left_join(airports_coord %>% select(icao_code, latitude_deg, longitude_deg),
                by = c("origin" = "icao_code")) %>%
      rename(lat_orig = latitude_deg, lon_orig = longitude_deg) %>%
      left_join(airports_coord %>% select(icao_code, latitude_deg, longitude_deg),
                by = c("destination" = "icao_code")) %>%
      rename(lat_dest = latitude_deg, lon_dest = longitude_deg) %>%
      filter(!is.na(lat_orig), !is.na(lat_dest)) %>%
      mutate(
        distance_km = distHaversine(
          cbind(lon_orig, lat_orig),
          cbind(lon_dest, lat_dest)
        ) / 1000
      ) %>%
      filter(distance_km >= 10, distance_km <= 15500) %>%
      mutate(
        categorie = factor(case_when(
          distance_km < 1500 ~ "Court-courrier (< 1 500 km)",
          distance_km < 4000 ~ "Moyen-courrier (1 500 - 4 000 km)",
          TRUE               ~ "Long-courrier (> 4 000 km)"
        ), levels = c("Court-courrier (< 1 500 km)",
                      "Moyen-courrier (1 500 - 4 000 km)",
                      "Long-courrier (> 4 000 km)"))
      )
  })

  # =================================================
  # Q7 - GRAPHE 1 : Histogramme des distances
  # =================================================

  output$Q7Histogramme <- renderPlotly({
    req(flights_dist_q7())
    df <- flights_dist_q7()

    p <- ggplot(df, aes(x = distance_km, fill = categorie)) +
      geom_histogram(binwidth = input$q7_binwidth, boundary = 0,
                     color = "white", linewidth = 0.1) +
      geom_vline(xintercept = c(1500, 4000),
                 linetype = "dashed", color = "grey30") +
      scale_x_continuous(labels = scales::comma) +
      scale_fill_manual(values = c("#9ecae1","#4292c6","#08519c")) +
      labs(title = "Distribution des distances de vol",
           x = "Distance (km)", y = "Nombre de vols", fill = "Categorie",
           caption = "Source : OpenSky Network + OurAirports") +
      theme_minimal(base_size = 13) +
      theme(plot.title = element_text(face = "bold"),
            legend.position = "bottom")

    if (input$q7_echelle_log) p <- p + scale_y_log10(labels = scales::comma)

    ggplotly(p)
  })

  # =================================================
  # Q7 - GRAPHE 2 : Ridgeline par type d'aeronef
  # =================================================

  output$Q7Ridgeline <- renderPlot({
    req(flights_dist_q7())
    df <- flights_dist_q7()

    types_selec <- input$q7_types
    req(length(types_selec) > 0)

    flights_types <- df %>%
      filter(typecode %in% types_selec) %>%
      mutate(typecode = factor(typecode, levels = types_selec))

    req(nrow(flights_types) > 0)

    ggplot(flights_types,
           aes(x = distance_km, y = typecode, fill = after_stat(x))) +
      geom_density_ridges_gradient(scale = 1.8, rel_min_height = 0.01,
                                   color = "grey30", linewidth = 0.3) +
      scale_x_continuous(labels = scales::comma) +
      coord_cartesian(xlim = c(0, 14000)) +
      scale_fill_viridis_c(option = "mako", direction = -1, guide = "none") +
      labs(title = "Distribution des distances selon le type d'aeronef",
           x = "Distance de vol (km)", y = "Type d'aeronef (code OACI)",
           caption = "Source : OpenSky Network + OurAirports") +
      theme_minimal(base_size = 13) +
      theme(plot.title = element_text(face = "bold"))
  })

  # =================================================
  # Q7 - GRAPHE 3 : Parts vols / km / CO2
  # =================================================

  output$Q7Parts <- renderPlotly({
    req(flights_dist_q7())
    df <- flights_dist_q7()

    facteurs_co2 <- c(
      "Court-courrier (< 1 500 km)"       = 0.25,
      "Moyen-courrier (1 500 - 4 000 km)" = 0.19,
      "Long-courrier (> 4 000 km)"        = 0.15
    )

    parts <- df %>%
      mutate(facteur = facteurs_co2[as.character(categorie)]) %>%
      group_by(categorie) %>%
      summarise(vols = n(), km = sum(distance_km),
                co2 = sum(distance_km * facteur), .groups = "drop") %>%
      mutate(
        `Part des vols`         = vols / sum(vols) * 100,
        `Part des km parcourus` = km   / sum(km)   * 100,
        `Part du CO2 estime`    = co2  / sum(co2)  * 100
      ) %>%
      pivot_longer(cols = starts_with("Part"),
                   names_to = "indicateur", values_to = "pct") %>%
      mutate(indicateur = factor(indicateur,
               levels = c("Part des vols",
                          "Part des km parcourus",
                          "Part du CO2 estime")))

    p <- ggplot(parts, aes(x = categorie, y = pct, fill = indicateur)) +
      geom_col(position = position_dodge(width = 0.8), width = 0.7) +
      geom_text(aes(label = paste0(round(pct, 1), "%")),
                position = position_dodge(width = 0.8),
                vjust = -0.4, size = 3.5) +
      scale_fill_brewer(palette = "Blues") +
      scale_x_discrete(labels = function(x) str_wrap(x, width = 18)) +
      labs(title = "Vols, kilometres et CO2 estime par categorie",
           x = NULL, y = "Part (%)", fill = NULL,
           caption = "CO2 : ordre de grandeur non pondere par capacite — Source : OpenSky + OurAirports") +
      theme_minimal(base_size = 13) +
      theme(plot.title = element_text(face = "bold"),
            legend.position = "bottom",
            panel.grid.major.x = element_blank())
    ggplotly(p)
  })

  # =================================================
  # Q7 - GRAPHE 4 : Evolution COVID (dataset complet)
  # =================================================

  output$Q7Evolution <- renderPlotly({
    req(!is.null(flights_q1), !is.null(airports_coord))

    df_evo <- flights_q1 %>%
      filter(!is.na(origin), !is.na(destination), origin != destination) %>%
      left_join(airports_coord %>% select(icao_code, latitude_deg, longitude_deg),
                by = c("origin" = "icao_code")) %>%
      rename(lat_orig = latitude_deg, lon_orig = longitude_deg) %>%
      left_join(airports_coord %>% select(icao_code, latitude_deg, longitude_deg),
                by = c("destination" = "icao_code")) %>%
      rename(lat_dest = latitude_deg, lon_dest = longitude_deg) %>%
      filter(!is.na(lat_orig), !is.na(lat_dest)) %>%
      mutate(
        distance_km = distHaversine(
          cbind(lon_orig, lat_orig), cbind(lon_dest, lat_dest)
        ) / 1000
      ) %>%
      filter(distance_km >= 10, distance_km <= 15500) %>%
      mutate(
        categorie = factor(case_when(
          distance_km < 1500 ~ "Court-courrier (< 1 500 km)",
          distance_km < 4000 ~ "Moyen-courrier (1 500 - 4 000 km)",
          TRUE               ~ "Long-courrier (> 4 000 km)"
        ), levels = c("Court-courrier (< 1 500 km)",
                      "Moyen-courrier (1 500 - 4 000 km)",
                      "Long-courrier (> 4 000 km)")),
        mois = floor_date(as.Date(day), "month"),
        mois_cal = month(mois),
        annee = year(mois)
      )

    evolution <- df_evo %>%
      count(mois, mois_cal, annee, categorie) %>%
      group_by(categorie, mois_cal) %>%
      mutate(base_2019 = n[annee == 2019][1],
             indice    = n / base_2019 * 100) %>%
      ungroup()

    p <- ggplot(evolution, aes(x = mois, y = indice, color = categorie)) +
      geom_hline(yintercept = 100, linetype = "dashed", color = "grey50") +
      geom_line(linewidth = 1.1) +
      scale_color_manual(values = c("#9ecae1","#4292c6","#08519c")) +
      scale_x_date(date_breaks = "6 months", date_labels = "%b %Y") +
      labs(title = "Evolution mensuelle des vols par categorie (2019-2022)",
           subtitle = "Indice base 100 = meme mois de 2019",
           x = NULL, y = "Indice (100 = meme mois 2019)",
           color = "Categorie",
           caption = "Source : OpenSky Network + OurAirports") +
      theme_minimal(base_size = 13) +
      theme(plot.title = element_text(face = "bold"),
            legend.position = "bottom")
    ggplotly(p)
  })
}
