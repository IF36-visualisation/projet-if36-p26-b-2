# rendu 1
<br>

---
## Le trafic aérien a-t-il un rythme cardiaque ?

Nous cherchons ici à déterminer si le trafic aérien mondial suit des cycles réguliers comparables à un “rythme cardiaque”, 
c’est-à-dire des variations prévisibles selon l’heure de la journée, le jour de la semaine ou encore le mois de l’année. 
Nous pouvons supposer que l’activité aérienne est plus intense à certaines heures de la journée, 
notamment le matin en Europe puis plus tard dans la journée en Amérique du Nord. 
Nous pouvons également imaginer que certains jours, comme le dimanche, sont plus calmes que les jours ouvrés.



Pour répondre à cette question, nous avons construit trois visualisations : 
un graphique linéaire du nombre de vols par heure (UTC), un diagramme en barres du nombre de vols par jour de la semaine, et un diagramme en barres du nombre de vols par mois.

Les données utilisées proviennent de notre dataset couvrant l’ensemble de l’année 2019. 
Cette période a été retenue car le trafic aérien n’était alors pratiquement pas affecté par la pandémie de COVID-19,
ce qui permet d’observer un fonctionnement plus représentatif du rythme habituel de l’aviation mondiale.  

Cependant, le volume total de données étant particulièrement important, 
nous avons choisi de travailler sur un échantillon aléatoire de 1 % des observations, 
suffisant pour mettre en évidence les grandes tendances tout en réduisant le temps de calcul et la charge mémoire.

---
### Variation du trafic aérien selon l’heure de la journée (UTC)

Afin d’étudier l’existence d’un rythme journalier du trafic aérien mondial, nous avons calculé le nombre moyen de vols observés pour chaque heure de la journée (UTC), en moyennant les volumes sur l’ensemble des jours de l’année 2019. L’objectif est d’identifier les périodes de forte et de faible activité, ainsi que les zones du monde susceptibles d’influencer ces variations.

La variable utilisée est *firstseen*, qui correspond au premier moment où l’aéronef est détecté par le réseau de capteurs ADS-B utilisé par le dataset. Cette information est une approximation du moment de départ du vol.Les heures sont exprimées en temps universel coordonné (UTC) afin de garantir une comparaison cohérente entre les différentes régions du monde.

Sur le graphique, l’axe des abscisses représente les heures de la journée (de 0 à 23h UTC), tandis que l’axe des ordonnées indique le nombre moyen de vols observés pour chaque heure.
<p align="center">
  <img src="https://github.com/user-attachments/assets/17b32f90-ac56-4a65-b5ad-32573624d752" width="500">
</p>

Le graphique montre une évolution cyclique très nette du trafic au cours de la journée. Le volume de vols reste relativement élevé à 0h UTC (environ 412 vols), puis diminue progressivement durant la nuit pour atteindre un minimum entre 3h et 5h UTC, autour de 305 vols. Cette phase creuse correspond principalement à la nuit en Europe et en Afrique, deux zones situées à proximité du fuseau UTC et disposant d’un espace aérien dense. Elle correspond également à la fin de journée sur la côte Est de l’Amérique du Nord et à une activité déjà réduite sur la côte Ouest.

À partir de 6h UTC, le trafic recommence à augmenter progressivement. Cette reprise s’explique en grande partie par le début de journée en Europe occidentale et centrale, où se concentrent de nombreux vols courts et moyen-courriers. L’Afrique du Nord et le Moyen-Orient participent également à cette hausse matinale, avec le redémarrage des hubs régionaux.

Entre 10h et 15h UTC, la croissance devient plus marquée, passant d’environ 395 à 545 vols en moyenne. Le maximum est atteint à 15h UTC. Cette période correspond à un chevauchement entre plusieurs zones actives : l’Europe est encore en pleine journée, l’Amérique du Nord a commencé ses opérations matinales, et le Moyen-Orient reste actif. Ce cumul d’activités sur plusieurs continents explique le pic observé.

L’Asie et l’Océanie influencent moins directement ce maximum visible en UTC. D’une part, leurs heures de pointe locales se produisent à d’autres moments de la journée en temps universel. D’autre part, ces régions sont parfois moins représentées dans les données OpenSky en raison d’une couverture ADS-B et d’une densité de capteurs plus inégales selon les pays. Leur activité réelle peut donc être partiellement sous-observée dans le dataset.

Après 15h UTC, le trafic diminue progressivement. L’Europe entre en fin de journée, certaines liaisons court-courrier se terminent, tandis que l’activité nord-américaine se poursuit sans compenser entièrement la baisse européenne. En soirée UTC, le nombre moyen de vols redescend à environ 390 vols à 23h.

