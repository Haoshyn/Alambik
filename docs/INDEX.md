# Index du projet

Carte de routage pour les agents : choisir la ligne correspondant au travail,
puis chercher le symbole dans les fichiers indiqués. Les index de domaine
précisent les dépendances utiles ; leur lecture complète n'est pas nécessaire.

## Références

- [Statistiques jeu](../statistiques_jeu/INDEX.md) : toutes les listes chiffrées, une catégorie par fichier.
- [État actuel](CURRENT.md) : ce qui est implémenté et vérifié.
- [Périmètre du jeu](design/GAME_DESIGN.md) et [direction artistique](design/DIRECTION_ARTISTIQUE.md).

## Pour modifier le jeu

| Besoin | Source des valeurs | Logique ou écran |
|---|---|---|
| Courbes des ennemis et difficulté | `data/reglages.gd`, `data/progression/progression_statistiques.gd` | `data/mondes/chapitres.gd`, `scripts/monde/salle.gd` |
| Augments de run | `data/augments/` | `scripts/augments/`, `ui/draft.gd`, `ui/carte_reactif.gd` |
| Passifs et Épreuves | `data/progression/passifs.gd`, `data/mondes/epreuves.gd` | `ui/passifs.gd`, `scripts/combat/heros.gd` |
| Armes, familiers, bijoux et forge | `data/equipement/` | `ui/equipement.gd`, `autoload/reglages_joueur.gd` |
| Maîtrises et attributs | `data/progression/arbre_competences.gd`, `personnage.gd` | `scripts/combat/stats.gd`, `ui/heros.gd`, `ui/arbre_competences.gd` |
| Dégâts, tirs, acteurs | [index des scripts](../scripts/INDEX.md) | `scripts/combat/` |
| Salles, obstacles, terrains, XP au sol | `data/mondes/` | `scripts/monde/` |
| Butin et bilan | `data/progression/butins_run.gd`, `recompenses.gd` | `scripts/progression/bilan_run.gd`, `ui/fin_de_run.gd` |
| Cœurs de soin déposés par les ennemis | `data/progression/soins_run.gd` | `scripts/monde/collecte_soins.gd`, `scripts/presentation/coeurs_sol.gd` |
| Sauvegarde et migrations | `data/progression/migration_passifs.gd` | `autoload/reglages_joueur.gd` |
| Navigation et interface | [index UI](../ui/INDEX.md) | `scripts/menu.gd`, `ui/composants/` |
| Rendu, animations, matières | `data/presentation/` | `scripts/presentation/`, `shaders/` |
| Audio | `data/audio/` | `autoload/sons.gd`, `scripts/audio/` |
| Vérifications, statistiques, ressources | [index des outils](../tools/INDEX.md) | `tools/verifier.ps1` |
| Synthèse, pourcentages par source et listes Markdown | [circuit des statistiques](../tools/statistiques/INDEX.md) | `synthese.gd`, `attribution.gd`, `listes.gd` dans `tools/statistiques/` |
| Android demandé | [mise à jour Android](ops/MISES_A_JOUR_ANDROID.md) | `tools/android_mises_a_jour.py` |
| Zones sûres et mobile | [guide mobile](ops/MOBILE.md) | `autoload/ecran.gd` |

Les index [data](../data/INDEX.md), [scripts](../scripts/INDEX.md),
[ui](../ui/INDEX.md) et [tools](../tools/INDEX.md) précisent les points d'entrée.
La racine des scripts ne garde que les orchestrateurs et l'entrée de capture.
Les valeurs sont définies une fois dans `data/` ; les listes sont générées.

## Archives

La refonte du 26–27 septembre 2026 est sauvegardée dans
`../Alambik_sauvegardes/refonte_2026-09-26_233554/`.

- `avant_refonte/` : copie des sources et ressources, y compris les changements non commis.
- `retires/` : anciens systèmes, propositions, versions, APK, captures et sorties temporaires.
- `etat_git_avant.txt` et `deplacements_internes.json` : état initial et nouveaux chemins.
- `inventaire_retires_complet.json` : tous les fichiers archivés ; `inventaire_nettoyage.json` détaille la première passe.
- `LIRE_MOI.md` : contenu de la sauvegarde et précautions de restauration.

Ne pas restaurer en bloc par-dessus le jeu courant. Choisir les fichiers utiles
et comparer avant restauration. Les caches Godot et dépendances exécutables
encore utilisées restent dans les répertoires de travail ignorés par Git.

Les six anciennes listes `.txt`, remplacées par le Markdown, sont dans
`../Alambik_sauvegardes/statistiques_avant_markdown_2026-09-27/`, avec inventaire.

Le tutoriel retiré est conservé dans
`../Alambik_sauvegardes/tutoriel_retiré_2026-09-27/`, avec `INVENTAIRE.md`.
