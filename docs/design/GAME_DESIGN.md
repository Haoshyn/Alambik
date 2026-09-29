# Alambik — périmètre actif

## Boucle

Roguelite de tir portrait à une main. Le héros se déplace au joystick et tire
automatiquement lorsqu'il s'arrête. Le combat repose sur les tirs du héros,
son familier, l'esquive et les attaques annoncées des ennemis.

Le familier entre dans chaque salle, patrouille et s'arrête pour viser puis
tirer. Sa position et son cycle sont indépendants des déplacements du héros.
Ses projectiles traversent les murs ; leurs dégâts gardent les règles de
progression et de forge du familier.

Chaque tireur possède sa silhouette de projectile et ses dimensions de
collision : traits étroits, boules, trajectoires ondulantes, allers-retours
avec un arrêt avant le retour et ricochets lents en nombre limité. Les tirs
revenants suivent leur axe initial sans poursuivre le héros. Certains boss
avancent au contact pour un balayage, une morsure ou un choc circulaire.
L'approche est limitée et abandonnée si le joueur reste inaccessible. La frappe
ne s'annonce qu'à portée, avec une direction verrouillée, puis une récupération
immobile. Ils ne tirent pas pendant cet assaut. Leurs attaques disponibles
alternent dans un ordre variable selon la distance et les obstacles ; les motifs
de tir propres à chaque identité restent disponibles avec les attaques de monde.

Les augments sont des choix temporaires de run. L'équipement, les maîtrises,
les attributs, les passifs et les Cœurs de mana sont permanents.
La répartition des sources permanentes se lit avant les augments. Les choix
permanents visent chacun environ un cinquième du DPS sur le compte complet
de référence, synergies comprises. Cette cible concerne les dégâts ; les
proportions varient pendant la progression et selon la spécialisation.
Le temps nécessaire pour compléter ces familles doit aussi rester comparable.
Les parcours économiques de référence contrôlent les étapes à 50 %, 75 % et
maximum, avec des marges de temps définies dans `Reglages`, plus serrées
entre le niveau maximum du héros et les dernières maîtrises. Ce sont des
critères de simulation, sans verrouillage d'une progression par une autre.
Le build complet comprend cinq objets équipés forgés, tous les arbres,
tous les passifs et Cœurs ; forger toute la collection reste un objectif en plus.
Les attributs offensifs et les statistiques de passifs gagnent progressivement
en puissance avec le niveau du héros. Concentrer les points dans un seul
attribut offensif réduit leur rendement ; répartir les points reste utile.
Les premiers rangs de forge d'arme lancent le build, puis leur gain ralentit
pour laisser les autres familles de progression prendre leur place. Les choix
de run démultiplient ce socle et doivent expliquer la majeure partie du DPS
de fin de tentative ; ils ne sont pas une sixième tranche à ramener à 20 %.

Les gains offensifs et défensifs doivent rester comparables. Attributs,
maîtrises, équipement, passifs, Cœurs et augments apportent des gains modestes,
avec des PV et dégâts ennemis recalibrés sur ce niveau de puissance.
Les cinq sources de dégâts donnent des gains permanents visibles.
Une spécialisation offensive conserve son avantage de dégâts. Les PV, les
soins et le rendement du butin dépendent des points, équipements, maîtrises
et passifs réellement choisis ; concentrer ses investissements en dégâts
laisse une faible marge aux blessures et finance moins de rangs par coffre.
Le premier monde demande très peu de répétitions ; le besoin de
renforcement augmente vers la fin de campagne. Les premières salles doivent
rester accessibles avec l'équipement attendu, avant les augments aléatoires.
Une progression ordinaire doit garder plusieurs attaques par monstre intact,
même en se spécialisant en dégâts. Les critiques et circonstances favorables
peuvent exceptionnellement le tuer en une attaque. Un fort sur-farm peut
dépasser le chapitre suivant ; le chapitre d'après doit reprendre une marge.
Le jeu ne force jamais un nombre minimum de coups, ne plafonne pas les dégâts
et n'adapte pas les ennemis au build.

Les dégâts infligés apparaissent brièvement près de l'ennemi, boss compris.
Le nombre vient du montant appliqué, critiques et vulnérabilité inclus,
même si le coup dépasse les PV restants. Les impacts très proches sont
additionnés par cible ; les dégâts continus sont regroupés séparément.

## Campagne, Mine et Épreuves

La campagne comprend cinq mondes — Encre, Terre, Eau, Air et Feu — de sept
niveaux chacun. Chaque tentative comprend vingt salles. Les boss occupent
les salles 5, 10, 15 et 20 ; le dernier niveau de chaque monde se termine
par son boss signature.

