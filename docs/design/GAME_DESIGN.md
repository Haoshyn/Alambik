# Alambik — jeu actuellement implémenté

Ce document décrit le périmètre actif. Les chiffres et catalogues de `data/`
font foi pour l'équilibrage. L'ancienne specification, qui mêlait le jeu et des
projets futurs, est conservée dans `../OldAlambik/2026-09-20/retires/docs/design/`
(chemin depuis la racine du projet).

## Boucle de jeu

Roguelite de tir portrait Android, à une main. Le héros se déplace au joystick,
tire automatiquement selon son état et utilise les sorts équipés. Les salles
combinent vagues, obstacles, boss et récompenses. Une tentative développe ses
améliorations propres ; l'équipement, les maîtrises et les sorts persistent.

Sources : `scripts/run.gd`, `scripts/heros.gd`, `scripts/tir.gd`,
`autoload/jeu.gd`, `autoload/reglages_joueur.gd`.

## Campagne et modes annexes

La campagne comprend cinq mondes — Encre, Terre, Eau, Air et Feu — de sept
chapitres chacun. Un chapitre parcourt vingt salles ; le septième chapitre de
chaque monde porte son boss signature. Les salles et obstacles suivent un
parcours fixe par chapitre. Le centre et les accès restent praticables.

La Mine et les Épreuves de sorts sont accessibles depuis l'accueil. Leurs
récompenses et difficultés viennent des mêmes catalogues que l'aperçu de butin.

Sources : `data/chapitres.gd`, `data/vagues.gd`, `data/formes_salles.gd`,
`data/epreuves.gd`, `data/butins_run.gd`, `scripts/bilan_run.gd`.

## Combat et terrains

Les ennemis fragiles, moyens, costauds, élites, miniboss et boss ont des comportements
et motifs propres. Leur progression suit 35 profils fixes, construits depuis
les ressources des échecs et les achats accessibles sans jamais lire le build réel.
La cible passe de 3–4 tentatives sans farm obligatoire au début à dix échecs
et cinq ou six victoires sur le chapitre précédent à la fin. Ce sont des cibles
de conception, sans victoire automatique après un nombre d’essais. Les premières
salles laissent acquérir les augments avant une montée plus forte de la pression.
Le héros se déplace à 728 px/s, soit 30 % plus vite. Le coefficient global de
déplacement ennemi augmente de 15 %, en plus des vitesses propres à chaque rôle.
Le poursuivant fragile court sans s’arrêter ; les chargeurs annoncent leur couloir,
les harceleurs esquivent avec une recharge, et les artilleurs lancent un projectile
en cloche sur une position verrouillée. Son cercle rouge explose après 1,5 seconde.
Les projectiles peuvent onduler ou rebondir sur les murs ; les boss utilisent
également ces motifs et des impacts ciblés. Chaque famille possède une identité
par monde, avec nom, couleurs, proportions et ornements 3D spécifiques.
Terre introduit les éclats rebondissants, Eau les lames ondulantes, Air les vrilles,
et Feu les traces brûlantes de certaines charges.

Les boss conservent leur attaque propre et leurs charges ou invocations ; le
motif du monde complète leur cycle et alterne les ouvertures de ses salves.
Leur réserve de PV est augmentée de 25 % en campagne, Mine et Épreuves,
sans adaptation au build du joueur. Les poses de préparation, recul et impact
restent visuelles ; les annonces au sol donnent les repères d’esquive.

Une vague compte généralement 3–5 ennemis, jusqu’à 7 dans les grandes salles.
Les quatre premières salles restent limitées à 4 ennemis simultanés. Une seule
famille costaude occupe chaque vague conçue. La suivante attend 12–14,4 secondes
et suffisamment de places, ou 0,85 seconde après un nettoyage complet.
À partir du deuxième chapitre et de la salle 3, une vague ordinaire a 10 % de
chance de proposer un élite de n’importe quelle famille, avec un seul élite actif.
Ses PV et dégâts doublent, sa vitesse gagne 12 % et sa recharge baisse de 10 %.
Certains élites laissent des traces brûlantes annoncées lorsqu’ils se déplacent.
Les renforts supplémentaires partagent l’XP de la composition d’origine ; les
récompenses de salle et de coffre n’augmentent pas avec les effectifs.

Les projectiles,
collisions, protections et états restent gérés par la simulation 2D ; la
présentation de combat utilise des modèles et effets 3D.

Les terrains de campagne ajoutent sables mouvants, flaques, vent ou lave selon
le monde. Encre ne possède pas d'effet de terrain. Les boss et modes annexes
n'utilisent pas ces zones.

Sources : `data/catalogue_ennemis.gd`, `data/bestiaire_mondes.gd`, `data/evolution_ennemis.gd`,
`data/terrains_mondes.gd`, `scripts/terrain_elementaire.gd`,
`scripts/ennemi.gd`, `scripts/boss.gd`, `scripts/projectile.gd`.

## Améliorations de run et sorts

En campagne, l’XP des éliminations reste sous forme de petits cristaux au sol, sans ramassage
au contact. Après nettoyage complet de la salle, les dangers restants disparaissent
et les cristaux rejoignent le héros avant les choix de niveau. Les soins sur
élimination restent immédiats.

