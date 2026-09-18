# Alambik

Roguelite de tir vue de dessus pour Android, en portrait et jouable à une main. Un apprenti alchimiste traverse les salles d'un grimoire vivant, choisit des améliorations pendant ses runs et développe son équipement, ses maîtrises et ses sorts.

Le projet est sous Godot 4.7.1 / GDScript.

## Commencer ici

Pour comprendre le dépôt sans charger des dizaines de fichiers :

- `AGENTS.md` — règles de travail pour les agents et développeurs.
- `docs/INDEX.md` — quel fichier ouvrir pour quelle tâche.
- `docs/CURRENT.md` — état de travail court.
- `docs/design/GAME_DESIGN.md` — design complet, à consulter par section.
- `scripts/INDEX.md` — carte de la logique de jeu.

Les anciens journaux et états détaillés sont conservés dans `docs/archive/` mais ne font pas partie du contexte normal de travail.

## Structure

```text
autoload/    état global, préférences, audio et écran
data/        équilibrage et catalogues
scripts/     logique du jeu et sous-dossier presentation/ pour le rendu
scenes/      petites scènes Godot qui branchent les scripts
ui/          interface de jeu
assets/      modèles du jeu, images, audio et polices
shaders/     matériaux et effets visuels
tools/       génération d'assets et outils Android
human/       interface d'édition humaine du design
tests/       tests déterministes
sondes/      simulations et contrôles headless
docs/        index, design, état courant, opérations, archives
tmp/         aperçus et sorties de travail hors runtime
build/       exports Android hors runtime
```

Les valeurs de gameplay vivent dans `data/`; la logique ne doit pas les dupliquer.
Les sources 3D conservées vont dans `assets/3d/sources/`, les modèles utilisés par
le jeu dans les dossiers de `assets/3d/`, et les essais/rendus temporaires dans
`tmp/`. Voir `docs/ARCHITECTURE.md` pour le rôle des dossiers.

## Commandes disponibles

Ce sont des outils à utiliser sur demande, pas une suite à lancer après chaque
modification. Le propriétaire teste le jeu ; tests, runs et APK ne sont pas
automatiques.

| Commande | Usage |
|---|---|
| `./lancer.sh` | Ouvrir le jeu sur PC |
| `./verifier.sh` | Import Godot et vérifications générales, si demandés |
| `./sondes/vingt_runs.sh` | Simulation de vingt runs, si demandée |
| `Mettre_a_jour_Android.cmd` | Export d'un APK de test sous Windows |
| `./deploy.sh` | Export debug, installation et lancement sur téléphone |
| `./publier.sh` | Export Android signé et versionné |

Arguments de développement après `--` : `--salle=N`, `--chapitre=N`, `--graine=N`, `--dote=N`, `--auto`, `--bavard`, `--mode=mine`, `--mode=epreuve_sorts`.

Le guide téléphone est dans `docs/ops/MOBILE.md`.

*Alambic est un nom de travail, pas encore vérifié sur les registres de marques.*
