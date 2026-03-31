# B2-Spirit — Exploration interactive du trafic aérien mondial

**Projet IF36 — Université de Technologie de Troyes**

---

## Introduction

### Données

Notre projet repose sur l'assemblage de plusieurs sources de données de référence dans le domaine de l'aviation ouverte, que nous croiserons pour construire une vision riche et multidimensionnelle du trafic aérien mondial.

#### Source principale : OpenSky Network — COVID-19 Flight Dataset

Le cœur de notre analyse s'appuie sur le **OpenSky Network COVID-19 Flight Dataset**, publié sur [Zenodo](https://zenodo.org/records/7923702) sous licence CC-BY et documenté dans un article scientifique de référence ([Strohmeier et al., 2021](https://essd.copernicus.org/articles/13/357/2021/)). Ce dataset recense l'ensemble des vols captés par le réseau collaboratif OpenSky entre **janvier 2019 et décembre 2022**.

Les données sont issues du protocole **ADS-B** (Automatic Dependent Surveillance–Broadcast) : les avions diffusent automatiquement leur position, vitesse et identification, captées par un réseau de plus de 5 500 récepteurs au sol déployés par des bénévoles et institutions à travers le monde. En période de pointe pré-pandémie, près de 100 000 vols étaient suivis par jour.

**Format :** Fichiers CSV mensuels (un par mois, 48 fichiers au total).

**Volume :** Plus de **41 millions de vols**, couvrant environ **160 000 aéronefs** et **13 900 aéroports** dans **127 pays**. Pour notre analyse, nous sélectionnerons des mois stratégiques (pré-COVID, pic de crise, reprise) afin de garder un volume exploitable en R tout en couvrant les moments clés.

**Variables du dataset principal (17 colonnes) :**

| Variable | Type | Description |
|---|---|---|
| `callsign` | Catégorielle | Identifiant du vol sur les écrans ATC (ex : AFR = Air France, DLH = Lufthansa, RYR = Ryanair) |
| `number` | Catégorielle | Numéro commercial du vol (quand disponible) |
| `icao24` | Catégorielle | Identifiant unique du transpondeur (code hexadécimal 24 bits) |
| `registration` | Catégorielle | Immatriculation de l'aéronef (numéro de queue) |
| `typecode` | Catégorielle | Code OACI du modèle d'aéronef (ex : A320, B738, E190) |
| `origin` | Catégorielle | Code OACI de l'aéroport d'origine (4 lettres, ex : LFPG = Paris-CDG) |
| `destination` | Catégorielle | Code OACI de l'aéroport de destination |
| `firstseen` | Continue (temporelle) | Timestamp UTC du premier signal ADS-B reçu |
| `lastseen` | Continue (temporelle) | Timestamp UTC du dernier signal ADS-B reçu |
| `day` | Continue (temporelle) | Jour UTC du dernier signal |
| `latitude_1` | Continue | Latitude de la première position détectée |
| `longitude_1` | Continue | Longitude de la première position détectée |
| `altitude_1` | Continue | Altitude barométrique au départ (en pieds, ref. 1013 hPa) |
| `latitude_2` | Continue | Latitude de la dernière position détectée |
| `longitude_2` | Continue | Longitude de la dernière position détectée |
| `altitude_2` | Continue | Altitude barométrique à l'arrivée |

#### Source complémentaire 1 : OpenSky Aircraft Database

