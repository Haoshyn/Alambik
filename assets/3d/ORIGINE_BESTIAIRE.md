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
OpenAI Image Generation puis affiné avec le même outil le 28 septembre 2026
pour ce projet : quatre cases
neutres de céramique brossée, tissu fin, parchemin et métal satiné, sans
texte, emprunt ni motif issu d'un autre jeu. La demande de génération
précisait une grille 2 × 2, des tons gris clairs et des coups de pinceau doux.
L'image utilisée mesure 1254 × 1254 pixels. Les générations sont conservées
dans le dossier `generated_images` de Codex et la texture précédente dans
la sauvegarde inventoriée indiquée ci-dessous.

Le premier UV place chaque pièce dans l'atlas, en conservant les dépliages
des volumes et des coordonnées continues le long des tubes et des plumes.
Les couleurs par sommet
portent le modelage peint et l'occlusion calculée dans Blender ; UV2 conserve
le rôle de matière et sa valeur lumineuse pour les variantes des mondes.
`data/presentation/matieres_bestiaire.gd` définit la rugosité et la part
métallique des quatre cases pour Blender et Godot. Une carte technique
partagée distingue le cuivre et l'acier du papier et du tissu mats.
Les sources Blender référencent l'atlas et conservent cette carte ; les GLB
portent les UV et les couleurs, puis `habillage_ennemis_3d.gd` installe les
deux textures partagées à l'exécution pour éviter de les embarquer trente
et une fois. Les variantes conservent ce matériau commun.

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
Les modèles, sources, texture et générateurs précédant la finition des
raccords et des matières sont conservés avec leurs empreintes dans
`/home/giovanni/.codex/visualizations/2026/09/28/01a0e718-1f25-7cd2-ac3b-915e171d584d/bestiaire/avant/`.
