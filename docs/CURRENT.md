# État courant — 20 septembre 2026

- Godot 4.7.1, Android portrait ; simulation 2D, combat présenté en 3D.
- Héros unique : `assets/3d/characters/mage_sculpte.glb`, matériaux standard,
  six animations et armes séparées. Sources et générateurs actifs conservés.
- Accueil : `assets/visual/arcane/accueil.png`. Menus, HUD, augments et récompenses
  partagent le kit peint `assets/visual/interface/` et le scriptorium saphir.
- Cinq mondes, sept chapitres de vingt salles chacun ; Mine et Épreuves de sorts.
  Contours et obstacles fixes par chapitre, terrains élémentaires en campagne.
- Augments, sorts, équipement, forge, maîtrises et garanties de butin actifs.
  Le détail est dans `docs/design/GAME_DESIGN.md` et les valeurs dans `data/`.
- Bilan : nouvelle tentative directe et raccourcis vers la maîtrise ou le bijou
  améliorable. Effets sonores distincts avec variantes et priorités ; vibrations
  Android désactivables. Outils développeur réservés aux versions de debug.
- Premiers pas progressifs : déplacement et premier tir avec ennemis suspendus,
  puis indication du portail après le combat. Pause lors du passage en arrière-plan.
- Identifiants historiques et migrations de sauvegarde conservés ; rendu 2D
  de secours et outils de capture toujours disponibles sur demande.

## Organisation

`docs/INDEX.md` est la carte unique. `human/`, anciennes cartes redondantes,
tests, diagnostics et composants sans appel sont dans
`../OldAlambik/2026-09-20/organisation/`. Les diagnostics se restaurent à leurs
chemins d'origine si demandés ; le bot PC `--auto` reste dans `sondes/`.
Les six shaders restants et les générateurs Blender/audio sont utilisés.
Les sources 3D, outils et docs sont exclus de l'import Godot par `.gdignore`.

Le nettoyage précédent (fusions, anciens modèles et prototypes) est dans
`../OldAlambik/2026-09-20/retires/` ; les copies avant chaque passe sont dans
leurs dossiers d'archive respectifs. Les prochaines sorties vont dans `tmp/`
et `build/`.

Relecture statique uniquement : aucun test, import Godot, lancement ou APK.
Le propriétaire teste le jeu ; les règles de travail restent dans `AGENTS.md`.
