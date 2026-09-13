# Assets Atelier vivant

Créés pour Alambic le 13 septembre 2026, après validation de la piste A.

- `fond.png` : fond d'atelier sans personnage ni interface, généré avec l'outil image_gen pour cette intégration. Les commandes sont des contrôles Godot et le héros est rendu séparément en 3D.
- `calcaire.png` : texture originale de matière, générée avec image_gen. Les joints et motifs de dalles sont produits par le shader du sol.
- SVG : dessins vectoriels originaux de sac, boussole, livre, fiole, baguette et interrupteurs.
- `armes.png` : cinq illustrations originales générées avec image_gen pour les
  armes existantes ; atlas de trois colonnes et deux lignes, dernière case vide.
- `parametres.svg`, `verrou.svg` : pictogrammes originaux, indépendants des glyphes
  Unicode de la police.
- Cadres gravés : SVG produits par `scripts/presentation/cadres_atelier.gd`,
  découpés en neuf tranches par Godot pour préserver les coins.
- Titres : Cinzel, distribuée sous SIL Open Font License ; source Google Fonts,
  licence embarquée dans `assets/fonts/OFL-Cinzel.txt`.

La source de direction et les mesures sont dans `docs/design/ATELIER_VIVANT.md` et `docs/ops/ATELIER_VIVANT.md`.
