library(shiny)
library(tidyverse)
library(maps)
library(viridis)


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