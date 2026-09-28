# Outils — index

| Besoin | Entrée |
|---|---|
| Vérification complète de cette refonte, profil isolé | [verifier.ps1](verifier.ps1) |
| Actualiser ou vérifier les listes du propriétaire | [statistiques/exporter.gd](statistiques/exporter.gd) |
| Trouver le calcul ou le texte d'une liste | [statistiques/INDEX.md](statistiques/INDEX.md) |
| Construction des cinq listes de catalogues | [statistiques/listes.gd](statistiques/listes.gd) |
| Formules et exemples globaux | [statistiques/mathematiques.gd](statistiques/mathematiques.gd), [modeles.gd](statistiques/modeles.gd) |
| Contrôles des catalogues, coûts et courbes | [verifier_progression.gd](verifier_progression.gd) |
| Rythme des attaques, passage des zigzags et départs des tirs de boss | [verifier_patterns.gd](verifier_patterns.gd) |
| Profil maximal, équipement optimal et répartition des contributions | [verifier_reference.gd](verifier_reference.gd) |
| Contrôles des choix et cumuls de run | [verifier_augments.gd](verifier_augments.gd) |
| Dix niveaux, écrans de choix et paiement des cœurs inutilisés | [verifier_niveaux_augments.gd](verifier_niveaux_augments.gd) |
| Projectiles, collisions, familiers autonomes et contact des boss | [verifier_projectiles.gd](verifier_projectiles.gd) |
| Modeles ennemis, articulations, gel, disparition et budgets 3D | [verifier_bestiaire.gd](verifier_bestiaire.gd) ; planches via [blender/apercu_bestiaire.py](blender/apercu_bestiaire.py) |
| Apercu anime des poses reelles du bestiaire | [apercu_mouvements_bestiaire.gd](apercu_mouvements_bestiaire.gd), puis [rendu Blender](blender/apercu_mouvements_bestiaire.py) |
| Nombres de dégâts réels, regroupement des salves et effets réduits | [verifier_degats_affiches.gd](verifier_degats_affiches.gd) |
| Distribution des choix mixtes et courbes de run | [verifier_simulation_augments.gd](verifier_simulation_augments.gd) |
| Parcours de compte, durées et achats avec retries | [verifier_parcours.gd](verifier_parcours.gd) |
| Équilibrage normal, offensif, deux défenses et sur-farm | [verifier_equilibrage_progression.gd](verifier_equilibrage_progression.gd) |
| Cœurs au sol, fins de rencontre et retrait du tutoriel | [verifier_soins_run.gd](verifier_soins_run.gd) |
| Contrôles de sauvegarde ancienne et passifs | [verifier_migrations.gd](verifier_migrations.gd) |
| Instanciation des écrans et des trois modes | [verifier_scenes.gd](verifier_scenes.gd) |
| Décors des cinq mondes : contours, matières, variantes, budget et effets réduits | [verifier_decors.tscn](verifier_decors.tscn) ; `-- --exporter=DOSSIER` produit les GLB pour [blender/apercu_decors.py](blender/apercu_decors.py). Transitions 3D dans `verifier_scenes.gd`. |
| Flaques et rafales : placement, collisions, ralentissement, lave et rendu | [verifier_terrains.tscn](verifier_terrains.tscn) ; utilise un profil de vérification isolé. |
| Export, signature, version et installation Android | [android_mises_a_jour.py](android_mises_a_jour.py), [guide](../docs/ops/MISES_A_JOUR_ANDROID.md) |
| Héros 3D actuel | [blender/mage_sculpte.py](blender/mage_sculpte.py) |
| Bestiaire 3D, sources articulees et matieres peintes | [blender/bestiaire_sculpte.py](blender/bestiaire_sculpte.py), [creatures](blender/creatures_bestiaire.py), [boss](blender/souverains_bestiaire.py), [matieres](blender/matieres_bestiaire.py) |
| Portail et regeneration 3D globale | [blender/build_all.py](blender/build_all.py), [blender/portail_azur.py](blender/portail_azur.py) |
| Armes tenues | [blender/armes_tenues.py](blender/armes_tenues.py) |
| Kit d'interface | [generer_email_arcanique.py](generer_email_arcanique.py), [refonte_svg.py](refonte_svg.py), [signatures_svg.py](signatures_svg.py) |
| Glyphes des menus | [generer_glyphes_menus.py](generer_glyphes_menus.py) |
| Clairière animée | [generer_clairiere_vivante.py](generer_clairiere_vivante.py) |
| Deux esquisses musicales et sources originales | [audio/composer.py](audio/composer.py), [audio/masteriser_originaux.py](audio/masteriser_originaux.py), [compositions](../assets/audio/COMPOSITIONS.md) |
| Icône d'application | [preparer_identite.gd](preparer_identite.gd) |

Sources conservées : `sources_svg/`, `sources_email/`, `sources_clairiere/`,
`design_svg/`, `audio/sources/` et `../assets/3d/sources/`.
`generer_icones.py` est aussi une bibliothèque de motifs importée par le kit
actif ; ce n'est pas un générateur à relancer isolément.
