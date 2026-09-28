# Origine du bestiaire 3D

Les onze modèles de `enemies/` et les vingt modèles de `bosses/` sont des
créations procédurales originales pour Alambik. Ils ne reprennent ni modèle,
ni texture, ni personnage d'un autre jeu.

Les sources éditables sont les fichiers `.blend` correspondants dans
`sources/enemies/` et `sources/bosses/`. Les générateurs sont
`tools/blender/bestiaire_sculpte.py`, `creatures_bestiaire.py`,
`souverains_bestiaire.py`, `sculpture_bestiaire.py` et `matieres_bestiaire.py`. Ils réemploient les
primitives originales de `build_all.py`. La génération ciblée ne reconstruit
ni le mage, ni ses armes, ni le portail.

L'atlas original `textures/bestiaire_matieres_peintes.png` a été généré avec
OpenAI Image Generation le 28 septembre 2026 pour ce projet : quatre cases
neutres de céramique brossée, tissu fin, parchemin et métal satiné, sans
texte, emprunt ni motif issu d'un autre jeu. La demande de génération
précisait une grille 2 × 2, des tons gris clairs et des coups de pinceau doux.
L'original est conservé dans le dossier `generated_images` de Codex.

Le premier UV place chaque pièce dans l'atlas. Les couleurs par sommet
portent le modelage peint et l'occlusion calculée dans Blender ; UV2 conserve
le rôle de matière et sa valeur lumineuse pour les variantes des mondes.
Les sources Blender référencent l'atlas ; les GLB portent les UV et les
couleurs, puis `habillage_ennemis_3d.gd` installe la texture partagée à
l'exécution pour éviter de l'embarquer trente et une fois.

Chaque articulation regroupe ses pièces en une surface. Les pivots `Art_*`
suivent les états de combat via `animation_membres_ennemis.gd` ; les repères
`Appui_*` et les segments de patte sont résolus par `appuis_bestiaire_3d.gd`.
Les poses de l'aperçu animé sont exportées par le proxy réel de Godot,
puis rendues dans Blender ; ce n'est pas une capture sur téléphone.

Les sources et exports antérieurs à cette refonte ont été copiés avec
inventaire dans `../Alambik_sauvegardes/monstres_avant_20260928_005051/`
depuis la racine du projet.
La version précédant les matières peintes est aussi conservée dans
`../Alambik_sauvegardes/matieres_avant_20260928_012750/`, avec inventaire.
