# Index de travail

But : arriver au bon fichier avec le moins de contexte possible.

| Tâche | Commencer par | Puis, si nécessaire |
|---|---|---|
| Garantie de drop et économie monde 3 | `data/butins_run.gd`, `scripts/bilan_run.gd` | `docs/ops/ECONOMIE_MONDE3_ET_GARANTIES.md`, `sondes/economie_monde_trois.gd` |
| Boucle d'une run, salles, récompenses | `scripts/run.gd` | `autoload/jeu.gd`, `scripts/bilan_run.gd`, `data/butins_run.gd`, `data/recompenses.gd` |
| Niveaux d'épreuve et loots de sorts | `data/epreuves.gd` | `ui/selection_grimoire.gd`, `ui/apercu_butin.gd`, `data/sorts.gd` |
| Héros, déplacement, dégâts reçus | `scripts/acteurs/heros.gd` | `scripts/combat/stats.gd`, `data/reglages.gd` |
| Ennemi commun / IA | `scripts/acteurs/ennemi.gd` | `scripts/acteurs/cerveaux.gd`, `data/catalogue_ennemis.gd` |
| Boss / gardien | `scripts/boss.gd` | `scripts/salle.gd`, `scripts/gardien.gd`, `data/catalogue_ennemis.gd` |
| Tirs / ciblage / impacts | `scripts/combat/` | `data/reglages.gd` |
| Améliorations / effets de run | `scripts/ameliorations/` | `data/catalogue_reactifs.gd`, `data/catalogue_elements.gd` |
| Salle, obstacles, géométrie | `scripts/salle.gd`, `data/formes_salles.gd` | `data/reglages.gd`, `data/vagues.gd`, `scripts/geometrie.gd` |
| Menu principal | `scripts/menu.gd` | `ui/accueil_3d.gd`, `ui/onglet_menu.gd` |
| Rendu 3D / modeles Blender | `scripts/presentation/monde_3d.gd`, `data/visuels_3d.gd` | `tools/blender/`, `docs/ops/RENDU_3D_MOBILE.md` |
| Interface | `ui/`, `scripts/presentation/style_azur.gd` | `scripts/presentation/`, `human/interface/` si design demandé |
| Équilibrage | fichier précis dans `data/` | tests associés ; pas `scripts/run/run.gd` par défaut |
| Courbe de statistiques, équipement et maîtrises | `data/progression_statistiques.gd`, `data/catalogue_objets.gd`, `data/arbre_competences.gd` | `docs/ops/PROGRESSION_STATISTIQUES.md`, `sondes/profil_progression.gd` |
| Effets de bijoux et paliers de forge | `data/effets_bijoux.gd`, `data/catalogue_objets.gd` | `docs/ops/EFFETS_BIJOUX.md`, `autoload/jeu.gd`, `ui/equipement.gd` |
| Sauvegarde / progression joueur | `autoload/reglages_joueur.gd` | `data/arbre_competences.gd`, `data/catalogue_objets.gd` |
| Audio | `autoload/sons.gd`, `data/musiques.gd` | `assets/audio/COMPOSITIONS.md`, `tools/audio/composer.py` |
| Mobile / safe area | `autoload/ecran.gd` | `docs/ops/MOBILE.md` |
| Bug de compilation | recherche du symbole/chemin | `./verifier.sh`, `sondes/selftest.gd` |
| Design global | chercher un titre dans `docs/design/GAME_DESIGN.md` | `human/` seulement si demandé |

## Règle de lecture

Les fichiers de plus d'environ 12 Ko (`run.gd`, gros acteurs, certains écrans UI, sauvegarde) ne doivent pas être chargés intégralement sans raison. Chercher d'abord le symbole, la chaîne, le signal ou la fonction concernée et lire quelques dizaines de lignes autour.

Pour l'historique d'une décision, chercher dans `docs/archive/JOURNAL.md` ; ne jamais le mettre dans le contexte de base.
