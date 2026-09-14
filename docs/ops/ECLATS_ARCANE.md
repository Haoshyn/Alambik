# Menus Éclats d'arcane — 14 septembre 2026

## Intégration

Direction validée pour essai par le propriétaire : menus bleu/prune, accents turquoise et violets, textures de verre facetté, titres Cinzel et texte DM Sans clair. Les grandes surfaces beige/lavande pâle des menus sont remplacées. Équipement, sorts, maîtrises, réglages, pause, sélection de campagne, haltes, choix et bilans partagent cette présentation.

L'accueil utilise une nouvelle illustration de l'apprenti, produite à partir d'un rendu du véritable modèle. Le héros 3D, son sous-viewport, son éclairage et son animation ont été retirés de cet écran. Le fichier `ui/accueil_3d.gd` garde son chemin pour préserver les références existantes ; il ne contient plus de scène 3D. Compteurs, réglages, chapitre, lancement et navigation restent des contrôles natifs adaptatifs.

Trois atlas contiennent 90 illustrations : 83 identifiants existants de compétences, augmentations, éléments et sorts, plus sept commandes/ressources. `IconesArcane` conserve une correspondance explicite entre identifiant et cellule. Les maîtrises utilisent leur propre illustration, y compris lorsque verrouillées, un médaillon vectoriel et un signe distinct pour la sélection ou un rang acquis. Les choix restent trois cartes superposées avec descriptions issues des catalogues, et reçoivent des accents bleu, violet et turquoise.

Le fond, le cadre, les atlas et l'accueil sont des images séparées ; aucune capture de maquette n'est utilisée comme écran interactif. Le cadre est importé à 256 pixels puis étiré à neuf tranches. Provenance : `assets/visual/arcane/ORIGINE.md`.

## Périmètre

Aucun changement aux modèles, décors, ennemis, équilibrage ou règles de combat. Le HUD consomme également les couleurs partagées et les icônes de sorts ; sa disposition et ses mécanismes restent ceux déjà présents. Les anciennes illustrations de bijoux et d'armes sont conservées, puisque la demande d'icônes porte sur les sorts, augmentations et maîtrises.

## Vérifications

Toutes les commandes Godot sont exécutées en `--headless` et le rendu de référence Blender en `--background`. Aucun jeu ni atelier interactif ouvert.

- `./verifier.sh` : 35 suites, 15 120 assertions, zéro échec ; selftest compile et valide les données.
- `sondes/interface_azur.gd` : 194 contrôles, zéro échec. Achats, équipement, reroll, réglages en pause, couverture des catalogues par les icônes et absence de sous-viewport 3D à l'accueil.
- `sondes/menus_atelier.gd` : 924 contrôles, zéro échec, sur tous les menus testés.
- `sondes/formats_mobile.gd` : 1 774 contrôles, zéro échec, sur six formats de 480 × 800 à 960 × 540, y compris téléphone allongé et tablette.
- `./sondes/vingt_runs.sh` : vingt runs terminées, zéro blocage et aucune erreur de script. Le bot perd entre les salles 4 et 10 ; ceci vérifie la terminaison technique, pas l'équilibrage humain.
- APK debug exportée et signature vérifiée : `build/alambic-eclats-arcane.apk`. Export Godot et vérification indépendante par `apksigner`. Aucune installation sur téléphone effectuée.

Le selftest signale encore des ressources non libérées à sa fermeture : 109 instances ObjectDB, 40 ressources, 18 textures RendererDummy et deux ressources de police. Cette famille de diagnostics existait avant cette passe ; les nombres augmentent avec les nouvelles ressources. Aucune erreur de script dans le selftest. Les contrôles de disposition ne constituent pas une validation du rendu graphique.

Les illustrations ont été inspectées, mais aucune nouvelle capture Godot n'a été produite en mode headless. Lisibilité finale, appréciation artistique, masquage des icônes et cadrage du héros restent à apprécier sur téléphone. Les fonds d'atlas présentent quelques variations de couleur ; ce sont des vignettes illustrées, pas des silhouettes détourées.

Journaux : `tmp/eclats-arcane/verification.log`, `interface.log`, `menus.log`, `formats.log`, `vingt-runs.log` et `export.log`. Les sondes d'interface désactivent la sauvegarde avant leurs fixtures.
