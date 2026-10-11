# Aster chibi — héros d'Alambik

Modèle original créé le 10 octobre 2026 pour ce projet, dans un style de jeu
mobile (environ deux têtes de haut). Tous les volumes, le visage, le chapeau,
la robe et la palette sont construits par `tools/blender/heros_chibi.py`,
sans ressource extérieure ; la source modifiable est
`../../sources/characters/aster_chibi/aster_chibi.blend`.

Le squelette et les huit actions viennent d'Aster V7
(`../aster/ORIGINE.md`) : squelette raccourci depuis la racine, cuisses, bras
et pans plus courts, déplacements animés mis à la même échelle. Leurs
provenances restent celles d'Aster V7 (base VRoid HairSample_Male, CC0 ;
animations Quaternius Universal Animation Library, CC0). La baguette, le
grimoire et les repères `Aster_PriseArme` et `Aster_PointeBaguette` sont
repris d'Aster V7 et suivent le nouveau repos.

Régénération (sans fenêtre) :
`blender --background assets/3d/sources/characters/aster/aster.blend --python tools/blender/heros_chibi.py -- tmp/heros_chibi --exporter`
(`--apercu` produit des rendus de contrôle dans le dossier indiqué).
