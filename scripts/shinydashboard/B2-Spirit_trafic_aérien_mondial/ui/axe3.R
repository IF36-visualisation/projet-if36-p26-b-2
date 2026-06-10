library(shiny)
library(shinydashboard)
library(plotly)

# =====================================================
# AXE 3 UI
# =====================================================

axe3_ui <- tabItem(

  tabName = "Axe3",

  fluidRow(

    # =================================================
    # INTRODUCTION
    # =================================================

    box(
      title = "Axe 3 — Les machines : analyse de la flotte mondiale",
      width = 12,
      status = "primary",
      solidHeader = TRUE,

      h2("Q7 — Court, moyen ou long-courrier : comment se répartit le trafic ?"),

      p("
        Dans cette partie, nous calculons la distance orthodromique
        (formule de Haversine) entre l’aéroport d’origine et l’aéroport
        de destination de chaque vol, grâce aux coordonnées GPS de la
        base OurAirports.
      "),

      p("
        Cette distance permet de classer chaque vol dans l’une des trois
        catégories utilisées par l’industrie aérienne : court-courrier
        (moins de 1 500 km), moyen-courrier (1 500 à 4 000 km) et
        long-courrier (plus de 4 000 km).
      "),

      p("
        Seuls les vols dont l’origine et la destination sont renseignées
        et retrouvées dans la base OurAirports sont exploitables, soit
        environ 37 % du dataset. Cette limite est discutée dans l’analyse.
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

      h4("Hypothèse 1 — Le court-courrier domine largement le volume de vols"),

      p("
        Nous supposons que la majorité des vols sont des vols courts :
        liaisons domestiques, navettes régionales et rotations rapides
        autour des hubs.
      "),

      br(),

      h4("Hypothèse 2 — La distance de vol reflète le type d’appareil"),

      p("
        Les turbopropulseurs et jets régionaux devraient voler court,
        les monocouloirs sur le court et moyen-courrier, et les
        gros-porteurs sur le long-courrier. Si cette hiérarchie
        n’apparaissait pas, cela remettrait en cause la qualité des
        données (un A380 sur 200 km serait suspect).
      "),

      br(),

      h4("Hypothèse 3 — Le long-courrier domine les kilomètres ET le CO2"),

      p("
        Bien que minoritaires en nombre, les vols longs-courriers
        devraient concentrer l’essentiel des kilomètres parcourus,
        et donc — supposons-nous — l’essentiel des émissions de CO2.
      "),

      br(),

      h4("Hypothèse 4 — Le COVID a frappé le long-courrier plus durement"),

      p("
        Les fermetures de frontières internationales ont dû pénaliser
        davantage le long-courrier que le trafic domestique, et retarder
        sa reprise.
      ")
    ),

    # =================================================
    # GRAPH 1 — Histogramme des distances
    # =================================================

    box(
      title = "Distribution des distances de vol",
      width = 12,
      status = "info",
      solidHeader = TRUE,

      plotlyOutput("Q7Histogramme", height = "450px")
    ),

    # =================================================
    # PARAMÈTRES
    # =================================================

    box(
      title = "Paramètres de visualisation",
      width = 12,
      status = "warning",
      solidHeader = TRUE,

      fluidRow(

        column(
          width = 5,

          radioButtons(
            inputId = "q7_dataset_choice",
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
        ),

        column(
          width = 4,

          sliderInput(
            inputId = "q7_binwidth",
            label = "Largeur des barres de l’histogramme (km)",
            min = 100,
            max = 1000,
            value = 250,
            step = 50
          )
        ),

        column(
          width = 3,

          checkboxInput(
            inputId = "q7_echelle_log",
            label = "Échelle verticale logarithmique (sans empilement des catégories)",
            value = FALSE
          )
        )
      ),

      fluidRow(

        column(
          width = 12,

          selectizeInput(
            inputId = "q7_types",
            label = "Types d’aéronefs affichés dans le graphique par type",
            choices = c(
              "DH8D", "AT76", "CRJ9", "E75L",
              "A319", "A320", "B738", "A321",
              "B763", "A332", "A333", "B772",
              "B789", "A359", "B77W", "A388"
            ),
            selected = c(
              "DH8D", "AT76", "CRJ9", "E75L",
              "A319", "A320", "B738", "A321",
              "B763", "A332", "A333", "B772",
              "B789", "A359", "B77W", "A388"
            ),
            multiple = TRUE
          )
        )
      )
    ),

    # =================================================
    # GRAPH 2 — Ridgeline par type d’aéronef
    # =================================================

    box(
      title = "Distribution des distances selon le type d’aéronef",
      width = 12,
      status = "info",
      solidHeader = TRUE,

      plotOutput("Q7Ridgeline", height = "550px")
    ),

    # =================================================
    # GRAPH 3 — Parts vols / km / CO2
    # =================================================

    box(
      title = "Vols, kilomètres parcourus et CO2 estimé par catégorie",
      width = 12,
      status = "info",
      solidHeader = TRUE,

      plotlyOutput("Q7Parts", height = "450px")
    ),

    # =================================================
    # GRAPH 4 — Évolution des catégories 2019-2022
    # =================================================

    box(
      title = "Évolution des trois catégories pendant la crise COVID (2019-2022)",
      width = 12,
      status = "info",
      solidHeader = TRUE,

      p("
        Ce graphique utilise le dataset complet 2019-2022,
        indépendamment de l’année sélectionnée ci-dessus.
        Indice base 100 = niveau moyen de 2019 pour chaque catégorie.
      "),

      plotlyOutput("Q7Evolution", height = "450px")
    ),

    # =================================================
    # ANALYSE DES RÉSULTATS
    # =================================================

    box(
      title = "Analyse des résultats",
      width = 12,
      status = "success",
      solidHeader = TRUE,

      h4("Hypothèse 1 : Le court-courrier domine — Validée"),

      p("
        Sur l’année 2019, 64,9 % des vols exploitables font moins de
        1 500 km, contre 26,1 % pour le moyen-courrier et seulement
        9,1 % pour le long-courrier. La distance médiane d’un vol est
        de 1 040 km, soit un Paris-Madrid.
      "),

      br(),

      h4("Hypothèse 2 : La distance reflète l’appareil — Validée"),

      p("
        La hiérarchie des appareils est parfaitement respectée : la
        distance médiane s’échelonne de 321 km pour l’ATR 72 à environ
        7 400 km pour le Boeing 787-9, en passant par 1 331 km pour le
        B737-800. Cette cohérence valide la qualité de notre calcul de
        distance.
      "),

      p("
        On note toutefois que les gros-porteurs présentent aussi une
        petite bosse de vols courts : vols de positionnement,
        convoyages ou liaisons très denses (ex : Tokyo-Osaka en B777).
      "),

      br(),

      h4("Hypothèse 3 : Le long-courrier domine km et CO2 — Non concluante"),

      p("
        Le long-courrier ne représente que 9,1 % des vols mais bien
        37,8 % des kilomètres parcourus : la première partie de
        l’hypothèse est validée.
      "),

      p("
        Pour le CO2, notre estimation simple (distance × facteur
        indicatif par catégorie, décroissant avec la distance) donne
        le moyen-courrier (35,4 %) et le court-courrier (34,9 %) au
        coude-à-coude devant le long-courrier (29,7 %). Mais ce
        classement n’est pas robuste : sans pondération par la
        capacité des appareils — un gros-porteur emporte 3 à 5 fois
        plus de passagers qu’un appareil régional — la part du
        long-courrier est mécaniquement sous-estimée. La conclusion
        prudente est que les trois catégories pèsent des ordres de
        grandeur comparables (~30-35 %), sans classement tranchable
        avec nos données.
      "),

      br(),

      h4("Hypothèse 4 : Le COVID a frappé le long-courrier plus durement — Validée"),

      p("
        Les trois catégories s’effondrent ensemble en avril 2020
        (indice ≈ 27-38), mais leurs trajectoires de reprise divergent
        fortement : le court-courrier repasse au-dessus du niveau du
        même mois de 2019 dès le printemps 2021, tandis que le
        long-courrier ne retrouve durablement son niveau de 2019 à
        aucun moment avant la fin 2022. Les fermetures de frontières
        intercontinentales ont durablement pesé sur les vols longs.
      "),

      br(),

      h4("Limites"),

      p("
        Seuls 37 % des vols sont exploitables : origine ou destination
        manquantes (46 %), aéroports absents de la base OurAirports, ou
        vols bouclant sur le même aéroport (aviation légère). Ce
        filtrage favorise probablement les régions bien couvertes par
        les capteurs OpenSky (Europe, Amérique du Nord).
      "),

      p("
        Par ailleurs, 27 vols affichaient une distance supérieure à
        15 500 km, soit plus que le plus long vol commercial du monde :
        ces erreurs manifestes de codes aéroports ont été retirées.
        L’estimation du CO2 ne pondère ni par la capacité des appareils
        ni par le taux de remplissage : il s’agit d’ordres de grandeur.
        Enfin, la couverture du réseau OpenSky s’est densifiée entre
        début 2019 et début 2020 : les indices élevés de janvier-février
        2020 reflètent en partie cette croissance des capteurs, pas le
        trafic réel.
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
        La catégorisation court / moyen / long-courrier par distance
        orthodromique fonctionne et révèle la structure du trafic :
        un ciel dominé en volume par les vols courts, mais dont les
        kilomètres se jouent sur une minorité de vols longs — avec des
        émissions estimées étonnamment équilibrées entre les trois
        catégories, sous nos hypothèses simplificatrices.
      "),

      p("
        Cette grille de lecture s’avère aussi pertinente pour analyser
        la crise COVID : plus le vol est long, plus la chute a été
        profonde et la reprise lente.
      ")
    )
  )
)
