library(shiny)
library(shinydashboard)
library(plotly)
library(tidyverse)
library(lubridate)

# =====================================================
# Chargement des données
# =====================================================

flights_19 <- read_csv(
  "../../../data/clean/clean_COVID_19_Flightfile_2019.csv"
)

# =====================================================
# Préparation des données
# =====================================================

Q2 <- flights_19 %>%
  
  mutate(
    firstseen = ymd_hms(firstseen, tz = "UTC"),
    
    annee = year(firstseen),
    mois = month(firstseen),
    jour = day(firstseen),
    heure = hour(firstseen)
  )

# =====================================================
# SERVER AXE 1
# =====================================================

axe1_server <- function(input, output, session) {
  
  # =================================================
  # GRAPHE 1 — Trafic moyen par heure
  # =================================================
  
  output$Moyenne_trafic_heure <- renderPlotly({
    
    hour_day <- Q2 %>%
      
      group_by(jour, heure) %>%
      
      summarise(
        n = n(),
        .groups = "drop"
      )
    
    mean_hour <- hour_day %>%
      
      group_by(heure) %>%
      
      summarise(
        mean_flights = mean(n),
        .groups = "drop"
      )
    
    p <- ggplot(
      mean_hour,
      aes(
        x = heure,
        y = mean_flights
      )
    ) +
      
      geom_line(
        color = "#08519c",
        linewidth = 1
      ) +
      
      geom_point(
        color = "#08519c",
        size = 2
      ) +
      
      coord_cartesian(
        ylim = c(250, 600)
      ) +
      
      labs(
        title = "Moyenne du trafic aérien par heure (UTC)",
        subtitle = "Échantillon 1% — Année 2019",
        x = "Heure (UTC)",
        y = "Nombre moyen de vols"
      ) +
      
      theme_minimal(base_size = 13) +
      
      theme(
        plot.title = element_text(face = "bold")
      )
    
    ggplotly(p)
  })
  
  
  # =================================================
  # GRAPHE 2 — Variation selon le jour
  # =================================================
  
  output$Variation_trafic_semaine <- renderPlotly({
    
    daily <- Q2 %>%
      
      filter(
        !is.na(annee),
        !is.na(mois),
        !is.na(jour)
      ) %>%
      
      mutate(
        date = make_date(annee, mois, jour),
        
        jour_semaine = wday(
          date,
          label = TRUE,
          week_start = 1
        )
      ) %>%
      
      group_by(date, jour_semaine) %>%
      
      summarise(
        n = n(),
        .groups = "drop"
      )
    
    dow_mean <- daily %>%
      
      group_by(jour_semaine) %>%
      
      summarise(
        mean_flights = mean(n),
        .groups = "drop"
      )
    
    p <- ggplot(
      dow_mean,
      aes(
        x = jour_semaine,
        y = mean_flights
      )
    ) +
      
      geom_col(
        fill = "#4C78A8",
        width = 0.7
      ) +
      
      geom_text(
        aes(label = round(mean_flights, 0)),
        vjust = -0.3,
        size = 3.5
      ) +
      
      coord_cartesian(
        ylim = c(600, 950)
      ) +
      
      labs(
        title = "Trafic aérien moyen selon le jour de la semaine",
        subtitle = "Nombre moyen de vols par jour — 2019",
        x = NULL,
        y = "Nombre moyen de vols"
      ) +
      
      theme_minimal(base_size = 12) +
      
      theme(
        plot.title = element_text(
          face = "bold",
          size = 14
        ),
        
        panel.grid.major.x = element_blank()
      )
    
    ggplotly(p)
  })
  
  
  # =================================================
  # GRAPHE 3 — Variation selon le mois
  # =================================================
  
  output$Variation_trafic_mois <- renderPlotly({
    
    month_counts <- Q2 %>%
      
      filter(!is.na(mois)) %>%
      
      group_by(mois) %>%
      
      summarise(
        n = n(),
        .groups = "drop"
      ) %>%
      
      mutate(
        mois = factor(
          mois,
          levels = 1:12
        )
      )
    
    p <- ggplot(
      month_counts,
      aes(
        x = mois,
        y = n
      )
    ) +
      
      geom_col(
        fill = "#4C78A8"
      ) +
      
      scale_y_continuous(
        labels = scales::comma
      ) +
      
      labs(
        title = "Nombre de vols par mois (2019)",
        x = "Mois",
        y = "Nombre de vols"
      ) +
      
      theme_minimal(base_size = 12) +
      
      theme(
        plot.title = element_text(face = "bold")
      )
    
    ggplotly(p)
  })
}