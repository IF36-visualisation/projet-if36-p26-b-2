library(shiny)
library(shinydashboard)
library(plotly)

options(shiny.autoreload = TRUE)

# =====================================================
# Working directory
# =====================================================
# Pas de setwd : runApp() place déjà le working directory dans le
# dossier de l'application, le chemin en dur ne marchait que sur un
# seul poste.

# =====================================================
# Chargement des pages UI
# =====================================================

source("ui/intro.R", local = TRUE)
source("ui/axe1.R", local = TRUE)
source("ui/axe2.R", local = TRUE)
source("ui/axe3.R", local = TRUE)
source("ui/axe4.R", local = TRUE)

# =====================================================
# UI
# =====================================================

shinyUI(
  
  dashboardPage(
    
    dashboardHeader(
      title = "B2-Spirit : Exploration interactive du trafic aérien mondial"
    ),
    
    dashboardSidebar(
      
      sidebarMenu(
        
        menuItem(
          "Introduction",
          tabName = "intro",
          icon = icon("dashboard")
        ),
        
        menuItem(
          "Axe 1 — Le pouls du ciel",
          tabName = "Axe1",
          icon = icon("chart-line")
        ),
        
        menuItem(
          "Axe 2 - La géographie du ciel",
          tabName = "Axe2",
          icon = icon("globe")
        ),
        
        menuItem(
          "Axe 3 - Les machines",
          tabName = "Axe3",
          icon = icon("plane")
        ),
        
        menuItem(
          "Axe 4 - Les compagnies",
          tabName = "Axe4",
          icon = icon("building")
        )
      )
    ),
    
    dashboardBody(
      
      tabItems( # les page dans l'odre issue d'autre fichier
        
        intro_ui,
        
        axe1_ui,
        
        axe2_ui,
        
        axe3_ui,
        
        axe4_ui
        
      )
    )
  )
)