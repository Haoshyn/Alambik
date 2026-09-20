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

Les ennemis communs, costauds, élites, miniboss et boss ont des comportements
et motifs propres. Leur progression suit le chapitre. Les projectiles,
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
des trois communs. Les maîtrises et passifs réunis accordent au maximum
3 relances par run, partagées entre les choix qui autorisent une relance.

Les augments couvrent tirs, protections, récupération et phénomènes comme les
familiers, météores ou orbes. Leurs effets se cumulent selon leur catalogue.
Les sorts actifs, passifs et ultimes sont équipés depuis le menu. Les dégâts
partent de l'attaque cumulée du héros. Les passifs interviennent ensuite sur les
valeurs finales : dégâts de toutes les sources, récupération après les autres
bonus, protection après les défenses, soins sur les PV max finaux. Ils
n'ajoutent pas d'attaque ; Moisson soigne hors du budget des soins d'augments.

Sources : `data/catalogue_reactifs.gd`, `data/progression_augments.gd`,
`data/sorts.gd`, `scripts/mods.gd`, `scripts/draft_logique.gd`,
`scripts/bonus_sorts.gd`, `data/animations_sorts.gd`.

## Progression persistante

Les récompenses financent l'équipement, la forge et les maîtrises. Les dix armes
et les bijoux possèdent leurs propres caractéristiques ; les pouvoirs de
bijoux se débloquent avec la forge. Les doublons et butins de sorts suivent
les règles de progression des catalogues.

Les identifiants historiques d'équipement et migrations de sauvegarde restent
pris en charge afin de conserver les objets et rangs déjà acquis.

Sources : `data/catalogue_objets.gd`, `data/effets_bijoux.gd`,
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