Les formes des salles, obstacles, terrains, rencontres et variantes de monde
sont définis dans leurs catalogues. Les salles de campagne varient entre
galeries étroites, salles allongées, murs arrondis, renfoncements et alcôves.
La majorité offre davantage de largeur, tout en conservant quelques galeries
étroites et les mêmes formes et longueurs. Leur géométrie reste stable par étage
et conserve l'accès à l'entrée, au portail et aux différentes alcôves.
Leurs murs arrêtent les déplacements, les contacts et les tirs ordinaires.
La croissance des PV et des dégâts est
composée. Les PV reçoivent un renfort progressif après le premier chapitre ;
sa transition évite une marche brutale au deuxième niveau, puis plafonne.
La croissance des niveaux suivants laisse une place au renforcement tardif.
Après le premier monde, les dégâts ajoutent un renfort progressif borné :
la résistance demande un investissement sans faire exploser les dégâts tardifs.
Les boss ont un renfort de niveau borné et leur propre croissance de PV par
salle, pour garder des durées distinctes des monstres ordinaires. Dans
une run, la hausse par salle conserve des paliers de difficulté en salles
5, 10 et 15, indépendamment des offres d'augments. Elle est fixe : le build et les
échecs du joueur ne la modifient pas.

Les durées de boss prennent comme référence un build équilibré, amélioré
pour le niveau affronté. Les cibles des boss ordinaires et des signatures
sont définies dans `Reglages` et présentées dans la
[liste mathématique](../../statistiques_jeu/liste_mathematique.md).
Les signatures ont un coefficient d'endurance propre au monde en campagne.
Les augments favorables aux dégâts rapprochent de la borne basse, les
défavorables de la haute, avec des exceptions possibles. Une spécialisation
offensive ou un fort sur-farm peut écourter le combat. Ce sont des repères
d'équilibrage : aucun chronomètre ni ajustement des PV au héros ne les impose.

Le contact physique avec tout monstre ou boss vivant inflige ses dégâts au
héros, y compris pour les tireurs et hors d'une attaque annoncée. Les
croisements rapides sont pris en compte ; les murs protègent du contact.
Le délai entre contacts et l'invulnérabilité normale évitent les dégâts par
image. Le corps reste dangereux quand il est gelé, après son apparition.

Certaines salles ordinaires portent un effet propre au monde : flaques
d'encre et d'eau ralentissantes, sables mouvants à ralentissement progressif,
ou flaques de lave infligeant des dégâts périodiques. Ces nappes sont larges
et allongées pour rendre leur traversée sensible. Les silhouettes et les
tailles varient ; le dessin est exactement la zone affectant le héros.
Encre et eau réduisent fortement la vitesse ; le sable enfonce progressivement
le héros et atteint rapidement son ralentissement maximal.
Les effets commencent après le délai d'entrée et cessent à l'ouverture du
portail. Le passage central, l'entrée et la sortie restent libres. Les
terrains n'empêchent pas de tirer ; seuls les pieds du héros dans la flaque
déclenchent son effet. Les salles de boss et les modes annexes restent sans
ces terrains de campagne.

Dans Air, des rafales alternent avec des accalmies. La direction apparaît
avant la poussée, reste fixe pendant la rafale et change entre deux rafales.
Le vent accélère la course dans son sens, ralentit la course opposée sans
l'empêcher et déplace légèrement le héros à l'arrêt. Cette dérive respecte
les collisions et conserve le tir automatique si le joueur ne commande pas
de déplacement. Les effets réduits figent les traits visuels, sans modifier
la force ou le calendrier. Les chiffres des terrains sont générés dans
`statistiques_jeu/liste_mathematique.md` depuis `TerrainsMondes`.

Les premières tentatives gardent des vagues moins longues et des annonces
lisibles. Les tirs lents se lisent en mouvement, sans tracé préalable. Les tirs
rapides, ou trop proches pour laisser réagir, annoncent leur trajectoire avec
une visée verrouillée jusqu’au départ. Les frappes instantanées gardent leur
avertissement. La vitesse et le rythme montent progressivement avec le niveau, puis
modérément au cours de chaque tentative, avec des plafonds pour les trajectoires
complexes. Le tisseur lance des rubans plus larges sans annonce ni anticipation :
leur écart et leur oscillation permettent une traversée au bon moment.
Les boss gardent des ouvertures dans leurs barrages ; les départs des tirs
respectent le contour réel de la salle et leurs annonces. Le tutoriel est retiré.