La Mine suit une boucle survivor : la horde apparaît continuellement et le joueur
doit approcher des cristaux laissés à la mort des ennemis pour gagner leur XP.
Les montées de niveau ouvrent immédiatement un choix d’augment, avec pause du
combat pendant le choix. Aucun répit ni ramassage global n’interrompt la horde.
Le boss apparaît à cinq minutes même si des ennemis sont encore présents ; les
apparitions continuent pendant ce combat et sa mort termine la run sans exiger
de nettoyer les survivants. Les invocations ne produisent pas d’XP supplémentaire.

La campagne propose dix niveaux de run, dont quatre choix rares tirés sans
remise. Les autres choix de niveau proposent soin, attaque ou PV max. Les
paliers précédant les salles 5, 10 et 15 proposent trois pouvoirs et rendent
30 % des PV maximum après le choix. Un de ces trois paliers, tiré au hasard
au début du run, propose des légendaires ; les deux autres proposent des
épiques. Le choix légendaire ne peut jamais être relancé et les légendaires
sont exclus des tirages ordinaires des modes annexes.

Le catalogue propose 22 rares, 14 épiques majeures et 7 légendaires, en plus
des trois communs. Les maîtrises accordent au maximum 3 relances par run,
partagées entre les choix qui autorisent une relance. Héritage réactif ajoute
séparément un ou deux augments rares au début de l’aventure.

Battement triple ouvre les rafales successives et Couronne incisive les builds
critiques. Les nouveaux pouvoirs couvrent aussi bouclier renouvelé par salle,
corrosion, sorts élargis, attaque lourde, défense, mobilité, soins et tirs
élémentaires. Les boucliers inutilisés ne se cumulent pas entre les salles ;
recalculer le build ne recharge pas un bouclier consommé. La chance critique
reste plafonnée à 100 % et les soins de combat gardent leur budget partagé.

Les augments couvrent tirs, protections, récupération et phénomènes comme les
familiers, météores ou orbes. Leur Attaque de run multiplie la progression
permanente séparément. Le premier trait simultané reste entier et chaque trait
supplémentaire suit désormais la règle de son augment : Tir multiple et Salve
réduisent de 20 % les dégâts finaux de tous leurs traits, après les autres calculs.
Les sorts actifs, passifs et ultimes sont équipés depuis le menu. Un passif se
découvre au rang 1 et un seul doublon double son effet au rang 2. Les dégâts
partent de l'attaque cumulée du héros. Les onze Épreuves donnent chacune un
Cœur de mana unique à 1 chance sur 10, garanti au dixième succès du niveau ;
chaque Cœur ajoute 10 % de dégâts finaux. Les sorts tombent à 1 chance sur 5,
garantis au cinquième succès. Découvrir un sort ne donne plus de dégâts finaux.

Sources : `data/catalogue_reactifs.gd`, `data/progression_augments.gd`,
`data/sorts.gd`, `scripts/mods.gd`, `scripts/draft_logique.gd`,
`scripts/bonus_sorts.gd`, `data/animations_sorts.gd`.

## Progression persistante

Le héros commence avec 10 Attaque, 100 PV et 10 Défense. Chaque niveau de
compte donne cinq points à répartir entre Force, Vitalité, Agilité,
Intelligence et Sagesse. Mage, Sorcier et Moine apportent une spécialisation
finale changeable contre des Gouttes.

Les récompenses financent l'équipement, la forge et les maîtrises. La forge
compte vingt niveaux par objet, avec un premier achat accessible après deux
échecs à cinq puis dix salles et un coût croissant. Les dix armes,
anneaux, bracelets et colliers possèdent une statistique principale, un bonus
fixe et un passif. Les bijoux donnent aussi de l’Attaque brute. Les statistiques
brutes et leurs gains de forge augmentent avec la provenance de l’équipement ;
changer de modèle conserve un coût de forge propre, sans transfert gratuit.
Les familiers sont autonomes, ont leur propre Attaque et
accordent un petit passif au héros. Les pouvoirs de bijoux débloqués par la forge
restent passifs : cumul de dégâts, cinquième attaque, sursis ou incantation. Les
doublons et butins de sorts suivent les garanties des catalogues. Une défaite
conserve les ressources des salles terminées et permet un bijou manquant à
1/30 après cinq salles, 1/20 après dix, 1/10 après quinze. Chaque chapitre
garantit son bijou manquant au plus tard à la troisième victoire complète ;
les défaites ne font pas avancer ce compteur. Les Cœurs de mana renforcent les
dégâts finaux sans être requis par le budget minimal de campagne.

Les identifiants historiques d'équipement et migrations de sauvegarde restent
pris en charge afin de conserver les objets et rangs déjà acquis.

Sources : `data/personnage.gd`, `data/catalogue_objets.gd`, `data/catalogue_familiers.gd`, `data/effets_bijoux.gd`,
`data/arbre_competences.gd`, `data/progression_statistiques.gd`,
`data/recompenses.gd`, `autoload/reglages_joueur.gd`.

## Présentation et commandes

L'accueil affiche l'illustration d'arcane. Le menu regroupe équipement,
aventure, maîtrises et sorts ; les paramètres règlent commandes, musique et
effets. L'interface s'adapte au portrait et aux zones sûres du téléphone.

Le héros de combat est le mage sculpté, avec ses textures, animations et arme
tenue. Les sources Blender nécessaires à ce modèle sont conservées. Le rendu
2D de secours et les outils de développement restent disponibles sur demande.

Sources : `scripts/menu.gd`, `ui/`, `scripts/presentation/`,
`data/visuels_3d.gd`, `autoload/ecran.gd`, `autoload/sons.gd`.
