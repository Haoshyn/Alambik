# Index de travail

Chemins relatifs à la racine. Choisir une ligne, puis chercher le symbole utile ;
il n'est pas nécessaire de lire tous les fichiers d'une ligne.

| Besoin | Point d'entrée | Dépendances utiles |
|---|---|---|
| Boucle, salles, transitions et récompenses | `scripts/run.gd`, `scripts/bilan_run.gd` | `autoload/jeu.gd`, `data/butins_run.gd`, `data/recompenses.gd` |
| Campagne, rencontres et difficulté | `data/chapitres.gd`, `data/vagues.gd` | `data/catalogue_ennemis.gd`, `data/progression_statistiques.gd`, `data/profils_progression.gd`, `data/evolution_ennemis.gd` |
| Épreuves et butins de sorts | `data/epreuves.gd`, `data/sorts.gd` | `ui/selection_grimoire.gd`, `ui/apercu_butin.gd` |
| Sorts et leurs animations | `scripts/bonus_sorts.gd`, `data/animations_sorts.gd` | `scripts/presentation/animation_sorts.gd`, `scripts/effets.gd`, `scripts/presentation/effets_3d.gd` |
| Augments et phénomènes de combat | `data/catalogue_reactifs.gd`, `scripts/mods.gd` | `scripts/draft_logique.gd`, `scripts/reactif.gd`, `scripts/details_reactif.gd`, `data/progression_augments.gd` |
| Héros, déplacement et dégâts reçus | `scripts/heros.gd`, `scripts/stats.gd` | `data/reglages.gd`, `scripts/joystick_logique.gd`, `ui/joystick.gd` |
| Premiers pas et apprentissage | `scripts/apprentissage.gd`, `ui/conseils_debut.gd` | `scripts/run.gd`, `scripts/heros.gd`, `data/reglages.gd` |
| Ennemis et boss | `scripts/ennemi.gd`, `scripts/boss.gd` | `scripts/cerveaux.gd`, `scripts/gardien.gd`, `scripts/salle.gd` |
| Tirs, ciblage et impacts | `scripts/tir.gd`, `scripts/projectile.gd`, `scripts/ciblage.gd` | `scripts/priorite_projectile.gd`, `data/catalogue_projectiles.gd` |
| Formes, obstacles et terrains | `scripts/salle.gd`, `scripts/geometrie.gd` | `data/formes_salles.gd`, `data/terrains_mondes.gd`, `scripts/terrain_elementaire.gd` |
| Statistiques, spécialisations, équipement et forge | `data/personnage.gd`, `data/catalogue_objets.gd` | `data/catalogue_familiers.gd`, `data/catalogue_projectiles.gd`, `ui/equipement.gd` |
| Listes lisibles des capacités, maîtrises, items et augments | `statistiques_jeu/` | `data/sorts.gd`, `data/arbre_competences.gd`, catalogues de `data/` |
| Maîtrises, sauvegarde et migrations | `autoload/reglages_joueur.gd`, `data/arbre_competences.gd` | `ui/arbre_competences.gd`, `autoload/jeu.gd` |
| Accueil et navigation | `scripts/menu.gd`, `ui/accueil_3d.gd` | `ui/onglet_menu.gd`, `ui/selection_grimoire.gd` |
| Écran ou panneau particulier | chercher son nom dans `ui/` avec `rg --files ui` | `ui/hud.gd`, `ui/draft.gd`, `ui/pause.gd`, `ui/sorts.gd`, `ui/fin_de_run.gd` |
| Style commun de l'interface | `scripts/presentation/style_azur.gd`, `scripts/style_interface.gd` | `scripts/palette.gd`, `scripts/polices.gd`, `assets/visual/interface/ORIGINE.md` |
| Rendu 3D et décor | `scripts/presentation/monde_3d.gd`, `data/visuels_3d.gd` | `scripts/presentation/arene_3d.gd`, `scripts/presentation/proxy_3d.gd`, `data/decors_mondes.gd` |
| Héros 3D, matières, animations et armes | `scripts/presentation/materiaux_apprenti.gd`, `scripts/presentation/animation_heros_3d.gd` | `scripts/presentation/suivi_visuel_2d.gd`, `scripts/presentation/arme_tenue_3d.gd` |
| Effets et shaders | `scripts/presentation/effets_3d.gd`, `scripts/presentation/phenomenes_3d.gd` | `scripts/presentation/projectile_3d.gd`, `scripts/presentation/portail_3d.gd`, `shaders/` |
| Présentation 2D de secours | `scripts/dessin.gd`, `scripts/retro16.gd` | `scripts/fond.gd`, `scripts/fond_adaptatif.gd`, `scripts/cadre_retro.gd` |
| Transitions et raccourcis tactiles | `scripts/voile_transition.gd`, `scripts/raccourci_tactile.gd` | `ui/transition_grimoire.gd`, `scripts/presentation/passage_manga.gd` |
| Audio, vibrations et choix de musique | `autoload/sons.gd`, `data/effets_sonores.gd`, `data/musiques.gd` | `scripts/audio/synthese_effets.gd`, `ui/reglages.gd`, `assets/audio/COMPOSITIONS.md` |
| Génération de modèles, images ou audio | `tools/AGENTS.md` | ouvrir seulement le générateur indiqué et ses dépendances |
| Mobile et zones sûres | `autoload/ecran.gd` | `docs/ops/MOBILE.md` |
| Export ou installation Android demandés | `tools/android_mises_a_jour.py` | `docs/ops/MISES_A_JOUR_ANDROID.md`, `export_presets.cfg` |
| Capture ou mode automatique demandé | `scripts/capture.gd`, `sondes/bot.gd` | `sondes/navigation_bot.gd` |
| Périmètre, état ou direction artistique | `docs/design/GAME_DESIGN.md`, `docs/CURRENT.md` | `docs/design/DIRECTION_ARTISTIQUE.md` pour le visuel |

## Archives et diagnostics sur demande

`../OldAlambik/2026-09-20/organisation/` conserve `human/`, tests, diagnostics,
anciens composants et documents remplacés, avec inventaire et copies avant modification.
Le nettoyage précédent est dans `../OldAlambik/2026-09-20/retires/`.

Les tests et sondes archivés ne s'exécutent pas directement depuis OldAlambik :
leurs chemins `res://` nécessitent une restauration dans Alambik. Pour une
vérification demandée, consulter le `LIRE_MOI.md` de l'archive et restaurer le
périmètre nécessaire avec ses dépendances, sans écraser le travail actuel.
Leur archivage ne signifie pas qu'ils sont tous obsolètes ; leur exécution reste
sur demande selon `AGENTS.md`.
