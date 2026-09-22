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

Un nouveau profil commence par un tutoriel distinct de cinq étages, terminé
par un mini-boss. Il équipe la Baguette d'acier, enseigne déplacement, tir,
portails et augmentations, puis offre une seule fois le coût d'un premier
rang de maîtrise. Il ne donne ni XP de compte ni progression de campagne.
Le tutoriel terminé ou passé ouvre la Mine et l'Épreuve 1 ; le passage demande
confirmation et désactive les conseils suivants. Les sauvegardes déjà jouées
conservent leur progression sans introduction imposée ni cadeau rétroactif.

Le guidage de l'accueil encourage ensuite maîtrises, spécialisation, musique,
Mine et Épreuves. Les gestes de lancement sont présentés dans les paramètres
après l'obtention d'un sort actif en Épreuve, puis rappelés en combat jusqu'au
premier lancement. Chaque étape validée est conservée dans la sauvegarde.

Sources : `data/chapitres.gd`, `data/vagues.gd`, `data/formes_salles.gd`,
`data/epreuves.gd`, `data/butins_run.gd`, `scripts/bilan_run.gd`,
`data/tutoriel.gd`, `scripts/parcours_tutoriel.gd`.

## Combat et terrains

Les ennemis communs, costauds, élites, miniboss et boss ont des comportements
et motifs propres. Leur progression suit 35 profils fixes, construits depuis
les achats accessibles sans jamais lire le build réel. Standards, petits,
gros, miniboss et signatures ont des budgets d’attaques distincts. Les projectiles,
collisions, protections et états restent gérés par la simulation 2D ; la
présentation de combat utilise des modèles et effets 3D.

Les terrains de campagne ajoutent sables mouvants, flaques, vent ou lave selon
le monde. Encre ne possède pas d'effet de terrain. Les boss et modes annexes
n'utilisent pas ces zones.

Sources : `data/catalogue_ennemis.gd`, `data/evolution_ennemis.gd`,
`data/terrains_mondes.gd`, `scripts/terrain_elementaire.gd`,
`scripts/ennemi.gd`, `scripts/boss.gd`, `scripts/projectile.gd`.

## Améliorations de run et sorts

La campagne propose dix niveaux de run, dont quatre choix rares tirés sans
remise. Les autres choix de niveau proposent soin, attaque ou PV max. Les
paliers précédant les salles 5, 10 et 15 proposent trois pouvoirs et rendent
30 % des PV maximum après le choix. Un de ces trois paliers, tiré au hasard
au début du run, propose des légendaires ; les deux autres proposent des
épiques. Le choix légendaire ne peut jamais être relancé et les légendaires
sont exclus des tirages ordinaires des modes annexes.

Le catalogue propose 15 rares, 10 épiques majeures et 5 légendaires, en plus
des trois communs. Les maîtrises accordent au maximum 3 relances par run,
partagées entre les choix qui autorisent une relance. Héritage réactif ajoute
séparément un ou deux augments rares au début de l’aventure.

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
compte vingt niveaux par objet ; chacun regroupe la puissance et le prix de cinq
anciens niveaux, sans modifier le coût total jusqu’au maximum. Les dix armes,
anneaux, bracelets et colliers possèdent une statistique principale, un bonus
fixe et un passif. Les familiers sont autonomes, ont leur propre Attaque et
accordent un petit passif au héros. Les pouvoirs de bijoux débloqués par la forge
restent passifs : cumul de dégâts, cinquième attaque, sursis ou incantation. Les
doublons et butins de sorts suivent les garanties des catalogues.

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
