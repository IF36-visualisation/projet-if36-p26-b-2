#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(shinydashboard)
library(plotly)

dashboardPage(
  
  dashboardHeader(title = "B2-Spirit : Exploration interactive du trafic aérien mondial"),
  
  dashboardSidebar(
 #---------------- definition du menu--------------   
    sidebarMenu(
   #-------- definition des onglets----------   
      menuItem(
        "Introduction",
        tabName = "intro",
        icon = icon("dashboard")
      ),
      
      menuItem(
        "Axe 1 — Le pouls du ciel",
        tabName = "Axe1",
        icon = icon("th")
      ),
      
      menuItem(
        "Axe 2 - La géographie du ciel ",
        tabName = "Axe2",
        icon = icon("th")
      ),
   menuItem(
     "Axe 3 - Les machines",
     tabName = "Axe3",
     icon = icon("th")
   ),
   menuItem(
     "Axe 4 - Les compagnies ",
     tabName = "Axe4",
     icon = icon("th")
   )
   
    )
    
  ),
#---------------------------fin side bar ; debut page principale----------------  
  dashboardBody(
    tabItems(
      
      # --------------------------page 1 : intro ------------
      tabItem(
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
      ),
      
# --------------------------------fin intro debut page Axe 1---------------------------------------
tabItem(
  tabName = "Axe1",
  
  fluidRow(
    
    box(
      title = "Axe 1 — Le pouls du ciel : dynamiques temporelles du trafic",
      width = 12,
      status = "primary",
      solidHeader = TRUE,
      
      h2("Q2 — Le trafic aérien a-t-il un rythme cardiaque ?"),
      
      p("
        Dans cette partie, nous cherchons à déterminer si le trafic aérien mondial
        suit des cycles réguliers comparables à un rythme biologique.
        L’objectif est d’identifier des variations récurrentes selon l’heure,
        le jour de la semaine ou encore la période de l’année.
      "),
      
      p("
        Pour cette analyse, nous utilisons les données de l’année 2019,
        choisie comme année de référence car elle précède la pandémie de COVID-19
        et représente donc un fonctionnement plus “normal” du trafic aérien mondial.
      ")
    ),
    
    
    # ---------------------------------------------------------
    # GRAPH 1
    # ---------------------------------------------------------
    
    box(
      title = "Hypothèse — Variation selon l’heure",
      width = 12,
      status = "warning",
      solidHeader = TRUE,
      
      p("
        Nous supposons que le trafic aérien mondial suit un cycle journalier marqué.
        L’activité devrait être faible pendant la nuit européenne puis augmenter
        progressivement au cours de la journée avec l’ouverture des grands hubs
        internationaux.
      "),
      
      p("
        Nous nous attendons également à observer un pic en fin de journée UTC,
        correspondant au chevauchement des activités aériennes entre l’Europe
        et l’Amérique du Nord.
      ")
    ),
    
    box(
      title = "Moyenne du trafic aérien par heure (UTC)",
      subtitle = "Échantillon 1% — Année 2019",
      width = 12,
      status = "info",
      solidHeader = TRUE,
      
      plotlyOutput("Moyenne_trafic_heure")
    ),
    
    box(
      title = "Analyse des résultats",
      width = 12,
      status = "success",
      solidHeader = TRUE,
      
      h4("Hypothèse validée"),
      
      p("
        Le graphique met clairement en évidence un rythme journalier du trafic aérien.
        Le nombre de vols diminue fortement entre 3h et 5h UTC, puis augmente
        progressivement à partir du matin européen.
      "),
      
      p("
        Le maximum est atteint vers 15h UTC, moment où les activités aériennes
        européennes et nord-américaines se chevauchent.
      "),
      
      p("
        Cette structure cyclique semble principalement s’expliquer par les fuseaux
        horaires et par la concentration des départs et arrivées autour des grandes
        zones économiques mondiales.
      ")
    ),
    
    
    # ---------------------------------------------------------
    # GRAPH 2
    # ---------------------------------------------------------
    
    box(
      title = "Hypothèse — Variation selon le jour de la semaine",
      width = 12,
      status = "warning",
      solidHeader = TRUE,
      
      p("
        Nous supposons que les jours ouvrés concentrent davantage de vols que
        le week-end en raison des déplacements professionnels.
      "),
      
      p("
        Nous nous attendons à observer une baisse notable le samedi,
        traditionnellement plus calme pour l’aviation d’affaires.
      ")
    ),
    
    box(
      title = "Variation du trafic aérien selon le jour de la semaine",
      width = 12,
      status = "info",
      solidHeader = TRUE,
      
      plotlyOutput("Variation_trafic_semaine")
    ),
    
    box(
      title = "Analyse des résultats",
      width = 12,
      status = "success",
      solidHeader = TRUE,
      
      h4("Hypothèse globalement validée"),
      
      p("
        Les jours ouvrés présentent effectivement les volumes de trafic les plus élevés.
        Le trafic augmente progressivement du lundi au vendredi.
      "),
      
      p("
        Une chute importante apparaît le samedi, tandis que le dimanche remonte
        légèrement sans retrouver les niveaux observés en semaine.
      "),
      
      p("
        Cette organisation hebdomadaire semble liée à l’importance des déplacements
        professionnels dans le trafic aérien mondial.
      ")
    ),
    
    
    # ---------------------------------------------------------
    # GRAPH 3
    # ---------------------------------------------------------
    
    box(
      title = "Hypothèse — Variation selon le mois de l’année",
      width = 12,
      status = "warning",
      solidHeader = TRUE,
      
      p("
        Nous supposons que le trafic aérien mondial augmente fortement durant l’été,
        notamment en juillet et août, période correspondant aux vacances scolaires
        et au tourisme international dans l’hémisphère nord.
      "),
      
      p("
        À l’inverse, nous nous attendons à un trafic plus faible durant les mois
        d’hiver, en particulier en janvier et février.
      ")
    ),
    
    box(
      title = "Variation du trafic aérien selon le mois de l’année",
      width = 12,
      status = "info",
      solidHeader = TRUE,
      
      plotlyOutput("Variation_trafic_mois")
    ),
    
    box(
      title = "Analyse des résultats",
      width = 12,
      status = "success",
      solidHeader = TRUE,
      
      h4("Hypothèse validée"),
      
      p("
        Le graphique montre une saisonnalité très marquée du trafic aérien mondial.
        Les volumes sont relativement faibles en début d’année puis augmentent
        progressivement jusqu’au pic estival de juillet-août.
      "),
      
      p("
        Une légère reprise apparaît également en décembre,
        probablement liée aux déplacements des fêtes de fin d’année.
      "),
      
      p("
        Cette saisonnalité semble principalement s’expliquer par les flux touristiques
        internationaux et les périodes de vacances scolaires.
      ")
    ),
    
    
    # ---------------------------------------------------------
    # CONCLUSION
    # ---------------------------------------------------------
    
    box(
      title = "Conclusion de l’axe",
      width = 12,
      status = "primary",
      solidHeader = TRUE,
      
      p("
        L’ensemble des analyses confirme que le trafic aérien mondial possède bien
        un véritable “rythme cardiaque”.
      "),
      
      p("
        Des cycles réguliers apparaissent à différentes échelles temporelles :
        au cours de la journée, de la semaine et de l’année.
      "),
      
      p("
        Ces dynamiques semblent principalement structurées par les fuseaux horaires,
        l’activité économique mondiale et les comportements touristiques.
      ")
    )
  )
),
#-------------------------------------------fin page 1 debut page 2----------------------------------
tabItem(
  tabName = "Axe2",
  
  fluidRow(
    
    box(
      title = "Axe 2 - La géographie du ciel : cartographier les flux",
      width = 12,
      status = "primary",
      solidHeader = TRUE,
      
    )
    
  )
),
#------------------------------------page 3--------------------
tabItem(
  tabName = "Axe3",
  
  fluidRow(
    
    box(
      title = "Axe 3 - Les machines : analyse de la flotte mondiale",
      width = 12,
      status = "primary",
      solidHeader = TRUE,
      
      
    )
    
  )
),
#-----------------------------page 4-------------------

tabItem(
  tabName = "Axe4",
  
  fluidRow(
    
    box(
      title = "Axe 4 - Les compagnies : stratégies et résilience",
      width = 12,
      status = "primary",
      solidHeader = TRUE,
      
      
    )
    
  )
)




#parenthese de fin de page ne pas toucher
    )
  )
)
