# Alambik — travailler dans le projet

Roguelite de tir portrait Android, Godot 4.7.1 et GDScript. Simulation 2D,
présentation 3D. Les demandes du propriétaire définissent le travail à réaliser.

## Trouver la bonne source

- Si le fichier est connu, aller directement à ce fichier. Sinon, choisir
  une ligne dans `docs/INDEX.md`, puis le seul index de domaine utile.
- Pour les chiffres lisibles par le propriétaire : `statistiques_jeu/INDEX.md`.
- Pour les règles du jeu : `docs/design/GAME_DESIGN.md` ; pour son état :
  `docs/CURRENT.md` ; pour son style : `docs/design/DIRECTION_ARTISTIQUE.md`.
- Lire les `AGENTS.md` du chemin modifié. Chercher un symbole avec `rg` avant
  d'ouvrir un gros fichier ; ne lire que les dépendances utiles à la tâche.
- Les index servent au routage des agents : ne pas les charger tous.
  Ne pas lire les listes générées ou tous les catalogues pour retrouver une
  fonction. Pour les statistiques, `tools/statistiques/INDEX.md` donne la
  chaîne de calcul et le fichier responsable de chaque partie.

## Responsabilités

- `data/` définit les catalogues et les nombres ; aucune valeur d'équilibrage
  ne doit être dupliquée dans la logique ou dans une description manuelle.
- `scripts/` applique les règles ; `scripts/presentation/` les représente.
- `autoload/` porte la session et la sauvegarde ; `ui/` présente les choix.
- Les listes de `statistiques_jeu/` sont générées depuis les mêmes fonctions
  que le jeu. Après un changement de chiffres, les régénérer et les vérifier.
- Un fichier porte un concept. Extraire une responsabilité lorsqu'elle est
  autonome ; ne pas ajouter des couches qui ne font que relayer un appel.

## Invariants

### Ecrans de reference (refonte du 9 octobre 2026)

- Le 9 octobre 2026, le proprietaire a demande une refonte graphique complete
  « plus jeu, moins site internet » et leve le gel des cinq menus pour ce
  travail. L'etat issu de cette refonte (kit Email serti, voir
  `docs/design/DIRECTION_ARTISTIQUE.md`) devient la reference des menus
  **Heros**, **Equipement**, **Aventure**, **Maitrises** et **Passifs**.
- Hors demande du proprietaire visant un ecran ou un element, ne pas retoucher
  la presentation, les commandes ou l'agencement de ces menus, y compris par
  un changement de theme, de police, de composant partage ou de ressource.
  L'equilibrage et la progression restent ouverts aux demandes.
- Aucun petit rectangle sombre derriere un titre, un nom, un rang, une
  description ou une indication : le contraste vient de la typographie
  (graisse et contour), comme dans les Passifs.
- Musiques conservees : First Arcade, Dynamic Arcade et Accueil originale.
  Les autres anciennes compositions sont retirees ; seules les deux nouvelles
  bases Aventure et Atelier restent ouvertes aux retouches avec le proprietaire.

### Regles de code

- Identifiants et commentaires français sans accents ; textes joueur avec accents.
- Toute valeur d'amelioration affichee au joueur est un entier, sans virgule ;
  le combat applique exactement la valeur affichee (voir `data/AGENTS.md`).
- Les commentaires expliquent une intention ou une contrainte.
- Typer les valeurs issues de `Dictionary` ; avec `:=`, préférer `lerpf`,
  `clampf`, `maxf`, `maxi`, `absf` aux variantes renvoyant un `Variant`.
- Ne pas modifier un tableau pendant son itération.
- Utiliser `Geometrie.ligne_libre` pour les obstacles, pas un rayon par image.
- Préserver les identifiants sauvegardés ou écrire une migration explicite.
- Préserver les `.uid` lors d'un déplacement et mettre à jour les chemins
  `res://`, les chargements dynamiques, les scènes, les outils et les index.
- Aucune reprise de contenu d'un autre jeu. Conserver l'origine des ressources.

## Vérifier et préserver

Vérifier chaque changement avec un contrôle proportionné : diff et scénario
ciblé pour une retouche ; import Godot, contrôles de progression et scènes
touchées pour une refonte. Lire les erreurs, pas seulement le code de sortie.
Exécuter Godot avec `--headless`, Blender avec `--background`, et les processus
Windows lancés en arrière-plan avec `-WindowStyle Hidden`. Isoler `APPDATA`
pour les runs de vérification afin de protéger la vraie sauvegarde.

Ne pas écraser des changements existants. Un nettoyage déplace ce qui est
prouvé obsolète vers une sauvegarde hors dépôt, avec inventaire. Les caches
`.godot/`, sorties `tmp/`, `build/`, binaires et archives ne sont pas des
sources à explorer par défaut. Les sources artistiques encore utilisées
restent conservées même si leurs noms sont anciens.

Une demande d'APK autorise l'export et les contrôles de version, paquet et
signature : un seul `Alambic.apk` à la racine, journaux dans `build/android/`.
Ne pas exporter un APK à chaque modification. Ne pas créer de rapport pour
une petite retouche ; actualiser le document devenu faux.
