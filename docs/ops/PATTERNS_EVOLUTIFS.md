# Boss plus courts et attaques évolutives

Demande du propriétaire : réduire la durée des boss, mais rendre les attaques
de tout le bestiaire plus exigeantes en milieu et fin de progression.

## Endurance

En campagne, multiplicateur des PV des miniboss : 6,5 → 3,8 (−41,5 %).
Boss signatures : 5 → 3 (−40 %). Les premiers miniboss demandent maintenant
17–27 secondes de tir de base continu dans le budget de test, contre 30–45 s.
Cela ne représente pas une durée réelle incluant les déplacements et les bonus.
Les boss de Mine et d'Épreuves perdent 35 % de PV par rapport à leur ancien
calcul. Pas d'augmentation des dégâts individuels dans cette passe.

## Progression des attaques

`data/evolution_ennemis.gd` transforme une copie du profil à la création de chaque
ennemi, y compris les invocations. Les onze monstres, dix miniboss et dix boss
signatures passent par cette fabrique. Les annexes prennent le chapitre atteint.
Le prototype rétro conserve son comportement de démonstration.

| Campagne | Évolution |
|---|---|
| Monde 1, chapitres 1–3 | Comportements d'apprentissage conservés |
| Mondes 2–4, dès chapitre 4 | Rythme légèrement accru, anneaux décalés et éventails élargis |
| Mondes 5–7, dès chapitre 13 | Deux salves, charges doubles, élan annoncé du rampant, motifs de boss enrichis |
| Mondes 8–10, dès chapitre 22 | Trois salves, anneaux plus denses, passages de certains barrages plus étroits |

- Sentinelle, harceleuse, orbiteur : éventails puis rafales successives. La
  visée peut anticiper le mouvement ; les cibles annoncées restent figées.
- Tisseur : éventail ajouté aux tirs décalés et rafales ; la visée annoncée est
  figée aux paliers évolués, plutôt que corrigée au dernier moment.
- Miroir : anneaux décalés entre deux pulsations, deux puis trois pulsations.
- Phaseur : anneau de retour et tir dirigé renforcés par les salves successives.
- Essaimeur : réserve d'invocations conservée ; les anneaux évoluent et, aux
  paliers avancés, le scribe continue de tirer après épuisement de sa réserve.
- Volatile : explosion annoncée inchangée dans son principe, couronne plus dense.
  Sa mort empêche les relances différées : une seule couronne est réellement émise.
- Véloce et bélier : deuxième charge avec nouvelle préparation et nouvelle visée.
- Rampant : petit élan de mêlée annoncé à partir du monde 5.
- Boss : cadence accrue et pauses réduites, projectiles plus rapides ; doubles
  spirales, éventails enrichis, anneaux/rosaces plus denses, quadrillage et pluie
  aux passages plus étroits, mâchoire plus large, copies doubles plus précoces.
  Les identités et répertoires des deux phases sont conservés.

Les télégraphes communs restent au moins à 0,40 s ; celui des signatures reste
à 0,42 s. Les nouvelles charges ont une ligne d'annonce dans le rendu 3D.
Les salves sont traitées dans la logique physique, suspendues par le gel et par
la pause ; aucune coroutine ne survit à la mort d'un ennemi.

## Vérification

- 35 suites, 15 044 assertions, zéro échec ; compilation et cohérence réussies.
- `sondes/evolution_patterns.gd` : 11 957 contrôles sans échec sur les 31 profils
  aux chapitres 1, 13 et 28 ; exécution des motifs des deux phases des boss,
  nombre de relances borné, transitions des charges et validité des trajectoires.
- Le banc émet respectivement 3 047, 3 938 et 4 989 tirs sur son parcours fixe.
  Ce comptage caractérise les motifs ; il ne mesure pas la difficulté humaine
  ni une densité de projectiles simultanés dans une vraie salle.
- Contrôles exécutés en headless, sans fenêtre visible. Les avertissements de
  ressources non libérées à la fermeture du harnais général persistent.
- Vingt runs au chapitre 1 et trois runs sur chacun des chapitres 13 et 28 :
  26 terminaisons, sans blocage ni erreur de script. Le bot perd les 26 runs ;
  au chapitre 13 il atteint les salles 1–3, et au chapitre 28 la salle 1.
  Ces parcours tardifs ne valident donc pas une victoire ou un équilibre humain
  de fin de campagne ; le banc des 31 profils couvre séparément les motifs majeurs.
- Export Android et vérification de l'APK réussis.

APK : `build/alambic-patterns-evolutifs.apk`. Sensation d'esquive et performances
sur téléphone restent à confirmer en jouant ; les simulations ne les remplacent pas.
