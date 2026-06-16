library(shiny)
library(shinydashboard)
library(plotly)
library(tidyverse)
library(lubridate)
library(scales)

# =====================================================
# Données chargées une seule fois dans global.R
# flights_q1   = entier 2019-2022 (avec date, annee, mois_num, mois_date)
# flights_2019 = année 2019 seule (Q2, Q6)
# =====================================================

flights_all <- flights_q1    # alias lisible pour Q1
flights_19  <- flights_2019  # alias lisible pour Q2

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
  # Q1 — GRAPHE 1 : Série temporelle mensuelle 2019–2022
  # =================================================

  output$q1_serie_temporelle <- renderPlotly({

    monthly_all <- flights_all %>%
      group_by(mois_date) %>%
      summarise(n_flights = n(), .groups = "drop")

    events <- tibble(
      date  = as.Date(c("2020-03-15", "2020-12-01", "2021-07-01", "2022-06-01")),
      label = c("Confinements\nmondiaux", "Vaccins\ndéployés",
                "Reprise\npartielle", "Retour\nniveau 2019")
    )

    p <- ggplot(monthly_all, aes(x = mois_date, y = n_flights)) +
      geom_area(fill = "#08519c", alpha = 0.12) +
      geom_line(color = "#08519c", linewidth = 1.2) +
      geom_point(color = "#08519c", size = 2) +
      geom_vline(
        data = events,
        aes(xintercept = as.numeric(date)),
        linetype = "dashed", color = "#d62728", alpha = 0.7
      ) +
      scale_y_continuous(labels = comma, limits = c(0, NA)) +
      scale_x_date(date_breaks = "6 months", date_labels = "%b %Y") +
      labs(
        title   = "Volume mensuel de vols — Trafic aérien mondial 2019–2022",
        subtitle = "Effondrement COVID-19 (avril 2020) et reprise progressive",
        x       = NULL,
        y       = "Nombre de vols",
        caption = "Source : OpenSky Network COVID-19 Flight Dataset"
      ) +
      theme_minimal(base_size = 13) +
      theme(
        plot.title  = element_text(face = "bold"),
        axis.text.x = element_text(angle = 30, hjust = 1)
      )

    ggplotly(p)
  })


  # =================================================
  # Q1 — GRAPHE 2 : Superposition des courbes par année
  # =================================================

  output$q1_superposition <- renderPlotly({

    monthly_year <- flights_all %>%
      group_by(annee, mois_num) %>%
      summarise(n_flights = n(), .groups = "drop") %>%
      mutate(annee = factor(annee))

    p <- ggplot(
      monthly_year,
      aes(x = mois_num, y = n_flights, color = annee, group = annee)
    ) +
      geom_line(linewidth = 1.3) +
      geom_point(size = 2.5) +
      scale_color_manual(values = c(
        "2019" = "#2196F3",
        "2020" = "#F44336",
        "2021" = "#FF9800",
        "2022" = "#4CAF50"
      )) +
      scale_x_continuous(
        breaks = 1:12,
        labels = c("Jan","Fév","Mar","Avr","Mai","Jun",
                   "Jul","Aoû","Sep","Oct","Nov","Déc")
      ) +
      scale_y_continuous(labels = comma) +
      labs(
        title    = "Saisonnalité du trafic aérien : comparaison 2019–2022",
        subtitle = "Chaque courbe représente une année — même axe de mois",
        x        = NULL,
        y        = "Nombre de vols",
        color    = "Année",
        caption  = "Source : OpenSky Network COVID-19 Flight Dataset"
      ) +
      theme_minimal(base_size = 13) +
      theme(
        plot.title      = element_text(face = "bold"),
        legend.position = "bottom"
      )

    ggplotly(p)
  })


  # =================================================
  # Q1 — GRAPHE 3 : Indice de reprise (base 100 = 2019)
  # =================================================

  output$q1_indice_reprise <- renderPlotly({

    monthly_year <- flights_all %>%
      group_by(annee, mois_num) %>%
      summarise(n_flights = n(), .groups = "drop") %>%
      mutate(annee = factor(annee))

    base_2019 <- monthly_year %>%
      filter(annee == 2019) %>%
      select(mois_num, base = n_flights)

    reprise <- monthly_year %>%
      filter(annee != 2019) %>%
      left_join(base_2019, by = "mois_num") %>%
      mutate(indice = n_flights / base * 100)

    p <- ggplot(reprise, aes(x = mois_num, y = indice,
                              color = annee, group = annee)) +
      geom_hline(yintercept = 100, linetype = "dashed",
                 color = "gray50", linewidth = 0.8) +
      geom_ribbon(
        data = reprise %>% filter(annee == "2020"),
        aes(ymin = indice, ymax = 100),
        fill = "#F44336", alpha = 0.1, color = NA
      ) +
      geom_line(linewidth = 1.3) +
      geom_point(size = 2.5) +
      annotate("text", x = 11.8, y = 102, label = "Niveau 2019",
               hjust = 1, size = 3.5, color = "gray40") +
      scale_color_manual(values = c(
        "2020" = "#F44336",
        "2021" = "#FF9800",
        "2022" = "#4CAF50"
      )) +
      scale_x_continuous(
        breaks = 1:12,
        labels = c("Jan","Fév","Mar","Avr","Mai","Jun",
                   "Jul","Aoû","Sep","Oct","Nov","Déc")
      ) +
      scale_y_continuous(labels = function(x) paste0(x, "%")) +
      labs(
        title    = "Indice de reprise du trafic aérien (base 100 = niveau 2019)",
        subtitle = "Zone rouge = déficit par rapport à 2019 / Vert au-dessus = dépassement",
        x        = NULL,
        y        = "Indice de reprise (%)",
        color    = "Année",
        caption  = "Source : OpenSky Network COVID-19 Flight Dataset"
      ) +
      theme_minimal(base_size = 13) +
      theme(
        plot.title      = element_text(face = "bold"),
        legend.position = "bottom"
      )

    ggplotly(p)
  })


  # =================================================
  # Q2 — GRAPHE 1 : Trafic moyen par heure
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
        ylim = c(0, 950)
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