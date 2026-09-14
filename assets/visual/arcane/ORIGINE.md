# Éclats d'arcane — assets d'interface

Créés pour Alambik le 14 septembre 2026, après validation de la proposition Éclats d'arcane. Aucune image d'un autre jeu utilisée.

- `accueil.png` : illustration originale produite avec ImageGen à partir d'un rendu Blender du modèle local `assets/3d/sources/characters/apprenti_a.blend`. Chapeau, costume, écharpe et accessoires servent de référence ; illustration embellie à la demande du propriétaire. Aucune modification du modèle 3D. Le rendu de référence est dans `tmp/eclats-arcane/reference.png`.
- `fond.png` : fond abstrait bleu/prune original produit avec ImageGen, sans personnage ni texte.
- `cadre.png` : texture de verre facetté originale produite avec ImageGen, puis retouchée avec le même outil pour rendre le centre opaque et calmer les bordures. Import limité à 256 pixels pour garder des coins compacts lors de l'étirement à neuf tranches ; source haute définition conservée.
- `icones_0.png`, `icones_1.png`, `icones_2.png` : trois planches originales ImageGen de 30 illustrations chacune. Découpage en six colonnes et cinq lignes par `AtlasTexture`, sans dupliquer les fichiers. L'ordre exact est conservé dans `scripts/presentation/icones_arcane.gd`, de gauche à droite puis de haut en bas : 83 identifiants existants et sept commandes/ressources.
- `medaillon.svg` : dessin vectoriel original, avec verre bleu, intérieur prune et trois attaches. Utilisé par les boutons de maîtrises. Le shader `shaders/icone_arcane.gdshader` adoucit les bords de leur illustration dans le médaillon.

Les textes et nombres sont des contrôles Godot, jamais des pixels incorporés aux images. Cinzel est déjà fournie dans `assets/fonts/` avec sa licence ; DM Sans reste la police des descriptions et compteurs.

Les planches générées n'ont pas toutes un fond parfaitement uniforme : les cellules sont utilisées comme vignettes illustrées, avec une atténuation circulaire pour les maîtrises. Les illustrations ont été inspectées en planches ; leur appréciation à taille réelle sur téléphone reste à faire.
