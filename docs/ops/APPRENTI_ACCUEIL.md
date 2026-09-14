# Essai Apprenti de l'accueil — 14 septembre 2026

Le propriétaire conserve les maîtrises et les icônes manga. Il demande de
remplacer le bouton Jouer rouge, les projectiles rectangulaires du bâton et de
tenter une variante 3D inspirée du personnage de l'illustration de l'accueil,
en gardant le modèle existant.

## Modèle séparé et retour arrière

Le générateur `tools/blender/apprenti_accueil.py` réutilise les outils de
construction, le squelette et les gestes de l'Apprenti A. Il remodèle le visage
(yeux bruns plaqués sur la courbure, blancs, pupilles, reflets, sourcils, nez,
sourire), la frange et les tempes, incline le chapeau et élargit le pan de
l'écharpe. Les couleurs reprennent le violet, le turquoise et le cuir brun
de `assets/visual/arcane/accueil.png`.

Il s'agit d'une interprétation en volume de l'illustration, à apprécier par
le propriétaire ; ce n'est pas une reconstruction automatique exacte.

- Modèle actif : `assets/3d/characters/apprenti_accueil.glb`.
- Source : `assets/3d/sources/characters/apprenti_accueil.blend`.
- 80 197 triangles avant LOD, 15 surfaces, 18 os, 3 133 876 octets.
- Six animations : repos, course, attaque, touche, mort, victoire.
- Baguette toujours attachée à la main droite et synchronisation conservée.
- Rendus Blender : `tmp/apprenti-accueil/trois-quarts.png`, `face.png`,
  `combat.png`. Ce sont des rendus du vrai maillage, pas des captures Godot.

`apprenti_a.glb`, `apprenti_a.blend` et `tools/blender/apprenti_a.py` n'ont
pas été modifiés : comparaison SHA-256 avec l'état initial réussie. Le
générateur exporte d'abord dans `tmp/apprenti-accueil/export`, puis copie
vers les nouveaux noms uniquement.

Pour revenir à la v9, affecter `HEROS_MODELE_ORIGINAL` à `HEROS_MODELE`
dans `data/visuels_3d.gd`, puis réexporter l'APK. Les deux modèles sont
disponibles, sans remplacement de la sauvegarde du joueur.

## Interface et tirs

Jouer devient une commande violette de 624 × 136 unités, avec contour lilas,
texte clair, états appuyé/survolé et cible tactile conservés. Les maîtrises,
sorts et augmentations validés ne sont pas retouchés.

Les tirs alliés utilisent un SphereMesh partagé et un shader opaque avec
reflet crème. Le bâton standard produit une perle lavande, l'aiguille est
allongée et les autres armes gardent des tailles/couleurs distinctes. Deux
petites perles décroissantes remplacent le ruban plat ; elles disparaissent
en mode Effets réduits, le projectile principal reste visible. Leur hauteur
les maintient au-dessus du sol pour ne pas couper la silhouette.

Les projectiles ennemis gardent leur présentation. Aucun changement de
collision, vitesse, portée, dégâts, cadence ou règles de tir. Les volumes
et matériaux des projectiles sont testés en headless ; l'aspect du shader
sur le téléphone reste à apprécier en jeu.

## Contrôles

Toutes les exécutions Godot sont headless et Blender est lancé avec
`--background`. Aucun atelier ni fenêtre de jeu ouvert. Profil des sondes isolé.

- `verifier.sh` via `tools/verifier_windows.ps1` : 35 suites, 15 120 assertions,
  zéro échec ; selftest compile et valide les données.
- `projectiles_manga.gd` : 55 assertions, zéro échec, cinq armes et tirs
  ennemis, ancrage à la collision, hauteur du volume et Effets réduits.
- `fluidite_heros_3d.gd` : 643 assertions, zéro échec avec le nouveau GLB.
- `synchronisation_tir.gd` : 30 assertions, zéro échec.
- `interface_azur.gd` : 194 contrôles, zéro échec.
- `formats_mobile.gd` : 1 781 contrôles, zéro échec sur six formats.
- `vingt_runs.sh` : vingt runs terminées, zéro blocage, aucune erreur de
  script. Le bot atteint les salles 3 à 7 puis perd ; cela valide la
  terminaison technique, pas la difficulté ressentie par un joueur.
- `build/alambic-apprenti-accueil.apk` : export debug de 157 158 163 octets,
  signature vérifiée par Godot puis apksigner (v2 et v3). Pas d'installation.

Le selftest conserve ses diagnostics de fermeture : 18 textures Dummy,
une police, 105 instances ObjectDB et 37 ressources. Aucune erreur de script.
Ces diagnostics existaient avant cette passe. Journaux dans
`tmp/apprenti-accueil/`. Performances et appréciation artistique sur téléphone
restent à valider ; les rendus studio ne reproduisent pas le shader Godot.
