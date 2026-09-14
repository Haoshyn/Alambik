# Essai manga — 14 septembre 2026

Le propriétaire apprécie le personnage et le fond de l'accueil, mais rejette
le réalisme des maîtrises, sorts et augmentations, les rectangles de l'accueil,
le cadrage de la navigation, le symbole des paramètres et le second écran de
transition. Cette demande prime sur l'ancienne direction pixel art conservée
dans `human/11_DIRECTION_ARTISTIQUE.txt`, qui n'a pas été modifiée.

## Présentation intégrée

- Illustration `arcane/accueil.png` et fond `arcane/fond.png` conservés.
- Jouer : sceau allongé corail à pointes et filet crème ; modes : ruban prune.
  Le chapitre reste dans une capsule sombre lisible, distincte des actions.
- Navigation : marges latérales, icônes plus petites, texte séparé des images,
  taille du libellé bornée par la largeur réelle de l'onglet, accents ambre,
  corail, menthe et lilas ; espace système inférieur conservé.
- Cadres partagés : aplats prune et contours colorés, sans verre peint ni
  médaillon métallique. Titres DM Sans à la place de Cinzel.
- 90 illustrations manga/chibi : cœurs symboliques, objets simples,
  familiers expressifs et effets colorés. Correspondance des identifiants
  préservée dans `IconesArcane`. Aucun masque circulaire qui coupe les pointes.
- Maîtrises : couleurs par branche ; descriptions, rangs, verrouillage et
  achat explicite conservés. Augmentations : cartes corail, menthe et ambre.
- Paramètres : véritable rouage à huit dents.
- Lancement et passage de salle : même livre illustré sur fond prune et trois
  points colorés. Ancien portail filaire retiré. Durées et fonctionnement des
  transitions conservés ; option Effets réduits respectée.

Armes, bijoux, modèles 3D, décors de combat et équilibrage inchangés.

## Vérifications

Toutes les exécutions Godot utilisent `--headless`, avec un profil de test
isolé. Aucune fenêtre de jeu ou d'atelier ouverte.

- `./verifier.sh` via `tools/verifier_windows.ps1` : 35 suites,
  15 120 assertions, zéro échec ; selftest compile et valide les données.
- `sondes/interface_azur.gd` : 194 contrôles, zéro échec, y compris couverture
  des catalogues, régions d'atlas et paramètres en pause. L'attente du test
  sur les listes passe de StyleBoxTexture à StyleBoxFlat pour la nouvelle DA.
- `sondes/menus_atelier.gd` : 928 contrôles, zéro échec.
- `sondes/formats_mobile.gd` : 1 781 contrôles, zéro échec, sur six formats.
- `./sondes/vingt_runs.sh` : vingt terminaisons, zéro blocage, zéro erreur de
  script. Salles atteintes 3 à 8 ; le bot perd ses runs, ce n'est pas une
  mesure de difficulté humaine.

La dernière retouche de l'atlas a été suivie d'un nouveau verifier et du
contrôle d'interface. Elle ne modifie ni la disposition ni le gameplay.

APK debug exportée : `build/alambic-manga.apk` (155 671 005 octets).
Signature vérifiée par Godot puis indépendamment par apksigner (v2 et v3).
Le profil d'export isolé a été raccordé au SDK Android et au JDK 17 locaux.
Aucune installation sur téléphone effectuée.

Le selftest présente encore les diagnostics de ressources à la fermeture
déjà connus : 18 textures RendererDummy, une police, 105 instances ObjectDB,
37 ressources. Aucune erreur de script.

Journaux dans `tmp/manga/`. Les planches ont été inspectées visuellement,
y compris la grille particulière du premier atlas. Les contrôles de cadrage
headless ne produisent pas de capture rendue : appréciation graphique et
toucher restent à valider sur téléphone avec `build/alambic-manga.apk`.
