# Outils

Consulter `INDEX.md` pour choisir l'entrée utile. Ce dossier est exclu de
l'import et de l'export du jeu ; les scripts Godot s'exécutent explicitement.

`verifier.ps1` utilise un profil temporaire et exécute les contrôles de données,
de migration et de scènes. `statistiques/exporter.gd` produit les listes du
propriétaire ; `--verifier` contrôle leur fraîcheur sans les écrire.
Les modèles de comparaison appartiennent à l'outillage et n'équilibrent jamais
les ennemis en fonction du joueur.
Pour modifier les listes Markdown, suivre `statistiques/INDEX.md` : il sépare
mise en forme, profil d'exemple, mesures du build et attribution des synergies.
Une proportion de contribution ne doit pas être présentée comme un effet
de nerf ; préciser le build, les conditions et la convention de répartition.
Les 100 % des sources permanentes excluent les augments. Présenter ensuite
leur multiplicateur de run et le gain de DPS par rapport au même build de
départ ; ils doivent pouvoir représenter la majorité des dégâts finaux.

Les générateurs artistiques peuvent écraser des ressources actives : ne les
lancer que si le travail exige leur régénération. Garder leurs sources
éditables, y compris les modules Blender aux anciens noms encore importés.
Godot s'exécute en `--headless`, Blender en `--background`.

Les sorties vont dans `tmp/`, les journaux Android dans `build/android/`.
Un outil temporaire doit être archivé hors dépôt lorsqu'il n'a plus d'usage.
