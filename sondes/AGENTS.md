# sondes/

`bot.gd` et `navigation_bot.gd` restent actifs pour l'option PC `--auto` de `scripts/run.gd`. Ils sont exclus des exports Android. Ne pas les déplacer sans adapter ce consommateur.

`test_tutoriel_progression.tscn` contrôle le parcours, les sauvegardes et les outils de progression. Il exige un `XDG_DATA_HOME` isolé et `--profil-isole` ; ajouter `--combat --auto --vierge --mode=tutoriel --graine=22092026` pour son unique run tutoriel. Exécuter seulement sur demande.

Les autres diagnostics sont archivés, voir `docs/INDEX.md`. Pour toute simulation demandée, utiliser un profil isolé et lire les résultats détaillés : une fin de processus ne prouve pas la progression d'une run.
