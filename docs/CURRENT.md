# État courant — 22 septembre 2026

- Godot 4.7.1, Android portrait ; simulation 2D, combat présenté en 3D.
- Héros unique : `assets/3d/characters/mage_sculpte.glb`, matériaux standard,
  six animations et armes séparées. Sources et générateurs actifs conservés.
- Accueil : `ui/accueil_clairiere.tscn`, composé de scènes indépendantes dans
  `ui/composants/`. Académie arcanique, héros détouré au centre, modes
  latéraux, destination et Jouer en bas ; cinq onglets fixes et zones sûres.
- Kit A « Émail arcanique » : turquoise, ivoire et bronze, volumes simplifiés.
  Cadres « Sceaux liquides », emplacements et commandes circulaires ; onglets
  Héros, Équipement, Aventure, Maîtrises, Sorts. Héros : portrait, commandes −/+
  et reset gratuit, sous-menu de classe obligatoire au premier accueil sans classe.
  Composition : Héros asymétrique autour du personnage, maîtrises en constellation,
  sorts en symboles avec fiches détaillées, parure en sceaux décalés. Titres et
  ressources sans cadres ; marges intérieures protégées sous les ornements.
  SVG natifs légers (icônes, cadres, équipements, capacités et contrôles),
  filtrage avec mipmaps et sans ancien détourage alpha. Générateur :
  `tools/generer_email_arcanique.py`. Zones sûres latérales, grilles adaptatives
  et accueil défilable ; menus, HUD, augments et récompenses partagent le kit.
- Cinq mondes, sept chapitres de vingt salles chacun ; Mine et Épreuves de sorts.
  Contours et obstacles fixes par chapitre, terrains élémentaires en campagne.
- Déplacement du héros à 728 px/s (+30 %), coefficient de vitesse ennemi +15 %.
  Familles fragiles/moyennes/costaudes et 55 identités de monde avec habillages 3D.
  Charges, esquives, tirs ondulants, rebonds et impacts ciblés annoncés actifs.
  Élites : PV/dégâts doublés ; certaines laissent des traces brûlantes.
- Animation de combat : préparations, recul et mouvements par famille en 3D,
  impacts et dissipation des sorts, tirs en cloche annoncés et vrilles en rubans.
  Les réactions aux coups préservent la lecture des attaques. Boss : +25 % de PV
  dans les trois modes ; attaques propres conservées et salves de monde alternées.
- Vagues de 3–5 ennemis, jusqu’à 7 dans les grandes salles, départ limité à 4.
  Espacement accru, plafond simultané appliqué aussi aux invocations et XP conservée.
  En campagne, l’XP reste au sol jusqu’au nettoyage ; les choix arrivent hors combat.
- Mine survivor : horde continue, cristaux d’XP à ramasser près des ennemis abattus,
  augments obtenus pendant la survie. Boss à cinq minutes sans nettoyage préalable ;
  les apparitions continuent jusqu’à sa mort, qui termine immédiatement la run.
- Attributs de compte, trois spécialisations, familiers autonomes, Cœurs de
  mana, augments, équipement, forge, maîtrises et garanties de butin actifs.
  Le détail est dans `docs/design/GAME_DESIGN.md` et les valeurs dans `data/`.
- Huit passifs à deux rangs : un seul doublon double leur effet. Les bijoux de
  forge 10 utilisent seulement des bonus passifs courts, sans attaque automatique.
- Augments : 22 rares, 14 épiques et 7 légendaires, plus les trois communs.
  Rafales, critiques de run, bouclier par salle et tirs élémentaires disponibles.
- Forge sur 20 niveaux : premier achat à 30 Pierres, coût croissant. Les bases
  des armes, bijoux et familiers augmentent avec leur provenance ; les bijoux
  donnent aussi de l’Attaque brute. Aucun bonus final caché sur les armes.
- Équilibrage fixe sur 35 budgets d’achats : cible 3–4 tentatives au début,
  6–7 au milieu, jusqu’à 10 échecs et 5–6 victoires de farm en fin de campagne.
  Premières salles adoucies puis montée accentuée ; légendaire toujours aléatoire.
  Calculs et hypothèses dans `plan_eq.txt`, sans validation par parties.
- Bijou possible dès 5/10/15 salles terminées à 1/30, 1/20 et 1/10 ; garantie
  au troisième succès complet du même chapitre, y compris au premier chapitre.
- Les tirs du héros n’ont pas de portée maximale par défaut ; les tirs hostiles
  ont une distance maximale, y compris après rebond. Les augments utilisent
  leurs mécaniques révisées, détaillées dans `statistiques_jeu/liste_augments.txt`.
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

La version précédant la composition modulaire est conservée dans
`../OldAlambik/2026-09-22/interface-avant-composition-161302/`.

Relecture statique uniquement : aucun test, import Godot, lancement ou APK.
Le propriétaire teste le jeu ; les règles de travail restent dans `AGENTS.md`.
