# Direction artistique active

Repère du jeu actuel, à consulter pour une tâche visuelle. Les anciennes fiches
de `human/` sont archivées dans `../OldAlambik/` depuis la racine du projet ;
elles conservent les idées historiques sans définir le rendu actuel.

## Identité et combat

- Fantasy alchimique originale, lumineuse et aventureuse : encre, fioles,
  grimoires, sceaux et magie. La lisibilité sur téléphone prime sur l'ornement.
- Le combat utilise des modèles et effets 3D sur une simulation 2D.
- Le héros est le mage sculpté, avec son chapeau, ses textures, ses animations
  et une arme tenue séparée qui suit l'équipement.
- Les silhouettes, impacts et télégraphes doivent rester distincts. Les effets
  décoratifs ne masquent pas les dangers et ne rendent pas les hitbox ambiguës.
- Le centre de l'arène reste calme ; le décor plus riche se place en bordure.
  Les couleurs des mondes distinguent leur ambiance sans brouiller les attaques.

## Interface du scriptorium

- Fond peint saphir, or chaud, turquoise et crème ; cadres, sceaux, emblèmes,
  jauges et coffre du kit partagé `assets/visual/interface/`.
- Fantasy féerique lumineuse, avec des icônes peintes en volume, des contours
  dorés arrondis et de l'émail lisse, proches du rendu du héros. Utiliser le kit
  `interface/peint/` plutôt que des emblèmes filaires et des cadres anguleux.
  Éviter le grain de toile et les halos bruités ; filtrage linéaire avec mipmaps
  pour garder les contours propres à l'échelle du téléphone.
- L'accueil conserve l'illustration `assets/visual/arcane/accueil.png`.
- Garder une action principale claire par écran, des textes contrastés et de
  grandes cibles tactiles adaptées au portrait et aux zones sûres du téléphone.
- Dorures fines, marges intérieures généreuses et compteurs sur fond sombre.
  Le HUD de combat utilise des panneaux discrets pour dégager textes et jauges.
- Les polices utilisent leurs graisses natives ; aucun détourage d'image ni
  épaississement artificiel ne doit modifier le rendu des glyphes MSDF.
- Textes et valeurs restent des contrôles Godot, séparés des illustrations.
  Animations et lumières accompagnent le toucher sans gêner les longues lectures.

## Fichiers de référence

- Modèle et rendu : `data/visuels_3d.gd`, `scripts/presentation/monde_3d.gd`,
  `scripts/presentation/materiaux_apprenti.gd`, `scripts/presentation/arme_tenue_3d.gd`.
- Interface : `scripts/presentation/style_azur.gd`, `ui/`,
  `assets/visual/interface/ORIGINE.md`, `assets/visual/arcane/ORIGINE.md`.
- Génération du héros : `tools/blender/mage_sculpte.py` et ses modules.
