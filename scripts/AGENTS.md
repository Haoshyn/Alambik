# scripts/

Le routage est dans `docs/INDEX.md`. Chercher les symboles avant d'ouvrir les gros fichiers ; pour le rendu, lire aussi `presentation/AGENTS.md`.

La logique consomme `data/`. Éviter d'ajouter une responsabilité à `run.gd`, aux gros acteurs ou au menu lorsqu'un module local suffit.

Les acteurs, entrées, scripts de combat et de salle sont directement dans `scripts/` ; le rendu est dans `presentation/`.

`run.gd` coordonne les systèmes. `menu.gd` coordonne la navigation ; la construction visuelle réutilisable appartient à `ui/` ou `presentation/`. Les calculs de combat partagés restent indépendants des acteurs quand c'est possible.

Les rencontres viennent de `data/vagues.gd`. Pour les contraintes tactiles sur appareil, voir `docs/ops/MOBILE.md` seulement lorsque cela est demandé.

Les outils de capture et de développement ne doivent pas être nécessaires à une partie normale. Leur présence n'autorise pas une exécution automatique.
