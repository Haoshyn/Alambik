# État courant — 9 octobre 2026

Alambik est un roguelite de tir portrait Android sous Godot 4.7.1 : simulation
2D, présentation 3D. Le héros Aster V7 aux proportions manga, la clairière
animée, les cinq mondes et les annonces de danger restent actifs. L'interface
utilise le kit Émail serti de la refonte du 9 octobre 2026.

## Refonte graphique et sonore du 9 octobre 2026

À la demande du propriétaire (carte blanche, gel des menus levé pour ce
travail), toutes les surfaces passent par `StyleBoxJeu` : émail bombé, monture
dorée, épaisseur, reflet. Les textes utilisent Nunito très grasse avec contour ;
la graisse des polices variables est désormais réellement appliquée (la clé
texte `"wght"` était ignorée et tout le jeu s'affichait en graisse fine).
HUD, cartes d'augments façon cartes à collectionner (rareté, lueur, valeurs en
or, distribution animée), pause, fin de partie (« VICTOIRE ! », fanfare),
navigation à onglet soulevé, accueil, Héros, Équipement, Maîtrises, Passifs et
Paramètres suivent ce kit. Les combats gagnent des nombres de dégâts épais,
des critiques dorés distincts, un éclair sur l'ennemi touché, des ombres de
contact, des explosions plus fournies, une secousse de caméra et des
micro-arrêts sur les coups marquants, une vignette, un rendu filmique contrasté
avec halo, et des bandeaux d'annonce (boss, salle nettoyée). Les familiers, qui
s'affichaient en silhouette blanche faute de matière lisant leur peinture par
sommet, retrouvent leurs couleurs. Vingt-deux bruitages synthétisés (clic,
cartes et choix par rareté, critique, explosion, gamme d'XP, niveau, salle,
achat, victoire, défaite…) sont produits en arrière-plan au démarrage.
Les contrôles de scènes, passifs, héros, familiers, bestiaire, projectiles et
dégâts affichés passent ; le coût du halo, des éclairs et de la synthèse sur
téléphone reste à mesurer sur appareil (`Visuels3D.LUEUR_ANDROID`).

Aucune valeur d'amélioration n'affiche de décimale. Les cumuls composés
(maîtrises, passifs, Cœurs, collier) donnent des points entiers par rang, non
décroissants, jusqu'à l'arrondi du cumul. Agilité : +1 point de chance et
+1 point de dégâts critiques ; Intelligence : 1 % de cadence par point (2 % au
dernier palier) ; Vitalité : 1 puis 2 de Défense ; le dernier palier de Force
passe à 13 pour compenser. Familiers : tirs toutes les 2 s (golem 3 s), avec
une attaque qui garde leur débit. Élan vital se charge en 1 s pour +60 %,
Pas de brume donne +70 % d'invulnérabilité, les satellites frappent chaque
seconde, Moisson vitale rend 3 % toutes les 7 éliminations, et les tirs
multiples s'affichent en pourcentage retiré. Les parts du DPS permanent de
référence restent à 18 / 21 / 21 / 19 / 20 %. Les contrôles d'équilibrage
passent, sauf `rythme_progression` : en monde 1, le compte financé demande
encore 7 attaques en C4 et jusqu'à 8 en C7 (cible : 6), comme avant ces
changements. Ralentir la montée du renfort de PV corrige C4 mais dégrade C5
à C7 dans la simulation ; l'arbitrage reste ouvert. Le contrôle `patterns`
attendait l'ancienne courbe de PV sans la rampe ralentie après la salle du
légendaire ; il suit désormais la formule du jeu et passe.

Le paysage de la clairière, prairie comprise, reste fixe. Le vent suit des
feuilles précises du premier plan et quatre rameaux articulés. Clairière et
îles composent leurs animations sans arrondi au pixel, à la résolution
affichée ; les effets réduits conservent une image figée. Le contrôle dédié
vérifie les attaches, les zones de pierre et de bois exclues du vent, le
cadrage portrait et l'arrêt des fonds cachés. La fluidité sur téléphone
reste à apprécier sur appareil.

