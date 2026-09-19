# État courant — 19 septembre 2026

Ce fichier décrit la base active. Les valeurs exactes restent dans `data/` ; les
anciens essais et résultats de tests ne valent pas validation de l'état présent.

## Présentation

- Le nouveau modèle de travail et par défaut est `assets/3d/characters/mage_reference.glb`,
  généré par `tools/blender/mage_reference.py`. Référence fournie conservée dans
  `assets/3d/sources/characters/mage_reference/direction.png`, avec sa source Blender.
  Textures couleur et normales intégrées, matières éclairées, écharpe sur trois os,
  six animations. Rendu encore à apprécier avec le propriétaire dans l'atelier.
- L'essai procédural `mage_fidele` a été rejeté pour ses proportions, ses facettes
  et ses matières. Il n'est pas activé dans le jeu. La copie de travail
  `mage_sculpte`, issue du maillage sculpté et exportée séparément, reste hors jeu
  tant que sa direction visuelle n'est pas retenue.
- Atelier sculpté : éclairage neutre et shader dédié
  `shaders/mage_sculpte_surface.gdshader`, diffusion adoucie, relief réduit et
  matières cuir/or séparées. Marges UV et découpage du chapeau repris ; filtre
  de projection contre les débordements violets dans les cheveux. Des raccords
  de texture restent visibles ; la fidélité artistique reste à valider.
- Le modèle précédent `apprenti_accueil_v2.glb` reste intact depuis cette séparation.
  Sa version avant les retouches du 18 septembre a été récupérée depuis Git dans
  `apprenti_secours.glb`, avec shader et source Blender distincts. Retour arrière :
  `docs/ops/RETOUR_MODELE_ORIGINAL.md`.
- Aucun sélecteur de modèle dans les paramètres. V2 Meshy et KayKit restent hors
  du catalogue actif ; leurs fichiers sont conservés.
- Les essais Feutre & cuir et les variantes chibi de l'atelier du 18 septembre
  ont été rejetés et sont retirés. Les retouches actuelles portent sur le nouveau mage,
  observable en course dans l'atelier interactif `tools/atelier_apprenti.ps1`.
- L'accueil utilise l'illustration `assets/visual/arcane/accueil.png`, affichée par
  `ui/accueil_3d.gd` malgré son nom. Le combat conserve sa présentation 3D.
- Interface portrait adaptative, base 1080 × 1920 ; menus, équipement, maîtrises,
  sorts et commandes tactiles sont en place.

## Boucle et progression

- Campagne par chapitres et salles, Mine de survie et Épreuves de sorts.
- Augments de campagne : 25 niveaux, légendaires aux niveaux 5/10/15/20/25,
  avec rattrapage par salle pour obtenir le dernier avant le boss final ; les
  anciens choix de halte sont intégrés à cette progression. Chaque offre garde
  sa rareté lors des relances. Petits bonus cumulables à rendement décroissant,
  rares de spécialisation et légendaires uniques ; Héritage donne des rares.
- Soins de campagne : 1 % des PV max par niveau, choix de 16 % supplémentaires
  à la place d'un bonus ordinaire, 20 % avant un boss. Mine et Épreuves gardent
  leur cadence. Source : `data/progression_augments.gd` et catalogue des réactifs.
  Première passe modifiée et relue, sans lancement, test ni export APK.
- Améliorations de run, sorts actifs, passifs et ultimes ; les fusions
  expérimentales ne font plus partie des choix proposés dans la boucle active.
- Équipement, forge, maîtrises et progression sauvegardée dans
  `autoload/reglages_joueur.gd`.
- Butins et garanties partagés entre aperçu et attribution :
  `data/butins_run.gd`, `data/recompenses.gd`, `data/epreuves.gd` et
  `scripts/bilan_run.gd`. Courbes statistiques : `data/progression_statistiques.gd`.
- Formes des salles et décors par monde : `data/formes_salles.gd` et
  `data/decors_mondes.gd`.

## Reprise du travail

Les variantes du héros restent des exemples à comparer. Les prochaines tâches doivent partir du
besoin demandé et des catalogues actifs, pas des anciennes listes de chantier.

Le processus par défaut est celui d'`AGENTS.md` : modification ciblée et relecture ;
le propriétaire teste le jeu. Tests, runs et APK uniquement sur demande explicite.
L'ancien état détaillé est conservé dans
`docs/archive/ETAT_AVANT_MENAGE_2026-09-18.md` à titre historique.
