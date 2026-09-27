# Logique — index

| Catégorie | Point d'entrée |
|---|---|
| Coordination de la tentative | [run.gd](run.gd) |
| Coordination de la navigation | [menu.gd](menu.gd) |
| Statistiques et attaque | [combat/stats.gd](combat/stats.gd), [bonus_attaque.gd](combat/bonus_attaque.gd) |
| Héros, dégâts reçus et passifs équipés | [combat/heros.gd](combat/heros.gd) |
| Tirs et impacts | [combat/tir.gd](combat/tir.gd), [projectile.gd](combat/projectile.gd), [ciblage.gd](combat/ciblage.gd) |
| Familier autonome et approche des boss | [combat/familier.gd](combat/familier.gd), [contact_boss.gd](combat/contact_boss.gd) ; contrôle dans `../tools/verifier_projectiles.gd` |
| Ennemis et boss | [combat/ennemi.gd](combat/ennemi.gd), [boss.gd](combat/boss.gd), [capacites_ennemis.gd](combat/capacites_ennemis.gd), [cerveaux.gd](combat/cerveaux.gd) |
| Augments : données de choix, effets, offres, texte | [augments/reactif.gd](augments/reactif.gd), [mods.gd](augments/mods.gd), [draft_logique.gd](augments/draft_logique.gd), [details_reactif.gd](augments/details_reactif.gd) |
| Salle et échelle des ennemis | [monde/salle.gd](monde/salle.gd) |
| Approche, flancs et orbites des boss | [combat/deplacement_boss.gd](combat/deplacement_boss.gd), valeurs dans `../data/mondes/deplacements_boss.gd` ; contrôle dans `../tools/verifier_patterns.gd` |
| Obstacles et zones | [monde/geometrie.gd](monde/geometrie.gd), [terrain_elementaire.gd](monde/terrain_elementaire.gd), [zone_hostile.gd](monde/zone_hostile.gd) |
| Collecte d'XP | [monde/collecte_experience.gd](monde/collecte_experience.gd) |
| Cœurs de soin au sol | [monde/collecte_soins.gd](monde/collecte_soins.gd), paramètres dans `../data/progression/soins_run.gd` |
| Butin et fin de run | [progression/bilan_run.gd](progression/bilan_run.gd) |
| Style et gestes communs | `interface/` : joystick, transition, palette, polices, styles et rendu 2D de secours |
| Rendu du combat | [presentation/monde_3d.gd](presentation/monde_3d.gd), [arene_3d.gd](presentation/arene_3d.gd), [proxy_3d.gd](presentation/proxy_3d.gd) |
| Héros et familier 3D | `presentation/animation_heros_3d.gd`, `materiaux_apprenti.gd`, `suivi_familier_3d.gd` |
| Retours visuels | `presentation/effets.gd`, `effets_3d.gd`, `animation_impacts.gd`, `annonces_ennemis.gd` |
| Nombres de dégâts infligés | `presentation/nombres_degats.gd`, relié aux signaux de combat par `monde/salle.gd` ; contrôle dans `../tools/verifier_degats_affiches.gd` |
| Bruitages | [audio/synthese_effets.gd](audio/synthese_effets.gd) |
| Capture de développement | [capture.gd](capture.gd) ; bot PC dans `../sondes/` |

Le moteur de calcul lit les catalogues de [data](../data/INDEX.md).
Les acteurs émettent des événements, le rendu les représente et l'UI
présente des décisions ; ni rendu ni écrans ne redéfinissent l'équilibrage.
