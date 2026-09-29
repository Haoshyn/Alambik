# Sols de combat — enduit ciré et bordures d'émail

## Matière active

`enduit_cire.png` est une peinture originale générée avec `imagegen` le
28 septembre 2026, à partir de l'enduit ciré B retenu par le propriétaire.
Source : `exec-e6147de3-2ed8-47b2-97da-0f690f79517f.png`. Le PNG RGB de
1024 × 1536 est conservé sans transformation. Il représente uniquement la
matière en vue orthographique, sans objets, interface, joints ni éclats.
La génération ne reprend aucun contenu d'un autre jeu.

Cette base nacrée est commune aux cinq mondes. Leurs palettes et les graines
de composition sont définies dans `data/presentation/decors_mondes.gd`.
`scripts/presentation/sol_alchimique.gd` répartit des reprises plus chaudes,
des plages patinées et un passage poli selon l'étage. Les limites des plages
restent irrégulières et fondues ; l'orientation et la déformation locale des
traces de taloche changent avec la composition. Les couleurs et les UV sont
portés par un seul maillage, sans surface transparente supplémentaire.
La texture utilise compression ordinateur et Android, mipmaps et filtrage
anisotrope. Le centre reste calme et les variations ne signalent aucun danger.

Les pigments de chaque monde sont renforcés. La bordure originale est
générée dans `scripts/presentation/bordures_sol.gd` : émail coloré et filet
doré, construits par polygones sans ressource extérieure. Ils reprennent
cette peinture pour leur matière et les palettes de
`data/presentation/decors_mondes.gd`. Un maillage porte l'ensemble,
découpé sur le contour et placé sous les flaques, sans collision ni halo.
Les illustrations de livres, feuilles et autres motifs plaqués au sol ont
été retirées. Leur source précédente est archivée hors dépôt dans
`/home/giovanni/.codex/visualizations/2026/09/28/01a0e704-4057-73e1-b607-ceffdccb22dc/sources_motifs_retires/`,
avec son inventaire. L'identifiant du script est conservé avec la bordure.

Les décors en volume sont originaux et générés dans
`scripts/presentation/decors_rives.gd` et `ornements_monde.gd` : lanternes,
établis, jarres, champignons, coraux, carillons et cristaux. Leurs surfaces
reprennent l'atlas peint original du bestiaire ; ils restent hors du
contour jouable. Des parures miniatures restent sur les murets et rochers,
dans leur emprise physique. Leur composition et la frise varient par étage.
Les contours viennent de `data/mondes/formes_salles.gd` et sont communs à
la simulation et au décor.
Une salle conserve la même matière et les mêmes zones à chaque reconstruction.

## Sources précédentes conservées

Peintures originales générées avec `imagegen` le 28 septembre 2026 pour
Alambik, à partir du précédent style D. Chaque albédo est
une vue orthographique de matière, sans interface ni objets de décor. Aucun
élément d'un autre jeu n'a été repris.

Les cinq PNG RGB de 1024 × 1536 et leurs identifiants d'import sont conservés.
Ils ne servent plus au sol actif.

| Source conservée | Matière | Génération source |
| --- | --- | --- |
| `terrazzo_encre.png` | Liant lavande, faïence violette et ivoire | `exec-eae896b0-f650-4fc6-a1d9-3244493b4ee1.png` |
| `terrazzo_terre.png` | Liant sable, terre cuite et céramique végétale | `exec-6b0b9037-a524-4c7e-9782-66c609d4fb85.png` |
| `terrazzo_eau.png` | Liant turquoise pâle, faïence bleue et nacre | `exec-28fbc696-8f3e-4ad2-bec5-c1f124c911d8.png` |
| `terrazzo_air.png` | Liant gris perle, fragments fins bleu ardoise | `exec-74dd9b1e-6519-4667-a8d8-9d5da867fa09.png` |
| `terrazzo_feu.png` | Liant cendre, terre cuite et cuivre patiné | `exec-c183356c-9c74-46d1-8b28-2d958befdb74.png` |

La patine et les grands éclats de ces anciennes matières appartiennent à
leurs peintures d'origine. Les incrustations de céramique supplémentaires
ont été remplacées par les reprises d'enduit.

Les aperçus obtenus par `tools/verifier_decors.tscn` et
`tools/blender/apercu_decors.py` montrent cette géométrie et ces matières.
L'export convertit les couleurs de sommets sRGB en linéaire, comme dans le
rendu du jeu. Les sols conservent leur absence d'ombre portée. L'éclairage
Blender permet le contrôle visuel ; il ne constitue pas une capture de
gameplay Android.
