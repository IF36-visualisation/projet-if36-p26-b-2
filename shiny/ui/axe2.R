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

  # =========================================================================
  # Q4 - Quels hubs structurent le reseau aerien mondial ?
  # =========================================================================

  fluidRow(

    box(
      title = "Axe 2 - La geographie du ciel",
      width = 12, status = "primary", solidHeader = TRUE,

      h2("Q4 - Quels hubs structurent le reseau aerien mondial ?"),

      p("Nous cherchons a identifier les aeroports qui jouent le role de
        hubs dans le reseau aerien mondial, c'est-a-dire les noeuds qui
        concentrent le plus de connexions et structurent les flux de
        passagers a travers le globe."),

      p("Au-dela du simple classement par volume de vols, nous voulons
        comprendre la portee geographique de ces hubs : un aeroport peut
        etre tres actif tout en ne desservant que des destinations
        regionales, tandis qu'un autre peut avoir un role de pivot
        intercontinental malgre un volume de trafic moindre."),

      p("Donnees : echantillon 2019 (environ 70 % des vols ont origine
        ET destination renseignees). Le biais de couverture OpenSky
        (capteurs plus denses en Europe et Amerique du Nord) est discute
        dans l'analyse.")
    ),

    # --- Q4 Hypotheses -------------------------------------------------------

    box(
      title = "Hypotheses avant analyse",
      width = 12, status = "warning", solidHeader = TRUE,

      h4("Hypothese 1 - Les hubs majeurs sont domines par les aeroports americains et europeens"),
      p("La couverture des capteurs OpenSky favorise ces deux regions ;
        nous nous attendons a retrouver KATL, KDFW, LFPG, EGLL dans le
        top 20."),
      br(),
      h4("Hypothese 2 - Volume de vols et connectivite sont fortement correles"),
      p("Un aeroport qui traite beaucoup de vols devrait aussi desservir
        plus de destinations, mais la relation n'est pas lineaire :
        certains hubs concentrent le trafic sur peu de routes a haute
        frequence."),
      br(),
      h4("Hypothese 3 - Les hubs americains sont surtout domestiques"),
      p("Les aeroports americains desservent principalement d'autres
        aeroports americains (prefixe K), contrairement aux hubs europeens
        qui jouent un role de pivot intercontinental.")
    ),

    # --- Q4 Graphique 1 -------------------------------------------------------

    box(title = "Top 20 des aeroports les plus connectes (2019)",
        width = 12, status = "info", solidHeader = TRUE,
        p("Nombre de destinations uniques desservies depuis chaque
          aeroport d'origine (degre sortant du graphe du reseau aerien)."),
        plotlyOutput("q4_top20", height = "500px")),

    box(title = "Analyse - Graphique 1", width = 12,
        status = "success", solidHeader = TRUE,
        h4("Hypothese 1 validee"),
        p("Les aeroports americains (KATL, KDFW, KORD, KJFK, KLAX) et
          europeens (LFPG, EGLL, EDDF, EHAM) dominent le classement.
          Le nombre de destinations uniques varie de ~50 a plus de 150
          pour les plus connectes.")),

    # --- Q4 Graphique 2 -------------------------------------------------------

    box(title = "Volume de trafic vs. connectivite des aeroports (2019)",
        width = 12, status = "info", solidHeader = TRUE,
        p("Chaque point est un aeroport avec au moins 100 vols.
          Les 10 premiers hubs (par connectivite) sont mis en evidence."),
        plotlyOutput("q4_scatter", height = "500px")),

    box(title = "Analyse - Graphique 2", width = 12,
        status = "success", solidHeader = TRUE,
        h4("Hypothese 2 validee avec nuances"),
        p("La correlation est positive mais imparfaite. Certains
          aeroports ont une connectivite elevee relativement a leur
          volume (vrais hubs redistributeurs), d'autres ont un volume
          eleve mais peu de destinations (corridors a haute frequence,
          typique du domestique americain).")),

    # --- Q4 Graphique 3 -------------------------------------------------------

    box(title = "Profil geographique des destinations depuis les 6 principaux hubs",
        width = 12, status = "info", solidHeader = TRUE,
        p("Repartition (%) des vols par region de destination identifiee
          par le prefixe du code OACI. Affichage en facettes."),
        plotOutput("q4_profil_geo", height = "550px")),

    box(title = "Analyse - Graphique 3", width = 12,
        status = "success", solidHeader = TRUE,
        h4("Hypothese 3 validee"),
        p("Les aeroports americains (KATL, KORD, KDFW) affichent un
          profil fortement domestique : la quasi-totalite de leurs
          destinations ont le prefixe K. En comparaison, LFPG et EDDF
          presentent une repartition diversifiee avec des parts
          significatives vers l'Europe du Nord, l'Afrique, le Moyen-Orient
          et l'Amerique du Nord."),
        p("Ce profil confirme leur role de pivots intercontinentaux :
          le concept de 'hub' recouvre des realites tres differentes
          selon le contexte geographique.")),

    box(title = "Conclusion Q4", width = 12, status = "primary", solidHeader = TRUE,
        p("La hierarchie du reseau aerien mondial est lisible depuis un
          simple classement par connectivite : quelques dizaines de hubs
          concentrent la majorite des connexions mondiales."),
        p("Le croisement volume / connectivite revele deux logiques
          distinctes : les redistributeurs intercontinentaux (hubs europeens
          et asiatiques) et les amplificateurs de flux domestiques
          (hubs americains). La couverture OpenSky bialise cependant
          ce classement en faveur des regions occidentales."))
  ),

  # =========================================================================
  # Q5 - Toutes les régions ont-elles subi le COVID de la même manière ?
  # =========================================================================

  fluidRow(

    box(
      title = "Q5 — Toutes les régions ont-elles subi le COVID de la même manière ?",
      width = 12, status = "primary", solidHeader = TRUE,

      h2("Q5 — Impact régional du COVID sur le trafic aérien mondial"),

      p("Dans cette partie, nous cherchons à déterminer si toutes les régions
        du monde ont subi la crise COVID de la même façon en termes de trafic
        aérien."),

      p("En regroupant les aéroports par continent grâce aux métadonnées
        OurAirports, nous comparerons les profils de chute et de reprise
        du trafic entre 2019 et 2022."),

      p("Nous discuterons également du biais de couverture du réseau OpenSky,
        plus dense en Europe et en Amérique du Nord, et de son impact sur
        nos conclusions.")
    ),

    box(
      title = "Hypothèses avant analyse",
      width = 12, status = "warning", solidHeader = TRUE,

      h4("Hypothèse 1 — L'Asie a chuté en premier"),
      p("Nous supposons que l'Asie a été la première région à voir son trafic
        chuter, dès janvier-février 2020, avant même les autres continents,
        du fait de sa proximité avec l'épicentre initial de la pandémie."),
      br(),
      h4("Hypothèse 2 — L'Europe et l'Amérique du Nord ont chuté de façon synchronisée"),
      p("Nous supposons que l'Europe et l'Amérique du Nord ont connu une chute
        simultanée en mars 2020, lors des premiers confinements généralisés."),
      br(),
      h4("Hypothèse 3 — L'Asie a connu une reprise tardive et lente"),
      p("En raison des politiques zéro-COVID appliquées notamment en Chine et
        au Japon, nous supposons que l'Asie a été la dernière grande région à
        retrouver un niveau de trafic proche de 2019."),
      br(),
      h4("Hypothèse 4 — L'Europe a connu une reprise en dents de scie"),
      p("Les vagues successives de COVID et les confinements répétés en Europe
        nous amènent à supposer une reprise irrégulière, marquée par des
        rebonds et des rechutes.")
    ),

    box(
      title = "Évolution du trafic aérien par continent (base 100 = janvier 2019)",
      width = 12, status = "info", solidHeader = TRUE,

      fluidRow(
        column(width = 12,
          checkboxGroupInput("q5_years",
            "Années à afficher :",
            choices  = c("2019","2020","2021","2022"),
            selected = c("2019","2020","2021","2022"),
            inline   = TRUE))
      ),
      plotlyOutput("q5_line_chart", height = "450px")
    ),

    box(
      title = "Analyse des résultats — Graphique 1",
      width = 12, status = "success", solidHeader = TRUE,

      h4("Hypothèse 1 : L'Asie a chuté en premier — Difficilement confirmable"),
      p("La granularité mensuelle ne permet pas de distinguer clairement une
        chute asiatique anticipée. Toutes les courbes semblent chuter
        simultanément autour d'avril 2020."),
      br(),
      h4("Hypothèse 2 : Europe et Amérique du Nord synchronisées — Validée"),
      p("Les deux courbes chutent au même moment (mars-avril 2020) et suivent
        des trajectoires très similaires lors de la descente initiale."),
      br(),
      h4("Hypothèse 3 : Reprise asiatique tardive et lente — Validée"),
      p("La courbe asiatique reste en dessous de l'indice 100 jusqu'à fin 2022,
        bien après les autres continents. Impact durable des politiques
        zéro-COVID."),
      br(),
      h4("Hypothèse 4 : Reprise européenne en dents de scie — Partiellement validée"),
      p("La courbe européenne montre des fluctuations en 2021, mais la tendance
        reste globalement croissante à partir de mi-2020."),
      br(),
      p("Note : la courbe africaine est très erratique (biais de couverture
        OpenSky très faible sur ce continent) — voir graphique 3.")
    ),

    box(
      title = "Hypothèse — Profondeur de la chute par région",
      width = 12, status = "warning", solidHeader = TRUE,
      h4("Hypothèse 5 — L'Asie et l'Europe ont subi les chutes les plus profondes"),
      p("Nous supposons que l'Asie et l'Europe ont enregistré les baisses les
        plus importantes entre la moyenne mensuelle de 2019 et le pic de
        crise d'avril 2020.")
    ),

    box(
      title = "Chute du trafic aérien au pic de crise (moyenne 2019 → avril 2020)",
      width = 12, status = "info", solidHeader = TRUE,
      plotlyOutput("q5_bar_chute", height = "400px")
    ),

    box(
      title = "Analyse des résultats — Graphique 2",
      width = 12, status = "success", solidHeader = TRUE,
      h4("Hypothèse 5 : Asie et Europe les plus touchées — Invalidée"),
      p("Ce sont l'Afrique et l'Amérique du Sud qui affichent les plus fortes
        baisses. L'Europe arrive en troisième position, l'Asie en quatrième."),
      p("Cependant ce résultat doit être interprété avec prudence : une forte
        baisse dans les données africaines peut refléter une dégradation de la
        couverture OpenSky pendant la crise, pas une chute réelle plus importante."),
      p("En excluant ces deux continents, l'Europe présente bien la chute la
        plus profonde parmi les continents fiables, ce qui valide partiellement
        l'hypothèse initiale.")
    ),

    box(
      title = "Hypothèse — Biais de couverture OpenSky",
      width = 12, status = "warning", solidHeader = TRUE,
      h4("Hypothèse 6 — Les conclusions sur l'Afrique et l'Amérique du Sud sont à nuancer"),
      p("Le réseau OpenSky est principalement composé de récepteurs ADS-B situés
        en Europe et en Amérique du Nord. Cette inégalité de couverture se traduit
        par une sous-représentation de certains continents dans nos données.")
    ),

    box(
      title = "Couverture OpenSky vs réalité — Aéroports par continent",
      width = 12, status = "info", solidHeader = TRUE,
      plotlyOutput("q5_bar_couverture", height = "400px")
    ),

    box(
      title = "Analyse des résultats — Graphique 3",
      width = 12, status = "success", solidHeader = TRUE,
      h4("Hypothèse 6 : Biais de couverture — Validée"),
      p("L'Afrique ne couvre qu'environ 5 % de ses aéroports réels, l'Amérique
        du Sud environ 10 %. À l'inverse, l'Europe couvre environ 60 % et
        l'Amérique du Nord environ 50 %, rendant leurs données bien plus
        représentatives."),
      p("Ce déséquilibre invalide toute conclusion directe sur l'Afrique et
        l'Amérique du Sud. Leurs analyses doivent systématiquement être
        nuancées par ce biais structurel.")
    ),

    box(
      title = "Conclusion — Q5",
      width = 12, status = "primary", solidHeader = TRUE,
      p("Non, toutes les régions du monde n'ont pas subi le COVID de la même
        manière. Les données révèlent des profils de chute et de reprise très
        différents selon les continents."),
      p("L'Europe et l'Amérique du Nord ont chuté de façon synchronisée en
        mars-avril 2020, mais l'Amérique du Nord a montré une reprise plus
        rapide et régulière. L'Asie, malgré une chute similaire, a connu une
        reprise nettement plus tardive, imputable aux politiques zéro-COVID."),
      p("Les résultats concernant l'Afrique et l'Amérique du Sud doivent être
        interprétés avec la plus grande prudence : le faible taux de couverture
        OpenSky (~5 % et ~10 %) rend leurs courbes peu fiables.")
    )
  )
)