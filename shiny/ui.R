# =============================================================================
# FICHIER : ui.R (À placer à la racine)
# =============================================================================
# Chargement des sous-fichiers UI
source("ui/intro.R", local = TRUE)
source("ui/axe1.R", local = TRUE)
source("ui/axe2.R", local = TRUE)
source("ui/axe3.R", local = TRUE)
source("ui/axe4.R", local = TRUE)

shinyUI(
  dashboardPage(
    skin = "blue",
    
    dashboardHeader(
      title = "B2-Spirit : Trafic Aérien",
      titleWidth = 300
    ),
    
    dashboardSidebar(
      width = 240,
      tags$head(tags$style(HTML(css_global))), # Injection de ton design
      br(),
      
      # --- TES CONTRÔLES GLOBAUX ---
      div(style = "padding:0 15px;", tags$label("📅 Année", style = "color:#aec6e8; font-size:13px;"), sliderInput("annee", label = NULL, min = 2019, max = 2022, value = 2019, step = 1, sep = "", width = "100%")),
      div(style = "padding:4px 15px 8px;", uiOutput("badge_covid")),
      hr(style = "border-color:#1a3a5c; margin:8px 0;"),
      
      div(style = "padding:0 15px;", tags$label("🌍 Région", style = "color:#aec6e8; font-size:13px;"), selectInput("region", label = NULL, choices = regions_disponibles, selected = "Toutes", width = "100%")),
      hr(style = "border-color:#1a3a5c; margin:8px 0;"),
      
      div(style = "padding:0 15px;", tags$label("⚙️ Globe", style = "color:#aec6e8; font-size:13px;"), checkboxInput("show_arcs", "Afficher routes", value = TRUE), checkboxInput("show_points", "Afficher aéroports", value = TRUE)),
      hr(style = "border-color:#1a3a5c; margin:8px 0;"),
      
      div(style = "padding:0 15px;", tags$label("📊 Évolution globale", style = "color:#aec6e8; font-size:13px;"), plotOutput("sparkline", height = "80px"), br(), uiOutput("resume_sidebar")),
      hr(style = "border-color:#1a3a5c; margin:15px 0;"),
      
      # --- LE MENU D'ELODIE ---
      sidebarMenu(
        menuItem("Introduction", tabName = "intro", icon = icon("globe")),
        menuItem("Axe 1 — Le pouls du ciel", tabName = "Axe1", icon = icon("chart-line")),
        menuItem("Axe 2 — La géographie", tabName = "Axe2", icon = icon("map")),
        menuItem("Axe 3 — Les machines", tabName = "Axe3", icon = icon("plane")),
        menuItem("Axe 4 — Les compagnies", tabName = "Axe4", icon = icon("building"))
      )
    ),
    
    dashboardBody(
      tabItems(
        intro_ui,
        axe1_ui,
        axe2_ui,
        axe3_ui,
        axe4_ui
      )
    )
  )
)