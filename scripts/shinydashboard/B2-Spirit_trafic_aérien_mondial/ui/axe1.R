library(shiny)
library(shinydashboard)


# --------------------------------fin intro debut page Axe 1---------------------------------------
axe1_ui<-tabItem(
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
)