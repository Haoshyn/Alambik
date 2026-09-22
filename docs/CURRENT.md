# État courant — 22 septembre 2026

- Godot 4.7.1, Android portrait ; simulation 2D, combat présenté en 3D.
- Héros unique : `assets/3d/characters/mage_sculpte.glb`, matériaux standard,
  six animations et armes séparées. Sources et générateurs actifs conservés.
- Accueil : `assets/visual/arcane/accueil.png`. Menus, HUD, augments et récompenses
  partagent le kit peint `assets/visual/interface/` et le scriptorium saphir.
- Cinq mondes, sept chapitres de vingt salles chacun ; Mine et Épreuves de sorts.
  Contours et obstacles fixes par chapitre, terrains élémentaires en campagne.
- Attributs de compte, trois spécialisations, familiers autonomes, Cœurs de
  mana, augments, équipement, forge, maîtrises et garanties de butin actifs.
  Le détail est dans `docs/design/GAME_DESIGN.md` et les valeurs dans `data/`.
- Huit passifs à deux rangs : un seul doublon double leur effet. Les bijoux de
  forge 10 utilisent seulement des bonus passifs courts, sans attaque automatique.
- La forge est plafonnée à 20 niveaux avec la puissance et le coût total de
  l’ancienne forge 100. Les armes n’emploient aucun bonus final ni augment caché.
- Équilibrage fixe sur 35 profils achetables : standards autour de trois
  attaques, petits autour de deux, gros autour de sept à huit, augments de run
  séparés des Maîtrises et cinq boss de monde à mécaniques distinctes.
- Les tirs n’ont plus de portée maximale par défaut : murs, limites et impacts
  les arrêtent. Les augments de trajectoire, défense et phénomènes utilisent
  leurs mécaniques révisées, détaillées dans `statistiques_jeu/liste_augments.txt`.
- Bilan : nouvelle tentative directe et raccourcis vers la maîtrise ou le bijou
  améliorable. Effets sonores distincts avec variantes et priorités ; vibrations
  Android désactivables. Outils développeur réservés aux versions de debug.
- Tutoriel hors campagne : cinq étages, baguette de départ, un choix d'augment
  et un mini-boss. Cadeau unique au coût du premier rang de maîtrise, sans XP
  de compte ni progression de campagne. Mine et Épreuve 1 ouvertes à la sortie.
- Guidage de l'atelier sauvegardé : maîtrises, spécialisation, musique, Mine,
  Épreuves, puis commandes après un sort actif obtenu en Épreuve. Passage avec
  confirmation en haut à droite ; anciennes sauvegardes jouées non forcées.
- Paramètres : réinitialisation avec confirmation et retour à un accueil neuf.
  « Avancer à » en debug prépare cinq victoires par chapitre précédent, Mine
  ouverte et Épreuve de difficulté correspondante, avec aperçu des vrais butins
  à tirages fixes. Ressources non dépensées, mode développeur désactivé à l'application.
- Déplacement et premier tir avec ennemis suspendus, puis indication du portail.
  Pause lors du passage en arrière-plan.
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
