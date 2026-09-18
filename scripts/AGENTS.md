# scripts/

Lire `scripts/INDEX.md`, puis le `AGENTS.md` du sous-dossier ciblé. Chercher les symboles avant d'ouvrir les gros fichiers.

La logique consomme `data/` et ne possède pas sa propre copie des chiffres. Garder les dépendances entre domaines explicites ; éviter d'ajouter une nouvelle responsabilité à `scripts/run.gd`, aux gros acteurs ou au menu lorsqu'un module local suffit.

Les orchestrateurs, acteurs, entrées, scripts de combat et de salle sont actuellement directement dans `scripts/`. Les sous-dossiers actifs sont `ameliorations/` et `presentation/` ; ne pas présumer d'une arborescence par domaine qui n'existe pas.

`run.gd` coordonne les systèmes. `menu.gd` coordonne la navigation ; la construction visuelle réutilisable appartient à `ui/` ou `presentation/`. Les calculs de combat partagés restent indépendants des acteurs quand c'est possible.

Pour la salle et les obstacles, utiliser `Geometrie` plutôt qu'une requête physique dépendante d'une frame. Les compositions de rencontres viennent de `data/vagues.gd`. Les contraintes tactiles réelles se valident sur appareil lorsque cela est demandé ; voir `docs/ops/MOBILE.md`.

Les outils de capture et de développement ne doivent pas être nécessaires à une partie normale. Leur présence n'autorise pas une exécution automatique.