La sentinelle anticipe une course régulière puis lance un trait très rapide
après sa visée verrouillée. Continuer tout droit expose au coup, même au fond
de la salle : il faut changer de direction ou se couvrir. Les chargeurs
anticipent aussi la course dès le début de leur préparation, puis conservent
le trajet annoncé. Chaque visée doit permettre de croiser la course prévue
sur ce trajet, après la préparation ; sinon, le chargeur se rapproche.
Les poursuivants et les chargeurs sont ralentis, avec une durée de charge
prolongée pour conserver la portée annoncée.
Les monstres gagnent légèrement en déplacement et en cadence ; le Tison
arbalétrier du monde Feu conserve une cadence réduite propre à sa variante.
Le premier boss de chaque niveau de campagne a une endurance réduite pour
alléger le combat avant le premier légendaire.
Les poursuivants et chargeurs blessent dès le contact réel de leurs corps,
même pendant la préparation de leur attaque, avec un délai entre deux coups. Un obstacle
empêche cette frappe et l’invulnérabilité normale après dégât reste active.

Les boss arrivent près du milieu de la salle. Selon leur identité, ils avancent
directement, prennent un flanc ou orbitent autour du joueur ; leurs annonces
de tir gardent une origine fixe. Leurs projectiles couvrent la salle et les
boomerangs partent en éventail dirigé, avec retour sur le premier mur rencontré.
Les tireurs peuvent attaquer dès leur portée réelle, sans attendre leur distance
de placement ; les tireurs fuyards conservent leur recul. Les phaseurs se
téléportent aussi depuis le fond de la salle, vers une place libre annoncée près
du joueur. Les invocateurs appellent leurs renforts à distance et continuent à
tirer après épuisement de leur réserve.
Les dashs parcourent le segment affiché, limité par les murs et obstacles.
Une cible hors de portée ou un ralentissement empêchant de couvrir le trajet
pendant la préparation annule le départ. Une fois lancé, le dash garde son
extrémité et sa direction, même sous ralentissement ou changement de phase.

Les monstres prévus par une salle peuvent déposer des cœurs de soin, avec
un quota de zéro, un ou deux pour toute la rencontre. Les invocations ne
renouvellent pas ce budget. Les cœurs non ramassés sont recueillis avant de
quitter la salle ; ils ne se transportent pas comme une réserve de potions.

La Mine est une survie avec ramassage de cristaux d'XP au sol. Les augments
arrivent pendant la survie ; le boss apparaît après cinq minutes et sa mort
termine la tentative. La Mine finance la forge et les niveaux du compte,
y compris partiellement lorsqu'une tentative échoue. L'XP de compte de
survie est distincte des cristaux donnant les augments de cette tentative.

Les Épreuves proposent onze niveaux de rencontres. Elles donnent les
passifs et leurs doublons, ainsi qu'un Cœur de mana unique par niveau.
Une garantie borne le nombre de victoires sans récompense.
La première s'ouvre après le premier chapitre de campagne. Les suivantes
exigent à la fois la victoire de l'Épreuve précédente et l'avancement de
campagne correspondant à leur palier. Le niveau accessible reste rejouable.
Les anciennes acquisitions et records sont conservés ; leur accès respecte
désormais aussi la campagne, y compris depuis une ancienne sélection ou Rejouer.

La campagne seule, sans répétitions ni modes annexes, donne un budget limité.
La Mine et les Épreuves permettent de renforcer le compte lorsqu'un chapitre
résiste, sans rendre les éliminations en une attaque ordinaires. Le farm n'est
pas une interdiction de lancer une tentative. Les comparaisons et leurs
hypothèses sont dans `statistiques_jeu/liste_mathematique.md`.

## Personnage et équipement

Sorcier et Moine restent sélectionnables. Leurs bonus sont temporairement
neutres ; aucun build ne reçoit d'avantage de classe.

Le niveau de compte augmente légèrement le socle d'attaque et de PV, puis
donne des points à répartir. Force, Vitalité, Agilité, Intelligence et Sagesse
ont chacune un effet actuel ; Intelligence n'est plus liée à des sorts.

Un équipement complet comprend une arme, un familier, un anneau, un bracelet
et un collier. Chaque modèle possède une identité et des chiffres fixes.
La forge augmente les statistiques du modèle ; sa provenance renforce ses
valeurs brutes. Les pourcentages s'additionnent dans chaque source ; les
étages équipement, maîtrises et passifs se multiplient. Les augments agissent
ensuite sur les tirs et statistiques de run ; les Cœurs sont le dernier facteur
de dégâts. Ils font partie de la progression permanente.

Le repère demandé est un impact normal d'environ mille dégâts sans augment
sur un compte complet, pour dix dégâts au départ sans équipement. Ce sont
des impacts, pas le DPS ni les critiques. Les bijoux et le familier doivent
apporter un gain visible ; leur utilité offensive et défensive se lit objet
par objet dans la liste mathématique. Chaque rang de forge du familier augmente
ses dégâts, indépendamment de l'arme ; il partage les facteurs permanents
et les augments d'attaque, sans recevoir les critiques ni les salves du héros.
La forge d'arme ralentit après ses premiers achats, avec un gain continu
plus sensible sur les rangs suivants. Les ennemis gardent des courbes fixes,
recalibrées avec les achats et offres réels, sans lire les statistiques du joueur.

