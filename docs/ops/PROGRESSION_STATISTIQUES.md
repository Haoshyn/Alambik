# Progression des statistiques — 16 septembre 2026

Cette passe remplace le recalage du 15 septembre : conserver les anciens rapports
rendait la progression équipée trop facile. La difficulté dépend uniquement du
chapitre, jamais du build réel du joueur.

## Courbe fixe

La correction du même jour est détaillée dans `ECONOMIE_MONDE3_ET_GARANTIES.md`.
Le repère monde 3 est désormais calculé sur douze à dix-huit victoires payant les
maîtrises et les vrais drops : **120 dégâts de référence**, PV ennemis ×3.
Interpolation exponentielle entre le premier chapitre, l’entrée du monde 3 et
le dernier chapitre ; première et dernière valeurs conservées. La montée interne
reste ×1,75 PV et ×1,30 dégâts. Les annexes partagent l’échelle des chapitres.

Base offensive : 5,49 dégâts et **1,586 tir/s**. La cadence a été réduite de 20 %,
interprétation provisoire de la demande orale. Les bijoux n’en donnent aucune.

## Maîtrises

Trois branches de dix nœuds : les positions **3, 6 et 9** ont un seul rang.
Les autres ont dix rangs à plein effet. Les rangs d’un nœud s’additionnent ;
les nœuds de dégâts/PV se multiplient.

- Offense : dégâts +10/15/20/25 % par rang ; cadence +1/1,5/2 % par rang
  (ensemble plafonné à +45 %) ; trois majeurs doublant les dégâts.
- Défense : PV +10/15/20/25 % par rang ; armure +5/7/10 % par rang ;
  majeurs doublant les PV, divisant les dégâts reçus par deux, puis doublant les PV.
  L’armure divise les dégâts par `1 + armure`.
- Utilitaire : gouttes, pierres, XP et coffres +4 à +6 % par rang.
  Majeurs : un nouveau tirage, un second passif, un autre nouveau tirage.
- Les majeurs coûtent quatre fois le prix initial de leur ancien emplacement.

Les achats de l’ancien arbre sont remboursés une seule fois, à leur ancien coût,
pour permettre une nouvelle répartition. Sauvegarde `maitrise/version = 2`.

## Baguettes et sorts

Dix baguettes, aux chapitres 1/4/7/10/13/16/19/22/25/28 : acier, aiguille,
cuivre, astrale, étincelles, prisme, diapason, cornue, néant, souverain.
L’aiguille donne ×0,78 dégâts et ×1,20 cadence (93,6 % du DPS de base), sans
bonus de recharge. Le cuivre donne ×1,65 dégâts et ×0,70 cadence ; ses trois
impacts gardent leur pleine puissance. Les dernières armes sont plus puissantes.
Les cinq nouvelles armes réutilisent pour l’instant les illustrations existantes.

Les rangs des sorts sont conservés : +3 % par rang supplémentaire, donc +27 %
au rang 10. Réserve d’ultime réduit la recharge de 45 % dès le premier rang.

## Interface et mesures

Un conseil de départ non bloquant et mémorisé accompagne la première aventure.
Choisir un chapitre accessible lance directement sa transition vers le combat.
Les aperçus de butin utilisent les assets du jeu et ouvrent des fiches détaillées.

`sondes/calibrer_progression.gd` écrit `tmp/progression/courbe.csv` : parcours
indicatif avec achats progressifs, forge jusqu’à 30 et baguettes accessibles.
Ce modèle ne simule pas les revenus ou les choix humains. Les tests du monde 3 utilisent désormais le parcours économique payé ;
l’ancien profil théorique reste seulement un outil de comparaison.
`tests/progression_avant.json` reste un relevé historique, plus une cible de calibration.

Vérifications : `verifier.sh`, `sondes/vingt_runs.sh`,
`sondes/refonte_progression.gd` et `sondes/effets_bijoux.gd`, tous en headless.
Les résultats automatiques ne remplacent pas l’appréciation du rythme sur téléphone.

## Résultats de cette passe

- 40 suites, **31 252 assertions**, zéro échec ; selftest cohérent.
- **47 contrôles d’intégration** réussis (30 refonte + 17 bijoux) : impacts du
  cuivre, tutoriel, lancement direct, illustrations/fiches, dix armes et trois formats.
- Vingt runs du chapitre 1 : **17 victoires**, trois défaites (salles 8, 9 et 10),
  aucun blocage ni erreur de script. Le profil isolé est sans sauvegarde de joueur.
- Le profil de sonde historique `--intermediaire` (offense 8, défense 2,
  forge 30, baguette de base) meurt salle 1 au chapitre 30, graine 1.
  Il ne valide donc pas la fin de campagne avec un investissement défensif faible.
  Le parcours chiffré équilibré est contrôlé séparément ; la difficulté humaine
  et l’économie complète restent à apprécier en jeu.
- Les diagnostics préexistants de ressources à la fermeture du selftest headless
  subsistent (textures, police et instances), sans erreur de script.

Logs : `tmp/verification-refonte16-final.log`, `tmp/vingt-refonte16-final.log`,
`tmp/sonde-refonte16-final.log`, `tmp/bijoux16-final.log`, `tmp/run30-refonte16.log`.
