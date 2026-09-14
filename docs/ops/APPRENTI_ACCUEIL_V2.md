# Apprenti accueil v2 — 14 septembre 2026

Le propriétaire rejette le rendu 3D précédent, surtout la forme générale,
les bras, la peau et les yeux. Il conserve le reste des menus et demande
des épées croisées à la place de la carte de l'onglet Aventure.

## Modifications

`tools/blender/apprenti_accueil_v2.py` construit une variante séparée. Le
buste et les jambes gagnent de la hauteur, la taille de la tunique est
resserrée et son ourlet suit légèrement les cuisses. Les manches ont une
section plus épaisse, des variations de tissu et un revers ; elles restent
pondérées progressivement entre bras et avant-bras. Les mains sont resculptées
en surfaces continues. La main libre est entrouverte, la droite tient la
baguette. Les poignets sont amincis dans le revers. Les articulations des
bras sont repositionnées pour suivre les nouveaux volumes.

Les yeux ont un iris brun et miel, un blanc plus discret et des reflets
dessinés. La couleur de peau est reprise. Le shader
`shaders/apprenti_accueil_surface.gdshader` utilise des ombres chaudes et une
occlusion réduite sur la peau, et traite les yeux séparément des tissus.
Il est appliqué uniquement au nouveau modèle par `materiaux_apprenti.gd`.
Les anciennes variantes conservent leur shader : le retour arrière reste
fidèle à leur présentation précédente.

Modèle actif : `assets/3d/characters/apprenti_accueil_v2.glb`, sélectionné par
`Visuels3D.HEROS_MODELE`. Source Blender au même nom dans
`assets/3d/sources/characters/`. 86 590 triangles avant LOD, 16 surfaces,
18 os et six animations. Les gestes et leur synchronisation sont conservés.

Les fichiers `apprenti_a.glb`, `apprenti_accueil.glb` et la source Blender de
l'accueil v1 sont inchangés, vérifiés par SHA-256. Pour revenir en arrière,
pointer `HEROS_MODELE` sur `HEROS_MODELE_ACCUEIL` ou `HEROS_MODELE_ORIGINAL`.

L'icône `assets/visual/manga/navigation_aventure.png` est une création
ImageGen originale : épées claires croisées, gardes ambre, poignées prune et
petit losange menthe. Import borné à 256 pixels. `IconesArcane` ne remplace
que `navigation_aventure` ; les autres icônes restent celles validées.

## Vérifications et limites

Godot exclusivement en `--headless`, Blender en `--background`, profil des
sondes isolé. Aucune fenêtre de jeu ni atelier ouvert.

- `verifier.sh` : 35 suites, 15 120 assertions, zéro échec ; selftest valide.
- `materiaux_accueil.gd` : 22 assertions, zéro échec. Matériau spécifique
  de la peau et des yeux, rig complet, shader conservé pour les deux anciens
  modèles, nouvelle icône et résolution d'import.
- `fluidite_heros_3d.gd` : 643 assertions, zéro échec.
- `synchronisation_tir.gd` : 30 assertions, zéro échec.
- `interface_azur.gd` : 194 contrôles, zéro échec.
- `formats_mobile.gd` : 1 781 contrôles, zéro échec sur six formats.
- `vingt_runs.sh` : vingt runs terminées sans blocage ni erreur de script,
  après la dernière retouche du modèle. Le bot perd entre les salles 3 et 8 ;
  ce contrôle ne mesure pas la difficulté ressentie.
- `build/alambic-apprenti-accueil-v2.apk` : export debug, signature vérifiée
  par Godot puis indépendamment avec apksigner (v2 et v3). Pas d'installation.

Les vérifications générales, matériaux et animations ont été relancées après
la retouche finale des poignets et de l'ourlet. Rendus Blender de face,
trois-quarts, angle plongeant, course et attaque inspectés dans
`tmp/apprenti-accueil-v2/`. Ces images vérifient la géométrie et les poses ;
elles ne reproduisent pas le shader Godot. Le rendu effectif et la satisfaction
artistique restent à valider directement sur téléphone. Aucun changement de
statistiques, collisions ou comportement des projectiles.

Le selftest signale toujours des ressources à la fermeture : 19 textures
Dummy, une police, 107 instances ObjectDB et 38 ressources. Aucune erreur de
script. Les mêmes types de diagnostics existaient avant cette passe.
Journaux complets dans `tmp/apprenti-accueil-v2/`.
