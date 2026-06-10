library(shiny)
library(tidyverse)
library(lubridate)
library(plotly)
library(geosphere)
library(ggridges)

# =====================================================
# AXE 3 SERVER — Q7 : court, moyen et long-courrier
# =====================================================

# Niveaux et couleurs partagés par tous les graphiques
q7_niveaux <- c(
  "Court-courrier (< 1 500 km)",
  "Moyen-courrier (1 500 – 4 000 km)",
  "Long-courrier (> 4 000 km)"
)

q7_couleurs <- c("#9ecae1", "#4292c6", "#08519c")
names(q7_couleurs) <- q7_niveaux

# Liste de référence des types d'aéronefs, des régionaux aux
# gros-porteurs (la même que dans scripts/Q7_distances.R)
q7_types_reference <- c(
  "DH8D", "AT76", "CRJ9", "E75L",
  "A319", "A320", "B738", "A321",
  "B763", "A332", "A333", "B772",
  "B789", "A359", "B77W", "A388"
)

# Calcule la distance orthodromique de chaque vol et le
# catégorise (logique identique à scripts/Q7_distances.R)
q7_calculer_distances <- function(flights, airports_coord) {

  flights %>%
    filter(
      !is.na(origin), !is.na(destination),
      origin != destination
    ) %>%
    left_join(airports_coord, by = c("origin" = "icao_code")) %>%
    rename(lat_orig = latitude_deg, lon_orig = longitude_deg) %>%
    left_join(airports_coord, by = c("destination" = "icao_code")) %>%
    rename(lat_dest = latitude_deg, lon_dest = longitude_deg) %>%
    filter(
      !is.na(lat_orig), !is.na(lon_orig),
      !is.na(lat_dest), !is.na(lon_dest)
    ) %>%
    mutate(
      distance_km = distHaversine(
        cbind(lon_orig, lat_orig),
        cbind(lon_dest, lat_dest)
      ) / 1000
    ) %>%
    # Distances quasi nulles (aéroports co-localisés) et distances
    # physiquement impossibles (erreurs de codes aéroports)
    filter(distance_km >= 10, distance_km <= 15500) %>%
    mutate(
      categorie = case_when(
        distance_km < 1500 ~ q7_niveaux[1],
        distance_km < 4000 ~ q7_niveaux[2],
        TRUE               ~ q7_niveaux[3]
      ),
      categorie = factor(categorie, levels = q7_niveaux)
    )
}

