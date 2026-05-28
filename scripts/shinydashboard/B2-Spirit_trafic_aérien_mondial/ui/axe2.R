library(shiny)
library(shinydashboard)
library(plotly)

# =====================================================
# AXE 2 UI
# =====================================================

axe2_ui <- tabItem(
  
  tabName = "Axe2",
  
  fluidRow(
    
    # =================================================
    # INTRODUCTION
    # =================================================
    
    box(
      title = "Axe 2 — La géographie du ciel",
      width = 12,
      status = "primary",
      solidHeader = TRUE,
      
      h2("Q3 — Quels sont les corridors aériens les plus empruntés ?"),
      
      p("
        Cette partie du projet cherche à visualiser les principaux flux
        du trafic aérien mondial.
      "),
      
      p("
        En reliant les aéroports les plus connectés par des arcs géographiques,
        nous pouvons observer la structure du réseau aérien mondial ainsi que
        les grands corridors internationaux.
      "),
      
      p("
        Les zones les plus denses devraient révéler les grands axes du trafic :
        Amérique du Nord, Europe occidentale et Asie de l’Est.
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
      
      h4("Hypothèse 1 — Forte densité aux États-Unis et en Europe"),
      
      p("
    Les zones les plus denses devraient révéler les grands axes du trafic :
        Amérique du Nord, Europe occidentale et dans une moindre mesure Asie de l’Est.
  "),
      
      
      br(),
      
      h4("Hypothèse 2 — Un trafic très inégal selon les régions du monde"),
      
      p("
    Nous supposons que certaines régions du globe, notamment l’Afrique,
    l’Asie centrale ou certaines zones d’Amérique du Sud, apparaîtront
    beaucoup moins connectées dans les données.
  "),
      
      p("
    Cette différence pourrait refléter à la fois les inégalités du trafic
    aérien mondial et d’éventuels biais dans les données disponibles.
  "),
      
      br(),
      
      h4("Hypothèse 3 — Les longs trajets dominent le trafic mondial"),
      
      p("
    Nous supposons que les corridors les plus fréquentés correspondent
    principalement à des vols long-courriers reliant les grands centres
    économiques internationaux.
  "),
      
      p("
    Les trajets régionaux plus courts devraient théoriquement apparaître
    moins dominants.
  "),
      
      br(),
      
      h4("Hypothèse 4 — Les corridors dominants restent stables selon les années"),
      
      p("
    Nous supposons que, malgré les variations du volume total de vols,
    les principaux corridors mondiaux restent globalement les mêmes
    d’une année à l’autre.
  ")
    ),
    
    
    # =================================================
    # CARTE
    # =================================================
    
    box(
      title = "Carte des corridors aériens mondiaux",
      width = 12,
      status = "info",
      solidHeader = TRUE,
      
      plotOutput(
        outputId = "Axe2Q3Map",
        #height = "700px"
      )
    ),
  ),
    # =================================================
    # PARAMÈTRES
  # =================================================
  fluidRow(
    
    box(
      title = "Paramètres de visualisation",
      width = 12,
      status = "warning",
      solidHeader = TRUE,
      
      fluidRow(
        
        # =========================================
        # Slider
        # =========================================
        
        column(
          width = 4,
          
          sliderInput(
            inputId = "nb_corridors",
            label = "Nombre de corridors affichés",
            min = 10,
            max = 1000,
            value = 300,
            step = 10
          )
        ),
        
        
        # =========================================
        # Checkbox
        # =========================================
        
        column(
          width = 3,
          
          checkboxInput(
            inputId = "corridor_bidirectionnel",
            label = "Fusionner aller / retour",
            value = TRUE
          )
        ),
        
        
        # =========================================
        # Dataset
        # =========================================
        
        column(
          width = 5,
          
          radioButtons(
            inputId = "dataset_choice",
            label = "Choisir le dataset",
            
            choices = c(
              "2019" = "data_2019",
              "2020" = "data_2020",
              "2021" = "data_2021",
              "2022" = "data_2022",
              "Général" = "data_general"
            ),
            
            selected = "data_2022",
            
            inline = TRUE
          )
        )
      )
    )
  ),
  
  # =================================================
  # ANALYSE DES RÉSULTATS
  # =================================================
  
  box(
    title = "Analyse des résultats",
    width = 12,
    status = "success",
    solidHeader = TRUE,
    
    h4("Hypothèse 1: Forte densité aux États-Unis et en Europe — Globalement validée"),
    
    p("
    La carte confirme une concentration extrêmement forte du trafic
    aérien aux États-Unis.
  "),
    
    p("
    mais Le réseau domestique américain et beaucoup plus dense que
    le réseau européen, avec de nombreux corridors régionaux très actifs.
  "),
    
    p("
    Ce phénomène semble lié à la taille du territoire américain,
    à la dépendance au transport aérien intérieur et au grand nombre
    d’aéroports secondaires connectés.
  "),
    
    br(),
    
    
    br(),
    
    h4("Hypothèse 2: Un trafic très inégal selon les régions du monde — Validée"),
    
    p("
    Une grande partie du globe apparaît très peu connectée dans les données.
  "),
    
    p("
    L’Afrique, certaines zones d’Asie centrale et d’Amérique du Sud
    présentent relativement peu de corridors majeurs.
  "),
    
    p("
    Cette différence semble provenir à la fois des inégalités réelles
    du trafic mondial et probablement de biais de couverture dans le dataset.
  "),
    p("
    en effet, ce dataset est tourné vers les pays occidentaux 
    (plus de capteurs aux États-Unis et en Europe que dans les autres régions) 
    de plus 
    pour pouvoir utiliser correctement le dataset, j'ai dû en utiliser qu'1%
    réduisant les chances des courriers plus faibles d'apparaître,
    enfin j'ai dû retirer de nombreuses lignes dues à des valeurs NA,
    On peut supposer que les régions avec moin de capteur ont plus de valeur NA.
    exaspérant encore plus les bias
  "),
    
    br(),
    
    h4("Hypothèse 3: Les longs trajets dominent le trafic mondial — Invalidée"),
    
    p("
    Contrairement à ce que nous attendions, les corridors les plus utilisés
    ne sont pas majoritairement des vols long-courriers.
  "),
    
    p("
    De nombreux trajets relativement courts ou moyen-courriers dominent
    fortement le classement.
  "),
    
    p("
    Cela semble s’expliquer par la fréquence très élevée des vols régionaux
    autour des grands hubs économiques.
  "),
    p("
    les routes les plus fréquentées sont souvent des liaisons
    régionales très spécifiques entre grandes métropoles proches ou
    difficilement reliées autrement.
  "),
    p("
    cela est particulièrement visibles lorsque le nombre de corridors affichés
    reste faible (ex : top 100 ou top 200).
  "),
    
    
    br(),
    
    h4("Hypothèse 4: Les corridors dominants restent stables selon les années — Invalidée"),
    
    p("
    Le classement des principaux corridors évolue sensiblement selon les années.
  "),
    
    p("
    Certains axes majeurs disparaissent temporairement tandis que d’autres
    deviennent beaucoup plus visibles.
  "),
    
    p("
    Les années COVID montrent particulièrement bien ces changements,
    avec une forte réorganisation des flux aériens mondiaux.
  "),
    p("
    nous ne savons pas trop d'où vient ce phénomène, mais une partie de l'explication
    Peut-être un effet de mode mais aussi être dû au covid.
    en effet, pendant le Covid, les routes ont été interdites et de manière générale les voyages ont été 
    Décourage.
  ")
  )
)