Ce graphique confirme donc l’existence d’un véritable “rythme cardiaque” du trafic aérien mondial. L’activité suit un cycle régulier structuré par les fuseaux horaires, avec un creux nocturne centré sur l’Europe et l’Afrique, une reprise matinale européenne, un pic lié au chevauchement Europe–Amérique, puis un ralentissement progressif en fin de journée.

---
### Variation du trafic aérien selon le jour de la semaine

Afin d’analyser l’existence d’un cycle hebdomadaire du trafic aérien mondial, nous avons calculé le nombre moyen de vols observés pour chaque jour de la semaine. Cette approche permet d’identifier d’éventuelles différences entre les jours ouvrés et les jours de week-end, ainsi que les périodes de forte ou faible activité.

Sur le graphique, l’axe des abscisses représente les jours de la semaine, tandis que l’axe des ordonnées indique le nombre moyen de vols observés pour chaque jour.
<p align="center">
  <img src="https://github.com/user-attachments/assets/97a2fb71-7044-4eda-a935-11674c7b25c1" width="500">
</p>

Le graphique montre une variation relativement modérée du trafic aérien au cours de la semaine. Les jours ouvrés présentent les niveaux les plus élevés, avec une progression du lundi (environ 840 vols) jusqu’à un maximum atteint le vendredi (environ 895 vols). Cette hausse progressive reflète l’intensification des déplacements professionnels et des activités de transport au fil de la semaine.

Le week-end affiche une légère baisse du trafic. Le samedi enregistre une diminution plus marquée avec environ 803 vols en moyenne, ce qui correspond à une réduction des vols liés aux déplacements professionnels. Le dimanche présente une légère remontée (environ 823 vols), mais reste globalement inférieur aux jours de semaine, ce qui confirme une activité aérienne plus faible durant le week-end.

Cette tendance suggère que le trafic aérien est principalement structuré par les rythmes économiques hebdomadaires, avec une activité plus soutenue en milieu de semaine et un ralentissement durant le week-end. Toutefois, les écarts restent relativement limités, ce qui montre que le transport aérien demeure un système globalement continu et fortement sollicité même les jours de faible activité.

---
### Variation du trafic aérien selon le mois de l’année

Afin d’analyser l’existence d’une saisonnalité annuelle du trafic aérien mondial, nous avons calculé le nombre total de vols pour chaque mois de l’année. Cette analyse permet d’identifier les périodes de forte et de faible activité à l’échelle annuelle, souvent influencées par les saisons touristiques et les cycles économiques.

Sur le graphique, l’axe des abscisses représente les mois de l’année (de 1 à 12), tandis que l’axe des ordonnées indique le nombre de vols observés pour chaque mois.

<p align="center">
  <img src="https://github.com/user-attachments/assets/6302120f-1a3a-4477-823f-19462e3a33f4" width="500">
</p>

Le graphique met en évidence une variation saisonnière nette du trafic aérien. En début d’année, le volume de vols est relativement faible, avec environ 21 000 à 20 000 vols en janvier et février. Une augmentation progressive est ensuite observée à partir du mois de mars, marquant le retour d’une activité plus soutenue.

Le trafic continue de croître jusqu’à atteindre un pic durant l’été, notamment en juillet et août, avec respectivement environ 28 972 et 29 893 vols. Cette période correspond à la haute saison touristique dans l’hémisphère nord, où se concentre une grande partie de la demande mondiale en transport aérien.

Après le mois d’août, une légère baisse est observée en septembre, suivie d’une stabilisation autour de 27 000 à 29 000 vols pour les mois d’automne et de fin d’année. Le mois de décembre montre une activité légèrement plus élevée que certains mois d’automne, ce qui peut être lié aux déplacements liés aux fêtes de fin d’année.

Dans l’ensemble, ce graphique confirme l’existence d’une forte saisonnalité du trafic aérien, avec un maximum durant l’été et des niveaux plus faibles en hiver. Ces variations reflètent principalement les flux touristiques internationaux ainsi que les périodes de vacances scolaires et professionnelles.



---
### Conclusion

L’analyse confirme que le trafic aérien mondial possède bien un “rythme cardiaque”. 
Des cycles nets apparaissent selon l’heure de la journée, le jour de la semaine et le mois de l’année. 
Le trafic augmente et diminue de manière régulière, 
avec des pics correspondant aux grandes zones économiques mondiales et des périodes plus calmes comme la nuit ou le dimanche. 
Le transport aérien mondial apparaît donc comme un système fortement rythmé et structuré dans le temps.



