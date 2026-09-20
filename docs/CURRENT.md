# État courant — 19 septembre 2026

Ce fichier décrit la base active. Les valeurs exactes restent dans `data/` ; les
anciens essais et résultats de tests ne valent pas validation de l'état présent.

## Présentation

- Le modèle actif en jeu et par défaut est `assets/3d/characters/mage_sculpte.glb`,
  avec ses retouches récentes et ses matériaux standard. Les anciens choix
  sauvegardés sont redirigés vers ce modèle au chargement.
  Le précédent modèle `assets/3d/characters/mage_reference.glb` reste conservé,
  généré par `tools/blender/mage_reference.py`. Référence fournie conservée dans
  `assets/3d/sources/characters/mage_reference/direction.png`, avec sa source Blender.
  Textures couleur et normales intégrées, matières éclairées, écharpe sur trois os,
  six animations. Rendu encore à apprécier avec le propriétaire dans l'atelier.
- L'essai procédural `mage_fidele` a été rejeté pour ses proportions, ses facettes
  et ses matières. Il n'est pas activé dans le jeu. La copie de travail
  `mage_sculpte`, issue du maillage sculpté et exportée séparément, est désormais
  utilisée en jeu à la demande du propriétaire.
- Atelier sculpté : éclairage neutre et matériaux standard importés du GLB.
  Le shader dédié `shaders/mage_sculpte_surface.gdshader` est désactivé à la
  demande du propriétaire. Retrait local de l'écharpe du mage sculpté par
  `tools/blender/sans_echarpe.py`. Os de l'écharpe supprimés.
  Reprise du vêtement par `tools/blender/vetement_sculpte.py` : haut de tunique
  et manches continus, violet uniforme aux épaules, reste de pan isolé retiré.
  Coudes fléchis vers l'avant et doigts recourbés vers la paume.
  `tools/blender/poignets_sculptes.py` réduit les mains d'environ un quart,
  les recentre sur les avant-bras et remplace les bracelets par du cuir uni.
  Potion de ceinture retirée ; tissu sous son attache repris depuis le côté opposé.
  `tools/blender/bottes_sculptees.py` raccourcit et affine les bottes,
  anime une course sur un cycle de 0,54 s, avec des appuis courts et une
  phase aérienne entre les pas. Foulée élargie et flexion des genoux réduite.
  Buste penché vers l'avant, épaules en torsion alternée et bras fléchis
  balancés à l'opposé des jambes ; tête compensée pour garder le regard devant.
  `tools/blender/raccord_tunique.py` prolonge le tissu sous la ceinture et
  harmonise leur attache au bassin pour fermer le ventre pendant la course.
  Armes tenues séparées dans `assets/3d/weapons/`, générées par
  `tools/blender/armes_tenues.py` d'après les silhouettes du catalogue.
  `arme_tenue_3d.gd` les attache à la main droite et le proxy suit l'arme équipée.
  L'atelier propose les dix armes sans modifier la sauvegarde.
  `gestes_baguette.py` maintient la prise droite, légèrement vers l'avant en
  course ; au lancer, le bras avance sans balayage latéral. Prise rapprochée
  de la monture de la baguette.
  Genoux légèrement relevés et recentrés dans le pantalon.
  Pointes redressées vers l'avant ; bottines entièrement rigides sur les pieds.
  La foulée distingue poussée arrière, remontée du talon, passage du pied
  sous le bassin et extension avant. Les bottines restent rigides et basculent
  avec les pieds ; leur levée tient compte de la pointe pour éviter le sol.
  Bas du pantalon reconstruit en surfaces continues autour des genoux pour
  supprimer les pans du scan qui se pinçaient sur les bottes.
  Version avant les bottes conservée dans `tmp/retouche-bottes/avant.glb` et `avant.blend`.
  Version avant cette passe conservée dans `tmp/retouche-poignets/avant.glb`
  et `avant.blend`.
  Copie antérieure dans `tmp/retouche-vetement/avant.glb` et `avant.blend`.
  Chapeau reconstruit en pièces distinctes dans `tools/blender/chapeau_sculpte.py` :
  bord violet à épaisseur constante, calotte et ruban séparés. Marges UV et filtre
  de projection contre les débordements violets dans les cheveux. Des raccords
  de texture restent visibles ; la fidélité artistique reste à valider.
  Cheveux du dessus et de l'arrière repris dans `tools/blender/cheveux_sculptes.py` :
  fond rentré, mèches superposées et courtes aux tempes ; frange sculptée conservée.
  Les mèches et le fond reprennent la texture de la frange. Racines limitées sous
  le bord du chapeau ; sa base suit la tête, seule la pointe reste souple.
  Raccords du chapeau repris : base de calotte plane engagée dans le bord,
  ruban suivant sa surface et ouverture intérieure ajustée aux racines.
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

- Campagne : 5 mondes (Encre, Terre, Eau, Air, Feu), chacun avec
  7 chapitres de 20 salles, soit 35 niveaux. Boss signature au chapitre 7.
  Les trois bijoux de chaque monde reviennent en cycle sur ses sept chapitres.
  Progression sauvegardée conservée par rang de niveau ; anciens bijoux conservés.
  Mine de survie et Épreuves de sorts restent disponibles.
