# Logique du jeu

Utiliser `INDEX.md` pour choisir la responsabilité concernée. `run.gd` et
`menu.gd` coordonnent ; les calculs de combat, les augments et la géométrie
vivent dans leurs modules. Ne pas charger tous les acteurs pour une retouche.

La logique lit `data/`. Un même calcul doit servir au gameplay et à son
affichage. Les fonctions de calcul restent indépendantes de l'arbre des
scènes quand c'est possible ; les acteurs gèrent le temps et les événements.

Un dégât suit une source explicite ; ne pas multiplier deux fois une même
famille de bonus. Les effets visuels appartiennent à `presentation/`, les
écrans à `ui/`. Les outils de capture ne sont pas une dépendance obligatoire
d'une partie normale.
