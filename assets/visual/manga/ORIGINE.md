# Icônes et commandes manga

Créations originales pour Alambik, 14 septembre 2026. Aucun asset d'un autre
jeu ni référence artistique tierce. Les fonds et le personnage existants
restent ceux d'Éclats d'arcane.

`icones_0.png`, `icones_1.png`, `icones_2.png` : nouvelles illustrations
ImageGen, contours dessinés, ombres cel shading, couleurs corail, menthe,
ambre et lilas. Chaque planche mesure 1374 × 1145 pixels. Index exact :
`scripts/presentation/icones_arcane.gd` (90 identifiants).

La première génération ajoutait une sixième rangée de navigation à la
première planche. Une retouche ImageGen a retiré cette rangée et aéré les
icônes. La grille utile du résultat est `(0, 70, 1374, 1020)`, divisée en
six colonnes et cinq lignes. Les deux autres planches utilisent la surface
entière en 6 × 5. Les PNG originaux restent dans le répertoire de génération
Codex ; les copies du projet sont consommées directement par AtlasTexture.

Les anciennes commandes vectorielles originales `jouer.svg` et `ruban.svg`,
remplacées par le kit partagé, sont dans
`../OldAlambik/2026-09-20/organisation/retires/` depuis la racine du projet.

`navigation_aventure.png` : icône originale ImageGen ajoutée après demande
du propriétaire de remplacer la carte par des épées croisées. Silhouette
claire, gardes ambre, poignées prune, losange menthe, fond transparent.
L'import Godot est limité à 256 pixels ; l'original reste conservé.
