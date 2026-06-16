# =============================================================================
# FICHIER : server/intro_server.R
# =============================================================================

intro_server <- function(input, output, session) {
  
  # --- 1. Filtre réactif ---
  donnees_filtrees <- reactive({
    preparer_donnees(input$annee, input$region)
  })
  
  # --- 2. Widgets de la Sidebar ---
  output$badge_covid <- renderUI({
    ref <- sum(airports$vols_2019)
    cur <- sum(airports[[paste0("vols_", input$annee)]])
    pct <- round((cur - ref) / ref * 100)
    if (input$annee == 2019) {
      tags$span(class = "stat-badge stat-blue", "📊 Référence pré-COVID")
    } else if (pct < 0) {
      tags$span(class = "stat-badge stat-red", paste0("📉 ", pct, "% vs 2019"))
    } else {
      tags$span(class = "stat-badge stat-green", paste0("📈 +", pct, "% vs 2019"))
    }
  })
  
  output$titre_globe <- renderUI({
    tags$span(paste0("Trafic aérien mondial — ", input$annee))
  })
  
  output$sparkline <- renderPlot({
    df <- data.frame(
      annee = 2019:2022,
      vols  = c(sum(airports$vols_2019), sum(airports$vols_2020),
                sum(airports$vols_2021), sum(airports$vols_2022))
    )
    ggplot(df, aes(x = annee, y = vols)) +
      geom_line(color = "#2a4a6a", linewidth = 1) +
      geom_point(aes(color = (annee == input$annee)), size = 3, show.legend = FALSE) +
      scale_color_manual(values = c("TRUE" = "#ff6b35", "FALSE" = "#4aa3ff")) +
      scale_x_continuous(breaks = 2019:2022) +
      theme_void() +
      theme(plot.background = element_rect(fill = "transparent", color = NA))
  }, bg = "transparent")
  
  output$resume_sidebar <- renderUI({
    df  <- donnees_filtrees()
    tagList(
      tags$div(style = "color:#4aa3ff; font-size:16px; font-weight:700;", format(sum(df$vols), big.mark = " ")),
      tags$div(style = "color:#5a7a9a; font-size:11px;", "vols"),
      tags$div(style = "color:#4aa3ff; font-size:16px; font-weight:700; margin-top:6px;", nrow(df)),
      tags$div(style = "color:#5a7a9a; font-size:11px;", "aéroports")
    )
  })
  
  # --- 3. Le Rendu du Globe 3D ---
  output$globe <- renderEcharts4r({
    df <- donnees_filtrees()
    df$altitude <- 0
    
    if (nrow(df) > 1) {
      df$taille <- 5 + ((df$vols - min(df$vols)) / (max(df$vols) - min(df$vols) + 1)) * 15
    } else {
      df$taille <- 10
    }
    
    df$region <- factor(df$region, levels = names(couleurs_region))
    palette_dynamique <- unname(couleurs_region[levels(droplevels(df$region))])
    
    arcs_df <- data.frame(slon = numeric(), slat = numeric(), tlon = numeric(), tlat = numeric())
    
    if (input$show_arcs) {
      idx <- which(airports$code %in% df$code)
      routes_ok <- routes %>% filter(from %in% idx & to %in% idx)
      
      if (nrow(routes_ok) > 0) {
        arcs_df <- data.frame(
          slon = airports$lon[routes_ok$from], slat = airports$lat[routes_ok$from],
          tlon = airports$lon[routes_ok$to], tlat = airports$lat[routes_ok$to]
        )
      }
    }
    
    url_world <- "https://upload.wikimedia.org/wikipedia/commons/b/ba/The_earth_at_night.jpg"
    url_stars <- "https://raw.githubusercontent.com/JohnCoene/echarts4r.assets/master/inst/assets/starfield.jpg"
    
    e <- df %>%
      group_by(region) %>%
      e_charts(lon) %>%
      e_globe(
        base_texture = url_world,
        environment  = url_stars,
        displacementScale = 0.04,
        shading = "lambert",
        light = list(main = list(intensity = 2, shadow = TRUE), ambient = list(intensity = 0.8)),
        viewControl = list(autoRotate = TRUE, autoRotateSpeed = 4, distance = 180, alpha = 25)
      )
    
    if (input$show_points) {
      e <- e %>%
        e_scatter_3d(
          y = lat, z = altitude, size = taille, bind = name, 
          coord_system = "globe", blendMode = "source-over",
          itemStyle = list(opacity = 0.9, borderWidth = 0)
        ) %>%
        e_color(palette_dynamique)
    }
    
    if (input$show_arcs && nrow(arcs_df) > 0) {
      e <- e %>%
        e_data(arcs_df) %>%
        e_lines_3d(source_lon = slon, source_lat = slat, target_lon = tlon, target_lat = tlat, coord_system = "globe", effect = list(show = TRUE, period = 3.5, trailWidth = 2, trailLength = 0.25, trailOpacity = 0.8, trailColor = "#26de81"), lineStyle = list(width = 1.2, color = "#4aa3ff", opacity = 0.2, curveness = 0.25))
    }
    
    e %>% e_legend(show = TRUE, top = 10, textStyle = list(color = "#c8d8e8")) %>% e_tooltip(trigger = "item")
  })
  
  # =========================================================================
  # 4. INNOVATION : POP-UP INTERACTIF (Carte d'identité de l'aéroport)
  # =========================================================================
  observeEvent(input$globe_clicked_data, {
    
    clic <- input$globe_clicked_data
    if (is.null(clic)) return() 
    
    nom_aeroport <- clic$name 
    df_aeroport <- airports %>% filter(name == nom_aeroport)
    vol_actuel <- df_aeroport[[paste0("vols_", input$annee)]][1]
    
    showModal(
      modalDialog(
        title = tags$span(icon("plane-departure"), paste(" Fiche Renseignement :", nom_aeroport)),
        size = "m",         
        easyClose = TRUE,   
        fade = TRUE,        
        footer = modalButton("Fermer le radar"),
        
        fluidRow(
          column(12,
                 # En-tête de la modale
                 tags$div(style = "text-align: center;",
                          tags$h1(df_aeroport$code[1], style = "color: #00d8ff; font-weight: 900; margin-top: 0; letter-spacing: 2px;"),
                          tags$h4(df_aeroport$region[1], style = "color: #aec6e8;")
                 ),
                 hr(style = "border-color:#1a3a5c;"),
                 
                 # Chiffres clés (Trafic et GPS)
                 fluidRow(
                   column(6, 
                          tags$div(style = "text-align:center;",
                                   tags$p("Trafic en", input$annee, style = "color:#5a7a9a; margin-bottom:0;"),
                                   tags$h2(format(vol_actuel, big.mark = " "), style = "color:#4aa3ff; margin-top:5px;")
                          )
                   ),
                   column(6, 
                          tags$div(style = "text-align:center;",
                                   tags$p("Coordonnées GPS", style = "color:#5a7a9a; margin-bottom:0;"),
                                   tags$h3(paste(df_aeroport$lat[1], "N"), style = "color:#26de81; margin-top:5px; font-size:18px;"),
                                   tags$h3(paste(df_aeroport$lon[1], "E"), style = "color:#26de81; margin-top:0; font-size:18px;")
                          )
                   )
                 ),
                 
                 # ==========================================
                 # GRILLE DES 4 AXES (Mini-résumés)
                 # ==========================================
                 br(),
                 fluidRow(
                   # Case Axe 1 (Temporel)
                   column(6, 
                          tags$div(class = "placeholder-box", style = "padding: 5px; height: 130px; background: rgba(8,81,156,0.1); border: 1px solid #1a3a5c;",
                                   tags$b(style = "color:#4aa3ff; font-size:12px;", "📈 Chute et Reprise (Axe 1)"),
                                   plotOutput("mini_plot_axe1", height = "80px")
                          )
                   ),
                   # Case Axe 2 (Géographie)
                   column(6, 
                          tags$div(class = "placeholder-box", style = "padding: 5px; height: 130px; background: rgba(38,222,129,0.1); border: 1px solid #1a3a5c;",
                                   tags$b(style = "color:#26de81; font-size:12px;", "🗺️ Top Destinations (Axe 2)"),
                                   plotOutput("mini_plot_axe2", height = "80px")
                          )
                   )
                 ),
                 br(),
                 fluidRow(
                   # Case Axe 3 (Flotte)
                   column(6, 
                          tags$div(class = "placeholder-box", style = "padding: 5px; height: 130px; background: rgba(183, 110, 255, 0.1); border: 1px solid #1a3a5c;",
                                   tags$b(style = "color:#b76eff; font-size:12px;", "✈️ Top Avions (Axe 3)"),
                                   plotOutput("mini_plot_axe3", height = "80px")
                          )
                   ),
                   # Case Axe 4 (Compagnies)
                   column(6, 
                          tags$div(class = "placeholder-box", style = "padding: 5px; height: 130px; background: rgba(255, 170, 0, 0.1); border: 1px solid #1a3a5c;",
                                   tags$b(style = "color:#ffaa00; font-size:12px;", "🏢 Top Compagnies (Axe 4)"),
                                   plotOutput("mini_plot_axe4", height = "80px")
                          )
                   )
                 )
          )
        )
      )
    )
  })
  
  # =========================================================================
  # 5. MINI-GRAPHIQUES DU POP-UP
  # =========================================================================
  
  # --- Graphique de l'Axe 1 (Temporel) ---
  output$mini_plot_axe1 <- renderPlot({
    clic <- input$globe_clicked_data
    req(clic)
    
    df_apt <- airports %>% filter(name == clic$name)
    df_mini <- data.frame(
      annee = 2019:2022,
      vols = c(df_apt$vols_2019[1], df_apt$vols_2020[1], df_apt$vols_2021[1], df_apt$vols_2022[1])
    )
    
    ggplot(df_mini, aes(x = annee, y = vols)) +
      geom_area(fill = "#08519c", alpha = 0.3) +
      geom_line(color = "#4aa3ff", linewidth = 1.5) +
      geom_point(color = "#ffffff", size = 2) +
      geom_text(aes(label = scales::comma(vols)), vjust = -1.5, color = "#c8d8e8", size = 3) +
      scale_x_continuous(breaks = 2019:2022, labels = c("'19", "'20", "'21", "'22")) +
      scale_y_continuous(expand = expansion(mult = c(0, 0.4))) + 
      theme_void() +
      theme(
        plot.background = element_rect(fill = "transparent", color = NA),
        axis.text.x = element_text(color = "#aec6e8", size = 10, margin = margin(t = 5))
      )
  }, bg = "transparent")
  
  # --- Graphique de l'Axe 2 (Top Destinations) ---
  output$mini_plot_axe2 <- renderPlot({
    clic <- input$globe_clicked_data
    req(clic)
    
    code_apt <- airports$code[airports$name == clic$name][1]
    
    if (donnees_q6_ok) {
      df_dest <- flights_q6 %>%
        filter(origin == code_apt) %>%
        filter(!is.na(destination), destination != "NA", destination != "") %>%
        count(destination, sort = TRUE) %>%
        slice_head(n = 3) %>%
        mutate(destination = fct_reorder(destination, n))
      
      if (nrow(df_dest) > 0) {
        ggplot(df_dest, aes(x = destination, y = n)) +
          geom_col(fill = "#26de81", width = 0.6) +
          coord_flip() +
          geom_text(aes(label = scales::comma(n)), hjust = -0.2, color = "#c8d8e8", size = 3.5) +
          scale_y_continuous(expand = expansion(mult = c(0, 0.4))) +
          theme_void() +
          theme(
            plot.background = element_rect(fill = "transparent", color = NA),
            axis.text.y = element_text(color = "#c8d8e8", size = 11, face = "bold", hjust = 1, margin = margin(r = 5))
          )
      }
    }
  }, bg = "transparent")
  
  # --- Graphique de l'Axe 3 (Flotte) ---
  output$mini_plot_axe3 <- renderPlot({
    clic <- input$globe_clicked_data
    req(clic)
    
    code_apt <- airports$code[airports$name == clic$name][1]
    
    if (donnees_q6_ok) {
      df_flotte <- flights_q6 %>%
        filter(origin == code_apt | destination == code_apt) %>%
        filter(!is.na(typecode), typecode != "NA", typecode != "") %>%
        count(typecode, sort = TRUE) %>%
        slice_head(n = 3) %>%
        mutate(typecode = fct_reorder(typecode, n))
      
      if (nrow(df_flotte) > 0) {
        ggplot(df_flotte, aes(x = typecode, y = n)) +
          geom_col(fill = "#b76eff", width = 0.6) +
          coord_flip() + 
          geom_text(aes(label = scales::comma(n)), hjust = -0.2, color = "#c8d8e8", size = 3.5) +
          scale_y_continuous(expand = expansion(mult = c(0, 0.3))) +
          theme_void() +
          theme(
            plot.background = element_rect(fill = "transparent", color = NA),
            axis.text.y = element_text(color = "#c8d8e8", size = 11, face = "bold", hjust = 1, margin = margin(r = 5))
          )
      }
    }
  }, bg = "transparent")
  
  # --- Graphique de l'Axe 4 (Compagnies) ---
  output$mini_plot_axe4 <- renderPlot({
    clic <- input$globe_clicked_data
    req(clic)
    
    code_apt <- airports$code[airports$name == clic$name][1]
    
    if (donnees_q6_ok) {
      df_comp <- flights_q6 %>%
        filter(origin == code_apt | destination == code_apt)
      
      if ("callsign" %in% colnames(df_comp)) {
        df_comp <- df_comp %>%
          mutate(compagnie = substr(callsign, 1, 3)) %>%
          filter(!is.na(compagnie), compagnie != "NA", compagnie != "") %>%
          count(compagnie, sort = TRUE) %>%
          slice_head(n = 3) %>%
          mutate(compagnie = fct_reorder(compagnie, n))
        
        if (nrow(df_comp) > 0) {
          ggplot(df_comp, aes(x = compagnie, y = n)) +
            geom_col(fill = "#ffaa00", width = 0.6) +
            coord_flip() +
            geom_text(aes(label = scales::comma(n)), hjust = -0.2, color = "#c8d8e8", size = 3.5) +
            scale_y_continuous(expand = expansion(mult = c(0, 0.4))) +
            theme_void() +
            theme(
              plot.background = element_rect(fill = "transparent", color = NA),
              axis.text.y = element_text(color = "#c8d8e8", size = 11, face = "bold", hjust = 1, margin = margin(r = 5))
            )
        }
      }
    }
  }, bg = "transparent")
  
}