Aster possède une silhouette plus compacte, avec une tête légèrement agrandie,
des jambes et un buste raccourcis. Son squelette, ses expressions et les prises
d’armes suivent ces proportions ; la barre de vie accompagne la nouvelle hauteur.
Son repos, sa course, ses réactions aux dégâts et sa chute suivent les états du
jeu. Le tir à l'arrêt conserve un léger mouvement du buste, avec les pieds
stables ; les rafales prolongent le geste sans remettre la pose à zéro. Un
ordre de déplacement annule aussi les tirs déjà préparés. Les armes équipées
suivent la nouvelle main. Le modèle Blender et les anciennes sources du mage
sont conservés. Le contrôle dédié couvre le rig, les appuis pendant les
rafales, la priorité des dégâts et l'interruption du tir ; le coût sur
téléphone reste à mesurer.

Les décors de combat ont cinq signatures alchimiques : scriptorium,
distillerie végétale, fontaines, moulins et forge. Leurs sols adoptent
l'enduit ciré B coloré par monde, avec des reprises asymétriques et une
bordure d'émail et de cuivre. Les livres, feuilles, médaillons et arabesques
dessinés au sol sont retirés. Les décors en volume suivent les vrais murs :
lanternes de verre, établis de potions, jarres, champignons, coraux, carillons,
cristaux et appareils alchimiques. Nombre, emplacement, taille et orientation
varient par étage. Leur emprise reste hors du passage, y compris dans les
alcôves. Les murets et rochers portent aussi de petits volumes propres au
monde, contenus dans leur emprise physique. Les traces de taloche, les reprises
plus claires et le polissage restent déterministes. Les nuances appartiennent
à un maillage de sol,
et la bordure est regroupée dans un second, tous deux découpés sur les
parois réelles et sous les acteurs. Les coins varient aussi
en campagne, avec des galeries étroites, des salles allongées, des parois
ondulées, des renfoncements et des alcôves arrondies ou angulaires. La galerie
étroite conserve son gabarit ; la majorité des salles offre davantage de
largeur, avec les mêmes formes et longueurs. Dimensions et reliefs sont stables
par étage ; collisions et décor partagent le même contour. Le passage
central reste dégagé.
Frises d'émail et couverts peints complètent les ateliers.
Les contrôles dédiés exercent les neuf profils, les vingt étages de chaque
monde, les origines décalées, les textures, les volumes de décor, les variations
de teinte, la conservation des UV, la stabilité des variantes et les effets
réduits. L'accès, les couverts et les proportions sont contrôlés sur toute
la campagne. Les transitions dans les trois modes sur deux formats, les
terrains, les patterns et la progression sont vérifiés. Les aperçus Blender
utilisent la géométrie exportée du jeu, avec conversion des couleurs de
sommets sRGB en linéaire pour conserver
les pigments et respect des surfaces de sol sans ombre portée. Le rendu et
le coût réels sur Android restent à vérifier sur appareil.

Le chargement entre étages reprend celui du lancement : île illustrée du
monde, fond indigo, nom et niveau, avec le numéro d'étage et le total issus
de la run. Mine et Épreuves conservent leur illustration dédiée. Le même
composant est réutilisé pendant la tentative ; le voile bloque les commandes
pendant le passage et respecte les effets réduits.

Les terrains de campagne sont actifs dans les cinq mondes : encre et eau
ralentissantes, sables mouvants progressifs, rafales annoncées et lave à
dégâts périodiques. Leurs contours irréguliers sont partagés par la simulation
et le rendu. Les flaques forment maintenant de grandes nappes allongées,
avec une rive fine, des nuances de profondeur, une peinture originale et
des normales de surface. L'encre et l'eau ralentissent davantage ; le sable
atteint plus vite son ralentissement maximal. Le placement réserve le passage
central et teste le polygone entier contre les parois, les couverts et les
autres nappes. Le contrôle dédié parcourt les salles de campagne, vérifie la
vitesse réelle du héros, les tirs dans l'eau, la cadence des dégâts, la
poussée avec collision, les matières et les effets réduits. Les chiffres
viennent du catalogue et figurent dans les statistiques générées.

## Jeu et progression

