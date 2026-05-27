#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(shinydashboard)
library(dplyr)
library(ggplot2)
library(plotly)


#------------------préparation-----------------------

setwd("C:/Users/elodie/OneDrive/Bureau/sn2/IF36/projet_if36_2/projet-if36-p26-b-2")
flights_19 <- read_csv("data/clean/clean_COVID_19_Flightfile_2022.csv")

Q2 <- flights_19 %>%
  mutate(
    firstseen = ymd_hms(firstseen, tz = "UTC"),
    annee = year(firstseen),
    mois = month(firstseen),
    jour = day(firstseen),
    heure = hour(firstseen)
  )


#-----------------------------serveur--------------------
# Define server logic required to draw a histogram
function(input, output, session) {
  
  #---------------------------------Ax1 Q2------------------------------
    #-----------------graphe 1 ---------------------------
  output$Moyenne_trafic_heure <- renderPlotly({
    
    hour_day <- Q2 %>%
      group_by(jour, heure) %>%
      summarise(n = n(), .groups = "drop")
    
    mean_hour <- hour_day %>%
      group_by(heure) %>%
      summarise(mean_flights = mean(n), .groups = "drop")
    
    p<-ggplot(mean_hour, aes(x = heure, y = mean_flights)) +
      geom_line(color = "#08519c", linewidth = 1) +
      geom_point(color = "#08519c", size = 2) +
      coord_cartesian(ylim = c(250, 700)) +
      labs(
        title = "Moyenne du trafic aérien par heure (UTC)",
        subtitle = "Échantillon 1% — Année 2019",
        x = "Heure (UTC)",
        y = "Nombre moyen de vols"
      ) +
      theme_minimal(base_size = 13) +
      theme(plot.title = element_text(face = "bold"))
    print("fini")
    
    ggplotly(p)
    
  })
  
  #---------------------------graphe 2-------------------------------
  
  output$Variation_trafic_semaine <- renderPlotly({
    
    daily <- Q2 %>%
      filter(!is.na(annee), !is.na(mois), !is.na(jour)) %>%
      mutate(
        date = make_date(annee, mois, jour),
        jour_semaine = wday(date, label = TRUE, week_start = 1)
      ) %>%
      group_by(date, jour_semaine) %>%
      summarise(n = n(), .groups = "drop")
    
    dow_mean <- daily %>%
      group_by(jour_semaine) %>%
      summarise(mean_flights = mean(n), .groups = "drop")
    
    p<- ggplot(dow_mean, aes(x = jour_semaine, y = mean_flights)) +
      geom_col(fill = "#4C78A8", width = 0.7) +
      geom_text(aes(label = round(mean_flights, 0)),
                vjust = -0.3, size = 3.5) +
      coord_cartesian(ylim = c(600, 1100)) +
      labs(
        title = "Trafic aérien moyen selon le jour de la semaine",
        subtitle = "Nombre moyen de vols par jour — 2019",
        x = NULL,
        y = "Nombre moyen de vols"
      ) +
      theme_minimal(base_size = 12) +
      theme(
        plot.title = element_text(face = "bold", size = 14),
        panel.grid.major.x = element_blank()
      )
    ggplotly(p)
    
  })
  
  #---------------------------------------- graphe 3----------------------------
  
  output$Variation_trafic_mois <- renderPlotly({
    
    month_counts <- Q2 %>%
      filter(!is.na(mois)) %>%
      group_by(mois) %>%
      summarise(n = n(), .groups = "drop") %>%
      mutate(mois = factor(mois, levels = 1:12))
    
    p<-ggplot(month_counts, aes(x = mois, y = n)) +
      geom_col(fill = "#4C78A8") +
      scale_y_continuous(labels = scales::comma) +
      labs(
        title = "Nombre de vols par mois (2019)",
        x = "Mois",
        y = "Nombre de vols"
      ) +
      theme_minimal(base_size = 12) +
      theme(plot.title = element_text(face = "bold"))
    ggplotly(p)
    
  })
  
}
