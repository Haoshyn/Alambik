# Rendu Cuivre & Azur — 10 septembre 2026

> Cette page décrit la première intégration. Le cadrage de l’accueil, les salles, les icônes, le mage, les tirs et le portail ont ensuite évolué : voir [Retouches graphiques](RETOUCHES_GRAPHIQUES.md) pour leur état actuel et les nouvelles mesures.

## Accueil conservé

`assets/visual/azur/accueil_valide.png` est une copie exacte de l’image approuvée. Son SHA-256 est `464be56370deece952b9c44bc2f24dc34648c8bd2d2710e562dd4f2fde8d1414`. Aucune réduction de contraste n’a été appliquée.

`ui/accueil_3d.gd` conserve son nom pour les références existantes ; il affiche maintenant cette illustration avec `shaders/accueil_vivant.gdshader`. Respiration localisée, tissu, nuages, vapeur et bulles bougent ; la navigation reste immobile. Les compteurs et le chapitre sont remplacés à l’exécution par les valeurs réelles. Le réglage des effets réduits diminue les mouvements. La carte de chapitre ouvre aussi la Mine et les Épreuves ; Jouer lance le mode mémorisé.

## Interfaces

`StyleAzur` centralise panneaux, couleurs, typographie, atlas et contrôles. Équipement, maîtrises, sorts, sélection de campagne, améliorations, réglages, pause, infusion, récompenses et bilan utilisent désormais des contrôles natifs. Les longues listes défilent verticalement. Les trois améliorations sont des cartes horizontales superposées. Aucun portrait de personnage n’est utilisé dans les écrans fonctionnels.

Les emplacements visibles sont Anneau, Collier, Bague ; les identifiants de sauvegarde restent compatibles. Les opérations d’équipement, Forge et maîtrise passent par les API existantes. Consulter une maîtrise ne l’achète pas. Le dernier tirage désactive son bouton, et un double appui ne donne pas deux récompenses. Une infusion sans choix disponible propose Continuer. La réinitialisation de progression conserve sa confirmation en deux appuis.

## Héros et terrain

Le nouveau héros est réellement modélisé dans Blender : surfaces de manteau, chapeau asymétrique, visage, mèches effilées, mains à quatre doigts et pouce, bottes, coutures, écharpe, grimoire, potion à la ceinture et sceptre à cœur violet. Le modèle exporté compte 41 630 triangles et 11 surfaces, environ 1,8 Mo. Six animations : repos, course, attaque, touche, mort, victoire. Le squelette et ses poids sont conservés dans la source.

- Source : `assets/3d/sources/characters/heros.blend`.
- Modèle utilisé par le combat : `assets/3d/characters/heros.glb`.
- Génération reproductible : `tools/blender/heros_azur.py`, également appelée par `build_all.py`.

```powershell
& 'C:/Program Files/Blender Foundation/Blender 5.2/blender.exe' --background --python tools/blender/heros_azur.py
```

Le gardien, les onze ennemis, vingt boss/miniboss et les accessoires existants restent implémentés. Ils n’ont pas reçu la même sculpture détaillée que le héros lors de cette intervention.

La salle de campagne mesure 1500 × 2100 unités logiques, soit 15 × 21 avant correction de projection. Elle conserve un rectangle large et portrait. La caméra suit le héros à un zoom de 1,05 et n’affiche pas toute la salle. Les petits obstacles gardent des passages latéraux. Le sol utilise une texture originale de calcaire ; les éléments décoratifs restent hors du périmètre. Les règles et collisions sont en 2D, les modèles en 3D.

## Formats et vérifications

Le cadre logique 1080 × 1920 conserve les proportions via `canvas_items` et `keep`. Les autres ratios affichent des bandes ; l’illustration d’accueil est cadrée séparément sans étirement. Les encoches sont converties dans le repère du viewport par `autoload/ecran.gd`.

Essais avec Godot **4.7.1**, profil isolé dans `tmp/profil/` :

- `tools/verifier_windows.ps1` (`verifier.sh`) : **30 suites, 9 033 assertions, zéro échec**, compilation et cohérence valides.
- `tools/verifier_windows.ps1 -VingtRuns` : **20 fins de run, zéro blocage ni erreur de script**. Cette série finale compte 2 victoires et 18 défaites du bot : elle valide la terminaison, pas l’équilibrage ni la difficulté pour un humain. Des changements d’équilibrage ont été réalisés en parallèle dans le workspace et sont conservés.
- `sondes/interface_azur.gd` : **18 contrôles, zéro échec** : équipement, Forge et coût réel, achat explicite, mémorisation du mode, tirage épuisé, double appui, volume et animation locale sans déplacement des boutons.
- `sondes/formats_mobile.gd` : **1 338 contrôles, zéro échec**, formats 540 × 960, 540 × 1200, 480 × 800, 768 × 1024, 960 × 540 ; navigation, fenêtres modales, transitions rapides et lancement du combat.
- `sondes/integration_3d.gd` : **zéro échec** : projections sur les collisions, course articulée, nettoyage des modèles, portail et effets réduits. Dernière pose de mesure : 97 appels de dessin, 25 158 primitives (LOD et visibilité compris), sur RTX 4070 SUPER. Ce n’est pas une mesure Android.

Les journaux finaux et les captures sont dans `tmp/*azur*`. `tmp/azur-apercu.html` rassemble les captures Godot et un rendu Blender du modèle exporté.

Le magasin de certificats Windows produit toujours un diagnostic au démarrage ; certains arrêts graphiques signalent des ressources encore utilisées. Pas de validation sur téléphone physique, de mesure thermique/batterie, ni de nouvelle APK/AAB dans cette intervention. La préparation Google Play nécessite encore cette validation et le contrôle de la difficulté.
