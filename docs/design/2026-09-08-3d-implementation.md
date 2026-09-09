# Migration visuelle 3D — plan d'exécution

Exécution directe Codex autorisée. Conception : `2026-09-08-3d-visual-design.md`.
Travail dans le dossier demandé en préservant les changements existants.

## Contraintes

Godot 4.7.1, GL Compatibility, Android portrait, logique et UI 2D conservées.
Aucun changement de statistiques, de collisions, de ciblage ou d'IA.
Images sources intactes ; les nouveaux volumes sont des meshes, jamais des panneaux illustrés.

## Étapes et critères

- [x] Examiner individuellement les dix références et confirmer Blender/Godot.
- [ ] Pipeline `tools/blender/build_all.py` : matériaux communs, meshes nommés,
  sources `.blend` exclues de l'import Godot, exports GLB et rapport de géométrie.
- [ ] Pont `scripts/presentation/pont_3d.gd` : conversion centrale XZ, compensation
  de l'inclinaison 55° pour projeter les pieds aux coordonnées logiques exactes.
  Test de projection Camera3D et aller-retour aux coins, centre, formats hauts et Mine.
- [ ] Monde `scenes/3d/monde_3d.tscn` : caméra orthographique, lumière unique,
  environnement mat, Atelier dégagé, proxies du héros/encrier/projectile/obstacle.
  Observer les états existants sans écrire dans les acteurs et sans changer `visible`
  (l'IA utilise cette propriété). Marqueur de rendu seulement dans les `_draw`.
- [ ] Capture de la tranche jouable dans Godot, contrôle des pieds, tirs et obstacles ;
  vérifier animations dans plusieurs états et transitions de salle.
- [ ] Étendre le catalogue de meshes à tous les ennemis, miniboss, boss, gardien,
  portail et effets de monde. Conserver les télégraphes et informations 2D alignés.
- [ ] Vérifier le coût géométrique, matériaux partagés, qualité réduite et absence
  d'imports Blender automatiques. Mesures PC séparées des performances Android réelles.
- [ ] Exécuter `verifier.sh` et `sondes/vingt_runs.sh` via Git Bash avec GODOT explicite,
  examiner les logs et consigner les limites restantes.

## Vérification ciblée

Le test `tests/test_pont_3d.gd` doit échouer si une inclinaison déplace les points au sol.
La sonde `sondes/visuel_3d.gd` doit vérifier les projections réelles, la couverture du
catalogue, le nettoyage des proxies et capturer le rendu sous GL Compatibility.
Les sources Blender sont déterministes et leur rapport liste triangles, matériaux,
animations, dimensions et fichiers exportés. Une absence de mesure sur appareil
Android reste explicitement non validée.