- Campagne : cinq mondes de sept niveaux, vingt salles par tentative.
  Après une victoire, l'accueil sélectionne le chapitre suivant, y compris
  au passage au monde suivant. Le dernier chapitre reste sélectionné en fin
  de campagne ; Rejouer relance toujours le chapitre qui vient d'être terminé.
  Mine de survie pour les Pierres et l'XP ; Épreuves pour les passifs et les Cœurs.
  Les Épreuves suivent maintenant la campagne : seule la première s'ouvre
  après le chapitre initial. Les suivantes exigent aussi leur palier de
  campagne ; les répétitions restent possibles et les acquisitions conservées.
- Seize passifs à deux rangs, quatre emplacements équipés. Les sorts actifs,
  ultimes, commandes associées et anciennes animations autonomes sont retirés.
  Leur menu garde la clairière commune sans filtre propre, quatre sceaux
  équipés et une collection ouverte. Chaque passif possède un SVG distinct
  issu de la banque ; la collection affiche le bonus calculé au rang courant,
  ou l'aperçu du premier rang avant découverte. Les détails restent dans la fiche.
- Un bouton **DEV** temporaire dans l'accueil prépare un compte après la fin
  du monde choisi avec un peu de farm : attributs, maîtrises, équipement, forge,
  passifs, Cœurs et ressources suivent les récompenses et achats du jeu.
  Revenir à un monde inférieur retire les gains ultérieurs. Le compte d'origine
  est restaurable, même après redémarrage. L'outil est isolé dans
  [`dev_temporaire/`](../dev_temporaire/README.md), avec un seul branchement
  conditionnel dans le menu, sans modification des systèmes permanents.
  Les cinq profils, la régression, la restauration et les commandes en portrait
  sont vérifiés sans fenêtre ; le rendu sur appareil reste à vérifier.
- Vingt-neuf augments : quinze rares, neuf épiques et cinq
  légendaires. Les rares de statistiques gardent des bonus directs et leurs
  cartes restent courtes. Encrage vif et Sceau de ruine renforcent les stats ;
  Trait alchimique et Météorite alchimique sont deux choix séparés, sans
  bonus de stats. Traque donne seulement le guidage. Élan vital garde son
  bonus après déplacement en plus d'une hausse permanente d'attaque.
  Les satellites alchimiques ajoutent
  deux cercles de contact originaux autour du héros, actifs en mouvement,
  avec délai partagé par ennemi et protection par les murs. Leurs dégâts
  ne reçoivent ni critiques, ni salves, ni rebonds, ni diagonales.
  Aucun malus ordinaire d'attaque, de PV, de cadence ou de mobilité.
  Salve est rare et unique ; Tir double est rare et cumulable deux fois.
  Battement triple donne trois salves avec seulement 20 % de perte lorsqu'il
  est seul. Il se cumule avec Salve en quatre salves dans les deux ordres.
  Les gains de débit des salves, tirs parallèles et cadence s'additionnent,
  en ajustant la puissance des impacts. Les bonus directs d'attaque et de
  projectile s'additionnent aussi ; les critiques retirent les croisements
  entre choix distincts. Les épiques sont légèrement renforcés ; les
  légendaires donnent des gains plus forts, avec une puissance exceptionnelle
  assumée.
  Des comparaisons éprouvent un mixte avec Égide et quatre choix offensifs
  ordinaires contre les variantes frontales et toutes les diagonales guidées.
  Les PV ordinaires montent plus doucement après la salle du légendaire,
  avec des paliers ordinaires et boss recalés ; la courbe de dégâts de campagne
  est conservée. L'endurance du dernier boss est légèrement réduite et les
  dégâts de Mine sont légèrement relevés pour garder une pression de survie.
  Ricochet conserve sa limite et sa perte de puissance avec Perforation.
  Les pourcentages restent arrondis ; les gains de résistance effective et
  de DPS des rares sont comparables, en tenant compte des conditions de leurs
  effets. La défense n'a plus de prime systématique.
  Dix niveaux donnent dix choix, sans communs ni choix bonus de salle :
  légendaire garantie au niveau 5, trois épiques et autres rares. Dans 10 %
  des runs, une seconde légendaire remplace une rare ou une épique hors niveau 5.
