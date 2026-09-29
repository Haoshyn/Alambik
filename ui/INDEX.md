# Interface — index

| Écran ou rôle | Fichiers |
|---|---|
| Accueil et choix de campagne | `accueil_clairiere.tscn`, `accueil_3d.gd`, `selection_grimoire.gd` |
| Mine et Épreuves | `selection_mode.gd`, `apercu_butin.gd` |
| Attributs et classes | `heros.gd`, `choix_classe.gd` |
| Équipement et forge | `equipement.gd` |
| Maîtrises | `arbre_competences.gd` |
| Collection et emplacements de passifs | `passifs.gd`, `passifs.tscn` |
| Combat | `hud.gd`, `joystick.gd` |
| Choix d'augments | `draft.gd`, `carte_reactif.gd` |
| Pause et réglages | `pause.gd`, `reglages.gd` |
| Résultat de la tentative | `fin_de_run.gd`, `coffre_anime.gd` |
| Démarrage, entrée en partie et chargements entre étages | `demarrage.gd`, `demarrage.tscn`, `transition_grimoire.gd`, `composants/chargement_aventure.gd` ; voile de run dans `../scripts/interface/voile_transition.gd`, cadrage du démarrage dans `../shaders/chargement_adaptatif.gdshader` |
| Éléments réutilisables | `composants/` : navigation, compteurs, cartes, fiches, défilement et clairière |

La navigation des cinq onglets est coordonnée par `../scripts/menu.gd`.
La palette et les styles partagés sont dans `../scripts/interface/` et
`../scripts/presentation/style_azur.gd`. Certains écrans sont construits
entièrement en code ; la présence d'un script n'implique pas une scène séparée.
