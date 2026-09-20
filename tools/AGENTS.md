# tools/

Outils de maintenance des ressources actives et de publication Android.
Ils ne font pas partie du jeu exporté. Les règles de `../AGENTS.md` s'appliquent :
aucune génération, vérification ou export automatique après une retouche.

## Entrées utiles

| Besoin | Point d'entrée |
|---|---|
| APK, signature, version et installation demandés | `android_mises_a_jour.py`, `../docs/ops/MISES_A_JOUR_ANDROID.md` |
| Héros actuel | `blender/mage_sculpte.py` |
| Bestiaire, gardien et portail | `blender/build_all.py`, `blender/portail_azur.py` |
| Armes tenues | `blender/armes_tenues.py` |
| Glyphes de secours de l'interface | `generer_icones.py` |
| Musiques originales | `audio/composer.py`, `audio/collection.py` |
| Icônes de l'application | `preparer_identite.gd` |

Lire l'entrée concernée puis seulement les imports ou fonctions nécessaires.
Les modules `variantes_mage.py`, `animer_mage_v2.py` et le dossier source
`assets/3d/sources/characters/mage_v2/` participent encore au mage actuel.
Ne pas les considérer comme obsolètes à partir de leur nom.

Les générateurs écrasent des ressources actives : les lancer seulement si le
travail demandé exige leur régénération, avec Blender en `--background` et
Godot en `--headless`. Le dossier est exclu de l'import Godot par `.gdignore` ;
ses scripts GDScript se lancent explicitement avec `--script`, sur demande.
Les sorties temporaires vont dans `tmp/`, les exports Android dans `build/`.
