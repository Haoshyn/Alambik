# Alambik — guide des agents

Roguelite de tir portrait Android, Godot 4.7.1, GDScript.

## Lecture ciblée

1. Utiliser `docs/INDEX.md` pour trouver le point d'entrée si le fichier n'est pas déjà connu.
2. Lire les `AGENTS.md` applicables sur le chemin du dossier modifié ; les règles racine valent aussi pour les sous-agents.
3. Chercher avec `rg` avant d'ouvrir un gros fichier : `rg -n '^func|^class_name|^const' chemin`. Lire ensuite la plage utile.
4. Ne pas charger tous les catalogues, écrans ou documents pour une retouche locale.

Sources uniques : `data/` pour les valeurs, `docs/design/GAME_DESIGN.md` pour le périmètre du jeu, `docs/CURRENT.md` pour l'état court, `docs/design/DIRECTION_ARTISTIQUE.md` pour les décisions visuelles.

Ne pas lire par défaut les archives `../OldAlambik/`, caches `.godot/`, sorties `tmp/` et `build/`, `.uid`, `.import` ou binaires. Les ouvrir seulement si la tâche les concerne. L'ancien `human/` et les diagnostics sont archivés ; voir `docs/INDEX.md` uniquement si leur restauration est demandée.

## Invariants

- Identifiants et commentaires en français sans accents ; textes joueur avec accents.
- Les commentaires expliquent pourquoi, pas ce que le code dit déjà.
- Aucune valeur d'équilibrage en dur dans la logique : utiliser `data/reglages.gd` ou les catalogues de `data/`.
- Ne reprendre aucun nom, texte, icône, sprite ou son d'un autre jeu.
- Avec `:=`, préférer `lerpf`, `clampf`, `maxf`, `maxi`, `absf` aux fonctions renvoyant un `Variant`.
- Typer les valeurs provenant des clés de `Dictionary`.
- Ne pas modifier un tableau pendant son itération.
- Pour les blocs de salle, utiliser `Geometrie.ligne_libre` plutôt qu'un rayon lancé depuis `_process`.

## Vérification

Vérifier chaque modification avec un contrôle adapté à sa portée. Pour une petite retouche, privilégier la relecture du diff et un test ciblé rapide. Pour un changement plus large, vérifier les scènes ou comportements touchés et lire les erreurs détaillées. Éviter les batteries de tests sans rapport avec la modification.

Garder les exécutions sans fenêtre ni prise de focus : Godot `--headless`, Blender `--background`, processus Windows `-WindowStyle Hidden`. Pour les runs du jeu, isoler le profil de la sauvegarde réelle.

Une demande d'APK autorise export et contrôles de version, paquet et signature. Produire un seul fichier `Alambic.apk` à la racine du projet ; conserver journaux et métadonnées dans `build/android/`.

Ne pas créer de guide ou rapport pour une petite retouche ; corriger brièvement une information devenue fausse suffit.