- Sorcier et Moine restent sélectionnables, avec des bonus actuellement nuls.
- Attributs, trois branches de maîtrises, armes, bijoux, familiers et forge
  portent la progression permanente. Les cinq familles de dégâts visent une
  contribution comparable sur le compte complet de référence. Les attributs
  donnent des gains bruts par point, croissants par palier de niveau,
  sans rendement décroissant. Les points déjà investis profitent du nouveau
  palier. Les statistiques de passifs suivent des pourcentages entiers.
  Les maîtrises composent leurs rangs et leurs nœuds ; les taux offensifs
  tardifs dépassent les premiers. Les Cœurs composent leur gain relatif.
  La forge renforce les valeurs acquises avec des gains bruts arrondis et
  croissants. Le familier partage les augments d'attaque ; sa forge garde
  son attaque propre. Les unités d'attaque, de PV et de Défense sont divisées
  par dix ensemble, attributs et arrondis de forge compris. Le héros commence
  à 100 dégâts sans équipement, 140 avec la baguette initiale. Les courbes et
  pourcentages permanents sont conservés. Les impacts de référence se lisent
  dans la liste mathématique.
  Les courbes fixes des ennemis sont recalibrées
  en distinguant les entrées sans augment et la puissance acquise dans la run.
  Héros affiche le bonus actuel de chaque attribut et le gain du prochain point
  à son niveau, calculés par le runtime, sans modification des commandes.
  Tous les bijoux ont une base d'attaque commune et chaque rang de forge
  la renforce, en plus de la statistique principale et du pouvoir de palier.
  Les fiches d'équipement restent ouvertes après achat ou équipement ; elles
  montrent les valeurs actuelles, le prochain rang, le gain, le coût et les
  pierres manquantes. Une forge réussie a un retour visible. Les cadres et
  transitions d'Équipement et de ses fiches sont affinés.
  Un contrôle économique compare aussi les étapes à 50 %, 75 % et maximum
  sur deux parcours avec achats réels. Il recherche des temps de complétion
  proches, en particulier entre le héros et les dernières maîtrises.
- Le familier patrouille dans la salle et alterne déplacement, visée et tir
  depuis sa propre position. Ses tirs traversent les murs, avec une forme
  propre à chaque familier et une durée de vie bornée par la portée.
  Chaque identité équipée a une sculpture 3D originale : renard d'encre,
  salamandre élancée, ondine aquatique, sylphe aux ailes plumées et gardien de
  pierre. Corps, nuques et museaux forment des volumes continus ; des regards
  discrets et des silhouettes animales les distinguent des objets du bestiaire.
  Les sources Blender et la référence sont conservées dans
  `assets/3d/sources/familiers/`. Leurs projectiles ont des volumes magiques
  ivoire et azur, avec des contours et un rendu alliés propres.
  Membres et recul suivent déplacement et tir ; le repos se fige en effets
  réduits. La peinture par sommet et le regroupement des volumes fixes gardent
  une seule matière par pivot.
- Les dégâts infligés sont affichés en nombres entiers animés près des
  monstres et boss, avec regroupement des impacts proches et de la braise ;
  les critiques sont plus gros et dorés. Les effets réduits conservent une
  valeur sobre par cible. Les contrôles couvrent les montants appliqués, le
  dernier coup, le format entier et la durée des textes.
- Chaque tireur ennemi conserve sa silhouette de projectile dans ses motifs.
  Les traits fins sont épaissis, saturés et bordés d’un contour sombre ;
  la traînée reste visible en effets réduits, avec une longueur bornée.
  Disques et capsules ont des dimensions distinctes, balayées entre deux
  ticks physiques. Certains tirs reviennent après un arrêt ou rebondissent
  lentement sur un nombre limité de murs. Les boss de contact approchent,
  annoncent une frappe à direction fixe, puis récupèrent sans attaquer.
