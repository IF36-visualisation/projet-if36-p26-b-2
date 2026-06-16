library(shiny)
library(tidyverse)
library(maps)
library(geosphere)
library(viridis)
library(ggrepel)

# =====================================================
# PREPARATION Q5
# Recharge airports.csv avec na = c("") pour preserver
# "NA" (Amerique du Nord) comme chaine de caracteres.
# Par defaut readr traite "NA" comme NA (manquant).
# =====================================================

airports_q5_continent <- tryCatch({
  readr::read_csv("../data/clean/airports.csv",
                  show_col_types = FALSE,
                  na = c("")) %>%
    filter(!is.na(icao_code), !is.na(continent),
           !(continent %in% c("AN", ""))) %>%
    distinct(icao_code, .keep_all = TRUE) %>%
    select(icao_code, continent) %>%
    mutate(continent_label = dplyr::recode(continent,
      "AF" = "Afrique",
      "AS" = "Asie",
      "EU" = "Europe",
      "NA" = "Amerique du Nord",
      "SA" = "Amerique du Sud",
      "OC" = "Oceanie"
    ))
}, error = function(e) NULL)

axe2_server <- function(input, output, session) {

  # =================================================
  # 1. CHOIX DATASET
  # Donnees pre-chargees dans global.R au demarrage
  # => pas de lecture disque a chaque interaction
  # =================================================

  flights_selected <- reactive({
    switch(input$dataset_choice,
      data_2019    = flights_2019,
      data_2020    = flights_2020,
      data_2021    = flights_2021,
      data_2022    = flights_2022,
      data_general = flights_q1
    )
  })

  airports <- airports_map
  
  
  # =================================================
  # 2. CORRIDORS REACTIF
  # =================================================
  
  corridors <- reactive({

    flights_data <- flights_selected() %>%
      filter(
        !is.na(origin),
        !is.na(destination),
        origin != destination
      )
    
    # ---------------------------------------------
    # Bidirectionnel
    # ---------------------------------------------
    
    if (isTRUE(input$corridor_bidirectionnel)) {
      
      data <- flights_data %>%
        mutate(
          airport1 = pmin(origin, destination),
          airport2 = pmax(origin, destination)
        ) %>%
        count(airport1, airport2, sort = TRUE)
      
    } else {
      
      data <- flights_data %>%
        count(origin, destination, sort = TRUE) %>%
        rename(
          airport1 = origin,
          airport2 = destination
        )
    }
    
    # ---------------------------------------------
    # JOINTURE AEROPORTS
    # ---------------------------------------------
    
    data <- data %>%
      
      left_join(
        airports %>%
          select(icao_code, latitude_deg, longitude_deg),
        by = c("airport1" = "icao_code")
      ) %>%
      rename(
        latitude_1 = latitude_deg,
        longitude_1 = longitude_deg
      ) %>%
      
      left_join(
        airports %>%
          select(icao_code, latitude_deg, longitude_deg),
        by = c("airport2" = "icao_code")
      ) %>%
      rename(
        latitude_2 = latitude_deg,
        longitude_2 = longitude_deg
      ) %>%
      
      filter(
        !is.na(latitude_1),
        !is.na(longitude_1),
        !is.na(latitude_2),
        !is.na(longitude_2)
      ) %>%
      
      filter(
        !(latitude_1 == latitude_2 & longitude_1 == longitude_2)
      ) %>%
      
      arrange(desc(n)) %>%
      slice_head(n = input$nb_corridors) %>%
      arrange(n)
    
    data
  })
  
  # =================================================
  # 3. MAP
  # =================================================
  
  world <- map_data("world")
  
  # =================================================
  # Q4 - DONNEES
  # =================================================

  hub_connectivity <- reactive({
    req(!is.null(flights_2019))
    flights_2019 %>%
      filter(!is.na(origin), origin != "",
             !is.na(destination), destination != "") %>%
      group_by(origin) %>%
      summarise(
        n_destinations = n_distinct(destination),
        n_flights      = n(),
        .groups        = "drop"
      ) %>%
      arrange(desc(n_destinations))
  })

  # =================================================
  # Q4 - GRAPHE 1 : top 20 connectivite
  # =================================================

  output$q4_top20 <- renderPlotly({
    req(hub_connectivity())

    top20 <- hub_connectivity() %>%
      slice_head(n = 20) %>%
      mutate(origin = fct_reorder(origin, n_destinations))

    p <- ggplot(top20, aes(x = origin, y = n_destinations,
                           fill = n_flights,
                           text = paste0(origin,
                                         "<br>Destinations : ", n_destinations,
                                         "<br>Vols : ", scales::comma(n_flights)))) +
      geom_col() +
      coord_flip() +
      scale_fill_gradient(low = "#9ecae1", high = "#08306b",
                          labels = scales::comma,
                          name = "Nb de vols") +
      scale_y_continuous(labels = scales::comma) +
      labs(title = "Top 20 des aeroports les plus connectes (2019)",
           subtitle = "Nombre de destinations uniques desservies - Echantillon 1 %",
           x = "Aeroport (code OACI)", y = "Destinations uniques",
           caption = "Source : OpenSky Network COVID-19 Flight Dataset") +
      theme_minimal(base_size = 12) +
      theme(plot.title = element_text(face = "bold"),
            panel.grid.major.y = element_blank())

    ggplotly(p, tooltip = "text")
  })

  # =================================================
  # Q4 - GRAPHE 2 : scatter volume vs connectivite
  # =================================================

  output$q4_scatter <- renderPlotly({
    req(hub_connectivity())

    hub_scatter <- hub_connectivity() %>% filter(n_flights >= 100)
    top10       <- hub_connectivity() %>% slice_head(n = 10)

    p <- ggplot(hub_scatter,
                aes(x = n_flights, y = n_destinations,
                    text = origin)) +
      geom_point(alpha = 0.4, color = "#4C78A8", size = 2) +
      geom_point(data = top10,
                 aes(x = n_flights, y = n_destinations),
                 color = "#d62728", size = 3.5) +
      scale_x_continuous(labels = scales::comma) +
      labs(title = "Volume de trafic vs. connectivite des aeroports (2019)",
           subtitle = "Chaque point = 1 aeroport (min. 100 vols) - Top 10 en rouge",
           x = "Nombre de vols (departs)",
           y = "Nombre de destinations uniques",
           caption = "Source : OpenSky Network COVID-19 Flight Dataset") +
      theme_minimal(base_size = 12) +
      theme(plot.title = element_text(face = "bold"))

    ggplotly(p, tooltip = "text")
  })

  # =================================================
  # Q4 - GRAPHE 3 : profil geographique des hubs
  # =================================================

  output$q4_profil_geo <- renderPlot({
    req(!is.null(flights_2019), hub_connectivity())

    get_region <- function(code) {
      prefix <- str_sub(code, 1, 1)
      case_when(
        prefix == "K" ~ "Amerique du Nord (US)",
        prefix == "C" ~ "Canada",
        prefix %in% c("E") ~ "Europe du Nord",
        prefix %in% c("L") ~ "Europe du Sud / Med.",
        prefix %in% c("O") ~ "Moyen-Orient / Asie C.",
        prefix %in% c("V","W","Z","R") ~ "Asie / Pacifique",
        prefix %in% c("S","M","T") ~ "Amerique latine",
        prefix %in% c("D","F","G","H") ~ "Afrique",
        prefix %in% c("U") ~ "Russie / CEI",
        prefix %in% c("B") ~ "Chine / Taiwan",
        prefix %in% c("Y") ~ "Australie",
        TRUE ~ "Autre"
      )
    }

    top6 <- hub_connectivity() %>% slice_head(n = 6) %>% pull(origin)

    hub_dest <- flights_2019 %>%
      filter(origin %in% top6,
             !is.na(destination), destination != "") %>%
      mutate(region_dest = get_region(destination)) %>%
      count(origin, region_dest) %>%
      group_by(origin) %>%
      mutate(pct = n / sum(n) * 100) %>%
      ungroup()

    ggplot(hub_dest, aes(x = region_dest, y = pct, fill = region_dest)) +
      geom_col(show.legend = FALSE) +
      facet_wrap(~ origin, ncol = 3) +
      coord_flip() +
      scale_fill_brewer(palette = "Set3") +
      labs(title = "Profil geographique des destinations depuis les 6 principaux hubs",
           subtitle = "Repartition (%) des vols par region de destination - 2019",
           x = NULL, y = "Part des vols (%)",
           caption = "Source : OpenSky Network - Regions estimees par prefixe OACI") +
      theme_minimal(base_size = 11) +
      theme(plot.title  = element_text(face = "bold"),
            strip.text  = element_text(face = "bold", size = 11),
            axis.text.y = element_text(size = 8))
  })

  # =================================================
  # Q5 - donnees reactives (mensuel par continent)
  # =================================================

  q5_monthly_full <- reactive({
    req(!is.null(flights_q1), !is.null(airports_q5_continent))

    flights_q1 %>%
      filter(!is.na(origin)) %>%
      left_join(airports_q5_continent %>% select(icao_code, continent_label),
                by = c("origin" = "icao_code")) %>%
      filter(!is.na(continent_label)) %>%
      mutate(
        mois     = floor_date(as.Date(day), "month"),
        annee    = year(as.Date(day)),
        mois_cal = month(as.Date(day))
      ) %>%
      group_by(mois, annee, mois_cal, continent_label) %>%
      summarise(n_vols = n(), .groups = "drop")
  })

  # =================================================
  # Q5 - GRAPHE 1 : ligne base 100 = jan 2019
  # =================================================

  output$q5_line_chart <- renderPlotly({
    req(q5_monthly_full())

    base_2019 <- q5_monthly_full() %>%
      filter(annee == 2019) %>%
      group_by(continent_label, mois_cal) %>%
      summarise(base = mean(n_vols), .groups = "drop")

    donnees <- q5_monthly_full() %>%
      filter(as.character(annee) %in% input$q5_years) %>%
      left_join(base_2019, by = c("continent_label", "mois_cal")) %>%
      filter(!is.na(base), base > 0) %>%
      mutate(indice = n_vols / base * 100)

    p <- ggplot(donnees,
                aes(x = mois, y = indice, color = continent_label,
                    group = continent_label,
                    text = paste0(continent_label, "<br>",
                                  format(mois, "%b %Y"),
                                  "<br>Indice : ", round(indice, 1)))) +
      geom_hline(yintercept = 100, linetype = "dashed",
                 color = "grey60", linewidth = 0.7) +
      geom_line(linewidth = 0.9) +
      geom_point(size = 1.5) +
      scale_x_date(date_breaks = "6 months", date_labels = "%b %Y") +
      scale_color_brewer(palette = "Set1") +
      labs(title = "Evolution du trafic aérien par continent (base 100 = même mois 2019)",
           x = NULL, y = "Indice (100 = ref. 2019)",
           color = "Continent",
           caption = "Source : OpenSky Network COVID-19 Flight Dataset + OurAirports") +
      theme_minimal(base_size = 12) +
      theme(plot.title = element_text(face = "bold"),
            legend.position = "bottom")

    ggplotly(p, tooltip = "text") %>%
      layout(legend = list(orientation = "h", y = -0.2))
  })

  # =================================================
  # Q5 - GRAPHE 2 : chute au pic de crise
  # =================================================

  output$q5_bar_chute <- renderPlotly({
    req(q5_monthly_full())

    base_2019 <- q5_monthly_full() %>%
      filter(annee == 2019) %>%
      group_by(continent_label) %>%
      summarise(moy_2019 = mean(n_vols), .groups = "drop")

    avril_2020 <- q5_monthly_full() %>%
      filter(annee == 2020, mois_cal == 4) %>%
      select(continent_label, n_avril_2020 = n_vols)

    chute <- base_2019 %>%
      left_join(avril_2020, by = "continent_label") %>%
      mutate(
        n_avril_2020 = replace_na(n_avril_2020, 0),
        chute_pct    = (n_avril_2020 - moy_2019) / moy_2019 * 100,
        continent_label = fct_reorder(continent_label, chute_pct)
      )

    p <- ggplot(chute,
                aes(x = continent_label, y = chute_pct,
                    fill = chute_pct,
                    text = paste0(continent_label, "<br>",
                                  round(chute_pct, 1), " %"))) +
      geom_col(width = 0.7, show.legend = FALSE) +
      coord_flip() +
      scale_fill_gradient2(low = "#d73027", mid = "#fee090",
                           high = "#4575b4", midpoint = -50) +
      scale_y_continuous(labels = function(x) paste0(x, " %")) +
      labs(title = "Chute du trafic au pic de crise (moy. 2019 vs avril 2020)",
           x = NULL, y = "Variation (%)",
           caption = "Source : OpenSky Network COVID-19 Flight Dataset + OurAirports") +
      theme_minimal(base_size = 12) +
      theme(plot.title = element_text(face = "bold"),
            panel.grid.major.y = element_blank())

    ggplotly(p, tooltip = "text")
  })

  # =================================================
  # Q5 - GRAPHE 3 : couverture OpenSky vs realite
  # =================================================

  output$q5_bar_couverture <- renderPlotly({
    req(!is.null(airports_q5_continent), !is.null(flights_q1))

    airports_in_data <- flights_q1 %>%
      filter(!is.na(origin)) %>%
      distinct(origin) %>%
      pull(origin)

    coverage <- airports_q5_continent %>%
      mutate(in_data = icao_code %in% airports_in_data) %>%
      group_by(continent_label) %>%
      summarise(
        total    = n(),
        couverts = sum(in_data),
        .groups  = "drop"
      ) %>%
      mutate(
        pct_couverture = couverts / total * 100,
        continent_label = fct_reorder(continent_label, pct_couverture)
      ) %>%
      pivot_longer(cols = c(total, couverts),
                   names_to = "type", values_to = "n") %>%
      mutate(type = recode(type,
        "total"    = "Aeroports OurAirports (reference)",
        "couverts" = "Aeroports detectes dans OpenSky"
      ))

    p <- ggplot(coverage,
                aes(x = continent_label, y = n, fill = type,
                    text = paste0(continent_label, " — ", type,
                                  "<br>", scales::comma(n)))) +
      geom_col(position = position_dodge(width = 0.8), width = 0.7) +
      coord_flip() +
      scale_fill_manual(values = c(
        "Aeroports OurAirports (reference)"   = "#4C78A8",
        "Aeroports detectes dans OpenSky"     = "#f28e2b"
      )) +
      scale_y_continuous(labels = scales::comma) +
      labs(title = "Couverture OpenSky vs réalité — Aéroports par continent",
           x = NULL, y = "Nombre d'aéroports", fill = NULL,
           caption = "Source : OurAirports + OpenSky Network COVID-19 Flight Dataset") +
      theme_minimal(base_size = 12) +
      theme(plot.title = element_text(face = "bold"),
            panel.grid.major.y = element_blank(),
            legend.position = "bottom")

    ggplotly(p, tooltip = "text") %>%
      layout(legend = list(orientation = "h", y = -0.15))
  })

  # =================================================
  # 4. graphe Q3
  # =================================================

  output$Axe2Q3Map <- renderPlot({
    
    req(corridors())
    
    ggplot() +
      
      geom_polygon(
        data = world,
        aes(long, lat, group = group),
        fill = "aliceblue",
        color = "gray70",
        linewidth = 0.2
      ) +
      
      geom_curve(
        data = corridors(),
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
      
      scale_colour_viridis_c(
        option = "inferno",
        direction = -1,
        limits = c(0, max(corridors()$n, na.rm = TRUE))
      ) +
      
      coord_fixed(1.3) +
      theme_void() +
      
      labs(
        title = "Principaux corridors aériens mondiaux",
        subtitle = paste("Top", input$nb_corridors, "corridors"),
        colour = "Nb vols"
      )
  })
}