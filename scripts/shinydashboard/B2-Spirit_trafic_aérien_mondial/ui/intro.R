library(shiny)
library(shinydashboard)



# --------------------------page 1 : intro ------------
intro_ui<- tabItem(
  tabName = "intro",
  
  fluidRow(
    
    box(
      title = "Présentation du projet",
      width = 12,
      status = "primary",
      solidHeader = TRUE,
      
      h1("B2-Spirit : Exploration interactive du trafic aérien mondial"),
      
      br(),
      
      h3("Introduction"),
      
      p("
        Ce projet a pour objectif d’explorer et de visualiser de manière
        interactive les données du trafic aérien mondial à l’aide de Shiny
        et shinydashboard.
      "),
      
      p("
        L’application permet d’analyser différentes caractéristiques des vols,
        des compagnies aériennes et des aéroports grâce à des visualisations
        dynamiques et interactives.
      "),
      
      br(),
      
      h3("Données"),
      
      p("
        Notre projet repose sur l’assemblage de plusieurs sources de données
        de référence dans le domaine de l’aviation ouverte.
      "),
      
      p("
        Ces différentes bases ont été croisées afin de construire une vision
        riche et multidimensionnelle du trafic aérien mondial.
      "),
      
      br(),
      
      h3("Traitement des données"),
      
      p("
        Le dataset original étant extrêmement volumineux — plusieurs millions
        de lignes — nous avons dû mettre en place une stratégie de réduction
        des données afin de garantir des temps de calcul raisonnables et une
        compatibilité avec GitHub.
      "),
      
      p("
        Nous avons dans un premier temps créé un dataset par année contenant
        environ 1 % des données originales.
      "),
      
      p("
        Ensuite, nous avons fusionné ces datasets annuels afin de construire
        une base de données unique regroupant l’ensemble des années étudiées.
      "),
      
      p("
        Cette base finale a de nouveau été réduite à 30 % de sa taille afin
        d’optimiser les performances de l’application tout en conservant une
        représentativité satisfaisante des données.
      ")
    ),
    
    box(
      title = "Axes d’étude du projet",
      width = 12,
      status = "info",
      solidHeader = TRUE,
      
      h2("Plan d’analyse"),
      br(),
      
      h4("Axe 1 — Le pouls du ciel : dynamiques temporelles du trafic"),
      
      p("
    Cet axe vise à analyser l’évolution du trafic aérien mondial au fil du temps
    afin d’identifier les grandes tendances, les ruptures et les rythmes
    caractéristiques du secteur aérien.
  "),
      
      tags$ul(
        tags$li(
          strong("Q1 : "),
          "Comment le volume de vols a-t-il évolué entre 2019 et 2022 ?"
        ),
        tags$li(
          strong("Q2 : "),
          "Le trafic aérien présente-t-il des cycles saisonniers ou hebdomadaires ?"
        )
      ),
      
      br(),
      
      h4("Axe 2 — La géographie du ciel : cartographier les flux"),
      
      p("
    Cette partie du projet explore l’organisation spatiale du trafic aérien
    mondial afin de mettre en évidence les principales routes aériennes,
    les hubs majeurs et les disparités géographiques.
  "),
      
      tags$ul(
        tags$li(
          strong("Q3 : "),
          "Quels sont les corridors aériens les plus empruntés et comment structurent-ils le réseau mondial ?"
        ),
        tags$li(
          strong("Q4 : "),
          "Quels hubs dominent le réseau aérien mondial et quelle est leur zone d’influence ?"
        ),
        tags$li(
          strong("Q5 : "),
          "Toutes les régions du monde ont-elles subi la crise du COVID-19 de la même manière ?"
        ),
      ),
      
      br(),
      
      h4("Axe 3 — Les machines : analyse de la flotte mondiale"),
      
      p("
    Cet axe s’intéresse aux appareils utilisés dans le trafic mondial et à
    leur répartition selon les types de vols et les périodes étudiées.
  "),
      
      tags$ul(
        tags$li(
          strong("Q6 : "),
          "Quels modèles d’avions dominent le trafic aérien mondial et la crise sanitaire a-t-elle modifié leur répartition ?"
        ),
        tags$li(
          strong("Q7 : "),
          "Peut-on distinguer différentes catégories de vols (court, moyen et long-courrier) et comment se répartissent-elles ?"
        )
      ),
      
      br(),
      
      h4("Axe 4 — Les compagnies : stratégies et résilience"),
      
      p("
    Enfin, cette dernière partie analyse les compagnies aériennes afin
    d’identifier leurs stratégies d’adaptation face aux perturbations du
    trafic mondial.
  "),
      
      tags$ul(
        tags$li(
          strong("Q8 : "),
          "Quelles compagnies aériennes ont le mieux résisté à la crise et quelles tendances stratégiques émergent ?"
        ),
        tags$li(
          strong("Q9 : "),
          "Le réseau aérien de chaque compagnie reflète-t-il une stratégie spécifique ?"
        )
      )
    ),
    
    
    
  )
)
