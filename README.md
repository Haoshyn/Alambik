# Alambik

Roguelite de tir portrait Android, Godot 4.7.1 / GDScript.

Pour lire les statistiques du jeu, commencer par **[Liste mathématique](statistiques_jeu/liste_mathematique.md)** :
fiche au plafond de progression, contributions par source, puis formules détaillées.
Les autres listes Markdown de `statistiques_jeu/` couvrent les
augments, items à tous les niveaux, maîtrises, passifs, monstres et logique mathématique.

Pour travailler sur le projet : [index technique](docs/INDEX.md),
[règles des agents](AGENTS.md), [état actuel](docs/CURRENT.md),
[périmètre du jeu](docs/design/GAME_DESIGN.md).

| Dossier | Contenu |
|---|---|
| `statistiques_jeu/` | Listes lisibles, calculées depuis les données |
| `data/` | Chiffres et catalogues par catégorie |
| `scripts/` | Combat, monde, augments, interface et rendu |
| `autoload/` | Session, sauvegarde, audio et écran |
| `scenes/`, `ui/` | Assemblage Godot et écrans |
| `assets/`, `shaders/` | Ressources jouées et effets visuels |
| `tools/` | Vérification, statistiques, générateurs et export Android |
| `sondes/` | Bot de développement PC |
| `docs/` | Index, état, design et guides Android |

Sous Windows : `./tools/verifier.ps1 -ActualiserStatistiques` importe le projet,
actualise les listes et vérifie les comportements touchés avec une sauvegarde isolée.
Sans ce paramètre, la commande vérifie que les listes sont déjà à jour.
Le chemin du moteur peut être fourni par `-Godot CHEMIN` ou `GODOT`.

`Mettre_a_jour_Android.cmd` sert aux exports Android demandés. Les scripts
`lancer.sh`, `publier.sh` et `deploy.sh` restent disponibles sous Linux.

Les anciennes versions et sorties sont sauvegardées hors dépôt ; voir
[les repères d'archives](docs/INDEX.md#archives).
