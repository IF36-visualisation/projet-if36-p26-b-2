library(shiny)
library(tidyverse)
library(maps)
library(geosphere)
library(viridis)


# =================================================
# Q5 — Données préparées au chargement du module
# =================================================

continent_labels <- c(
  "AF" = "Afrique",
  "AN" = "Antarctique",
  "AS" = "Asie",
  "EU" = "Europe",
  "NA" = "Amérique du Nord",
  "OC" = "Océanie",
  "SA" = "Amérique du Sud"
)

flights_all_q5 <- bind_rows(
  read_csv("../../../data/clean/clean_COVID_19_Flightfile_2019.csv", show_col_types = FALSE) %>% mutate(annee = 2019L),
  read_csv("../../../data/clean/clean_COVID_19_Flightfile_2020.csv", show_col_types = FALSE) %>% mutate(annee = 2020L),
  read_csv("../../../data/clean/clean_COVID_19_Flightfile_2021.csv", show_col_types = FALSE) %>% mutate(annee = 2021L),
  read_csv("../../../data/clean/clean_COVID_19_Flightfile_2022.csv", show_col_types = FALSE) %>% mutate(annee = 2022L)
)

airports_q5 <- read_csv(
  "../../../data/clean/airports.csv",
  na = "",
  show_col_types = FALSE
) %>%
  select(icao_code, continent) %>%
  filter(!is.na(continent)) %>%
  distinct(icao_code, .keep_all = TRUE) %>%
  mutate(continent = recode(continent, !!!continent_labels))

flights_continent_q5 <- flights_all_q5 %>%
  left_join(airports_q5, by = c("origin" = "icao_code")) %>%
  filter(!is.na(continent)) %>%
  mutate(
    mois = month(firstseen)
  ) %>%
  group_by(annee, mois, continent) %>%
  summarise(n = n(), .groups = "drop")

base_jan2019_q5 <- flights_continent_q5 %>%
  filter(annee == 2019, mois == 1) %>%
  select(continent, base = n)

flights_normalized_q5 <- flights_continent_q5 %>%
  left_join(base_jan2019_q5, by = "continent") %>%
  filter(!is.na(base), base > 0) %>%
  mutate(
    index     = (n / base) * 100,
    date      = make_date(annee, mois, 1),
    annee_chr = as.character(annee)
  )

# =================================================

