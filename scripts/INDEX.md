# Carte des scripts

| Domaine | Fichiers | Responsabilité |
|---|---|---|
| Run | `run.gd`, `bilan_run.gd` | orchestration d'une tentative, transitions, récompenses |
| Acteurs | `heros.gd`, `ennemi.gd`, `boss.gd`, `gardien.gd`, `cerveaux.gd` | héros, ennemis, boss, IA spécialisée |
| Combat | `projectile.gd`, `tir.gd`, `ciblage.gd`, `stats.gd`, `priorite_projectile.gd` | projectile, tir, ciblage, stats et priorités |
| Sorts | `bonus_sorts.gd` | attaque, dégâts, récupération et rayon avec les bonus de run |
| Monde | `salle.gd`, `geometrie.gd`, `fond_adaptatif.gd` | salle, géométrie, adaptation du terrain |
| Améliorations | `mods.gd`, `reactif.gd`, `draft_logique.gd`, `details_reactif.gd` | effets et logique des choix de run |
| Animation du héros 3D | `presentation/animation_heros_3d.gd`, `presentation/suivi_visuel_2d.gd` | mélange des gestes, cadence et interpolation visuelle |
| Présentation 3D et styles | `presentation/` | rendu, matériaux, effets, styles et icônes |
| Présentation 2D | `dessin.gd`, `palette.gd`, `polices.gd`, `style_interface.gd`, `effets.gd`, `fond.gd` | dessin, polices et habillage commun |
| Entrées | `joystick_logique.gd`, `balayage_pages.gd`, `raccourci_tactile.gd` | joystick, balayage, raccourcis tactiles |
| Menu | `menu.gd` | accueil et navigation principale |
| Capture | `capture.gd` | captures de développement sur demande |
| Fusions conservées | `ameliorations/atelier_fusions.gd` | ancienne expérience, hors choix de la boucle active |

Tous les chemins de cette carte sont relatifs à `scripts/`. La majorité des
scripts sont à sa racine. Les scènes et préchargements utilisent ces chemins ;
ne pas déplacer les fichiers pour faire correspondre le dépôt à une ancienne
description de son organisation.
