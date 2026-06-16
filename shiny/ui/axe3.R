library(shiny)
library(shinydashboard)
library(plotly)

# =====================================================
# AXE 3 UI  -  Q6 (flotte) + Q7 (distances)
# =====================================================

axe3_ui <- tabItem(
  tabName = "Axe3",

  # =========================================================================
  # Q6 - Quels avions dominent le ciel ?
  # =========================================================================

  fluidRow(

    box(
      title = "Axe 3 - Les machines : analyse de la flotte mondiale",
      width = 12, status = "primary", solidHeader = TRUE,

      h2("Q6 - Quels avions dominent le ciel ?"),

      p("Nous cherchons a identifier les types d'aeronefs les plus utilises
        dans le trafic aerien mondial en 2019, et a comprendre comment la
        flotte se repartit entre les differents constructeurs."),

      p("24,6 % des vols ne disposent pas de typecode renseigne et ont ete
        retires de l'analyse.")
    ),

    # --- Q6 Graphique 1 ---------------------------------------------------

    box(title = "Hypothese - Types d'aeronefs dominants",
        width = 12, status = "warning", solidHeader = TRUE,
        p("Nous supposons que quelques modeles tres repandus (A320, B737)
          concentrent une grande partie du trafic mondial.")),

    box(title = "Top 15 des types d'aeronefs les plus frequents (2019)",
        width = 12, status = "info", solidHeader = TRUE,
        plotlyOutput("q6_top15", height = "450px")),

    box(title = "Analyse des resultats", width = 12, status = "success", solidHeader = TRUE,
        h4("Hypothese validee"),
        p("Le Boeing 737-800 (B738) arrive en tete (~43 000 vols), suivi de
          l'Airbus A320 (~38 500 vols). Ces deux modeles refletent leur
          popularite sur les vols court et moyen-courriers.")),

    # --- Q6 Graphique 2 ---------------------------------------------------

    box(title = "Hypothese - Duopole Airbus / Boeing",
        width = 12, status = "warning", solidHeader = TRUE,
        p("Nous supposons qu'Airbus et Boeing se partagent plus de 60 % du
          trafic mondial.")),

    box(title = "Repartition des vols par famille de constructeur (2019)",
        width = 12, status = "info", solidHeader = TRUE,
        plotlyOutput("q6_familles", height = "400px")),

    box(title = "Analyse des resultats", width = 12, status = "success", solidHeader = TRUE,
        h4("Hypothese validee - duopole confirme a pres de 70 %"),
        p("Boeing 35,3 % et Airbus 34,7 %, soit ensemble pres de 70 % du
          trafic total. Embraer (8,1 %) et Bombardier CRJ (4,9 %) couvrent
          les vols regionaux.")),

    # --- Q6 Graphique 3 ---------------------------------------------------

    box(title = "Hypothese - Saisonnalite identique pour tous les constructeurs",
        width = 12, status = "warning", solidHeader = TRUE,
        p("Nous supposons que toutes les familles suivent la meme
          saisonnalite avec un pic estival en juillet-aout.")),

    box(title = "Evolution mensuelle des vols par famille d'aeronef (2019)",
        width = 12, status = "info", solidHeader = TRUE,
        plotlyOutput("q6_mensuel", height = "400px")),

    box(title = "Analyse des resultats", width = 12, status = "success", solidHeader = TRUE,
        h4("Hypothese validee - saisonnalite universelle"),
        p("Boeing et Airbus suivent des courbes tres similaires avec un
          creux en fevrier et un pic en juillet-aout. Les constructeurs
          regionaux suivent la meme tendance avec une amplitude plus faible.")),

    box(title = "Conclusion Q6", width = 12, status = "primary", solidHeader = TRUE,
        p("La flotte mondiale est structuree autour du duopole Airbus/Boeing
          (70 %), portes par leurs monocouloirs (A320, B737). La saisonnalite
          estivale est universelle et confirme la dependance au tourisme."))
  ),

  # =========================================================================
  # Q7 - Court, moyen ou long-courrier ?
  # =========================================================================

  fluidRow(

    box(
      title = "Axe 3 - Les machines : analyse de la flotte mondiale",
      width = 12, status = "primary", solidHeader = TRUE,

      h2("Q7 - Court, moyen ou long-courrier : comment se repartit le trafic ?"),

      p("Dans cette partie, nous calculons la distance orthodromique
        (formule de Haversine) entre l'aeroport d'origine et l'aeroport
        de destination de chaque vol, grace aux coordonnees GPS de la
        base OurAirports."),

      p("Cette distance permet de classer chaque vol : court-courrier
        (moins de 1 500 km), moyen-courrier (1 500 a 4 000 km) et
        long-courrier (plus de 4 000 km)."),

      p("Seuls les vols dont l'origine et la destination sont renseignees
        et retrouvees dans OurAirports sont exploitables, soit environ
        37 % du dataset.")
    ),

    # --- Q7 Hypotheses ----------------------------------------------------

    box(
      title = "Hypotheses avant analyse",
      width = 12, status = "warning", solidHeader = TRUE,

      h4("Hypothese 1 - Le court-courrier domine largement le volume de vols"),
      p("La majorite des vols sont des liaisons courtes : domestiques,
        navettes regionales et rotations rapides autour des hubs."),
      br(),
      h4("Hypothese 2 - La distance de vol reflete le type d'appareil"),
      p("Les turbopropulseurs doivent voler court, les monocouloirs sur
        le court et moyen-courrier, et les gros-porteurs sur le long-courrier."),
      br(),
      h4("Hypothese 3 - Le long-courrier domine les kilometres et le CO2"),
      p("Bien que minoritaires en nombre, les vols longs-courriers
        devraient concentrer l'essentiel des kilometres parcourus."),
      br(),
      h4("Hypothese 4 - Le COVID a frappe le long-courrier plus durement"),
      p("Les fermetures de frontieres internationales ont du penaliser
        davantage le long-courrier que le trafic domestique.")
    ),

    # --- Q7 Graphique 1 ---------------------------------------------------

    box(title = "Distribution des distances de vol",
        width = 12, status = "info", solidHeader = TRUE,
        plotlyOutput("Q7Histogramme", height = "450px")),

    # --- Q7 Parametres ----------------------------------------------------

    box(
      title = "Parametres de visualisation",
      width = 12, status = "warning", solidHeader = TRUE,

      fluidRow(
        column(width = 5,
          radioButtons("q7_dataset_choice", "Choisir le dataset",
            choices = c("2019"="data_2019","2020"="data_2020",
                        "2021"="data_2021","2022"="data_2022",
                        "General"="data_general"),
            selected = "data_2019", inline = TRUE)),
        column(width = 4,
          sliderInput("q7_binwidth",
            "Largeur des barres de l'histogramme (km)",
            min = 100, max = 1000, value = 250, step = 50)),
        column(width = 3,
          checkboxInput("q7_echelle_log",
            "Echelle verticale logarithmique", value = FALSE))
      ),
      fluidRow(
        column(width = 12,
          selectizeInput("q7_types",
            "Types d'aeronefs affisches dans le graphique par type",
            choices = c("DH8D","AT76","CRJ9","E75L",
                        "A319","A320","B738","A321",
                        "B763","A332","A333","B772",
                        "B789","A359","B77W","A388"),
            selected = c("DH8D","AT76","CRJ9","E75L",
                         "A319","A320","B738","A321",
                         "B763","A332","A333","B772",
                         "B789","A359","B77W","A388"),
            multiple = TRUE))
      )
    ),

    # --- Q7 Graphique 2 ---------------------------------------------------

    box(title = "Distribution des distances selon le type d'aeronef",
        width = 12, status = "info", solidHeader = TRUE,
        plotOutput("Q7Ridgeline", height = "550px")),

    # --- Q7 Graphique 3 ---------------------------------------------------

    box(title = "Vols, kilometres parcourus et CO2 estime par categorie",
        width = 12, status = "info", solidHeader = TRUE,
        plotlyOutput("Q7Parts", height = "450px")),

    # --- Q7 Graphique 4 ---------------------------------------------------

    box(title = "Evolution des trois categories pendant la crise COVID (2019-2022)",
        width = 12, status = "info", solidHeader = TRUE,
        p("Ce graphique utilise le dataset complet 2019-2022,
          independamment de l'annee selectionnee ci-dessus.
          Indice base 100 = niveau moyen de 2019 pour chaque categorie."),
        plotlyOutput("Q7Evolution", height = "450px")),

    # --- Q7 Analyse -------------------------------------------------------

    box(
      title = "Analyse des resultats",
      width = 12, status = "success", solidHeader = TRUE,

      h4("Hypothese 1 : Le court-courrier domine - Validee"),
      p("64,9 % des vols exploitables font moins de 1 500 km. La distance
        mediane d'un vol est de 1 040 km."),
      br(),
      h4("Hypothese 2 : La distance reflete l'appareil - Validee"),
      p("La hierarchie est parfaitement respectee : distance mediane de
        321 km pour l'ATR 72 a 7 400 km pour le Boeing 787-9."),
      br(),
      h4("Hypothese 3 : Le long-courrier domine km et CO2 - Non concluante"),
      p("Le long-courrier ne represente que 9,1 % des vols mais 37,8 % des
        kilometres. Pour le CO2 estime, les trois categories pesent des
        ordres de grandeur comparables (~30-35 %)."),
      br(),
      h4("Hypothese 4 : Le COVID a frappe le long-courrier plus durement - Validee"),
      p("Le court-courrier repasse au-dessus de 2019 des le printemps 2021,
        tandis que le long-courrier ne retrouve pas durablement son niveau
        avant fin 2022.")
    ),

    box(title = "Conclusion Q7", width = 12, status = "primary", solidHeader = TRUE,
        p("Un ciel domine en volume par les vols courts, mais dont les
          kilometres se jouent sur une minorite de vols longs. La crise
          COVID a confirme cette asymetrie : plus le vol est long, plus
          la chute a ete profonde et la reprise lente."))
  )
)
