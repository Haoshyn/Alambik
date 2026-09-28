# Mode dev temporaire

Accueil → **DEV** → monde terminé → **Activer avec ce profil**.
Le monde choisi et les précédents sont terminés ; le suivant devient accessible.
**Appliquer ce profil** remplace tout le compte de test, y compris en descendant
de monde ou en réappliquant le même profil. La classe choisie est conservée.
**Désactiver et restaurer mon compte** retrouve la progression d'origine.
Les réglages audio et d'accessibilité restent indépendants.

Le profil rejoue les récompenses de la campagne avec une tentative partielle
par monde, quelques reprises, de la Mine et des Épreuves. Les hypothèses de
fréquence sont dans `profil.gd`. Les tirages sont reproductibles ; les coûts,
gains, rangs, déblocages et statistiques viennent des fonctions actuelles du jeu.
Les achats sont équilibrés entre les branches, une réserve est conservée et les
passifs obtenus sont équipés. Ce scénario est une hypothèse de test, pas une
mesure du parcours moyen des joueurs. Le debug historique à ressources infinies
est désactivé pendant l'application du profil.

La progression de test utilise la sauvegarde habituelle. La copie d'origine
reste dans `user://dev_temporaire/compte_original.cfg` jusqu'à la restauration,
y compris après un redémarrage. Changer de monde ne remplace jamais cette copie.
Aucune clé ni migration n'est ajoutée au format de sauvegarde du jeu.

L'unique branchement est le bloc `outil_temporaire` de `scripts/menu.gd`.
Le bouton est injecté uniquement dans l'accueil ; les autres menus et les
systèmes permanents ne dépendent pas de l'outil. Il est disponible aussi dans
un export Android tant que ce dossier est présent.

Pour retirer la feature : restaurer d'abord le compte depuis DEV, puis archiver
ce dossier et `tools/verifier_dev_temporaire.gd/.tscn` hors dépôt avec inventaire,
et retirer le bloc `outil_temporaire` du menu. Son chargement étant conditionnel,
l'absence du dossier ne bloque pas le jeu.

Contrôle dédié : lancer Godot avec `--headless` sur
`res://tools/verifier_dev_temporaire.tscn`, en isolant `APPDATA` et `LOCALAPPDATA`
dans un chemin contenant `verification_dev_temporaire`. Il couvre les cinq
profils, les budgets, la régression, la restauration et les clics du menu sur
deux formats portrait. Les arguments `--preparer-reprise-dev`, puis
`--verifier-reprise-dev` dans un second processus et le même profil isolé
contrôlent la conservation après redémarrage.
