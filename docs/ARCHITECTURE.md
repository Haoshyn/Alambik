# Architecture d'Alambik

## Objectif

Le dépôt est organisé pour qu'une tâche locale ait un contexte local. Un humain ou une IA doit pouvoir identifier le bon domaine avant d'ouvrir du code.

La règle centrale est : **un dossier = une responsabilité identifiable ; un document = une fonction documentaire**.

## Couches

```text
project.godot
├── autoload/          état global et services persistants
├── data/              données et équilibrage
├── scripts/
│   ├── *.gd           run, acteurs, combat, salles, entrées et menu
│   ├── presentation/  rendu 3D, matériaux, animation et styles
│   └── ameliorations/ ancien atelier de fusions, hors boucle active
├── scenes/            assemblage Godot minimal
├── ui/                écrans et contrôles
├── assets/            ressources du jeu ; sources 3D dans assets/3d/sources/
├── shaders/           matériaux et effets
├── tools/             générateurs d'assets et outils Android
├── tests/             vérification déterministe
├── sondes/            simulations et diagnostics sur demande
├── tmp/               essais, rendus et sorties temporaires hors runtime
└── build/             exports hors runtime
```

La logique de gameplay est réellement à la racine de `scripts/` ; la carte
`scripts/INDEX.md` la classe par rôle sans inventer de sous-dossiers. Les chemins
sont utilisés par les scènes, préchargements et outils : un simple ménage ne
justifie pas de déplacer le code ni de rebâtir son architecture.

Les GLB employés par le jeu restent dans `assets/3d/characters/`, `enemies/`,
`environment/` et les autres dossiers de ressources. Les fichiers de création
conservés vont dans `assets/3d/sources/`. Les rendus, prototypes et fichiers de
travail vont dans `tmp/`, les exports dans `build/` ; ils ne sont pas des sources
du jeu. Les packs tiers et leurs licences sont conservés dans
`assets/3d/sources/vendor/`, hors import Godot, à part des assets effectivement
intégrés.

## Dépendances

- `data/` ne dépend pas de l'UI.
- Les nombres d'équilibrage viennent de `data/`, jamais d'une copie dans la logique.
- `ui/` affiche et déclenche ; la logique de combat reste dans `scripts/`.
- `scenes/` reste mince : nœuds, collisions, script attaché.
- `autoload/` est réservé à l'état ou aux services réellement globaux.
- `tests/` et `sondes/` peuvent connaître le jeu ; le jeu normal ne doit pas dépendre des tests.

## Budget de contexte

La documentation est en trois températures :

1. **Chaude** — `AGENTS.md`, `docs/INDEX.md`, `docs/CURRENT.md`. Courte et fréquemment utile.
2. **Tiède** — design et guides spécialisés. À ouvrir par section lorsque la tâche l'exige.
3. **Froide** — `docs/archive/`. Historique conservé mais exclu du travail courant.

Les fichiers générés (`*.uid`, `*.import`) et les binaires ne doivent pas être lus pour comprendre le code.

## Gros fichiers

Un gros fichier n'est pas automatiquement mauvais. Il devient coûteux lorsqu'il
faut tout lire pour une petite modification. Chercher d'abord les symboles dans
`scripts/run.gd`, `scripts/ennemi.gd`, `scripts/boss.gd`, `scripts/menu.gd` ou
`autoload/reglages_joueur.gd`. Un découpage éventuel relève d'une tâche dédiée,
pas du ménage documentaire. Les vérifications restent soumises au processus
léger d'`AGENTS.md` et au périmètre demandé par le propriétaire.
