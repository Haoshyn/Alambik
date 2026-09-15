# Variété des salles — 15 septembre 2026

Les salles ordinaires de campagne alternent entre six profils : alcôves,
rotonde, galerie allongée, cour large à angles coupés, ovale et cour décalée.
Le chapitre, la graine et le numéro de salle déterminent le profil : une même
run est reproductible. Les dimensions alimentent aussi les limites du héros,
des ennemis, du fond et de la caméra.

`data/formes_salles.gd` porte les proportions, rayons des coins et subdivisions.
Le contour partagé alimente le sol 3D, ses bordures et les murs physiques.
Les alcôves conservent leurs retraits rectangulaires ; les autres profils
restent convexes pour préserver les lignes de tir entre acteurs à l'intérieur.
Les huit compositions d'obstacles restent combinables avec chaque profil.
Les apparitions vérifient la distance au contour ; leur repli est le pied du
portail, dégagé dans les compositions, plutôt qu'un dernier essai potentiellement
bloqué. Les boss restent dégagés et les modes annexes gardent leur emprise.

Quatre arrangements d'ornements alternent piliers, jardins, rangées mixtes et
groupes associés. Ils conservent les matériaux du monde et restent hors du sol
jouable. Aucun nouvel asset ni changement des couleurs des dangers.

Vérifications : `tests/test_formes_salles.gd` contrôle la triangulation, les
marges de passage de toutes les combinaisons, l'entrée, la sortie, les chemins
du bot et la diversité reproductible sur un chapitre. Le rendu sur téléphone
reste à apprécier ; les vérifications sont exécutées sans fenêtre visible.

Résultats : `verifier.sh` via `tools/verifier_windows.ps1`, 37 suites et
18 485 assertions, aucun échec. Selftest cohérent ; diagnostics de ressources
à la fermeture déjà présents. `sondes/vingt_runs.sh` : 20 fins de run, aucun
blocage ni erreur de script ; morts entre les salles 3 et 10, aucune victoire.
Ces runs ne couvrent donc pas toute une campagne ; les contrôles déterministes
couvrent les combinaisons de formes et d'obstacles.
