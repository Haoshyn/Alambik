# État courant — résumé de travail

Ce fichier sert à s'orienter, pas à remplacer les données du jeu. Pour une valeur exacte, lire le catalogue ou `data/reglages.gd` concerné.

## Jouable

- Fusions experimentales actives dans les Alambics de campagne/Mine : dix recettes, trois propositions compatibles, synergie Feu/Eau en vapeur, charges de mouvement et effets differes. Choix de niveau par familles distinctes. Essai direct et profil isole : `tools/essayer_fusions.ps1` ; protocole et limites dans `docs/ops/FUSIONS_EXPERIMENTALES.md`. Epreuves rituelles encore sur l'ancien systeme elementaire pour cette iteration.

- HUD et augmentations : PV chiffres et rangee d'inventaire sous l'XP retires ; commandes neutralisees avant les choix/pause pour eviter la course bloquee. Audit des trente augmentations, couts multiplicatifs separes des bonus, reequilibrage offensif/soin/defense. Boss de campagne renforces ; banc controle debutant a 33–41 s, premiere signature a 37 s. Protocole, limites et catalogue complet : `docs/ops/EQUILIBRAGE_AUGMENTATIONS.md`.

- Identite et demarrage : nouvelle icone illustree de l'Apprenti A, variantes Android configurees. Ancienne intro de 1,55 s et message « Le grimoire vivant s'eveille » retires ; menu et navigation disponibles immediatement. Splash moteur masque, fond bleu nuit raccorde au menu. Voir `docs/ops/IDENTITE_DEMARRAGE.md`.

- Apprenti A : silhouette v6 acceptee par le proprietaire. V7 polit les surfaces, raccourcit le lancer a 0,20 s et synchronise le projectile apres 0,05 s de preparation, y compris en rafale. Premier passage sur le decor : dalles claires, bordures chanfreinees, obstacles en pierre avec sceaux cuivre/turquoise et mousse. Essai : `tools/atelier_apprenti.ps1 -EnJeu`. Details et controles dans `docs/ops/APPRENTI_A.md`.

- Apprenti A : geometrie compacte conservee ; la demarche rebondissante v2 a ete rejetee. Sprint v3 compose de poses amples, cycle de 0,4 s, buste penche sans squash, genou lance et talon ramene, bras engages. Atelier avec controleur du jeu, profil et parcours en virages ; matieres toon communes au combat. 615 assertions de mouvement valides ; validation artistique encore a faire. Voir `docs/ops/APPRENTI_A.md`.

- Essai visuel actif : **Apprenti A chibi**, choisi sur la planche du 12 septembre. Nouvelle geometrie Blender originale, sans Meshy, grosse tete, chapeau violet souple, echarpe turquoise, fiole et baguette. 18 os et six animations ; export selectionne en combat. Atelier interactif : `tools/atelier_apprenti.ps1`. Premiere interpretation a valider visuellement ; optimisation mobile encore ouverte. Details : `docs/ops/APPRENTI_A.md`. Le modele B decrit plus bas est conserve mais n'est plus selectionne.

- Campagne structurée en mondes, chapitres et salles, avec miniboss et boss.
- XP de run, choix d'Améliorations et fusions élémentaires via les Alambics.
- Équipement, Forge et progression permanente.
- Mine de survie et Épreuves rituelles.
- Sort actif, Passif(s) et Ultime équipables.
- Interface portrait mobile, joystick/tactile, réglages, pause et navigation paginée.
- Combat 3D : modèles GLB existants du héros, gardien, bestiaire, boss, projectiles et décor ; palettes lumineuses des dix mondes.
- Accueil Cuivre & Azur sur fond portrait continu, animé par shader ; compteurs réels et commandes Godot. La barre illustrée est commune aux quatre pages. Le chapitre ouvre campagne, Mine et Épreuves.
- Menus natifs Cuivre & Azur : équipements Anneau/Collier/Bague, maîtrises, sorts, trois cartes d’amélioration superposées, paramètres, pause, infusion et bilan. Aucun portrait du héros sur ces écrans.
- Mage humain violet retravaillé dans Blender : chapeau souple à bord cuivre, manteau à pans et pèlerine, écharpe turquoise, sacoche de fioles et baguette en cornue. Visage abrité à la caméra de jeu, quatorze os et six animations. Géométrie dans `tools/blender/mage_arcade.py`, rig dans `mage_manga.py` ; source Blender et GLB reconstruits. Ce modèle a été rejeté visuellement par le propriétaire ; il reste provisoirement intégré. Bilan : `docs/ops/RETOUCHES_GRAPHIQUES.md`.
- Héros **B — Mage compact** intégré au combat : 41 083 triangles avec bâton et nouveau gant fermé, textures 2K, 20 os. Course arcade de 0,533 s à 60 Hz, genoux remontés, suspension et légère compression du buste ; pointe du chapeau souple. Prise devant la paume, bâton incliné à l’écart du chapeau. Mélange continu repos/course ; tirs et impacts filtrés sur le haut du corps. Caméra et modèle partagent une interpolation du mouvement 2D ; matières cuivre/tissu différenciées dans Godot. Contrôles : 609 assertions de fluidité, intégration graphique réussie. Mesure Android et retopologie manuelle restent à faire. Détails : `docs/ops/HEROS_B_MESHY.md` (section « Reprise de la fluidité et des matières »).
- Salles de campagne 1260 × 1900, trois obstacles centraux décalés et retraits latéraux raccordés aux collisions. Boss et Épreuves dégagés ; Mine sans retraits sur les bords d’apparition. Caméra de suivi avec vue 3D à 48°.
- 83 glyphes SVG : silhouettes distinctes par amélioration, maîtrise et sort. Bijoux absents dans les emplacements vides. Captures et validation des retouches : `docs/ops/RETOUCHES_GRAPHIQUES.md`.
- Cadrage portrait 1080 × 1920 conservé sans déformation ni rognage, avec bandes sur les autres ratios. Vérifications et limites : `docs/ops/RENDU_3D_MOBILE.md`.
- Sondes headless et suites de tests maison.

## Architecture de données

Les chiffres et catalogues sont centralisés dans `data/` : réglages généraux, Améliorations, Éléménts, ennemis, objets, chapitres, vagues, récompenses, sorts et Maîtrises. La logique doit consommer ces données au lieu de créer une deuxième source de vérité.

## Points encore ouverts

- Identité environnementale et bestiaire propres à chaque monde.
- Variantes et polissage final des boss.
- Effets finaux de certains équipements et migration d'anciens objets.
- Ajustement fin de l'économie et des paliers des modes annexes.
- Identité finale de certaines transformations élémentaires.
- Contrôle mobile définitif et post-game.
- Découpage progressif des plus gros contrôleurs lorsque leur modification l'exige réellement.

## Vérification

L'état historique détaillé et les anciennes mesures ont été conservés dans `docs/archive/ETAT_2026-08-14.md`. Elles ne doivent pas être considérées comme des mesures actuelles sans relancer les outils.

Pour vérifier l'état présent :

```sh
./verifier.sh
./sondes/vingt_runs.sh
```
