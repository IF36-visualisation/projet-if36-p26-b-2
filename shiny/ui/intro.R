# =============================================================================
# FICHIER : ui/intro.R
# =============================================================================
intro_ui <- tabItem(
  tabName = "intro",
  fluidRow(
    column(12,
           box(width = 12, status = "primary", solidHeader = TRUE,
               title = uiOutput("titre_globe"),
               withSpinner(echarts4rOutput("globe", height = "520px"), type = 8, color = "#4aa3ff"),
               fluidRow(
                 style = "margin-top:10px; padding:0 10px;",
                 column(5,
                        tags$small(style = "color:#aec6e8;",
                                   "● Taille = volume de trafic relatif", br(),
                                   "— Arcs = routes actives",             br(),
                                   "🎬 Choisir l'année dans le menu de gauche"
                        )
                 ),
                 column(7,
                        tags$div(style = "text-align:right;",
                                 lapply(names(couleurs_region), function(r) {
                                   tags$span(
                                     style = paste0("display:inline-block; margin:2px 4px; font-size:11px; color:", couleurs_region[r]),
                                     paste0("● ", r)
                                   )
                                 })
                        )
                 )
               )
           )
    )
  )
)
