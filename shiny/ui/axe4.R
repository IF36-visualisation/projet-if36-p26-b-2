library(shiny)
library(shinydashboard)
library(plotly)

# =====================================================
# AXE 4 UI  -  Q8 (compagnies) + Q9 (reseaux)
# =====================================================

q9_compagnies <- c(
  "Air France", "Ryanair", "Lufthansa", "easyJet",
  "British Airways", "Vueling", "Wizz Air", "Turkish Airlines",
  "Southwest Airlines", "Delta Air Lines", "American Airlines",
  "United Airlines", "FedEx", "UPS Airlines"
)

axe4_ui <- tabItem(
  tabName = "Axe4",

  # =========================================================================
  # Q8 - Quelles compagnies ont le mieux resiste ?
  # =========================================================================

  fluidRow(

    box(
      title = "Axe 4 - Les compagnies : strategies et resilience",
      width = 12, status = "primary", solidHeader = TRUE,

      h2("Q8 - Quelles compagnies ont le mieux resiste a la crise COVID ?"),

      p("Dans cette partie, nous comparons les trajectoires des principales
        compagnies aeriennes mondiales durant la crise COVID.
        Les compagnies sont identifiees via les trois premiers caracteres
        du callsign (code OACI de l'operateur)."),

      p("Nous cherchons a determiner si le modele economique - cargo,
        low-cost ou major - a joue un role dans la resistance et la
        vitesse de reprise de chaque compagnie.")
    ),

    # --- Q8 Graphique 1 ---------------------------------------------------

    box(title = "Hypothese avant analyse", width = 12, status = "warning", solidHeader = TRUE,
        h4("Hypothese 1 - Le cargo a mieux resiste a la crise"),
        p("FedEx et UPS transportant des marchandises, ils n'ont pas ete
          soumis aux memes restrictions. Nous supposons que leur trafic
          a peu chute en 2020.")),

    box(
      title = "Evolution du trafic par compagnie (base 100 = janvier 2019)",
      width = 12, status = "info", solidHeader = TRUE,

      fluidRow(
        column(width = 12,
          checkboxGroupInput("q8_years", "Annees a afficher :",
            choices = c("2019","2020","2021","2022"),
            selected = c("2019","2020","2021","2022"),
            inline = TRUE))),

      plotlyOutput("q8_line_chart", height = "500px")
    ),

    box(title = "Analyse des resultats - Graphique 1",
        width = 12, status = "success", solidHeader = TRUE,
        h4("Hypothese 1 : Le cargo a mieux resiste - Validee"),
        p("Les courbes de FedEx et UPS restent proches de l'indice 100
          tout au long de la periode, contrairement aux compagnies passagers
          qui s'effondrent en avril 2020."),
        p("La chute d'avril 2020 est visible pour toutes les compagnies
          passagers, mais l'amplitude varie sensiblement.")),

    # --- Q8 Graphique 2 ---------------------------------------------------

    box(title = "Hypothese avant analyse", width = 12, status = "warning", solidHeader = TRUE,
        h4("Hypothese 2 - Toutes les compagnies passagers ont chute de facon similaire"),
        p("Les confinements generalises ont cloue tous les avions passagers
          au sol de la meme facon au pic de la crise.")),

    box(title = "Chute du trafic au pic de crise (moyenne 2019 vs avril 2020)",
        width = 12, status = "info", solidHeader = TRUE,
        plotlyOutput("q8_bar_chute", height = "450px")),

    box(title = "Analyse des resultats - Graphique 2",
        width = 12, status = "success", solidHeader = TRUE,
        h4("Hypothese 2 : Chute similaire - Invalidee"),
        p("L'amplitude de la chute varie fortement : de -50 % pour Southwest
          Airlines a -95 % pour easyJet. La geographie des routes et la
          dependance au trafic international ont joue un role differenciant."),
        p("FedEx et UPS confirment la resistance du cargo avec des chutes
          inferieures a 10 %.")),

    # --- Q8 Graphique 3 ---------------------------------------------------

    box(title = "Hypothese avant analyse", width = 12, status = "warning", solidHeader = TRUE,
        h4("Hypothese 3 - Les low-cost ont rebondi plus vite que les majors"),
        p("Grace a leur modele economique flexible, Ryanair et easyJet
          devraient retrouver leur niveau de 2019 plus rapidement
          qu'Air France ou Lufthansa.")),

    box(title = "Niveau de recuperation par compagnie (indice fin 2021 vs 2019)",
        width = 12, status = "info", solidHeader = TRUE,
        plotlyOutput("q8_bar_reprise", height = "450px")),

    box(title = "Analyse des resultats - Graphique 3",
        width = 12, status = "success", solidHeader = TRUE,
        h4("Hypothese 3 : Low-cost plus rapides - Invalidee"),
        p("Les resultats sont tres heterogenes. Certes Southwest (~135) et
          Ryanair (~110) ont bien recupere, mais easyJet (~48) et Vueling
          (~75) se trouvent parmi les moins redresses."),
        p("UPS Airlines (~165) confirme la resilience exceptionnelle du
          cargo grace a l'explosion du e-commerce.")),

    box(title = "Conclusion - Q8", width = 12, status = "primary", solidHeader = TRUE,
        p("Le facteur le plus determinant n'est pas le modele economique
          low-cost vs major, mais la nature de l'activite : cargo ou passagers."),
        p("Parmi les compagnies passagers, la reprise suit la geographie :
          les compagnies dependantes du trafic international long-courrier
          ont recupere bien plus lentement que celles tournees vers le
          trafic domestique ou regional."))
  ),

  # =========================================================================
  # Q9 - Le reseau de chaque compagnie raconte-t-il une strategie ?
  # =========================================================================

  fluidRow(

    box(
      title = "Axe 4 - Les compagnies : strategies et resilience",
      width = 12, status = "primary", solidHeader = TRUE,

      h2("Q9 - Le reseau de chaque compagnie raconte-t-il une strategie differente ?"),

      p("Le reseau de routes d'une compagnie est la traduction geographique
        de son modele economique. Nous dessinons la carte de chaque
        compagnie et mesurons sa concentration autour de son aeroport principal."),

      p("Les compagnies sont identifiees par les trois premiers caracteres
        du callsign, comme pour la Q8.")
    ),

    # --- Q9 Hypotheses ----------------------------------------------------

    box(
      title = "Hypotheses avant analyse",
      width = 12, status = "warning", solidHeader = TRUE,

      h4("Hypothese 1 - Les majors organisent leur reseau en etoile autour d'un hub"),
      p("Air France autour de Paris-CDG, Lufthansa autour de Francfort :
        la carte devrait montrer une etoile ou presque toutes les routes
        passent par le hub national."),
      br(),
      h4("Hypothese 2 - Les low-cost maillent le territoire en point-a-point"),
      p("Ryanair ou Southwest devraient afficher une toile decentralisee
        reliant directement des dizaines de villes entre elles."),
      br(),
      h4("Hypothese 3 - Le cargo s'organise autour d'un super-hub de tri"),
      p("FedEx (Memphis) et UPS (Louisville) reposent sur un modele de
        tri centralise : leur reseau devrait etre encore plus concentre
        que celui des majors."),
      br(),
      h4("Hypothese 4 - La concentration du reseau suit le modele economique"),
      p("La part des vols touchant l'aeroport principal devrait separer
        nettement les trois familles de modeles economiques.")
    ),

    # --- Q9 Parametres ----------------------------------------------------

    box(
      title = "Comparateur de reseaux - parametres",
      width = 12, status = "warning", solidHeader = TRUE,

      fluidRow(
        column(width = 4,
          selectInput("q9_compagnie_a", "Compagnie A",
            choices = q9_compagnies, selected = "Air France")),
        column(width = 4,
          selectInput("q9_compagnie_b", "Compagnie B",
            choices = q9_compagnies, selected = "Ryanair")),
        column(width = 4,
          radioButtons("q9_dataset_choice", "Choisir le dataset",
            choices = c("2019"="data_2019","2020"="data_2020",
                        "2021"="data_2021","2022"="data_2022",
                        "General"="data_general"),
            selected = "data_2019", inline = TRUE))
      )
    ),

    # --- Q9 Cartes cote a cote --------------------------------------------

    box(title = "Reseau de la compagnie A",
        width = 6, status = "info", solidHeader = TRUE,
        plotOutput("Q9MapA", height = "420px")),

    box(title = "Reseau de la compagnie B",
        width = 6, status = "info", solidHeader = TRUE,
        plotOutput("Q9MapB", height = "420px")),

    # --- Q9 Concentration -------------------------------------------------

    box(
      title = "Part du reseau passant par l'aeroport pivot",
      width = 12, status = "info", solidHeader = TRUE,
      p("Pour chaque compagnie : part de ses vols dont le depart ou
        l'arrivee a lieu sur son aeroport le plus frequente."),
      plotlyOutput("Q9Concentration", height = "500px")
    ),

    # --- Q9 Courbe de concentration ---------------------------------------

    box(
      title = "Courbe de concentration des deux compagnies comparees",
      width = 12, status = "info", solidHeader = TRUE,
      p("Part cumulee des mouvements captee par les N premiers aeroports
        de chaque compagnie : plus la courbe grimpe vite, plus le reseau
        est centralise en etoile."),
      plotlyOutput("Q9Courbe", height = "450px")
    ),

    # --- Q9 Analyse -------------------------------------------------------

    box(
      title = "Analyse des resultats",
      width = 12, status = "success", solidHeader = TRUE,

      h4("Hypothese 1 : Les majors en etoile - Validee"),
      p("86,6 % des vols British Airways touchent Heathrow et 80,6 % des
        vols Air France touchent Paris-CDG. La carte d'Air France est une
        etoile presque parfaite."),
      br(),
      h4("Hypothese 2 : Les low-cost en point-a-point - Validee, avec exception"),
      p("Ryanair ne fait passer que 21,9 % de ses vols par Stansted et
        Southwest seulement 12,3 % par Chicago-Midway. Exception : Vueling
        (64,6 % a Barcelone) se comporte comme une major."),
      br(),
      h4("Hypothese 3 : Le cargo en super-hub - Non concluante"),
      p("UPS est bien concentree sur Louisville (40 %). Pour FedEx,
        Indianapolis (33,4 %) ressort devant Memphis en raison de la
        couverture des capteurs OpenSky."),
      br(),
      h4("Hypothese 4 : Concentration selon le modele - Globalement validee"),
      p("Gradient net : majors europeennes en tete (54-87 %), cargo au
        milieu (33-40 %), low-cost et majors americaines en bas (12-32 %).")
    ),

    box(title = "Conclusion de l'axe", width = 12, status = "primary", solidHeader = TRUE,
        p("La carte seule permet presque de deviner le modele economique.
          Etoile nationale pour les majors europeennes, toile point-a-point
          pour les low-cost, multi-hubs continentaux pour les majors
          americaines, tri centralise pour le cargo."),
        p("La part des vols touchant l'aeroport pivot est un indicateur
          simple et efficace : de 12 % (Southwest) a 87 % (British Airways)."))
  )
)
