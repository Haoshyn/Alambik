# Statistiques — routage des agents

Ne lire que la ligne utile. Les catalogues `data/` restent les sources des
valeurs ; les six `../../statistiques_jeu/liste_*.md` sont des sorties générées.

| Besoin | Fichier et symbole | Dépendance utile |
|---|---|---|
| Écrire les six listes ou vérifier leur fraîcheur | [exporter.gd](exporter.gd), `_exporter` | `listes.gd`, `mathematiques.gd` |
| Titres, tables et catalogues par catégorie | [listes.gd](listes.gd), `tableau`, `augments`, `items`, `maitrises`, `passifs`, `monstres` | Catalogue de la seule catégorie touchée |
| Résumé global et fiche finale en haut du document | [synthese.gd](synthese.gd), `ajouter` | `profil_reference.gd`, `attribution.gd` |
| Choix du build classique et du matériel optimal | [profil_reference.gd](profil_reference.gd), `AUGMENTS_CLASSIQUES`, `_chercher_equipement` | `modeles.gd` |
| ATK, critique, PV, défense et DPS d'un build | [modeles.gd](modeles.gd), `mesurer`, `bonus_equipement` | `Stats`, `Mods`, `Tir`, catalogues d'équipement et passifs |
| Répartition des sources permanentes, interactions comprises | [attribution.gd](attribution.gd), `calculer_permanent` | `modeles.gd` ; cinq familles, 32 combinaisons ; augments mesurés ensuite |
| Formules, courbes et comparaisons détaillées | [mathematiques.gd](mathematiques.gd), `_formules`, `_tirs_multiples`, `_ennemis` | `Reglages`, `Chapitres`, `ProgressionStatistiques` |
| Budget du scénario sans farm | [profil_campagne.gd](profil_campagne.gd), `budget`, `construire` | `ButinsRun`, coûts de forge et maîtrises |
| Trois orientations d'augments comparables | [profils_augments.gd](profils_augments.gd), `PROFILS` | `CatalogueReactifs` ; budget commun de raretés |
| Vraies offres et distributions par salle | [simulation_augments.gd](simulation_augments.gd), `simuler`, `une_run`, `calendrier` | `DraftLogique`, `ProgressionAugments`, `Modeles` |
| Budget, possessions et achats légaux d'un parcours | [compte_simule.gd](compte_simule.gd), `recevoir`, `acheter`, `configuration` | `ButinsRun`, coûts et calculateurs du jeu |
| Retries, durées, murs et lots de farm | [parcours_progression.gd](parcours_progression.gd), présentation dans [synthese_progression.gd](synthese_progression.gd) | `CompteSimule`, vagues et simulation des augments |
| Retour offensif après cinq ou six Épreuves | [retour_campagne.gd](retour_campagne.gd), `scenario`, `mesurer`, `rapport` | `CompteSimule`, `Parcours` ; contrôle `../verifier_retour_campagne.gd` |
| Progression équilibrée/offensive, deux défenses, sur-farm et critiques | [equilibrage_progression.gd](equilibrage_progression.gd), `rapport` | `RetourCampagne.mesurer`, achats réels ; contrôle `../verifier_equilibrage_progression.gd` |

Contrôle ciblé : `godot --headless --path . --script res://tools/verifier_reference.gd`
pour le profil, l'optimum et les contributions ; `tools/verifier_augments.gd`
pour les tirs, malus et cumuls. Isoler `APPDATA` comme dans `../verifier.ps1`.
Régénération : lancer `exporter.gd` ; vérification sans écriture : ajouter
`-- --verifier`. Ne jamais éditer les listes à la main.
