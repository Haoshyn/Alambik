# Provenance des éléments

## Anatomie, visage, cheveux, squelette initial et textures associées

- Modèle : **HairSample_Male**, exemple de la version bêta de VRoid Studio, pixiv.
- Licence déclarée par pixiv : **CC0**.
- Source primaire : [conditions des modèles VRoid, section « CC0 license models »](https://vroid.pixiv.help/hc/en-us/articles/4402614652569-Do-VRoid-Studio-s-sample-models-come-with-conditions-of-use).
- Copie du fichier source : [dépôt madjin/vrm-samples, vroid/beta/HairSample_Male.vrm](https://github.com/madjin/vrm-samples/blob/master/vroid/beta/HairSample_Male.vrm).
- Texte CC0 : [Creative Commons CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/).
- Vérification effectuée le 28 septembre 2026. La propriété `licenseName` intégrée au VRM indique également `CC0`.

Le VRM original, ses métadonnées et son empreinte sont conservés dans le pack de référence Aster V7 du projet de création. Le fichier `aster.blend` de ce dossier contient la base adaptée et ses textures intégrées.

## Travail propre à cette version

Proportions adaptées, cheveux ajustés au chapeau, suppression de la tenue d'origine, nouvelle robe, manches, mantelet, doublures, bottes, chapeau, plumes, broches, grimoire, baguette, accessoires, poids des vêtements, os secondaires, adaptation des animations, shaders et démo Godot.

Les textures décoratives `Costume_Painted`, `Navy_Fabric`, `Teal_Fabric` et `Ivory_Fabric` proviennent des assets générés précédemment pour ce projet. Le visage utilise les textures de la base VRoid citée ci-dessus. Les cheveux sont recolorés avec des couleurs de sommets.

Genshin est une référence de direction artistique. Le personnage livré est une adaptation originale de la base VRoid, avec une tenue et des accessoires créés pour Aster.

## Animation V7

La locomotion, la respiration, les dégâts et l’incantation sont adaptés de **Universal Animation Library — Standard**, Quaternius, licence **CC0 1.0**. Sources utilisées : Idle_Loop, Walk_Loop, Sprint_Loop, Hit_Chest et Spell_Simple_Enter / Idle_Loop / Shoot / Exit.

- [Source primaire et licence](https://quaternius.com/packs/universalanimationlibrary.html).
- [Publication du pack Standard par Quaternius](https://opengameart.org/content/universal-animation-library).

Les sources de mouvement et leur cache de poses sont conservés dans le pack de référence Aster V7. La licence Quaternius est jointe dans `CC0_Quaternius.txt` ; les actions adaptées sont intégrées à `aster.blend`.

L’attaque compacte, la pose de combat Aim et le contrôleur de tir rapide sont créés pour ce projet. Ils remplacent le geste de tir de la V5 dans cette version. Le contrôle du bras et du buste utilise des mouvements amortis, avec le bassin et les jambes exclus. Dans Alambik, une commande de déplacement interrompt le tir ; une poussée subie du terrain conserve les règles existantes du jeu.

La V7 ajoute un mouvement original du buste et de l’épaule à Attack, avec bassin et pieds fixes, et limite le tir aux phases à l’arrêt dans la démo.

## Intégration dans Alambik

Le modèle dérive de la V7 approuvée. La chute Death01 de la même bibliothèque Quaternius CC0 a été adaptée au squelette et au volume du chapeau pour les besoins du jeu. Le fichier Blender conserve toutes les actions et les textures intégrées.