- Arènes de campagne : parcours fixe de 20 étages, identique à chaque nouvelle
  run du même chapitre. Neuf contours proches du rectangle, dont deux davantage
  arrondis ; de zéro à quatre petits obstacles avec tailles et silhouettes variées
  (murets droits/en L, piliers, rochers, caisses ou livres). Déclinaisons fixes par
  chapitre, centre dégagé et variantes sans murets visibles. La graine de run
  ne change ni les contours, ni les obstacles, ni les effets de terrain.
  Les rebords conservent les limites de déplacement. Encre ouvre la campagne sans
  effet de terrain. Terre : sables mouvants (ralentissement de 5 % à 60 % en 4 s,
  remis à zéro à la sortie). Eau : flaques ralentissant de 15 % et bloquant les
  tirs, y compris rafales et préparations. Air : vent directionnel sur certaines
  salles, allure modulée de ±25 % selon le sens de marche, petits traits fléchés
  indiquant le sens ; aucune tornade ni poussée à l’arrêt. Feu : lave infligeant
  6 % des PV max toutes les 1,2 s avant protections. Zéro, une ou deux flaques
  selon la salle ; centre et accès dégagés.
  Pas de zones élémentaires sur les boss ou les modes annexes. Sources :
  `data/terrains_mondes.gd`, `scripts/terrain_elementaire.gd` et son rendu 3D.
  Première intégration procédurale de la direction retenue, relue sans lancement
  ni test ; les visuels ne sont pas des imports des illustrations de concept.
- Équilibrage du 19 septembre : cible de première complétion autour de 12 h
  pour les 35 chapitres, avec plusieurs tentatives pour farmer les ressources,
  acheter des maîtrises, forger puis surmonter les chapitres suivants. Le budget
  théorique comprend environ 7 h 20 de victoires et 4 h 40 de reprises/farm ;
  les 12 h ne représentent pas un parcours de premières victoires. Sans tests ni runs.
  Base héros : 60 PV, 6 ATK, 1,6 tir/s. Courbe ennemie fixe et progressive :
  PV ×0,75 → ×15, dégâts ×0,50 → ×15 ; montée interne ×1,60 PV et ×1,20 dégâts.
  Miniboss : coefficient PV progressif ×1,25 → ×3,50, pour garder l'entrée
  accessible. Motifs renforcés aux chapitres 10/18/26 ; annexes sur la même échelle.
- Maîtrises : bonus ATK/PV additifs de 5/7,5/10/12,5 % par rang, majeurs
  additifs. Cadence limitée à +45 % au total. Bijoux : même budget initial,
  forge +2,5 points d'ATK et de PV par niveau ; pouvoir unique au niveau 10.
  Coûts de maîtrise et de forge arrondis à 5. Gouttes : +7,5 % par chapitre et
  +10 % par boss dans le coffre ; Mine : croissance ×1,10 par chapitre.
  La croissance des Gouttes réserve une part du financement aux reprises,
  y compris aux échecs qui rémunèrent les salles terminées.
  Début rapide : un échec en salle 20 doit financer environ deux petits rangs
  de maîtrise. Au chapitre 1, les 19 salles et trois boss donnent déjà 56–59
  Gouttes hors bonus : quatre achats initiaux à 10/15 Gouttes, ou deux rangs
  à 25 Gouttes. Ensuite, quelques tentatives utiles financent un petit gain ;
  les maîtrises avancées et pouvoirs majeurs demandent davantage d'épargne.
  Le bilan du coffre rappelle les maîtrises et bijoux équipés
  améliorables immédiatement avec le solde disponible ; aucun achat automatique.
  Rangs acquis conservés, remboursement de l'ancien arbre au barème historique.
- Ennemis : profils communs et costauds, un costaud maximum par vague normale.
  Dès le chapitre 2, 10 % de chance d'élite par vague, un seul vivant à la fois.
  Élite commun : PV ×1,5, dégâts ×1,15 ; costaud : PV ×1,25, dégâts ×1,10.
  XP ×2 et bonus de Gouttes ; pas d'élites sur boss, invocations ou annexes.
- Augments de campagne : dix niveaux, dont exactement quatre rares tirés sans
  remise au début de la run. Les six autres proposent uniquement soin de 30 %
  des PV max, ATK +10 % ou PV max +10 %. Bonus additifs à plein effet à chaque
  choix ; augmenter les PV max ne soigne pas. Les fins de salle garantissent
  les dix niveaux avant le boss final ; aucune relance ne change leur rareté.
- Choix épiques avant les étages 5/10/15 (Salve, Tir multiple, etc.), avec soin
  garanti de 30 % des PV max. Trois raretés seulement : commun, rare, épique.
  Apothéose appartient aux épiques et peut être proposée à chacun des trois
  paliers. Pas de soin automatique de niveau ni de soin de boss supplémentaire.
- Sorts actifs et ultimes : dégâts proportionnels à l'attaque équipée et aux
  bonus ATK de run, indépendants des ratios de baguette et des pénalités par
  projectile. Rangs : +5 % de puissance ; passifs : paliers lisibles de 2,5
  points ou effets entiers. Brûlure : 10 % du coup par seconde pendant 4 s.
  Puissance arcanique (rare) : dégâts des sorts +25 %. Cycle arcanique
  (rare) : récupération −15 %. Apothéose (épique) : dégâts +75 % et
  rayon du sort actif +25 %. Les deux rares entrent dans les quatre choix rares
  de niveau. Exclus des choix sans sort ni ultime équipé.
  Héritage réactif donne des relances, sans ajouter de rares au départ.
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