axe2_server <- function(input, output, session) {

  print("START AXE2 SERVER")

  # =================================================
  # 1. CHOIX DATASET et telechargement donnée
  # =================================================
  
  flights_selected <- reactive({
    
    switch(input$dataset_choice,
           
           data_2019 = read_csv("../../../data/clean/clean_COVID_19_Flightfile_2019.csv"),
           data_2020 = read_csv("../../../data/clean/clean_COVID_19_Flightfile_2020.csv"),
           data_2021 = read_csv("../../../data/clean/clean_COVID_19_Flightfile_2021.csv"),
           data_2022 = read_csv("../../../data/clean/clean_COVID_19_Flightfile_2022.csv"),
           data_general = read_csv("../../../data/clean/clean_COVID_19_Flightfile_entier.csv"),
    )
  })
  airports <- read_csv("../../../data/clean/airports.csv")
  
  
  # =================================================
  # 2. CORRIDORS REACTIF
  # =================================================
  
  corridors <- reactive({
    
    print("REACTIVE CORRIDORS")
    
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
  # 4. graphe
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

  # =================================================
  # GRAPHE Q5-1 — Line chart normalisé (base 100)
  # =================================================

  output$q5_line_chart <- renderPlotly({

    req(input$q5_years)

    data_plot <- flights_normalized_q5 %>%
      filter(annee_chr %in% input$q5_years)

    p <- ggplot(
      data_plot,
      aes(
        x     = date,
        y     = index,
        color = continent,
        group = continent,
        text  = paste0(
          "Continent : ", continent,
          "<br>Date : ",  format(date, "%b %Y"),
          "<br>Indice : ", round(index, 1)
        )
      )
    ) +

      geom_line(linewidth = 0.9) +

      geom_hline(
        yintercept = 100,
        linetype   = "dashed",
        color      = "gray50"
      ) +

      scale_x_date(
        date_labels = "%b %Y",
        date_breaks = "3 months"
      ) +

      scale_color_brewer(palette = "Set1") +

      labs(
        title = "Évolution du trafic aérien par continent (base 100 = jan. 2019)",
        x     = NULL,
        y     = "Indice (base 100)",
        color = "Continent"
      ) +

      theme_minimal(base_size = 12) +

      theme(
        plot.title  = element_text(face = "bold"),
        axis.text.x = element_text(angle = 45, hjust = 1)
      )

    ggplotly(p, tooltip = "text")
  })

  # =================================================
  # GRAPHE Q5-2 — Bar chart % de chute
  # =================================================

  output$q5_bar_chute <- renderPlotly({

    moy_2019 <- flights_continent_q5 %>%
      filter(annee == 2019) %>%
      group_by(continent) %>%
      summarise(moy_2019 = mean(n), .groups = "drop")

    avril_2020 <- flights_continent_q5 %>%
      filter(annee == 2020, mois == 4) %>%
      select(continent, n_avril2020 = n)

    chute <- moy_2019 %>%
      left_join(avril_2020, by = "continent") %>%
      filter(!is.na(n_avril2020)) %>%
      mutate(
        pct_chute = ((n_avril2020 - moy_2019) / moy_2019) * 100,
        continent = reorder(continent, pct_chute)
      )

    p <- ggplot(
      chute,
      aes(
        x    = continent,
        y    = pct_chute,
        text = paste0(continent, " : ", round(pct_chute, 1), "%")
      )
    ) +

      geom_col(width = 0.7, fill = "#4C78A8") +

      coord_flip() +

      labs(
        title = "Chute du trafic par continent : moyenne 2019 → avril 2020",
        x     = NULL,
        y     = "Variation (%)"
      ) +

      theme_minimal(base_size = 12) +

      theme(
        plot.title = element_text(face = "bold")
      )

    ggplotly(p, tooltip = "text")
  })

  # =================================================
  # GRAPHE Q5-3 — Bar chart couverture OpenSky
  # =================================================

  output$q5_bar_couverture <- renderPlotly({

    airports_total <- airports_q5 %>%
      count(continent, name = "Total OurAirports")

    airports_in_data <- flights_all_q5 %>%
      select(origin) %>%
      filter(!is.na(origin)) %>%
      distinct() %>%
      left_join(airports_q5, by = c("origin" = "icao_code")) %>%
      filter(!is.na(continent)) %>%
      count(continent, name = "Couverts dans nos données")

    couverture <- airports_total %>%
      left_join(airports_in_data, by = "continent") %>%
      replace_na(list(`Couverts dans nos données` = 0)) %>%
      pivot_longer(
        cols      = c(`Total OurAirports`, `Couverts dans nos données`),
        names_to  = "source",
        values_to = "nb"
      )

    p <- ggplot(
      couverture,
      aes(
        x    = continent,
        y    = nb,
        fill = source,
        text = paste0(continent, " — ", source, " : ", nb)
      )
    ) +

      geom_col(position = "dodge", width = 0.7) +

      scale_fill_manual(
        values = c(
          "Total OurAirports"         = "#4C78A8",
          "Couverts dans nos données" = "#F58518"
        )
      ) +

      scale_y_continuous(labels = scales::comma) +

      labs(
        title = "Couverture OpenSky vs réalité par continent",
        x     = NULL,
        y     = "Nombre d'aéroports",
        fill  = NULL
      ) +

      theme_minimal(base_size = 12) +

      theme(
        plot.title      = element_text(face = "bold"),
        legend.position = "bottom",
        axis.text.x     = element_text(angle = 30, hjust = 1)
      )

    ggplotly(p, tooltip = "text")
  })
}