La [base de métadonnées aéronefs OpenSky](https://opensky-network.org/data/aircraft), téléchargeable en CSV, enrichit chaque vol avec des informations détaillées sur l'avion via une jointure sur `icao24`. Elle agrège des sources officielles (registres d'aviation civile US, UK, Irlande, Suisse) et du crowdsourcing par la communauté.

**Variables ajoutées :** `model` (nom complet de l'aéronef, ex : "Airbus A320-214"), `operator` (compagnie exploitante), `owner` (propriétaire), pays d'immatriculation. Cela nous permettra de passer du simple code `typecode` à une vision complète de la flotte.

#### Source complémentaire 2 : OurAirports

[OurAirports](https://ourairports.com/data/) ([GitHub](https://github.com/davidmegginson/ourairports-data)) fournit une base de référence exhaustive sur les aéroports du monde, mise à jour quotidiennement. Ce sont des fichiers CSV en domaine public.

**Fichiers utilisés :**
- `airports.csv` : ~78 000 aéroports avec identifiant, nom, type (large_airport, medium_airport, small_airport, heliport…), coordonnées GPS, élévation, continent, pays (ISO), région, municipalité, code OACI, code IATA, présence de service régulier. Jointure avec notre dataset principal sur les champs `origin`/`destination` via le code OACI (`icao_code`).
- `countries.csv` : 247 pays avec noms et codes ISO.
- `runways.csv` : 42 000+ pistes avec longueur, largeur, surface, orientation — potentiellement utile pour des analyses sur la capacité aéroportuaire.

#### Source complémentaire 3 : OpenFlights

[OpenFlights](https://openflights.org/data) ([GitHub](https://github.com/jpatokal/openflights)) fournit des données structurées sous licence Open Database License :
- `airlines.dat` : ~6 200 compagnies aériennes avec nom, alias, code IATA, code OACI, callsign, pays, statut actif/inactif. Permettra de mapper les préfixes de callsign à des compagnies complètes.
- `routes.dat` : ~67 600 routes commerciales entre aéroports, avec compagnie, nombre d'escales, type d'appareil. Même si ces données datent de 2014, elles offrent un excellent squelette du réseau aérien mondial pour comparaison avec nos données OpenSky.
- `planes.dat` : 173 types d'appareils avec codes IATA/OACI — table de correspondance pour enrichir les typecodes.

#### Résumé du schéma de données

En croisant ces 4 sources, notre jeu de données final combinera largement plus de 20 variables exploitables, couvrant les dimensions temporelle, spatiale, technique (appareil) et opérationnelle (compagnie, route). Les jointures se feront sur les clés `icao24` (aéronefs), les codes OACI (aéroports), et les préfixes de callsign (compagnies).

**Pourquoi ces données ?** Le trafic aérien est un miroir de l'activité humaine à l'échelle planétaire. Il reflète les dynamiques économiques, les flux migratoires et touristiques, les crises géopolitiques et sanitaires. La période 2019–2022 capture un événement historique sans précédent : l'effondrement puis la reconstruction progressive du transport aérien mondial. Mais au-delà du COVID, ces données permettent de révéler la structure profonde des réseaux aériens — quels hubs connectent le monde, quels corridors aériens dominent, comment les flottes sont distribuées.

**Sous-groupes naturels :** compagnie aérienne, type d'aéronef, région géographique (continent, pays), catégorie d'aéroport (hub international vs. régional), période temporelle, catégorie de vol (court/moyen/long-courrier).

---

### Plan d'analyse

Notre ambition est double : produire des analyses statistiques rigoureuses et les incarner dans une **application Shiny immersive centrée sur un globe terrestre 3D interactif** (via le package R `threejs` et sa fonction `globejs`, qui permet de tracer des arcs, des points et des textures sur une sphère WebGL directement intégrée à Shiny).

Nos questions s'articulent autour de quatre axes.

#### Axe 1 — Le pouls du ciel : dynamiques temporelles du trafic

**Q1 : Comment le volume de vols a-t-il pulsé entre 2019 et 2022 ?**
On construira une série temporelle du nombre de vols quotidiens sur l'ensemble de la période. Au-delà de la simple courbe, on cherchera à détecter des micro-patterns : effet du week-end, creux saisonniers, pics de vacances. Un line chart interactif avec annotations (dates de confinements, réouvertures de frontières) sera la base. On superposera les courbes année par année pour isoler l'effet COVID de la saisonnalité normale.

**Q2 : Le trafic aérien a-t-il un rythme cardiaque ?**
En décomposant le volume de vols par heure de la journée (UTC), par jour de la semaine et par mois, on cherchera les battements réguliers du trafic mondial. Y a-t-il un pic matinal européen suivi d'un pic américain ? Le dimanche est-il vraiment plus calme ? Un heatmap (jour × heure) et des ridgeline plots par mois pourraient révéler ces rythmes.

#### Axe 2 — La géographie du ciel : cartographier les flux

**Q3 : Quels sont les corridors aériens les plus empruntés et comment dessinent-ils le réseau mondial ?**
C'est ici que le globe 3D prend tout son sens. En traçant des arcs géodésiques entre les paires origine-destination les plus fréquentes, on visualisera le squelette du réseau aérien sur le globe. On pourra filtrer par compagnie, par région, par période. La densité des arcs révèlera les corridors dominants (transatlantique, Europe–Golfe, intra-asiatique). On comparera ce réseau observé au réseau théorique d'OpenFlights pour identifier les écarts.

**Q4 : Quels hubs structurent le réseau et quelle est leur zone d'influence ?**
En comptant les connexions uniques par aéroport (degré dans le graphe), on identifiera les hubs majeurs. Mais au-delà du simple classement, on s'intéressera à la portée géographique de chaque hub : un aéroport comme Dubaï connecte-t-il des destinations plus lointaines et plus variées que Francfort ? On pourra visualiser sur le globe la "zone d'influence" de chaque hub, avec des bulles proportionnelles au trafic et des arcs montrant les destinations.

**Q5 : Toutes les régions du monde ont-elles subi le COVID de la même manière ?**
En regroupant les aéroports par continent/pays (grâce aux métadonnées OurAirports), on comparera les profils de chute et de reprise. Le globe pourra être coloré par intensité de trafic à différentes dates, créant une animation temporelle de la "respiration" du trafic mondial. On discutera du biais de couverture d'OpenSky (réseau plus dense en Europe/Amérique du Nord) et de son impact sur nos conclusions.

#### Axe 3 — Les machines : analyse de la flotte mondiale

**Q6 : Quels avions dominent le ciel et la crise les a-t-elle redistribués ?**
Le croisement `typecode` + base aéronefs OpenSky permettra d'analyser la composition de la flotte active. Treemap des types les plus fréquents, évolution temporelle des parts de marché (A320 vs B737 vs E190…), comparaison avant/après COVID. Certains types d'avions ont-ils été retirés plus vite que d'autres ? Les monocouloirs (court-courrier) ont-ils repris plus vite que les gros-porteurs (long-courrier) ?

**Q7 : Peut-on catégoriser les vols en court, moyen et long-courrier, et comment se répartit le trafic ?**
En calculant la distance orthodromique (formule de Haversine) entre aéroports d'origine et de destination, on catégorisera chaque vol. Un histogramme de la distribution des distances, croisé avec le type d'aéronef, permettra de vérifier la cohérence des données (un A380 sur 200 km serait suspect). On pourra aussi estimer les émissions de CO₂ relatives par catégorie de distance.

#### Axe 4 — Les compagnies : stratégies et résilience

**Q8 : Quelles compagnies ont le mieux résisté et quelles stratégies se dessinent ?**
En identifiant les compagnies via les callsigns et la base OpenFlights, on comparera leurs trajectoires de crise. Un bump chart ou un animated bar chart race classant les compagnies par volume mensuel de vols racontera cette histoire. Les compagnies low-cost (Ryanair, easyJet) ont-elles rebondi plus vite que les majors (Air France, Lufthansa) ? Le cargo (FedEx, UPS) a-t-il été épargné ?

**Q9 : Le réseau de chaque compagnie raconte-t-il une stratégie différente ?**
Sur le globe, on pourra afficher le réseau de routes d'une compagnie spécifique et observer sa géographie : réseau en étoile autour d'un hub (Air France / CDG) vs. réseau point-à-point (Ryanair). On pourra comparer les réseaux de deux compagnies côte à côte.

#### Le globe interactif — vision technique

L'application Shiny intégrera un **globe terrestre 3D interactif** construit avec le package R `threejs` (`globejs`). Ce package, basé sur la librairie JavaScript three.js, permet de rendre un globe WebGL directement dans Shiny avec :
- Des **points** géolocalisés (aéroports) dont la taille/couleur encode le volume de trafic
- Des **arcs** géodésiques entre paires d'aéroports (routes) avec opacité proportionnelle à la fréquence
- Une **texture de fond** personnalisable (carte du monde, vue nocturne de la NASA…)
- Une **rotation et un zoom interactifs** dans le navigateur

L'utilisateur pourra :
- Sélectionner une période (slider temporel) et voir le globe s'animer pour refléter l'état du trafic à cette date
- Filtrer par compagnie aérienne, type d'avion, ou région pour isoler un sous-réseau
- Cliquer sur un aéroport pour afficher ses statistiques détaillées (nombre de vols, destinations principales, compagnies présentes)
- Comparer visuellement deux périodes (avant/après COVID par exemple) via des vues synchronisées
- Explorer les graphiques statistiques classiques (ggplot2) dans des onglets complémentaires du dashboard (shinydashboard)

En complément du globe, le dashboard Shiny utilisera `shinydashboard` pour organiser les visualisations ggplot2 (séries temporelles, bar charts, treemaps, heatmaps) dans des onglets thématiques correspondant à nos axes d'analyse.

#### Considérations méthodologiques

Nous aborderons avec transparence les limites de nos données :
- **Biais de couverture** : le réseau OpenSky couvre mieux l'Europe et l'Amérique du Nord. Nos analyses "mondiales" sont en réalité pondérées par la densité de capteurs. Nous quantifierons ce biais et nuancerons nos conclusions en conséquence.
- **Données manquantes** : les champs `origin`, `destination`, `typecode` et `registration` ne sont pas toujours renseignés. Nous analyserons le taux de complétion par variable et par période avant toute analyse, et documenterons notre stratégie de traitement (filtrage vs. catégorie "inconnu").
- **Volume** : avec des millions de lignes par mois, nous devrons échantillonner ou agréger intelligemment. Nous documenterons nos choix d'échantillonnage et vérifierons qu'ils ne biaisent pas les résultats.
- **Temps de visibilité ≠ durée de vol** : la différence `lastseen - firstseen` dépend de la couverture réseau, pas uniquement de la durée réelle du vol. Nous serons explicites sur cette approximation.

---

## Sources

| Source | URL | Licence | Description |
|---|---|---|---|
| OpenSky COVID-19 Flight Dataset | [zenodo.org/records/7923702](https://zenodo.org/records/7923702) | CC-BY | 41M+ vols mondiaux, jan. 2019 – déc. 2022 |
| OpenSky Aircraft Database | [opensky-network.org/data/aircraft](https://opensky-network.org/data/aircraft) | Non licenciée (as-is) | Métadonnées aéronefs (modèle, opérateur, propriétaire) |
| OurAirports | [ourairports.com/data](https://ourairports.com/data/) | Domaine public | 78K+ aéroports, pistes, pays, régions |
| OpenFlights | [openflights.org/data](https://openflights.org/data) | Open Database License | 6K+ compagnies, 67K+ routes, 173 types d'appareils |
| OpenSky REST API | [openskynetwork.github.io/opensky-api](https://openskynetwork.github.io/opensky-api/) | Gratuit (non-commercial) | State vectors en temps réel (optionnel, pour démo live) |

**Référence scientifique :** Strohmeier, M., Olive, X., Lübbe, J., Schäfer, M., & Lenders, V. (2021). *Crowdsourced air traffic data from the OpenSky Network 2019–2020.* Earth System Science Data, 13(2), 357–366. [doi:10.5194/essd-13-357-2021](https://doi.org/10.5194/essd-13-357-2021)