- Les onze monstres et vingt boss ont des modèles reconstruits avec des
  membres articulés, un atlas peint affiné et des variantes dans les cinq mondes.
  Papier et tissu restent mats ; cuivre et acier ont leurs propres reflets.
  Les UV, les plumes, les charnières et les ornements des variantes sont repris.
  Les pattes plient au genou et prennent appui au sol ; les
  corps gardent leurs proportions pendant les gestes. Les tirs portent des
  biseaux et des cœurs lumineux animés. Gel, effets réduits, appuis, arrêt,
  disparition sans collision, UV, normales, matières partagées et budgets
  sont contrôlés par `tools/verifier_bestiaire.gd`.
  Planches et aperçu animé Blender utilisent les poses calculées par Godot.
  L'aperçu met en scène une approche lente, l'arrêt et le tir ; le rendu et la fluidité
  sur téléphone restent à valider en partie.
- La croissance des monstres est fixe et composée par niveau et salle,
  avec transition progressive des PV après le chapitre initial, puis
  plafonnement du renfort et croissance composée vers la fin. Les dégâts gardent leur courbe
  distincte, avec renfort borné après le premier monde ; les boss de campagne
  ont aussi un renfort de niveau borné. Les marches en salles 5, 10 et 15 restent en place.
  Les contrôles recherchent des éliminations en une attaque exceptionnelles
  sur les parcours ordinaires, équilibrés comme offensifs, et comparent le
  sur-farm ainsi que le remplacement de deux choix par de fortes défenses.
  Les ennemis ne dépendent jamais du build ; aucun plancher de coups n'est ajouté.
  Un contrôle mesure aussi les premières salles sans augment, les gains
  des achats et un calendrier de reprises croissant, payé avec le vrai butin.
  Ce calendrier décrit une hypothèse de simulation, pas un nombre de reprises imposé.
  La lecture compare aussi les entrées des comptes qui financent réellement
  leurs annexes face aux murs : omettre Mine, passifs et Cœurs reste un stress
  sous-équipé. Le profil DEV après le monde 2 est contrôlé en équilibre,
  avec Force et maîtrises offensives, puis sans passifs : dégâts, résistance,
  soins, butin et dispersion des boss.
  Les premières vagues sont allégées et leurs attaques plus lisibles.
  Les durées des boss d’Aventure prennent le build équilibré au niveau attendu
  comme référence, avec une cible distincte pour les fins de monde et une
  endurance fixe propre à chaque monde. Le contrôle rejoue les comptes
  financés sur d'autres offres, pour distinguer médiane et dispersion des augments.
  Le full offensif reste plus rapide ; aucun temps minimal n'est imposé en jeu.
  Les cibles et mesures figurent dans la liste mathématique ; les durées
  réelles, avec esquives et motifs de boss, restent à vérifier en partie.
  Les dégâts des premières annexes sont contrôlés à leur déblocage.
  Tous les monstres et boss blessent au contact physique, y compris les tireurs,
  les corps gelés et les boss hors charge. Les murs, recharges et délais
  d'invulnérabilité restent pris en compte ; apparitions et cadavres ne blessent pas.
- Les tirs lents partent sans annonce. Les tirs rapides, ou trop proches
  pour laisser réagir, annoncent leur visée. Vitesse et rythme progressent
  avec le niveau et l'avancée de la tentative ; les annonces gardent un plancher.
  Le tisseur tire sans annonce ni prédiction, avec un passage entre ses rubans.
  Les tirs de boss utilisent le contour réel de la salle dès leur annonce.
  Les salles varient en largeur et en longueur ; la caméra suit le héros
  dans leurs limites et garde son recul.
- Les sentinelles anticipent une course régulière puis verrouillent leur visée.
  Leur anticipation couvre tout le vol, y compris au fond de salle.
  Les chargeurs anticipent la course avant leur annonce fixe. Chaque trajet
  doit pouvoir croiser la course prévue après la préparation ; sinon, ils
  se rapprochent. Les poursuivants et chargeurs sont ralentis, avec une durée
  de charge prolongée pour conserver la portée. Les contrôles sur les cinq
  mondes et les élites vérifient l’impact en ligne droite et l’esquive par
  changement de direction, ainsi que les trajets de charge annoncés.
  Les monstres gagnent légèrement en déplacement et en cadence ; le Tison
  arbalétrier du monde Feu conserve une cadence réduite propre à sa variante.
  Le premier boss de chaque niveau de campagne a une endurance réduite avant
  le premier légendaire ; les autres boss gardent leurs coefficients.
  Les tirs du héros, des familiers et des ennemis ont été accélérés.
  Les poursuivants et chargeurs blessent au contact réel, même pendant la
  préparation d’une attaque. Le délai entre deux coups
  et l’invulnérabilité normale du héros empêchent les dégâts par image.
