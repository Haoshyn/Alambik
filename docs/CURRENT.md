# État courant — 27 septembre 2026

Alambik est un roguelite de tir portrait Android sous Godot 4.7.1 : simulation
2D, présentation 3D. Le héros sculpté, la clairière animée, les cinq mondes,
les annonces de danger et le kit d'interface Émail arcanique restent actifs.

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
- Vingt-six augments : douze rares, neuf épiques et cinq
  légendaires. Ils modifient les statistiques ou les tirs ordinaires.
  Les gains de dégâts et de résistance sont resserrés, avec leurs effets conservés.
  Aucun malus ordinaire d'attaque, de PV, de cadence ou de mobilité.
  Salve est rare et unique ; Tir double est rare et cumulable deux fois.
  Salve, Tir double et Battement triple appliquent chacun −20 % aux projectiles,
  par multiplication. Battement triple reste légendaire et ajoute deux salves.
  Les pourcentages restent arrondis ; les gains de résistance effective et
  de DPS de même rareté sont comparables. La défense n'a plus de prime systématique.
  Dix niveaux donnent dix choix, sans communs ni choix bonus de salle :
  légendaire garantie au niveau 5, trois épiques et autres rares. Dans 10 %
  des runs, une seconde légendaire remplace une rare ou une épique hors niveau 5.
- Sorcier et Moine restent sélectionnables, avec des bonus actuellement nuls.
- Attributs, trois branches de maîtrises, armes, bijoux, familiers et forge
  portent une progression permanente plus mesurée. Leurs gains, ceux des
  passifs et des Cœurs ont été réduits avec les courbes ennemies. La forge du familier conserve un effet
  utile avec les bonus permanents du héros.
- Le familier patrouille dans la salle et alterne déplacement, visée et tir
  depuis sa propre position. Ses tirs traversent les murs, avec une forme
  propre à chaque familier et une durée de vie bornée par la portée.
- Les dégâts infligés sont affichés par de petits nombres animés près des
  monstres et boss, avec regroupement des impacts proches et de la braise.
  Les effets réduits conservent une valeur sobre par cible. Les contrôles
  couvrent les montants appliqués, le dernier coup et la durée des textes.
- Chaque tireur ennemi conserve sa silhouette de projectile dans ses motifs.
  Les traits fins sont épaissis, saturés et bordés d’un contour sombre ;
  la traînée reste visible en effets réduits, avec une longueur bornée.
  Disques et capsules ont des dimensions distinctes, balayées entre deux
  ticks physiques. Certains tirs reviennent après un arrêt ou rebondissent
  lentement sur un nombre limité de murs. Les boss de contact approchent,
  annoncent une frappe à direction fixe, puis récupèrent sans attaquer.
- La croissance des monstres est fixe et composée par niveau et salle,
  avec renfort des PV après le chapitre initial, puis plafonnement de ce
  renfort et croissance plus lente après les premiers chapitres. Les dégâts gardent leur courbe
  distincte et les marches en salles 5, 10 et 15 restent en place.
  Les contrôles recherchent des éliminations en une attaque exceptionnelles
  sur les parcours ordinaires, équilibrés comme offensifs, et comparent le
  sur-farm ainsi que le remplacement de deux choix par de fortes défenses.
  Les ennemis ne dépendent jamais du build ; aucun plancher de coups n'est ajouté.
  Les premières vagues sont allégées et leurs attaques plus lisibles.
  Les PV des boss suivent la réduction des gains du joueur ; les dégâts
  des premières annexes sont contrôlés à leur déblocage.
- Les tirs lents partent sans annonce. Les tirs rapides, ou trop proches
  pour laisser réagir, annoncent leur visée. Vitesse et rythme progressent
  avec le niveau et l'avancée de la tentative ; les annonces gardent un plancher.
  Le tisseur tire sans annonce ni prédiction, avec un passage entre ses rubans.
  Les tirs de boss utilisent le contour réel de la salle dès leur annonce.
  Les salles sont légèrement plus étroites et longues, la caméra plus reculée.
- Les sentinelles anticipent une course régulière puis verrouillent leur visée.
  Les contrôles sur les cinq mondes et les élites vérifient l’impact à mi-distance,
  l’esquive par changement de direction et la marge latérale au fond de salle.
  Les tirs du héros, des familiers et des ennemis ont été accélérés.
  Les poursuivants et chargeurs sont légèrement ralentis et blessent au contact
  réel, même pendant la préparation d’une attaque. Le délai entre deux coups
  et l’invulnérabilité normale du héros empêchent les dégâts par image.
- Les boss apparaissent près du milieu et avancent vers le joueur, prennent
  un flanc ou orbitent selon leur identité. Une fenêtre de déplacement entre
  motifs évite leur immobilisation par les annonces successives. Leurs tirs
  couvrent la salle ; les boomerangs épais partent par trois en éventail et
  reviennent aussi au contact d’un mur. Les dashs sont allongés et vérifient
  leur portée réelle, les ralentissements et les obstacles avant le départ.
  Ces comportements sont contrôlés en simulation ; le ressenti reste à jouer
  sur appareil.
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
les courbes et achats, les augments, les parcours équilibrés et le retour
offensif après cinq ou six Épreuves, l'affichage des dégâts, les soins, les migrations et les scènes. Les runs
utilisent un profil isolé : cinq onglets sur deux formats portrait et les
trois modes. Les journaux restent dans `tmp/verification_*/`.

Ces contrôles vérifient les calculs et le fonctionnement des scénarios
automatisés. Le rythme réel de progression, le ressenti des combats et le
rendu sur téléphone restent à éprouver par des parties.
