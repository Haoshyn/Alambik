# Matières des terrains de combat

Peintures et normales originales générées le 28 septembre 2026 pour Alambik
par `tools/generer_matieres_terrains.gd`. Aucune image externe n'est utilisée.
Les palettes et les matières sont définies dans
`data/presentation/decors_terrains.gd`.

Les quatre paires de PNG RGB de 384 × 384 sont conservées avec leur générateur :
encre visqueuse violette, sable ocre strié, eau turquoise et lave à veines chaudes.
Les nuances larges, reflets et normales donnent une surface aux nappes.
Leur silhouette vient du contour déterministe de la simulation ; la peinture
ne définit ni une taille supplémentaire ni un effet hors de ce contour.

Godot produit les mipmaps et les versions compressées utilisées sur Android.
Les normales modifient l'éclairage sans relever les surfaces au-dessus des
ombres des acteurs. Les ressources des sols de salle restent distinctes.