Héros affiche le bonus total de chaque attribut et le gain du prochain point
au niveau courant. Les chiffres viennent de la même fonction que le combat ;
les valeurs brutes et les points de critique sont identifiés avant combinaison.

Les bijoux gagnent un effet passif au palier de forge prévu. Aucun de ces
effets ne lance de sort. Les anciens modèles restent utilisables dans les
sauvegardes, sans réapparaître dans les butins actuels.

## Maîtrises et passifs

Les trois branches de maîtrises sont Offensif, Défensif et Utilitaire.
Les nœuds ordinaires ont plusieurs rangs ; les pouvoirs majeurs s'achètent
une fois. Les coûts, prérequis et effets sont détaillés par rang dans les listes.

Seize passifs remplacent les sorts actifs et ultimes. Quatre peuvent être
équipés simultanément, chacun sur deux rangs. Ils renforcent les statistiques,
les soins, l'économie ou un comportement simple du tir ; certains imposent
un compromis comme Audace.

Un passif possédé mais non équipé ne donne aucun bonus. Les nouveaux passifs
viennent exclusivement des Épreuves. Les anciennes capacités sont converties
lors du chargement d'une sauvegarde ; les rangs excédentaires sont compensés.
La migration conserve le reste de la progression.

## Augments

Les vingt-six augments modifient les statistiques ou les tirs existants.
Ils ne créent plus de météores, zones de dégâts, gardiens, flaques ni attaques
autonomes. Les légendaires donnent une orientation au build et un gain mesuré
de puissance. Aucun augment ordinaire ne retire d'attaque, de cadence, de PV
ou de mobilité en échange d'un autre bonus.

Salve est un choix rare unique. Tir double ajoute des projectiles parallèles
et peut être acquis deux fois. Chaque acquisition réduit de 20 % les dégâts de tous
les projectiles après le coefficient de l'arme. Battement triple ajoute deux
salves, reste légendaire et applique aussi une réduction de 20 % à tous les
projectiles ; il conserve les réductions des autres choix.

Les bonus positifs de même famille s'additionnent. Les réductions des tirs
multiples se multiplient et restent applicables aux légendaires. Choisir
l'offensive laisse passer une occasion de renforcer sa survie ; une défense
renforcée ne réduit jamais les dégâts déjà acquis. Les gains des sources
permanentes et des augments, les PV ennemis et leurs dégâts sont ajustés
ensemble pour éviter une succession de multiplicateurs excessifs.

Les pourcentages des augments sont des multiples de cinq ou de dix. Les
gains de PV effectifs et de DPS de même rareté restent du même ordre, sans
prime systématique à la défense. Ajouter deux augments défensifs à un build
offensif améliore sa survie au prix de deux choix offensifs ; cela ne doit
pas lui permettre de rester très résistant tout en éliminant les rencontres
en une attaque. Soins, boucliers et seconde vie sont présentés séparément
de la résistance permanente. Le déblocage progressif des augments est reporté.

En campagne et en Mine, dix niveaux donnent dix augments : trois épiques,
une légendaire garantie au niveau 5, et les autres en rares. Aucun commun,
aucun choix supplémentaire aux salles 5, 10 et 15. Le planning des autres
raretés est aléatoire et fixé avant les offres ; une relance ne le change pas.
Une run sur dix en moyenne reçoit une seconde légendaire, qui remplace une
rare ou une épique à un autre niveau, y compris le premier. Le total reste
dix : si le bonus remplace une épique, il en reste deux. Les comparaisons
d'équilibrage excluent cette seconde légendaire ; une combinaison chanceuse
doit pouvoir simplifier fortement le combat.

Un choix ne soigne plus automatiquement. Les cœurs au sol soignent à leur
ramassage si le héros est blessé ; à PV pleins ils restent au sol. En fin de
salle, chaque cœur restant soigne ou, si la vie est déjà pleine, donne une
Goutte fixe versée avec le bilan de run, sans multiplicateur de butin. Les
effets de soin propres aux passifs, objets et à Égide restent actifs.

## Présentation et persistance

Simulation 2D et présentation 3D, avec rendu 2D de secours. La direction
artistique, le héros animé, les décors, les attaques ennemies annoncées et
les musiques restent ceux de la version active.

L'interface comporte Héros, Équipement, Aventure, Maîtrises et Passifs.
Les commandes de sorts et d'ultimes ont été retirées du HUD.

La sauvegarde reste locale. Aucun compte en ligne, SDK publicitaire ou achat
intégré. Les migrations préservent les identifiants et la progression utile.

Les chiffres font foi dans `data/`. Les fichiers de `statistiques_jeu/`
sont leur traduction générée pour le propriétaire, pas une seconde source.
