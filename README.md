# Alambik

Roguelite de tir portrait Android, jouable à une main, sous Godot 4.7.1 / GDScript.
Simulation 2D, combat présenté en 3D et interface de scriptorium alchimique.

## Repères

- `AGENTS.md` : règles de travail, dont tests et exports uniquement sur demande.
- `docs/INDEX.md` : carte unique pour trouver le code et les outils.
- `docs/CURRENT.md` : état court du projet.
- `docs/design/GAME_DESIGN.md` : périmètre du jeu ; les chiffres restent dans `data/`.
- `docs/design/DIRECTION_ARTISTIQUE.md` : repères visuels actuels.

## Organisation

| Dossier | Rôle |
|---|---|
| `autoload/` | État global, sauvegarde, audio et écran |
| `data/` | Catalogues et équilibrage, source unique des valeurs |
| `scripts/` | Logique ; `presentation/` contient le rendu sans règles de gameplay |
| `scenes/`, `ui/` | Assemblage Godot, écrans et commandes |
| `assets/`, `shaders/` | Ressources et six shaders utilisés ; sources 3D éditables dans `assets/3d/sources/` |
| `tools/` | Générateurs des ressources actives et export Android |
| `sondes/` | Deux scripts nécessaires au mode PC `--auto` |
| `docs/` | Index, état, design et guides Android |
| `tmp/`, `build/` | Sorties de travail et exports, hors import et hors Git |

`Accueil.ogg` est la musique originale utilisée par le catalogue à la racine.
Les sources 3D, `tools/` et `docs/` sont hors import grâce à `.gdignore`.
Les anciens fichiers, `human/`, tests et diagnostics sont dans
`../OldAlambik/2026-09-20/organisation/` ; son `LIRE_MOI.md` explique la restauration.
Les archives sont à côté du dépôt, pas dans le jeu.

## Commandes sur demande

| Commande | Usage |
|---|---|
| `./lancer.sh` | Ouvrir le jeu sur PC |
| `Mettre_a_jour_Android.cmd` | Exporter un APK de test sous Windows |
| `./publier.sh` | Exporter un APK signé et versionné |
| `./deploy.sh` | Exporter, installer et lancer sur téléphone |

Arguments de développement après `--` : `--salle=N`, `--chapitre=N`,
`--graine=N`, `--dote=N`, `--auto`, `--bavard`, `--mode=mine`, `--mode=epreuve_sorts`.
Guides : `docs/ops/MISES_A_JOUR_ANDROID.md` et `docs/ops/MOBILE.md`.
