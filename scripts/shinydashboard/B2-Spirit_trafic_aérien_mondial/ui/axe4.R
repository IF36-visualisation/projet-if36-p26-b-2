library(shiny)
library(shinydashboard)
library(plotly)

# =====================================================
# AXE 4 UI
# =====================================================

# Compagnies disponibles dans le comparateur
q9_compagnies <- c(
  "Air France", "Ryanair", "Lufthansa", "easyJet",
  "British Airways", "Vueling", "Wizz Air", "Turkish Airlines",
  "Southwest Airlines", "Delta Air Lines", "American Airlines",
  "United Airlines", "FedEx", "UPS Airlines"
)

axe4_ui <- tabItem(

  tabName = "Axe4",

  fluidRow(

    # =================================================
    # INTRODUCTION
    # =================================================

    box(
      title = "Axe 4 — Les compagnies : stratégies et résilience",
      width = 12,
      status = "primary",
      solidHeader = TRUE,

      h2("Q9 — Le réseau de chaque compagnie raconte-t-il une stratégie différente ?"),

      p("
        Le réseau de routes d’une compagnie aérienne n’est pas un
        hasard : c’est la traduction géographique de son modèle
        économique. Dans cette partie, nous dessinons la carte du
        réseau de chaque compagnie et nous mesurons sa concentration
        autour de son aéroport principal.
      "),

      p("
        Les compagnies sont identifiées par les trois premiers
        caractères du callsign (code OACI de l’opérateur), comme dans
        la question 8. Le comparateur ci-dessous permet de mettre
        côte à côte les réseaux de deux compagnies au choix.
      ")
    ),

    # =================================================
    # HYPOTHÈSES
    # =================================================

    box(
      title = "Hypothèses avant analyse",
      width = 12,
      status = "warning",
      solidHeader = TRUE,

      h4("Hypothèse 1 — Les majors organisent leur réseau en étoile autour d’un hub"),

      p("
        Air France autour de Paris-CDG, Lufthansa autour de Francfort,
        British Airways autour de Heathrow : la carte de ces compagnies
        devrait montrer une étoile, où presque toutes les routes
        passent par le hub national.
      "),

      br(),

      h4("Hypothèse 2 — Les low-cost maillent le territoire en point-à-point"),

      p("
        Ryanair ou Southwest devraient au contraire afficher une toile
        décentralisée reliant directement des dizaines de villes entre
        elles, sans pivot dominant.
      "),

      br(),

      h4("Hypothèse 3 — Le cargo s’organise autour d’un super-hub de tri"),

      p("
        FedEx (Memphis) et UPS (Louisville) reposent sur un modèle de
        tri centralisé nocturne : leur réseau devrait être encore plus
        concentré que celui des majors passagers.
      "),

      br(),

      h4("Hypothèse 4 — La concentration du réseau suit le modèle économique"),

      p("
        Un indicateur simple — la part des vols touchant l’aéroport
        principal de chaque compagnie — devrait suffire à séparer
        nettement les trois familles de modèles économiques.
      ")
    ),

    # =================================================
    # PARAMÈTRES DU COMPARATEUR
    # =================================================

    box(
      title = "Comparateur de réseaux — paramètres",
      width = 12,
      status = "warning",
      solidHeader = TRUE,

      fluidRow(

        column(
          width = 4,

          selectInput(
            inputId = "q9_compagnie_a",
            label = "Compagnie A",
            choices = q9_compagnies,
            selected = "Air France"
          )
        ),

        column(
          width = 4,

          selectInput(
            inputId = "q9_compagnie_b",
            label = "Compagnie B",
            choices = q9_compagnies,
            selected = "Ryanair"
          )
        ),

        column(
          width = 4,

          radioButtons(
            inputId = "q9_dataset_choice",
            label = "Choisir le dataset",

            choices = c(
              "2019" = "data_2019",
              "2020" = "data_2020",
              "2021" = "data_2021",
              "2022" = "data_2022",
              "Général" = "data_general"
            ),

            selected = "data_2019",

            inline = TRUE
          )
        )
      )
    ),

    # =================================================
    # CARTES CÔTE À CÔTE
    # =================================================

    box(
      title = "Réseau de la compagnie A",
      width = 6,
      status = "info",
      solidHeader = TRUE,

      plotOutput("Q9MapA", height = "420px")
    ),

    box(
      title = "Réseau de la compagnie B",
      width = 6,
      status = "info",
      solidHeader = TRUE,

      plotOutput("Q9MapB", height = "420px")
    ),

    # =================================================
    # CONCENTRATION SUR L’AÉROPORT PIVOT
    # =================================================

    box(
      title = "Part du réseau passant par l’aéroport pivot",
      width = 12,
      status = "info",
      solidHeader = TRUE,

      p("
        Pour chaque compagnie : part de ses vols dont le départ ou
        l’arrivée a lieu sur son aéroport le plus fréquenté.
      "),

      plotlyOutput("Q9Concentration", height = "500px")
    ),

    # =================================================
    # COURBE DE CONCENTRATION CUMULÉE
    # =================================================

    box(
      title = "Courbe de concentration des deux compagnies comparées",
      width = 12,
      status = "info",
      solidHeader = TRUE,

      p("
        Part cumulée des mouvements (départs + arrivées) captée par
        les N premiers aéroports de chaque compagnie : plus la courbe
        grimpe vite, plus le réseau est centralisé en étoile.
      "),

      plotlyOutput("Q9Courbe", height = "450px")
    ),

    # =================================================
    # ANALYSE DES RÉSULTATS
    # =================================================

    box(
      title = "Analyse des résultats",
      width = 12,
      status = "success",
      solidHeader = TRUE,

      h4("Hypothèse 1 : Les majors en étoile — Validée"),

      p("
        Sur les données 2019, 86,6 % des vols British Airways touchent
        Heathrow et 80,6 % des vols Air France touchent Paris-CDG. La
        carte d’Air France est une étoile presque parfaite : les
        liaisons transversales évitant Paris sont rares.
      "),

      p("
        Cas particulier intéressant : le hub de Turkish Airlines
        ressort sur le code LTBW, un petit terrain voisin du nouvel
        aéroport d’Istanbul ouvert en avril 2019. Il s’agit d’un
        artefact d’attribution du dataset OpenSky (l’aéroport est
        déduit de la dernière position captée), qui confirme malgré
        tout la centralisation du réseau turc sur Istanbul (51 % des
        vols).
      "),

      br(),

      h4("Hypothèse 2 : Les low-cost en point-à-point — Validée, avec une exception"),

      p("
        Ryanair ne fait passer que 21,9 % de ses vols par son premier
        aéroport (Londres-Stansted) et Southwest seulement 12,3 %
        (Chicago-Midway) : leurs cartes montrent une toile dense sans
        centre dominant. L’exception est Vueling (64,6 % à Barcelone),
        une low-cost historiquement construite autour d’une base
        unique, qui se comporte ici comme une major.
      "),

      br(),

      h4("Hypothèse 3 : Le cargo en super-hub — Non concluante"),

      p("
        UPS est bien très concentrée sur son hub mondial de Louisville
        (40 % des vols). Pour FedEx en revanche, c’est Indianapolis
        (33,4 %) qui ressort devant le super-hub historique de
        Memphis : l’aéroport étant déduit de la dernière position
        captée (cf. Strohmeier et al., 2021), une couverture plus
        faible autour de Memphis suffit à déplacer le « premier
        aéroport » mesuré. La concentration mesurée du cargo est donc
        une borne basse : plus concentré que les low-cost dans nos
        données, sans qu’on puisse dire s’il dépasse réellement les
        majors.
      "),

      br(),

      h4("Hypothèse 4 : La concentration suit le modèle économique — Globalement validée"),

      p("
        Hors cas particuliers discutés ci-dessus (Vueling, Turkish
        Airlines), le classement fait apparaître un gradient net :
        majors européennes en tête (54 à 87 %), cargo au milieu
        (33 à 40 %), low-cost et majors américaines multi-hubs en bas
        (12 à 32 %). Deux nuances : les majors américaines (Delta,
        American, United) sont moins concentrées que les européennes
        car elles opèrent plusieurs hubs simultanément ; et la courbe
        cumulée montre que le top 3 des aéroports d’Air France capte
        plus de 50 % des mouvements, contre à peine plus de 20 % pour
        Ryanair.
      "),

      br(),

      h4("Limites"),

      p("
        L’identification par préfixe de callsign ignore les filiales
        (Hop pour Air France, Eurowings pour Lufthansa...) : le réseau
        mesuré est celui de la marque principale. Par ailleurs,
        l’échantillon à 1 % et la couverture inégale des capteurs
        OpenSky sous-représentent certaines régions (Memphis en est
        probablement un exemple), et environ la moitié des vols n’ont
        pas d’origine/destination renseignées.
      ")
    ),

    # =================================================
    # CONCLUSION
    # =================================================

    box(
      title = "Conclusion de l’axe",
      width = 12,
      status = "primary",
      solidHeader = TRUE,

      p("
        Oui, le réseau d’une compagnie raconte sa stratégie : la carte
        seule permet presque de deviner le modèle économique. Étoile
        nationale pour les majors européennes, toile point-à-point
        pour les low-cost, multi-hubs continentaux pour les majors
        américaines, tri centralisé pour le cargo.
      "),

      p("
        La part des vols touchant l’aéroport pivot s’avère un
        indicateur simple et efficace pour quantifier cette signature,
        de 12 % (Southwest) à 87 % (British Airways).
      ")
    )
  )
)