axe3_server <- function(input, output, session) {

  # =================================================
  # 1. CHARGEMENT DES DONNÉES
  # =================================================

  airports_coord_q7 <- read_csv(
    "../../../data/clean/airports.csv",
    show_col_types = FALSE
  ) %>%
    filter(
      !is.na(icao_code),
      !is.na(latitude_deg),
      !is.na(longitude_deg)
    ) %>%
    distinct(icao_code, .keep_all = TRUE) %>%
    select(icao_code, latitude_deg, longitude_deg)

  q7_flights <- reactive({

    switch(input$q7_dataset_choice,
      data_2019    = read_csv("../../../data/clean/clean_COVID_19_Flightfile_2019.csv"),
      data_2020    = read_csv("../../../data/clean/clean_COVID_19_Flightfile_2020.csv"),
      data_2021    = read_csv("../../../data/clean/clean_COVID_19_Flightfile_2021.csv"),
      data_2022    = read_csv("../../../data/clean/clean_COVID_19_Flightfile_2022.csv"),
      data_general = read_csv("../../../data/clean/clean_COVID_19_Flightfile_entier.csv")
    )
  })

  q7_periode <- reactive({

    switch(input$q7_dataset_choice,
      data_2019    = "2019",
      data_2020    = "2020",
      data_2021    = "2021",
      data_2022    = "2022",
      data_general = "2019-2022"
    )
  })

  # Distances calculées une seule fois par dataset choisi
  q7_distances <- reactive({

    q7_calculer_distances(q7_flights(), airports_coord_q7)
  })

  # =================================================
  # 2. GRAPHE 1 — Histogramme des distances
  # =================================================

  output$Q7Histogramme <- renderPlotly({

    req(q7_distances())

    # En échelle log, on N'EMPILE PAS les catégories : ggplot2
    # empile après la transformation, ce qui multiplierait les
    # comptes au lieu de les additionner (hauteurs fausses dès
    # qu'un bin chevauche un seuil 1500/4000 km)
    if (isTRUE(input$q7_echelle_log)) {

      p <- ggplot(
        q7_distances(),
        aes(x = distance_km)
      ) +
        geom_histogram(
          binwidth = input$q7_binwidth,
          boundary = 0,
          fill = "#4C78A8",
          color = "white",
          linewidth = 0.1
        ) +
        scale_y_log10()

    } else {

      p <- ggplot(
        q7_distances(),
        aes(x = distance_km, fill = categorie)
      ) +
        geom_histogram(
          binwidth = input$q7_binwidth,
          boundary = 0,
          color = "white",
          linewidth = 0.1
        ) +
        scale_y_continuous(labels = scales::comma) +
        scale_fill_manual(values = q7_couleurs)
    }

    p <- p +

      geom_vline(
        xintercept = c(1500, 4000),
        linetype = "dashed",
        color = "grey30"
      ) +

      scale_x_continuous(labels = scales::comma) +

      labs(
        title = paste0("Distribution des distances de vol (",
                       q7_periode(), ")"),
        x = "Distance (km)",
        y = "Nombre de vols",
        fill = "Catégorie"
      ) +

      theme_minimal(base_size = 13) +
      theme(plot.title = element_text(face = "bold"))

    ggplotly(p)
  })

  # =================================================
  # 3. GRAPHE 2 — Ridgeline par type d'aéronef
  # =================================================

  output$Q7Ridgeline <- renderPlot({

    req(q7_distances(), length(input$q7_types) >= 2)

    # Types choisis par l'utilisateur, ordonnés comme la liste
    # de référence (des régionaux aux gros-porteurs)
    types_choisis <- q7_types_reference[
      q7_types_reference %in% input$q7_types
    ]

    donnees <- q7_distances() %>%
      filter(typecode %in% types_choisis) %>%
      mutate(typecode = factor(typecode, levels = types_choisis))

    ggplot(
      donnees,
      aes(x = distance_km, y = typecode, fill = after_stat(x))
    ) +

      geom_density_ridges_gradient(
        scale = 1.8,
        rel_min_height = 0.01,
        color = "grey30",
        linewidth = 0.3
      ) +

      scale_x_continuous(labels = scales::comma) +
      # zoom sans suppression de données
      coord_cartesian(xlim = c(0, 14000)) +
      scale_fill_viridis_c(option = "mako", direction = -1,
                           guide = "none") +

      labs(
        title = paste0(
          "Distribution des distances selon le type d'aéronef (",
          q7_periode(), ")"
        ),
        subtitle = "Des turbopropulseurs régionaux (bas) aux gros-porteurs longs-courriers (haut)",
        x = "Distance de vol (km)",
        y = "Type d'aéronef (code OACI)"
      ) +

      theme_minimal(base_size = 13) +
      theme(plot.title = element_text(face = "bold"))
  })

  # =================================================
  # 4. GRAPHE 3 — Parts vols / km / CO2
  # =================================================

  output$Q7Parts <- renderPlotly({

    req(q7_distances())

    # Facteurs indicatifs (hypothèse de travail) : décroissants avec
    # la distance pour refléter le poids du décollage sur les vols
    # courts. Du même ordre de grandeur que les facteurs publiés par
    # passager-km (DEFRA 2023, ~0,15-0,25 kg CO2e/pax-km :
    # https://www.gov.uk/government/publications/greenhouse-gas-reporting-conversion-factors-2023)
    # mais sans reprendre leurs bandes ni leur classement. Pas de
    # pondération par la capacité des appareils : la part du
    # long-courrier est sous-estimée (cf. rapport, limites Q7).
    facteurs_co2 <- c(0.25, 0.19, 0.15)
    names(facteurs_co2) <- q7_niveaux

    parts <- q7_distances() %>%
      mutate(facteur = facteurs_co2[as.character(categorie)]) %>%
      group_by(categorie) %>%
      summarise(
        vols = n(),
        km   = sum(distance_km),
        co2  = sum(distance_km * facteur),
        .groups = "drop"
      ) %>%
      mutate(
        `Part des vols`         = vols / sum(vols) * 100,
        `Part des km parcourus` = km / sum(km) * 100,
        `Part du CO2 estimé`    = co2 / sum(co2) * 100
      ) %>%
      pivot_longer(
        cols = starts_with("Part"),
        names_to = "indicateur",
        values_to = "pct"
      ) %>%
      mutate(indicateur = factor(indicateur, levels = c(
        "Part des vols", "Part des km parcourus", "Part du CO2 estimé"
      )))

    p <- ggplot(
      parts,
      aes(x = categorie, y = pct, fill = indicateur,
          text = paste0(indicateur, " : ", round(pct, 1), "%"))
    ) +

      geom_col(position = position_dodge(width = 0.8), width = 0.7) +

      scale_fill_brewer(palette = "Blues") +
      scale_x_discrete(labels = function(x) str_wrap(x, width = 18)) +

      labs(
        title = paste0(
          "Vols, kilomètres parcourus et CO2 estimé par catégorie (",
          q7_periode(), ")"
        ),
        x = NULL,
        y = "Part (%)",
        fill = NULL
      ) +

      theme_minimal(base_size = 13) +
      theme(plot.title = element_text(face = "bold"))

    ggplotly(p, tooltip = "text")
  })

  # =================================================
  # 5. GRAPHE 4 — Évolution des catégories 2019-2022
  # =================================================

  # Toujours le dataset complet, quel que soit le choix utilisateur
  q7_evolution_data <- reactive({

    flights_entier <- read_csv(
      "../../../data/clean/clean_COVID_19_Flightfile_entier.csv"
    )

    q7_calculer_distances(flights_entier, airports_coord_q7) %>%
      mutate(mois = floor_date(as.Date(day), "month")) %>%
      count(mois, categorie) %>%
      mutate(
        annee = year(mois),
        mois_calendaire = month(mois)
      ) %>%
      # base 100 : MÊME MOIS de 2019, pour ne pas confondre la
      # saisonnalité (été plus chargé) avec la reprise post-COVID
      group_by(categorie, mois_calendaire) %>%
      mutate(
        base_2019 = n[annee == 2019][1],
        indice = n / base_2019 * 100
      ) %>%
      ungroup()
  })

  output$Q7Evolution <- renderPlotly({

    req(q7_evolution_data())

    p <- ggplot(
      q7_evolution_data(),
      aes(x = mois, y = indice, color = categorie)
    ) +

      geom_hline(yintercept = 100, linetype = "dashed",
                 color = "grey50") +
      geom_line(linewidth = 1.1) +

      scale_color_manual(values = q7_couleurs) +
      scale_x_date(date_breaks = "6 months", date_labels = "%b %Y") +

      labs(
        title = "Évolution mensuelle des vols par catégorie de distance (2019-2022)",
        x = NULL,
        y = "Indice (100 = même mois de 2019)",
        color = "Catégorie"
      ) +

      theme_minimal(base_size = 13) +
      theme(plot.title = element_text(face = "bold"))

    ggplotly(p)
  })
}
