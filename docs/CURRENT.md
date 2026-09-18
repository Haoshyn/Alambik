# État courant — 18 septembre 2026

Ce fichier décrit la base active. Les valeurs exactes restent dans `data/` ; les
anciens essais et résultats de tests ne valent pas validation de l'état présent.

## Présentation

- Les Paramètres proposent temporairement Basic (modèle actuel, par défaut),
  v2 (Little Purple Wizard Meshy texturé depuis `magealam.png` et articulé) et KayKit (Mage et animations
  du pack fourni, avec palette, chapeau et accessoires adaptés à cette référence). Le choix est sauvegardé et appliqué en combat.
- v2 : chapeau et écharpe avec matières dédiées, ruban/boucle en volume ; course et lancer plus amples, fiole liée à la ceinture.
- Basic utilise `assets/3d/characters/apprenti_accueil_v2.glb`. Ses matières passent par
  `scripts/presentation/materiaux_apprenti.gd` et
  `shaders/apprenti_accueil_surface.gdshader`.
- Les essais Feutre & cuir et les variantes chibi de l'atelier du 18 septembre
  ont été rejetés. Ils sont retirés ; aucune nouvelle direction de héros n'est
  retenue. Le modèle actif reste inchangé.
- L'accueil utilise l'illustration `assets/visual/arcane/accueil.png`, affichée par
  `ui/accueil_3d.gd` malgré son nom. Le combat conserve sa présentation 3D.
- Interface portrait adaptative, base 1080 × 1920 ; menus, équipement, maîtrises,
  sorts et commandes tactiles sont en place.

## Boucle et progression

- Campagne par chapitres et salles, Mine de survie et Épreuves de sorts.
- Améliorations de run, sorts actifs, passifs et ultimes ; les fusions
  expérimentales ne font plus partie des choix proposés dans la boucle active.
- Équipement, forge, maîtrises et progression sauvegardée dans
  `autoload/reglages_joueur.gd`.
- Butins et garanties partagés entre aperçu et attribution :
  `data/butins_run.gd`, `data/recompenses.gd`, `data/epreuves.gd` et
  `scripts/bilan_run.gd`. Courbes statistiques : `data/progression_statistiques.gd`.
- Formes des salles et décors par monde : `data/formes_salles.gd` et
  `data/decors_mondes.gd`.

## Reprise du travail

Les variantes du héros restent des exemples à comparer. Les prochaines tâches doivent partir du
besoin demandé et des catalogues actifs, pas des anciennes listes de chantier.

Le processus par défaut est celui d'`AGENTS.md` : modification ciblée et relecture ;
le propriétaire teste le jeu. Tests, runs et APK uniquement sur demande explicite.
L'ancien état détaillé est conservé dans
`docs/archive/ETAT_AVANT_MENAGE_2026-09-18.md` à titre historique.
