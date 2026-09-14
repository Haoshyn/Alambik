# Coffres, épreuves et récupération — 14 septembre 2026

## Combat

Les boss invoquent au maximum deux renforts toutes les 18 secondes, avec trois
renforts de boss simultanés dans la salle. Les invocations ont 28 % des PV et
55 % des dégâts du profil normal mis à l’échelle. Elles ne donnent pas d’XP ni
de déclenchement de passif sur élimination. Les renforts disparaissent avec leur
boss ; le boss final termine immédiatement l’aventure, sans portail ni draft.

Les actifs récupèrent en 12/16/18/20/22 secondes et frappent pour
5/6/8/10/11 fois un tir. Les ultimes Grand Œuvre, Temps suspendu et
Transmutation totale récupèrent en 75/55/90 secondes, pour 14/4/19 fois un tir.
Temps suspendu gèle pendant cinq secondes. Tous sont prêts au départ ; ensuite
seul le temps de jeu les recharge, hors pause, choix et transition. Le plafond
de quatre ultimes est remplacé par leur récupération. Les impacts, éliminations,
changements de salle et Sang-froid ne réinitialisent plus les sorts.

Aiguille vive : −10 % de récupération. Élan devient Élan arcanique : −3 % par
rang avec les rendements utilitaires existants (−15 % au maximum). Sang-froid :
−15 % sur l’actif au rang 1 ; Réserve d’ultime : −20 % sur l’ultime au rang 1.
Les facteurs se multiplient et le délai conserve au moins 45 % de sa valeur
initiale. Rempart initial passe à −12 % de dégâts subis, Audace à +30 %, Dernier
rempart à −30 %, Écho à 25 % de chance de répéter 60 % des dégâts. Riposte : ×2.

Les cinq maîtrises de dégâts donnent +10/+15/+20/+25/+30 % par rang, composés
sans rendement décroissant. Toutes au rang 10 : environ ×8 342 dégâts avant
équipement et augmentations. Les PV bruts augmentent de 28 % par chapitre ;
le dernier étage du chapitre 30 vaut environ ×2 250 hors multiplicateurs boss.
La difficulté dépend du chapitre, jamais des statistiques équipées. Le premier
chapitre conserve son facteur d’accueil. La défense et les coûts restent inchangés.
Cette courbe vise le farm et les gros nombres ; son rythme à long terme reste à
évaluer avec des parties humaines, sans promesse de durée de progression.

## Épreuves

Onze niveaux, chacun avec cinq boss. Le niveau suivant s’ouvre à la victoire ;
le niveau choisi et le niveau débloqué sont sauvegardés. Les sauvegardes existantes
gardent leurs sorts acquis, et commencent la progression d’épreuve au niveau 1.
La difficulté vient du niveau sélectionné, indépendamment de la campagne atteinte.
Entre le premier et le dernier boss, les PV doublent. Aucun augment au départ,
y compris avec Héritage réactif ; un choix de trois augments après chacun des
quatre premiers boss. Le dernier mène directement au coffre.

| Niveau | Sorts possibles |
|---|---|
| 1 | Onde alchimique, Rempart initial |
| 2 | Nova de givre, Héritage réactif |
| 3 | Le Grand Œuvre |
| 4 | Barrage de braise, Moisson vitale |
| 5 | Temps suspendu |
| 6 | Riposte alchimique, Seconde chance |
| 7 | Impulsion foudroyante, Réserve d’ultime |
| 8 | Sang-froid, Dernier rempart |
| 9 | Transmutation totale |
| 10 | Explosion corrosive |
| 11 | Audace, Écho alchimique |

Le coffre final a 80 % de chance de donner un exemplaire, partagé également entre
les sorts locaux non maximisés. Aucun jet de sort sur les boss intermédiaires.
Chaque exemplaire monte le rang, jusqu’à 10. Les gouttes sont de 1 à 2 par boss
vaincu, indépendamment du jet de sort. L’interface Sorts donne le niveau précis,
le rang possédé et le délai avec les bonus équipés. Les cadeaux historiques de
campagne Onde/Grand Œuvre restent disponibles et sont annoncés séparément.

## Coffre et aperçu

`Jeu.salles_terminees` est renseigné dès que la salle est nettoyée, même avant de
prendre le portail. `Jeu.boss_vaincus` ne compte chaque rencontre qu’une fois.
Un seul tirage et une seule attribution via `BilanRun.finaliser`, mémorisés pour
éviter les doubles gains. Les gains sont sauvegardés avant l’animation. Le joueur
touche le coffre pour ouvrir le couvercle, voit ses récompenses puis choisit le
retour à l’accueil. Seules les sondes automatiques ouvrent et quittent automatiquement.
Entrer dans la dernière salle puis abandonner ne débloque plus le chapitre suivant.

Campagne, premier chapitre, sans bonus :

| Salles terminées | Gouttes dans le coffre |
|---|---|
| 0 | 0, aucune XP |
| 1 | 2 |
| 4 | 8 |
| 5 | 13–14 |
| 10 | 29–31 |
| 15 | 48–51 |
| 20 | 72–76 et 60 XP de compte |

Le total de victoire reste proche de l’économie précédente. Les gouttes de
progression et le bonus de boss sont réunis dans le coffre ; pas de second versement.
Objets : victoire complète seulement, chance de 25 %, garantie au cinquième coffre
complet sans objet s’il reste un objet du chapitre à obtenir. Mine : pierres à la
victoire, coffre vide en cas d’abandon sans salle terminée. Épreuve : gains des boss
conservés à l’abandon, sort uniquement à la victoire complète.

Le bouton « ! » de chaque chapitre/niveau, et de la Mine, montre l’offre complète,
ses montants avec les bonus actuels, les probabilités individuelles et les garanties.
Le calcul pur `ButinsRun.offre` sert aussi au vrai tirage ; aucun tirage pour consulter.

## Présentation et vérification

Zone alchimique : disque translucide bordé, rayon pris directement dans les règles.
Familier tireur : silhouette manga persistante au point de départ des tirs, avec un
léger flottement. Ces deux visuels restent présents en effets réduits et suivent le
même lissage que le héros. L’icône de la Baguette d’atelier est rendue depuis les
maillages réellement portés par l’apprenti ; changer d’arme ne remplace pas son modèle.

Validation sans fenêtre visible : 17 700 assertions dans 36 suites, selftest,
41 assertions d’intégration spécifiques, 16 de combat, 37 de confort,
194 contrôles d’interface et 1 777 de formats. Vingt runs automatiques sans blocage
(défaites salles 3–10). Une épreuve complète vérifie la progression 0/1/2/3/4 augments ;
le profil intermédiaire de fin de campagne atteint le boss 5 puis perd, sans blocage.
Ces bots ne remplacent pas l’appréciation du dosage en jeu. Les diagnostics de
ressources retenues à la sortie du selftest headless préexistaient à cette modification.
Journaux : `tmp/refonte-gameplay/`. APK : `build/alambic-coffres-epreuves.apk`,
158 872 095 octets ; signature v2/v3 vérifiée avec apksigner.
