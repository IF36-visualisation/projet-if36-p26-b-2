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
  ),

  # =================================================
  # Q5 — Toutes les régions ont-elles subi le COVID de la même manière ?
  # =================================================

  fluidRow(

    # -----------------------------------------------
    # INTRODUCTION
    # -----------------------------------------------

    box(
      title = "Q5 — Toutes les régions ont-elles subi le COVID de la même manière ?",
      width = 12,
      status = "primary",
      solidHeader = TRUE,

      h2("Q5 — Impact régional du COVID sur le trafic aérien mondial"),

      p("
        Dans cette partie, nous cherchons à déterminer si toutes les régions du monde
        ont subi la crise COVID de la même façon en termes de trafic aérien.
      "),

      p("
        En regroupant les aéroports par continent grâce aux métadonnées OurAirports,
        nous comparerons les profils de chute et de reprise du trafic entre 2019 et 2022.
      "),

      p("
        Nous discuterons également du biais de couverture du réseau OpenSky,
        plus dense en Europe et en Amérique du Nord, et de son impact sur nos conclusions.
      ")
    ),

    # -----------------------------------------------
    # HYPOTHÈSES — H3, H4, H6, H7
    # -----------------------------------------------

    box(
      title = "Hypothèses avant analyse",
      width = 12,
      status = "warning",
      solidHeader = TRUE,

      h4("Hypothèse 1 — L'Asie a chuté en premier"),
      p("
        Nous supposons que l'Asie a été la première région à voir son trafic
        chuter, dès janvier-février 2020, avant même les autres continents,
        du fait de sa proximité avec l'épicentre initial de la pandémie.
      "),

      br(),

      h4("Hypothèse 2 — L'Europe et l'Amérique du Nord ont chuté de façon synchronisée"),
      p("
        Nous supposons que l'Europe et l'Amérique du Nord ont connu une chute simultanée
        en mars 2020, lors des premiers confinements généralisés.
      "),

      br(),

      h4("Hypothèse 3 — L'Asie a connu une reprise tardive et lente"),
      p("
        En raison des politiques zéro-COVID appliquées notamment en Chine et au Japon,
        nous supposons que l'Asie a été la dernière grande région à retrouver
        un niveau de trafic proche de 2019.
      "),

      br(),

      h4("Hypothèse 4 — L'Europe a connu une reprise en dents de scie"),
      p("
        Les vagues successives de COVID et les confinements répétés en Europe nous
        amènent à supposer une reprise irrégulière, marquée par des rebonds et des
        rechutes, contrairement à une reprise linéaire.
      ")
    ),

    # -----------------------------------------------
    # GRAPHIQUE 1 — Line chart normalisé
    # -----------------------------------------------

    box(
      title = "Évolution du trafic aérien par continent (base 100 = janvier 2019)",
      width = 12,
      status = "info",
      solidHeader = TRUE,

      fluidRow(
        column(
          width = 12,
          checkboxGroupInput(
            inputId = "q5_years",
            label = "Années à afficher :",
            choices = c("2019", "2020", "2021", "2022"),
            selected = c("2019", "2020", "2021", "2022"),
            inline = TRUE
          )
        )
      ),

      plotlyOutput("q5_line_chart", height = "450px")
    ),

    box(
      title = "Analyse des résultats — Graphique 1",
      width = 12,
      status = "success",
      solidHeader = TRUE,

      h4("Hypothèse 1: L'Asie a chuté en premier — Difficilement confirmable"),

      p("
        La granularité mensuelle de nos données ne permet pas de distinguer clairement
        une chute asiatique anticipée. Toutes les courbes semblent chuter simultanément
        autour d'avril 2020. Des données hebdomadaires auraient été nécessaires pour
        confirmer cette hypothèse.
      "),

      br(),

      h4("Hypothèse 2: L'Europe et l'Amérique du Nord ont chuté de façon synchronisée — Validée"),

      p("
        Les deux courbes chutent au même moment, autour de mars-avril 2020,
        et suivent des trajectoires très similaires lors de la descente initiale.
        Cela reflète la propagation rapide et simultanée des mesures de confinement
        dans ces deux régions.
      "),

      br(),

      h4("Hypothèse 3: L'Asie a connu une reprise tardive et lente — Validée"),

      p("
        La courbe asiatique reste en dessous de l'indice 100 jusqu'à fin 2022,
        bien après les autres continents. Cela confirme l'impact durable des
        politiques zéro-COVID appliquées notamment en Chine et au Japon.
      "),

      br(),

      h4("Hypothèse 4: L'Europe a connu une reprise en dents de scie — Partiellement validée"),

      p("
        La courbe européenne montre des fluctuations lors de la reprise en 2021,
        cohérentes avec les vagues successives de la pandémie. Cependant la reprise
        reste plus régulière qu'attendu, avec une tendance globalement croissante
        à partir de mi-2020.
      "),

      br(),

      p("
        À noter : la courbe africaine (en rouge) est extrêmement erratique et dépasse
        l'indice 200 à plusieurs reprises, ce qui est incohérent avec la réalité.
        Ce phénomène s'explique par le faible taux de couverture OpenSky sur ce continent,
        qui rend ses données peu fiables pour cette analyse.
      ")
    ),

    # -----------------------------------------------
    # HYPOTHÈSE H1
    # -----------------------------------------------

    box(
      title = "Hypothèse — Profondeur de la chute par région",
      width = 12,
      status = "warning",
      solidHeader = TRUE,

      h4("Hypothèse 5 — L'Asie et l'Europe ont subi les chutes les plus profondes"),
      p("
        Nous supposons que l'Asie et l'Europe ont enregistré les baisses
        les plus importantes en volume de trafic entre la moyenne mensuelle de 2019
        et le pic de crise d'avril 2020.
      ")
    ),

    # -----------------------------------------------
    # GRAPHIQUE 2 — Bar chart % de chute
    # -----------------------------------------------

    box(
      title = "Chute du trafic aérien au pic de crise (moyenne 2019 → avril 2020)",
      width = 12,
      status = "info",
      solidHeader = TRUE,

      plotlyOutput("q5_bar_chute", height = "400px")
    ),

    box(
      title = "Analyse des résultats — Graphique 2",
      width = 12,
      status = "success",
      solidHeader = TRUE,

      h4("Hypothèse 5: L'Asie et l'Europe ont subi les chutes les plus profondes — Invalidée"),

      p("
        Contrairement à notre hypothèse, ce sont l'Afrique et l'Amérique du Sud
        qui affichent les plus fortes baisses au pic de crise. L'Europe arrive
        en troisième position et l'Asie en quatrième.
      "),

      p("
        Cependant, ce résultat doit être interprété avec précaution. Comme démontré
        dans le graphique suivant, l'Afrique et l'Amérique du Sud sont très mal
        couvertes par le réseau OpenSky. Une forte baisse dans nos données peut
        simplement refléter une dégradation de la couverture pendant la crise,
        et non une chute réelle plus importante du trafic.
      "),

      p("
        En excluant ces deux continents du raisonnement, l'Europe présente bien
        la chute la plus profonde parmi les continents fiables, ce qui valide
        partiellement notre hypothèse initiale.
      ")
    ),

    # -----------------------------------------------
    # HYPOTHÈSE H8
    # -----------------------------------------------

    box(
      title = "Hypothèse — Biais de couverture OpenSky",
      width = 12,
      status = "warning",
      solidHeader = TRUE,

      h4("Hypothèse 6 — Les conclusions sur l'Afrique et l'Amérique du Sud sont à nuancer"),
      p("
        Le réseau OpenSky est principalement composé de récepteurs ADS-B situés en
        Europe et en Amérique du Nord. Nous supposons que cette inégalité de couverture
        se traduit par une sous-représentation de l'Afrique et de l'Amérique du Sud
        dans nos données, ce qui pourrait biaiser nos conclusions sur ces continents.
      ")
    ),

    # -----------------------------------------------
    # GRAPHIQUE 3 — Bar chart couverture
    # -----------------------------------------------

    box(
      title = "Couverture OpenSky vs réalité — Aéroports par continent",
      width = 12,
      status = "info",
      solidHeader = TRUE,

      plotlyOutput("q5_bar_couverture", height = "400px")
    ),

    box(
      title = "Analyse des résultats — Graphique 3",
      width = 12,
      status = "success",
      solidHeader = TRUE,

      h4("Hypothèse 6: Les conclusions sur l'Afrique et l'Amérique du Sud sont à nuancer — Validée"),

      p("
        Le graphique confirme un biais de couverture très marqué. L'Afrique ne couvre
        qu'environ 5% de ses aéroports réels, et l'Amérique du Sud environ 10%.
      "),

      p("
        À l'inverse, l'Europe couvre environ 60% de ses aéroports et l'Amérique du Nord
        environ 50%, ce qui rend leurs données beaucoup plus représentatives
        de la réalité du trafic aérien.
      "),

      p("
        Ce déséquilibre de couverture invalide toute conclusion directe sur l'Afrique
        et l'Amérique du Sud. Les analyses portant sur ces continents doivent
        systématiquement être nuancées par ce biais structurel du réseau OpenSky.
      ")
    ),

    # -----------------------------------------------
    # CONCLUSION
    # -----------------------------------------------

    box(
      title = "Conclusion — Q5",
      width = 12,
      status = "primary",
      solidHeader = TRUE,

      p("
        Non, toutes les régions du monde n'ont pas subi le COVID de la même manière.
        Les données révèlent des profils de chute et de reprise très différents
        selon les continents.
      "),

      p("
        L'Europe et l'Amérique du Nord ont chuté de façon synchronisée en mars-avril 2020,
        mais l'Amérique du Nord a montré une reprise plus rapide et plus régulière.
        L'Asie, malgré une chute similaire, a connu une reprise nettement plus tardive
        et plus lente, imputable aux politiques zéro-COVID maintenues jusqu'en 2022.
      "),

      p("
        Les résultats concernant l'Afrique et l'Amérique du Sud doivent être interprétés
        avec la plus grande prudence. Le faible taux de couverture du réseau OpenSky
        sur ces continents — respectivement environ 5% et 10% des aéroports réels —
        rend leurs courbes peu fiables et leurs chiffres non comparables aux autres régions.
      "),

      p("
        En conclusion, cette question illustre à la fois les inégalités mondiales
        face à la crise sanitaire et les limites structurelles d'un dataset construit
        à partir d'un réseau de capteurs inégalement réparti sur la planète.
      ")
    )
  )
)