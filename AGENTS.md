# Alambik — guide des agents

Roguelite de tir portrait Android, Godot 4.7.1, GDScript.

## Démarrage à faible contexte

1. Lire ce fichier, puis `docs/INDEX.md`.
2. Lire le `AGENTS.md` le plus proche du dossier modifié.
3. Ouvrir uniquement les fichiers indiqués par l'index ou trouvés par recherche de symbole.
4. Pour un gros fichier, chercher d'abord les fonctions/classes concernées (`rg -n '^func|^class_name|^const'`) puis lire une plage ciblée. Ne pas charger le fichier entier par réflexe.

Ne pas lire par défaut : `docs/archive/`, `human/`, les `.uid`, les `.import`, les PNG, polices, audio, APK ou autres binaires. Les ouvrir uniquement si la tâche les concerne.

## Sources de vérité

- Design voulu : `docs/design/GAME_DESIGN.md`. Chercher le chapitre pertinent au lieu de tout lire.
- État de travail court : `docs/CURRENT.md`.
- Routage code → fichiers : `docs/INDEX.md` puis `scripts/INDEX.md`.
- Historique : `docs/archive/` ; consultation exceptionnelle seulement.
- `human/` est l'interface d'édition du propriétaire. Ne la lire que s'il demande de « lire human », d'appliquer ses changements ou si la tâche porte explicitement sur son contenu.

## Invariants

- Godot 4.7.1.
- Identifiants et commentaires en français sans accents ; textes joueur avec accents.
- Les commentaires expliquent pourquoi, pas ce que le code dit déjà.
- Aucune valeur d'équilibrage en dur dans la logique : utiliser `data/reglages.gd` ou les catalogues de `data/`.
- Ne reprendre aucun nom, texte, icône, sprite ou son d'un autre jeu.
- Direction artistique : `human/11_DIRECTION_ARTISTIQUE.txt` uniquement quand la tâche visuelle l'exige.
- Avec `:=`, préférer `lerpf`, `clampf`, `maxf`, `maxi`, `absf` aux fonctions renvoyant un `Variant`.
- Typer les valeurs provenant des clés de `Dictionary`.
- Ne pas modifier un tableau pendant son itération.
- Pour les blocs de salle, utiliser `Geometrie.ligne_libre` plutôt qu'un rayon lancé depuis `_process`.

## Processus léger par défaut

Lire seulement les fichiers utiles, effectuer la modification, relire les
changements et faire un retour court. Le propriétaire teste lui-même le jeu.

- Ne pas lancer automatiquement de tests, sondes, simulations de runs,
  vérification générale ou import global Godot après une modification,
  y compris un retour à une ancienne version.
- Ne pas reconstruire l'APK, exporter pour Android, incrémenter la version
  ou installer sur téléphone sans demande explicite du propriétaire.
- Les tests et les builds sont sur demande. Ne pas proposer une confirmation
  systématique après chaque retouche : par défaut, ne pas les lancer.
- Si des tests sont demandés, cibler le changement et respecter le périmètre
  demandé. Ne pas élargir spontanément à toute la suite ou aux vingt runs.
  Ne pas ajouter de nouveaux tests sans demande.
- Une demande d'APK autorise son export et les contrôles associés de version,
  paquet et signature ; elle ne demande pas une batterie de tests ou de runs.
- Ne pas créer systématiquement de guide, rapport, captures ou documentation
  pour une petite modification. Une correction d'information devenue fausse
  dans l'état courant peut rester brève.

Les scripts `verifier.sh` et `sondes/vingt_runs.sh` restent disponibles pour
une demande explicite ; leur présence n'est pas une obligation de les lancer.
Ces règles s'appliquent aussi aux sous-agents et aux consignes locales.

## Exécutions demandées

Lorsqu'une exécution est nécessaire au travail demandé, la garder sans fenêtre
visible ni prise de focus : Godot en `--headless`, Blender en `--background`,
processus Windows lancés avec `-WindowStyle Hidden`. Ne pas ouvrir l'atelier
interactif ou une fenêtre de jeu sauf demande explicite du propriétaire ;
il peut jouer à LoL pendant le travail.

Si des tests ou runs sont demandés, lire leurs erreurs et résultats détaillés,
pas seulement le code de sortie. Utiliser un profil isolé de la sauvegarde réelle.