- Les boss apparaissent près du milieu et avancent vers le joueur, prennent
  un flanc ou orbitent selon leur identité. Une fenêtre de déplacement entre
  motifs évite leur immobilisation par les annonces successives. Leurs tirs
  couvrent la salle ; les boomerangs épais partent par trois en éventail et
  reviennent aussi au contact d’un mur. Leur choix de motif varie selon la
  distance et les obstacles, conserve leurs signatures et évite les répétitions
  immédiates. Les mêlées s’arment uniquement à portée ; une approche ratée
  laisse place à une autre attaque. Leurs préparations et récupérations sont resserrées.
- Les tireurs attaquent à portée réelle sans attendre leur distance de placement.
  Les phaseurs se téléportent aussi de loin, vers une arrivée libre annoncée.
  Les invocateurs agissent à distance et restent actifs après épuisement des renforts.
  Les dashs partagent un trajet unique entre annonce et déplacement, arrêté
  au premier mur ou obstacle, même entre deux alcôves. Les vérifications
  de tir, de contact et de collecte respectent les renfoncements.
  Les contrôles couvrent les neuf contours, plusieurs fréquences physiques,
  les ralentissements, l’esquive et les changements de phase.
  Ces comportements sont vérifiés en simulation ; le ressenti reste à jouer sur appareil.
- Les sources permanentes se combinent par étages. Leur répartition est
  mesurée avant les augments, qui démultiplient ensuite le DPS de la run.
  Les simulations utilisent les vraies offres et séparent les hypothèses
  de choix, de durée et de parcours avec achats et retries.
- Des cœurs de soin tombent sur les ennemis prévus : quota par rencontre,
  au plus deux. À PV pleins, ils restent au sol ; à la transition, chaque
  cœur soigne ou donne une Goutte fixe si la vie est déjà pleine. Aucun soin
  automatique aux choix d'augments. Les
  invocations ne produisent pas de nouveaux soins. Le tutoriel est retiré.
- Les sauvegardes anciennes sont migrées : sorts convertis en passifs,
  surplus compensés, autres possessions et progression conservées.

Les valeurs exactes, niveaux, prix et calculs sont dans
[Statistiques jeu](../statistiques_jeu/INDEX.md). Les six listes se régénèrent
depuis les catalogues et fonctions du jeu ; elles ne se corrigent pas à la main.
Elles sont en Markdown. La liste mathématique commence par la puissance
permanente au plafond, puis montre le gain des augments et la fiche finale.
Le [game design](design/GAME_DESIGN.md) décrit le périmètre et la
[direction artistique](design/DIRECTION_ARTISTIQUE.md) décrit la présentation.

## Organisation et vérification

[L'index du projet](INDEX.md) mène aux dossiers par domaine et à leurs index.
Les instructions `AGENTS.md` ont été réécrites. La copie avant refonte, les
systèmes retirés et les inventaires se trouvent hors dépôt dans
`../Alambik_sauvegardes/refonte_2026-09-26_233554/`.

`tools/verifier.ps1` contrôle l'import Godot, la concordance des listes,
les courbes et achats, les augments, les satellites, les effets périodiques et transactions de forge,
les parcours équilibrés et le retour
offensif après cinq ou six Épreuves, l'affichage des dégâts, les soins, les migrations et les scènes. Les runs
utilisent un profil isolé : cinq onglets sur deux formats portrait et les
trois modes. La sélection de campagne est contrôlée par des clics réels dans
l'interface : changement de monde et de niveau, réglages, reprise au même
endroit et retour Android, avec et sans effets réduits.
Les journaux restent dans `tmp/verification_*/`.

Ces contrôles vérifient les calculs et le fonctionnement des scénarios
automatisés. Le rythme réel de progression, le ressenti des combats et le
rendu sur téléphone restent à éprouver par des parties.
