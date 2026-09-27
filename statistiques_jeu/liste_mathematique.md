# Liste mathématique

**Compte au maximum, avant les augments : 489,18 DPS permanents, 455,04 PV et 37,12 Défense.** Le matériel est celui optimisé pour le panier classique détaillé plus bas ; il reste identique pendant la comparaison.

**Répartition de 100 % de ce DPS permanent :** Attributs **12,1 %** ; Équipement **44,7 %** ; Maîtrises **24,4 %** ; Passifs **7,1 %** ; Cœurs **7,5 %** ; socle du héros à son niveau **4,2 %**. Les cinq sources et le socle de niveau partagent leurs synergies ; les augments sont exclus de cette répartition.

> **Avec les augments classiques illustratifs : 489,18 → 2 142,58 DPS, soit ×4,38.** La run ajoute **1 653,4 DPS**, ce qui représente **77,17 % du DPS final** ; le socle permanent en représente les 22,83 % restants.

Calcul : (2 142,58 − 489,18) / 2 142,58 = 1 − 1 / 4,3799 = 77,17 %. Par exemple, 1 000 → 3 000 DPS signifie que les augments ajoutent 2 000 DPS, soit 66,7 % du total final. Ce panier fixe est illustratif ; la simulation présentée plus loin mesure la dispersion des résultats avec les offres réelles.

## Fiche : socle permanent puis augments

Les contributions se calculent sans augment et s’additionnent au chiffre de départ. La colonne de droite montre ensuite le même build avec le panier classique illustratif. Un impact peut diminuer alors que le DPS monte grâce aux projectiles et aux salves supplémentaires.

| Statistique | Départ permanent | Sources permanentes : valeur et part du départ | Après les augments classiques |
| --- | --- | --- | --- |
| Attaque | **106,81** | Base : 12,9 (12,1 %)<br>Attributs : +16,77 (15,7 %)<br>Équipement : +42,61 (39,9 %)<br>Maîtrises : +29,65 (27,8 %)<br>Passifs : +4,88 (4,6 %) | **149,54** |
| Dégâts moyens par projectile du héros | **196,49** | Base : 12,9 (6,6 %)<br>Attributs : +26,2 (13,3 %)<br>Équipement : +82,55 (42 %)<br>Maîtrises : +49,47 (25,2 %)<br>Passifs : +9,55 (4,9 %)<br>Cœurs : +15,81 (8 %) | **176,06** |
| Attaques par seconde | **2,3** | Base : 1,6 (69,6 %)<br>Attributs : +0,06 (2,5 %)<br>Équipement : +0,4 (17,4 %)<br>Maîtrises : +0,09 (4,1 %)<br>Passifs : +0,15 (6,5 %) | **2,99** |
| DPS du héros | **451,85** | Base : 20,64 (4,6 %)<br>Attributs : +59 (13,1 %)<br>Équipement : +193,59 (42,8 %)<br>Maîtrises : +111,51 (24,7 %)<br>Passifs : +33,27 (7,4 %)<br>Cœurs : +33,84 (7,5 %) | **2 105,25** |
| DPS du familier | **37,33** | Équipement : +25,27 (67,7 %)<br>Maîtrises : +7,95 (21,3 %)<br>Passifs : +1,35 (3,6 %)<br>Cœurs : +2,76 (7,4 %) | **37,33** |
| DPS total | **489,18** | Base : 20,64 (4,2 %)<br>Attributs : +59 (12,1 %)<br>Équipement : +218,85 (44,7 %)<br>Maîtrises : +119,46 (24,4 %)<br>Passifs : +34,62 (7,1 %)<br>Cœurs : +36,61 (7,5 %) | **2 142,58** |
| PV maximum | **455,04** | Base : 114,5 (25,2 %)<br>Attributs : +75,17 (16,5 %)<br>Équipement : +88,86 (19,5 %)<br>Maîtrises : +151,65 (33,3 %)<br>Passifs : +24,86 (5,5 %) | **750,82** |
| Défense | **37,12** | Base : 10 (26,9 %)<br>Attributs : +6,62 (17,8 %)<br>Équipement : +9,94 (26,8 %)<br>Maîtrises : +10,56 (28,5 %) | **46,41** |

Le tir normal vaut **151,78**, le critique **250,44**, avec **14,5 %** de chance critique. La moyenne inclut aussi Cinquième impact si l’anneau choisi le possède. Une attaque envoie **2 projectile(s) frontal(aux) × 2 salves**. Les DPS supposent que tous touchent et que les effets conditionnels d’anneau sont actifs.

## Ordre réel des calculs

Le héros nu au niveau 30 possède **12,9 ATK** et **114,5 PV** avant de répartir ses 145 points. Ce socle de niveau est compté séparément des attributs.

L’attaque brute vaut **12,9 niveau + 9,8 attributs + 19,4 équipement = 42,1**. On applique ensuite les pourcentages de l’équipement, puis les maîtrises, les passifs et les augments. Les pourcentages s’additionnent à l’intérieur d’une source ; les facteurs des sources se multiplient.

| Statistique | Base brute, attributs inclus | Équipement | Maîtrises | Passifs | Augments | Résultat |
| --- | --- | --- | --- | --- | --- | --- |
| Attaque | 42,1 | ×1,23 | ×1,88 | ×1,1 | ×1,4 | **149,54** |
| PV | 223,61 | ×1 | ×1,85 | ×1,1 | ×1,65 | **750,82** |
| Défense | 22,5 | ×1 | ×1,65 | ×1 | ×1,25 | **46,41** |
| Cadence avant l’arme | 1,648 | ×1,07 | ×1,05 | ×1,08 | ×1,3 | **2,6** |

Les valeurs affichées sont arrondies ; les calculs conservent la précision de chaque étape.

Pour la cadence, les attributs donnent ×1,03 avant les autres sources et l’arme ajoute ×1,15 : la cadence finale atteint 2,99 attaques/s. Les chances et les dégâts critiques s’additionnent en points ; la chance est plafonnée à 100 % après les augments.

Un projectile normal suit ensuite **149,54 ATK de run × 1,3 coefficient d’arme × 0,64 malus de projectile × 1 bonus conditionnels × 1,22 Cœurs = 151,78 dégâts**. Les Cœurs sont le dernier facteur de dégâts ; ils ne modifient ni l’ATK de run, ni les PV, ni la Défense, ni la cadence.

Pour la moyenne, on applique la probabilité critique et l’effet moyen de l’anneau. Puis on multiplie par la cadence, les projectiles frontaux et les salves. Le familier utilise sa propre attaque de forge × le produit permanent des bonus d’attaque du héros, plafonné à 100 % de l’ATK de run ; ses tirs reçoivent les dégâts finaux et les Cœurs, sans critique ni salve du héros.

## Ce que chaque source permanente apporte directement

| Source au plafond retenu | Bonus avant combinaison |
| --- | --- |
| Attributs répartis | +9,8 ATK brute ; +50 PV bruts ; +5 Défense brute ; +3 % cadence ; +2,5 points chance critique ; +5 points dégâts critiques |
| Cinq équipements, forge maximum | +19,4 ATK brute ; +59,11 PV bruts ; +7,5 Défense brute ; +23 % ATK ; +7 % cadence. S’y ajoutent la forme et le rythme de l’arme, le tir du familier et l’effet d’anneau. |
| Toutes les maîtrises | +87,5 % ATK ; +85 % PV ; +65 % Défense ; +5 % cadence ; +8 points chance critique ; +10 points dégâts critiques ; +15 % soins. Dégâts subis −5 %. |
| Quatre passifs au rang maximum | +10 % ATK ; +10 % PV ; +8 % cadence ; +4 points chance critique |
| Tous les Cœurs | +22 % de dégâts finaux. |
| Sorcier ou Moine | Aucun bonus actuellement. |

Les autres effets de soins, collecte et économie sont détaillés par rang dans les [maîtrises](liste_maitrises.md) et les [passifs](liste_passifs.md). Ils ne sont pas transformés artificiellement en dégâts dans la fiche.

## Le profil utilisé

**Tout est au plafond de progression**, avec une répartition polyvalente des attributs et quatre passifs équipés. Ce n’est pas un maximum simultané de chaque statistique : privilégier l’attaque, les PV ou le rendement économique conduit à des choix différents.

Le matériel ci-dessous maximise le DPS frontal continu total parmi **6250 combinaisons d’équipements actuellement obtenables**, à attributs, passifs et augments identiques. Les bijoux historiques réservés aux anciennes sauvegardes sont exclus. Le meilleur matériel pour résister ou toucher une cible mobile peut être différent.

| Emplacement | Modèle | Forge | Statistiques et effet |
| --- | --- | --- | --- |
| Arme | Alambic souverain | 20 | +13,64 ATK brute. Tir 130 %, cadence +15 %. |
| Familier | Ondine de givre | 20 | 22,92 attaque propre, un tir toutes les 1,9 s. Larme de givre · héros : cadence +4 % |
| Anneau | Anneau · Air | 20 | Attaque brute +1,8 · PV bruts +59 · Vitesse d’attaque +3 %<br>Chaque cinquième attaque inflige 30 % de dégâts supplémentaires. |
| Bracelet | Bracelet · Feu | 20 | Attaque brute +1,9 · Défense brute +7,5 · Attaque +3 %<br>La première blessure mortelle de l’aventure laisse le héros à 1 PV. |
| Collier | Collier · Terre | 20 | Attaque brute +2,1 · Attaque +15 %<br>Attaque +5 % tant que le collier est équipé. |

**Passifs :** Vigueur rang 2, Célérité rang 2, Œil précis rang 2, Vitalité rang 2. **Cœurs :** 11. **Maîtrises :** tous les rangs des trois branches.

**Run classique illustrative :** 6 rares, 3 épiques et 1 légendaire, sans légendaire bonus. Elle mêle dégâts et survie ; les offres aléatoires ne garantissent pas cette combinaison et ce panier ne représente pas leur médiane.

| Augment | Copies | Rareté | Effet cumulé |
| --- | --- | --- | --- |
| Salve | 1 | Rare | +1 salve par attaque<br>Dégâts de chaque projectile ×0,8 |
| Tir double | 1 | Rare | Dégâts de chaque projectile ×0,8<br>+1 projectile frontal parallèle par salve |
| Peau de cuivre | 1 | Rare | PV max +20 %<br>Défense +15 % |
| Baume profond | 1 | Rare | PV max +10 %<br>Soins reçus +20 % |
| Sceau de garde | 1 | Rare | Dégâts subis −15 % |
| Cadence fébrile | 1 | Rare | Cadence +20 % |
| Tir indélébile | 1 | Épique | Vitesse des projectiles +20 %<br>Poursuit la cible à travers les murs et les autres ennemis |
| Peau de pierre | 1 | Épique | PV max +25 %<br>Dégâts subis −5 % |
| Encre mordante | 1 | Épique | Attaque +30 % |
| Courage indomptable | 1 | Légendaire | Attaque +10 %<br>Cadence +10 %<br>PV max +10 %<br>Défense +10 %<br>Une seconde vie à 100 % des PV, une seule fois par tentative |

## Attributs : le vrai maximum disponible

Au niveau **30**, le compte possède **145 points à répartir au total**. On peut tous les placer dans un attribut, mais les maxima de la dernière colonne ne sont pas cumulables. La fiche utilise tous les points ; leurs bonus bruts sont renforcés ensuite par les maîtrises et les passifs.

| Attribut | Points du profil | Bonus dans cette fiche | Maximum individuel : 145 points |
| --- | --- | --- | --- |
| Force | 40 | +8 ATK brute | +29 ATK brute |
| Vitalité | 50 | +50 PV bruts ; +5 Défense brute | +145 PV bruts ; +14,5 Défense brute |
| Agilité | 25 | +2,5 points chance critique ; +5 points dégâts critiques | +14,5 points chance critique ; +29 points dégâts critiques |
| Intelligence | 30 | +1,8 ATK brute ; +3 % cadence | +8,7 ATK brute ; +14,5 % cadence |
| Sagesse | 0 | Aucun bonus | +101,5 % butin |

## Retrait d’une source permanente, sans augment

On retire une source permanente entière et on garde tous les autres choix identiques, sans réoptimiser et sans aucun augment. Retirer l’équipement signifie arme, familier et bijoux absents ; le socle du héros reste capable d’un tir simple pour mesurer les contributions.

| Source retirée | DPS restant | Perte de DPS total | PV restants | Défense restante |
| --- | --- | --- | --- | --- |
| Attributs | 367,07 | 24,96 % | 353,29 | 28,87 |
| Équipement | 116,81 | 76,12 % | 334,76 | 24,75 |
| Maîtrises | 237,15 | 51,52 % | 245,97 | 22,5 |
| Passifs | 405,25 | 17,16 % | 413,67 | 37,12 |
| Cœurs | 400,97 | 18,03 % | 455,04 | 37,12 |

### Comment lire les proportions

Pour les cinq sources permanentes, on mesure chaque source dans les 120 ordres possibles et on moyenne son apport. Ce partage de Shapley répartit les synergies entre équipement, attributs, maîtrises, passifs et Cœurs. Ces contributions, plus le socle du héros, retombent exactement sur le DPS permanent sans augments.

Le gain des augments répond à une autre question : combien de DPS a été ajouté pendant la run au même build ? Il vaut DPS final − DPS permanent, et sa part du DPS final vaut 1 − 1 / multiplicateur de run. Il ne fait pas partie des 100 % de sources permanentes.

La colonne de contribution est une répartition du socle, pas une prévision de nerf. Le tableau de retrait garde les augments absents et retire une source permanente entière. Ces pertes se chevauchent et ne s’additionnent pas ; elles ne prédisent pas directement l’effet d’un nerf de 10 %.

## La puissance gagnée pendant une tentative

**Un nouveau héros faisant des choix mixtes atteint en médiane ×4,25 DPS en salle 10 et ×7,57 en salle 20.** Les PV effectifs passent à ×1,73 en fin de run. Ces résultats viennent de 384 tirages par orientation, avec les offres réelles du jeu, sans relance.

Chaque run reçoit 10 choix : un légendaire garanti au niveau 5, 3 épiques placés sans remise parmi les autres niveaux et des rares ailleurs. Le tirage réel ajoute avec exactement 10 % de probabilité un second légendaire, en remplacement d’un rare ou d’un épique. Tous les niveaux hors 5 sont éligibles, y compris le premier ; la probabilité marginale est donc 1,11 % par niveau éligible. Le total reste 10 choix, avec au plus deux légendaires et 2 ou 3 épiques lorsqu’il y en a deux.

Les distributions ci-dessous incluent ce bonus. Les paniers fixes et les parcours de référence le désactivent pour comparer des runs ordinaires à un légendaire ; leurs offres restent aléatoires et les monstres conservent leurs courbes fixes.

L’orientation mixte choisit le meilleur compromis immédiat : **55 % du gain logarithmique de DPS + 45 % du gain logarithmique de PV effectifs**. Elle ne connaît pas les prochaines offres. Tout offensif utilise 100/0, offensif prudent 85/15 et défensif 20/80. Cela décrit des choix cohérents, pas la façon de jouer de chaque personne.

Les soins, secondes vies, esquives, boucliers, mobilité et dégâts sur plusieurs cibles ne sont pas valorisés par ce score. Le bonus d’Élan vital après déplacement n’est pas inclus dans ce DPS de tir continu. Les résultats restent un modèle de puissance : ils ne prédisent pas les dégâts réellement évités ni une probabilité de victoire.

**P10–P90** encadre les 80 % centraux des tirages. Les dégâts sont monocibles idéaux, tous les tirs frontaux touchent. Le familier est inclus ; le héros tire en continu.

| Choix | DPS final médian / début | DPS P10–P90 | PV effectifs / début | Contacts de fragile supportés salle 19, sans soin |
| --- | --- | --- | --- | --- |
| Tout offensif | ×8,36 | ×5,57–11,54 | ×1 | 4,44 |
| Offensif prudent | ×8,54 | ×5,67–11,39 | ×1,32 | 5,84 |
| Équilibré | ×7,57 | ×4,58–9,93 | ×1,73 | 7,69 |
| Défensif | ×3,43 | ×2,09–5,79 | ×3,3 | 14,65 |

### Courbe d’une run au premier niveau de campagne

Le héros commence avec la Baguette d’acier et l’Homoncule, sans attribut, maîtrise, passif, Cœur ni forge. Les colonnes indiquent les statistiques **pendant le combat** : les niveaux des salles précédentes sont reçus, le choix de fin de salle ne l’est pas. Aucun choix supplémentaire ne précède un boss.

| Salle | DPS mixte médian | DPS P10–P90 | PV effectifs mixtes | PV monstres | Dégâts monstres |
| --- | --- | --- | --- | --- | --- |
| 1 | ×1 | ×1–1 | ×1 | ×1 | ×1 |
| 2 | ×1,18 | ×1–1,54 | ×1 | ×1,04 | ×1,02 |
| 3 | ×1,18 | ×1–1,54 | ×1 | ×1,09 | ×1,04 |
| 4 | ×1,52 | ×1,18–1,97 | ×1 | ×1,14 | ×1,06 |
| 5 | ×1,83 | ×1,32–2,57 | ×1,18 | ×1,31 | ×1,14 |
| 6 | ×1,83 | ×1,32–2,57 | ×1,18 | ×1,37 | ×1,16 |
| 7 | ×2,17 | ×1,45–3,32 | ×1,22 | ×1,43 | ×1,18 |
| 8 | ×2,17 | ×1,45–3,32 | ×1,22 | ×1,5 | ×1,21 |
| 9 | ×3,68 | ×2,21–5,67 | ×1,32 | ×1,56 | ×1,23 |
| 10 | ×4,25 | ×2,54–6,32 | ×1,37 | ×2,45 | ×1,32 |
| 11 | ×4,25 | ×2,54–6,32 | ×1,37 | ×2,56 | ×1,34 |
| 12 | ×4,87 | ×2,79–7,13 | ×1,55 | ×2,68 | ×1,37 |
| 13 | ×4,87 | ×2,79–7,13 | ×1,55 | ×2,8 | ×1,4 |
| 14 | ×5,73 | ×3,42–8,23 | ×1,55 | ×2,92 | ×1,43 |
| 15 | ×5,73 | ×3,42–8,23 | ×1,55 | ×3,67 | ×1,53 |
| 16 | ×5,73 | ×3,42–8,23 | ×1,55 | ×3,83 | ×1,56 |
| 17 | ×6,53 | ×4,24–9,06 | ×1,61 | ×4 | ×1,59 |
| 18 | ×6,53 | ×4,24–9,06 | ×1,61 | ×4,18 | ×1,62 |
| 19 | ×6,53 | ×4,24–9,06 | ×1,61 | ×4,37 | ×1,65 |
| 20 | ×7,57 | ×4,58–9,93 | ×1,73 | ×4,57 | ×1,69 |

| Monstre | PV salle 1 | Tirs normaux nécessaires salle 1 | Même arme sans augment salle 19 |
| --- | --- | --- | --- |
| Encrier rampant | 36 | 3 | 12 |
| Plume-sentinelle | 46 | 4 | 15 |
| Tache véloce | 32 | 3 | 10 |
| Sceau-bélier | 116 | 9 | 37 |

Les tirs ci-dessus excluent critiques et dégâts du familier pour rendre le repère « trois ou quatre attaques » lisible ; les costauds conservent leur rôle. La salle 19 n’a pas exactement les mêmes espèces que la salle 1 : la dernière colonne compare la même espèce à statistiques de salle différentes.

Le premier niveau n’a aucun élite. Ses quatre premières salles ont moins de renforts, ses salles suivantes perdent une vague (minimum deux) et ses grandes salles restent plafonnées à l’effectif normal. Les projectiles et déplacements ennemis sont ralentis au début de la campagne, avec des annonces et repos allongés ; cette aide disparaît progressivement au troisième niveau. Aucun tutoriel ni protection d’invincibilité n’est ajouté.

## Cœurs de soin et marge d’erreur

Ces cœurs au sol sont distincts des **Cœurs de mana permanents**, qui augmentent les dégâts finaux. Un cœur de soin rend **8 % des PV maximum × bonus de soins**, dans la limite des PV manquants.

| Cœurs déposés dans la rencontre | Probabilité |
| --- | --- |
| 0 | 15 % |
| 1 | 80 % |
| 2 | 5 % |

Le budget est tiré une seule fois par salle/rencontre : **jamais plus de deux cœurs**, en moyenne 0,9. Les morts qui les déposent sont choisies parmi les ennemis prévus, sans compter les invocations. Un boss seul peut laisser les deux.

À PV pleins, un cœur reste au sol. Il se ramasse en passant à proximité, sans traverser un obstacle ; ceux qui restent sont récupérés à la fin de la salle ou de la tentative. Si le héros est alors à PV pleins, chaque cœur inutilisé donne 1 Goutte. Un héros mort n’est jamais ressuscité par cette collecte.

Sur 20 salles, cela représente en moyenne 18 cœurs, soit un potentiel de soin cumulé de 144 % d’une barre de vie avant bonus et pertes à PV pleins. Les choix épiques et légendaires n’ajoutent plus de soin automatique ; seul le soin propre d’un augment comme Égide reste actif. Ces quantités ne forment pas une réserve transportable et ne prouvent pas qu’un joueur survivra.

En Mine, un quota est ouvert toutes les 30 s, sur les 6 premières morts admissibles de cette tranche. Les quotas inutilisés ne s’accumulent pas ; après le chronomètre, aucun nouveau quota n’apparaît.

Les cœurs et Moisson vitale utilisent le soin garanti, distinct du plafond des soins de combat par salle. Récupération d’entrée reste dans le budget des soins de combat.

En Mine aussi, les niveaux ne donnent aucun soin automatique. Les cœurs convertis donnent un montant fixe de Gouttes, sans multiplicateur d’équipement ni d’augment ; ces recettes ne sont pas incluses dans le parcours économique, qui ne simule pas les blessures ni les trajets.

## Retour offensif après les premières Épreuves

24 comptes avec graines fixes : échec imposé en salle 9 du chapitre 1, puis victoire au même chapitre, suivie de zéro, cinq ou six victoires dans l’Épreuve 1. Ces victoires sont les hypothèses du scénario demandé ; aucun taux de réussite humain n’est déduit.

Tous les points d’attribut vont en Force. Les achats maximisent le gain de DPS par coût, avec les seules ressources effectivement reçues ; l’équipement privilégie le DPS. Le compte repart sans augment à chaque tentative. Les offres d’augments suivent la politique tout offensive (100 % dégâts, 0 % résistance), avec une seule légendaire garantie. Une offre sans gain offensif peut donner une défense incidente.

Le build offensif doit gagner du temps de combat sans banaliser les éliminations en une attaque. Les gains permanents, les augments, les PV et les dégâts ennemis ont été réduits ensemble. Aucun nombre minimum de coups ni ajustement au build ne s'applique en jeu.

Les chapitres du tableau sont testés séparément avec le même compte après le farm, sans ajouter les récompenses des chapitres intermédiaires. Les résultats sont des médianes. Le taux d’élimination concerne les formes ordinaires des monstres prévus par les vagues, sans transformation en élite, sans critique, sans rebond ni dégâts gratuits du familier.

Un projectile désigne un seul impact. Une attaque complète additionne les salves et projectiles frontaux qui touchent la même cible. Le temps du boss inclut le familier et les critiques moyens, à 70 % du DPS théorique ; il reste une estimation de débit.

| Victoires Épreuve 1 | Chapitre | DPS permanent | Projectiles à l’entrée | Monstres en 1 projectile | Monstres en 1 attaque | Boss final, s | Contacts minimum |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 0 | 2 | 33,8 | 5 | 0 % | 0 % | 22,5 | 2,1 |
| 0 | 3 | 33,8 | 7 | 0 % | 0 % | 33,1 | 2 |
| 0 | 4 | 33,8 | 8 | 0 % | 0 % | 37,5 | 1,9 |
| 0 | 7 | 33,8 | 11 | 0 % | 0 % | 72,4 | 1,7 |
| 5 | 2 | 42,3 | 4 | 0 % | 0 % | 18,2 | 2,1 |
| 5 | 3 | 42,3 | 6 | 0 % | 0 % | 26,7 | 2 |
| 5 | 4 | 42,3 | 7 | 0 % | 0 % | 30,2 | 1,9 |
| 5 | 7 | 42,3 | 9 | 0 % | 0 % | 58,4 | 1,7 |
| 6 | 2 | 42,8 | 4 | 0 % | 0 % | 18 | 2,1 |
| 6 | 3 | 42,8 | 6 | 0 % | 0 % | 26,5 | 2 |
| 6 | 4 | 42,8 | 7 | 0 % | 0 % | 30 | 1,9 |
| 6 | 7 | 42,8 | 9 | 0 % | 0 % | 58 | 1,7 |

### Enchaîner réellement les chapitres après six Épreuves

Cette fois, les achats et récompenses sont conservés entre deux chapitres. Le personnage continue à investir uniquement en dégâts permanents.

| Chapitre | Monstres en 1 attaque | Boss final, s | Contacts minimum |
| --- | --- | --- | --- |
| 2 | 0 % | 18 | 2,1 |
| 3 | 0 % | 26,3 | 2,1 |
| 4 | 0 % | 25,5 | 2,1 |
| 5 | 0 % | 24,9 | 2 |
| 6 | 0 % | 30,4 | 1,9 |
| 7 | 0 % | 36,7 | 1,9 |
| 8 | 0 % | 27,8 | 1,8 |

Sans autre farm après les six Épreuves, **24 comptes sur 24** ne rencontrent aucun boss dépassant 120 secondes sur les 35 chapitres. Cela mesure uniquement leur puissance de tir, en supposant qu’ils survivent.

Ce parcours offensif ignore volontairement le seuil de trois contacts pour isoler la puissance de tir. Les contacts minimum ci-dessus retiennent le monstre ordinaire le plus dangereux rencontré, hors élites. Les soins, esquives et blessures ne sont pas simulés.

Le scénario de six niveaux d’Épreuve successifs s’arrête désormais après le premier : vaincre une Épreuve ne suffit plus, la campagne doit aussi avoir atteint son palier. Rejouer le niveau accessible reste autorisé.

## Progression ordinaire, deux défenses et sur-farm

24 comptes par scénario, avec les mêmes graines. Tous commencent par l'échec en salle 9 puis la victoire au premier chapitre. Le parcours ordinaire enchaîne ensuite la campagne, équilibré ou tout offensif. Retour Épreuves ajoute six victoires à l'Épreuve 1. Sur-farm ajoute cinq Épreuves et six victoires supplémentaires au chapitre 1, avant de reprendre le chapitre 2.

Chaque victoire est supposée : ces résultats mesurent la puissance du compte, pas un taux de réussite humain. Les ressources et achats sont conservés entre chapitres et viennent du vrai butin. Aucune maîtrise, forge ou pièce d'équipement maximale n'est accordée gratuitement.

Le cas « Offensif + deux défenses » reprend le même compte offensif, mais remplace son choix légendaire par Égide et un choix épique par Peau de pierre, après leurs niveaux réels. Le nombre de choix, les raretés et les limites de copies sont conservés ; ces deux remplacements sont un stress volontaire, sans prétendre qu'ils figurent toujours dans les offres.

Une attaque additionne ses salves et tous ses projectiles frontaux sur la même cible. Les critiques sont calculés par une loi binomiale : chaque salve a son propre tirage, commun à ses projectiles. Les rebonds, le familier, Élan vital chargé et les effets conditionnels ne donnent pas d'élimination gratuite dans ce taux. Les élites sont exclues, ce qui privilégie les éliminations faciles.

Les lignes donnent des médianes de comptes, plus le P90 du taux avec critiques pour montrer les tirages favorables. Contacts équivalents = PV effectifs / dégâts bruts : 2,3 signifie mort au troisième coup identique, sans soin, esquive, bouclier ou seconde vie. Ce tableau prend le monstre médian ; le minimum est conservé dans les mesures détaillées. Le boss inclut familier et critiques moyens, avec 70 % de tir utile.

| Parcours | Chapitre | Attaques par monstre | En 1 attaque normale | Avec critiques : médiane / P90 | Contacts équivalents | Boss final, s |
| --- | --- | --- | --- | --- | --- | --- |
| Équilibré | 2 | 4 | 0 % | 0 % / 0 % | 6,8 | 28,7 |
| Équilibré | 3 | 5 | 0 % | 0 % / 0 % | 7,5 | 41,6 |
| Équilibré | 7 | 4,3 | 0 % | 0 % / 0 % | 7,7 | 62,3 |
| Équilibré | 14 | 7 | 0 % | 0 % / 0 % | 8,1 | 86,3 |
| Équilibré | 35 | 6 | 0 % | 0 % / 0 % | 5,7 | 58,1 |
| Offensif | 2 | 3 | 0 % | 0 % / 0,1 % | 4,6 | 22,5 |
| Offensif | 3 | 4 | 0 % | 0 % / 0 % | 4,8 | 31,2 |
| Offensif | 7 | 4 | 0 % | 0 % / 2,4 % | 4,2 | 46,2 |
| Offensif | 14 | 4 | 0 % | 0 % / 0 % | 3,4 | 48,9 |
| Offensif | 35 | 3 | 0 % | 0,1 % / 3,3 % | 1,5 | 25,7 |
| Offensif + deux défenses | 2 | 6 | 0 % | 0 % / 0 % | 8 | 46,1 |
| Offensif + deux défenses | 3 | 7 | 0 % | 0 % / 0 % | 7,7 | 57,9 |
| Offensif + deux défenses | 7 | 5 | 0 % | 0 % / 0 % | 7 | 98 |
| Offensif + deux défenses | 14 | 6,8 | 0 % | 0 % / 0 % | 5,4 | 93,6 |
| Offensif + deux défenses | 35 | 5 | 0 % | 0 % / 0 % | 2,4 | 42,4 |
| Retour Épreuves | 2 | 3 | 0 % | 0,2 % / 7,3 % | 4,7 | 18 |
| Retour Épreuves | 3 | 3,5 | 0 % | 0 % / 0,1 % | 4,9 | 26,3 |
| Retour Épreuves | 7 | 3 | 0 % | 0 % / 7,3 % | 4,3 | 36,7 |
| Retour Épreuves | 14 | 4 | 0 % | 0 % / 0,4 % | 3,4 | 43,4 |
| Retour Épreuves | 35 | 3 | 0 % | 0,3 % / 11,4 % | 1,5 | 22,2 |
| Sur-farm offensif | 2 | 2 | 7,2 % | 7,7 % / 35,2 % | 5,2 | 12,3 |
| Sur-farm offensif | 3 | 3 | 0 % | 0,4 % / 4 % | 5,5 | 19,5 |
| Sur-farm offensif | 7 | 3 | 0 % | 1 % / 11,3 % | 4,5 | 28,5 |
| Sur-farm offensif | 14 | 3 | 0 % | 0 % / 1,1 % | 3,6 | 38,1 |
| Sur-farm offensif | 35 | 3 | 0 % | 0,8 % / 13,2 % | 1,5 | 20,8 |

### Annexes à leur premier déblocage

Même compte après le chapitre 1 pour l'Épreuve 1, puis après le chapitre 3 pour la Mine 1, sans farm supplémentaire. Médianes des comptes. Les contacts prennent le boss le plus dangereux de l'Épreuve, ou le minimum contre un Encrier rampant pendant la Mine ; ils ne modélisent pas les collisions ni les soins. Les choix d'augments suivent la politique du compte.

| Parcours | Annexe | Contacts équivalents | Boss final, s |
| --- | --- | --- | --- |
| Équilibré | Épreuve 1 | 5,4 | 14,9 |
| Équilibré | Mine 1 | 8,6 | 45,5 |
| Offensif | Épreuve 1 | 4,4 | 12,4 |
| Offensif | Mine 1 | 5,9 | 22,2 |

### Budget des bonus offensifs et défensifs

Comparaison d'un seul choix de même rareté sur le héros initial. Les multiplicateurs de survie excluent le soin immédiat d'Égide. Le gain au-dessus de ×1 reste comparable, avec une tolérance de 15 % ; la défense n'a plus de prime systématique.

| Choix offensif | DPS héros | Choix défensif | PV effectifs |
| --- | --- | --- | --- |
| Sceau de ruine | ×1,2 | Sceau de garde | ×1,18 |
| Noyau pesant | ×1,35 | Peau de pierre | ×1,32 |
| Force cataclysmique | ×1,75 | Égide souveraine | ×1,67 |

Égide et Peau de pierre ensemble : **×2,19 PV effectifs**, en consommant un choix légendaire et un choix épique. Les deux effets ne donnent pas de DPS.

## Durée des runs, reprises et progression d’un compte neuf

Ces parcours appliquent les offres d’augments, les vagues, les coûts et les coffres du jeu. La référence utilise 10 choix sans légendaire bonus : 6 rares, 3 épiques et le légendaire garanti au niveau 5. Le bonus de 10 % par run reste inclus dans les distributions de puissance précédentes ; la progression de référence ne compte jamais sur deux légendaires. Les Épreuves gardent leurs quatre choix après boss.

Ils mesurent un modèle de puissance et de temps, sans simuler les déplacements ni prédire les victoires d’un joueur. Les 35 chapitres restent conditionnels aux critères de confort définis ci-dessous.

### Durée d’une run complète

Huit graines fixes servent à décrire la dispersion des offres. Le compte du retry reçoit seulement le butin de huit salles et d’un boss après une défaite imposée en salle 9, puis paie ses améliorations. Chaque run reprend sans augment.

| Situation | Run : médiane [P10–P90], min | Boss final : secondes | Contacts minimum équivalents |
| --- | --- | --- | --- |
| Compte neuf, chapitre 1 | 7,4 [6,8–9,2] | 18 [13,3–24,9] | 6,7 [6,3–7] |
| Même chapitre après la première défaite | 7,2 [6,6–8,9] | 17,3 [12,8–23,9] | 7 [6,5–7,2] |
| Permanent maximum, chapitre 35 | 7,4 [6,9–9] | 16,9 [12,5–22,8] | 9,9 [9,1–10,2] |

Avec le panier classique fixe au maximum, le boss final du chapitre 35 représente **21,5 secondes** à 70 % de tir utile, pour 2 142,6 DPS théoriques. La cohorte ci-dessus utilise les vrais choix proposés au fil des runs, donc peut obtenir d’autres résultats.

| Tir utile, vagues et boss | Compte neuf, min | Retry, min | Maximum chapitre 35, min |
| --- | --- | --- | --- |
| 50 % | 9,1 [8,3–11,4] | 8,8 [8,1–11,1] | 8,9 [8,3–11,1] |
| 80 % | 6,5 [6–8] | 6,3 [5,9–7,7] | 6,5 [6,2–7,9] |

### Parcours et premier besoin de renforcement

Sans annexe ni replay volontaire après la première défaite, huit comptes rencontrent leur premier seuil de confort au chapitre médian **17,5 [P10 7 ; P90 36]**. Ces rangs de chapitre décrivent les huit exemples ; ils ne sont pas une probabilité de défaite.

| Méthode | Chapitres validés par le modèle | Niveau du compte | Runs campagne / Mine / Épreuve | Temps total, min | Plus long farm, min | Plus long farm + échecs, min |
| --- | --- | --- | --- | --- | --- | --- |
| Sans farm | 35 | 20 | 36 / 0 / 0 | 870,4 | 0 | 0 |
| Lots selon le gain attendu, choix équilibrés | 35 | 20 | 36 / 0 / 0 | 870,4 | 0 | 0 |
| Choix défensifs après un manque de survie | 35 | 20 | 36 / 0 / 0 | 870,4 | 0 | 0 |
| Comparatif imposé : 3 replays + 3 Mines + 3 Épreuves | 35 | 20 | 36 / 0 / 0 | 870,4 | 0 | 0 |

Le comparatif de neuf runs impose volontairement un gros lot : il ne constitue pas une obligation de jeu. La politique équilibrée reste la référence ; toutes les victoires et défaites du tableau pilotent réellement les coffres reçus.

| Graine du compte équilibré | Chapitres | Niveau final | Farm maximum, min | Farm + échecs maximum, min |
| --- | --- | --- | --- | --- |
| 20260927 | 35 | 20 | 0 | 0 |
| 20261936 | 35 | 21 | 19,3 | 38,2 |
| 20262945 | 35 | 21 | 17,8 | 49,2 |

Avec un seuil de boss abaissé de 120 à 90 secondes, le compte de référence sans farm rencontre ce critère dès le chapitre 10. Le choix du seuil change donc le diagnostic ; aucune formule ne garantit une réussite en deux essais.

### Compte de référence : ce qui finance chaque chapitre

Les achats indiquent des rangs de maîtrise / forge effectivement payés pendant le chapitre et ses lots. La durée distingue le farm des tentatives du chapitre. Le tableau donne le temps du boss final et le minimum de contacts équivalents sur l’essai validé par le modèle.

| Chapitre | Niveau | Achats M / F | Mines / Épreuves / replays | Farm, min | Tentatives, min | Boss final, s | Contacts minimum |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 1 → 4 | 7 / 2 | 0 / 0 / 0 | 0 | 9,8 | 13,4 | 6,8 |
| 2 | 4 → 6 | 4 / 1 | 0 / 0 / 0 | 0 | 24 | 54,2 | 7,6 |
| 3 | 6 → 7 | 3 / 1 | 0 / 0 / 0 | 0 | 20,6 | 52,3 | 6,8 |
| 4 | 7 → 8 | 3 / 2 | 0 / 0 / 0 | 0 | 33,9 | 77,6 | 7,7 |
| 5 | 8 → 9 | 4 / 1 | 0 / 0 / 0 | 0 | 29,5 | 58,8 | 8,5 |
| 6 | 9 → 9 | 5 / 2 | 0 / 0 / 0 | 0 | 26,4 | 45,1 | 8,4 |
| 7 | 9 → 10 | 2 / 2 | 0 / 0 / 0 | 0 | 29,1 | 88,9 | 7,7 |
| 8 | 10 → 11 | 4 / 1 | 0 / 0 / 0 | 0 | 25 | 52,3 | 7,9 |
| 9 | 11 → 11 | 2 / 1 | 0 / 0 / 0 | 0 | 39,2 | 83,3 | 9,2 |
| 10 | 11 → 12 | 3 / 1 | 0 / 0 / 0 | 0 | 37,9 | 82,1 | 7,4 |
| 11 | 12 → 12 | 2 / 1 | 0 / 0 / 0 | 0 | 26,9 | 62,4 | 8,4 |
| 12 | 12 → 13 | 3 / 2 | 0 / 0 / 0 | 0 | 22,9 | 38 | 6,1 |
| 13 | 13 → 13 | 3 / 1 | 0 / 0 / 0 | 0 | 22,4 | 41 | 8,1 |
| 14 | 13 → 14 | 3 / 1 | 0 / 0 / 0 | 0 | 28,3 | 92,8 | 7 |
| 15 | 14 → 14 | 3 / 3 | 0 / 0 / 0 | 0 | 33,2 | 76,5 | 8 |
| 16 | 14 → 14 | 4 / 1 | 0 / 0 / 0 | 0 | 24,6 | 45,3 | 7,4 |
| 17 | 14 → 15 | 4 / 1 | 0 / 0 / 0 | 0 | 29,6 | 60 | 7,8 |
| 18 | 15 → 15 | 4 / 1 | 0 / 0 / 0 | 0 | 26,3 | 59 | 7 |
| 19 | 15 → 16 | 2 / 2 | 0 / 0 / 0 | 0 | 22,4 | 44,8 | 5,2 |
| 20 | 16 → 16 | 4 / 1 | 0 / 0 / 0 | 0 | 22,7 | 45,1 | 6,8 |
| 21 | 16 → 16 | 7 / 2 | 0 / 0 / 0 | 0 | 22,1 | 77,3 | 5,8 |
| 22 | 16 → 17 | 6 / 1 | 0 / 0 / 0 | 0 | 32,7 | 75,5 | 5,8 |
| 23 | 17 → 17 | 3 / 1 | 0 / 0 / 0 | 0 | 29,9 | 75,5 | 6,4 |
| 24 | 17 → 17 | 3 / 3 | 0 / 0 / 0 | 0 | 31,9 | 77 | 6,6 |
| 25 | 17 → 18 | 4 / 1 | 0 / 0 / 0 | 0 | 18,1 | 37,9 | 5,5 |
| 26 | 18 → 18 | 4 / 3 | 0 / 0 / 0 | 0 | 18,2 | 31,7 | 5,9 |
| 27 | 18 → 18 | 4 / 2 | 0 / 0 / 0 | 0 | 18,4 | 37,2 | 6 |
| 28 | 18 → 19 | 7 / 3 | 0 / 0 / 0 | 0 | 20,4 | 60,7 | 6,3 |
| 29 | 19 → 19 | 2 / 2 | 0 / 0 / 0 | 0 | 31,1 | 63,8 | 6,4 |
| 30 | 19 → 19 | 5 / 1 | 0 / 0 / 0 | 0 | 17,1 | 31,5 | 5,1 |
| 31 | 19 → 19 | 3 / 3 | 0 / 0 / 0 | 0 | 22,8 | 48,1 | 4,6 |
| 32 | 19 → 20 | 5 / 1 | 0 / 0 / 0 | 0 | 20,9 | 59,4 | 5,4 |
| 33 | 20 → 20 | 3 / 2 | 0 / 0 / 0 | 0 | 12,9 | 22,2 | 4,4 |
| 34 | 20 → 20 | 4 / 1 | 0 / 0 / 0 | 0 | 17,2 | 31,8 | 4,5 |
| 35 | 20 → 20 | 7 / 1 | 0 / 0 / 0 | 0 | 21,8 | 40,6 | 5,8 |

### Temps supplémentaire aux seuils de confort

Le farm inclut les replays terminés ou ratés du chapitre précédent. Les échecs ci-dessous concernent le chapitre en cours. Leur somme exclut la tentative finalement réussie. Le gain de puissance compare le compte avant le premier lot et après le dernier lot, sans augment.

| Chapitre | Mines / Épreuves / replays | Farm, min | Échecs, min | Somme avant succès, min | Gain DPS / PV effectifs |
| --- | --- | --- | --- | --- | --- |

### Hypothèses et limites

- Les temps sont des estimations de débit, pas des mesures de joueurs : 65 % du DPS théorique sert aux vagues et 70 % au boss ; sensibilité affichée à 50 % et 80 %.
- Les PV et dégâts viennent des catalogues, des vraies Vagues et des courbes fixes du runtime. Le DPS inclut le familier et tous les tirs frontaux ; utilité multicible, invocations, dégâts perdus et soins ne sont pas simulés séparément.
- Les vagues sont nettoyées successivement : annonce d'apparition et délai de nettoyage réels. Les départs forcés de vagues peuvent les faire se chevaucher dans le jeu ; ce petit temps d'attente constitue ici une borne prudente.
- Les élites sont tirés avec la graine de salle réelle, au plus un par vague nettoyée. Les renforts invoqués ne donnent aucune récompense inventée.
- Un choix prend 4 secondes et une transition 2 secondes. Marcher jusqu'aux portails, lire les menus et faire les achats ne sont pas chronométrés.
- Un mur du modèle signifie qu'un boss demande plus de 120 secondes de tir utile ou que la réserve entière supporte moins de trois contacts d'un Encrier rampant de la salle. Il ne prédit ni mort humaine ni nombre d'essais nécessaire.
- Le parcours commence par une défaite imposée en salle 9 : seules huit salles et un boss paient. Le retry réutilise le compte amélioré mais repart sans augment.
- Chaque victoire de parcours est une décision du modèle selon ces seuils ; les coffres utilisent ensuite le vrai booléen victoire et les seules salles validées. Les tirages, garanties, accès et coûts sont ceux du jeu.
- Les lots adaptatifs contiennent trois Mines, trois Épreuves ou deux replays d'un chapitre déjà terminé. Le comparatif mixte impose trois replays, trois Mines puis trois Épreuves avant de réessayer. Un bloc dépassant 40 minutes est signalé ; vingt cycles servent de limite de diagnostic, sans inventer une victoire.
- La Mine dure réellement 300 secondes avant son boss. Un modèle continu de dégâts abat sa file de monstres, respecte son plafond, ramasse leur XP et choisit les offres légales ; les blessures ne sont pas simulées.
- L'allocation progressive vise 40 Force, 50 Vitalité, 25 Agilité et 30 Intelligence. Les achats maximisent le gain logarithmique par coût, avec un poids explicite pour les ressources. Aucun objet manquant ni rang de forge n'est offert.
- Une défaite conventionnelle dure la moitié du combat concerné, plafonnée à 120 secondes ; ce temps d'échec est une hypothèse et n'est pas une mesure de survie. Les contacts des Épreuves utilisent leur boss, ceux de la campagne et de la Mine utilisent l'Encrier rampant.
- Les Épreuves proposent exactement quatre augments, après leurs quatre premiers boss. Leur XP ne donne pas d'autres choix dans le runtime.
- La référence de campagne et de Mine désactive le légendaire bonus : elle conserve un légendaire garanti au niveau prévu, trois épiques et les autres choix rares. Les offres restent aléatoires. Le bonus réel est réservé aux distributions d'augments ; il ne finance pas les critères de progression.
- Les Gouttes issues des cœurs inutilisés ne sont pas créditées : sans blessures ni trajets simulés, le modèle ne peut pas savoir lesquels seront convertis à PV pleins.
- Le comparatif adaptatif passe aux choix et achats défensifs après un mur de contacts ; après un mur de durée, il reprend les poids équilibrés. Cette réaction utilise seulement l'échec passé, jamais les offres ou le coffre futurs.
- Après un premier échec par manque de contacts supportés, les remplacements d'équipement et de passifs doivent préserver les PV effectifs du build avant le choix. Les ensembles de passifs sont comparés complets. Les poids équilibrés restent 55 % DPS et 45 % PV effectifs ; Audace peut être refusée malgré un meilleur score.

## Les formules, en détail

Les calculs suivants expliquent la fiche. Un **DPS** est une moyenne de dégâts par seconde, avec des tirs continus qui touchent. Les déplacements, obstacles, ratés et phases invulnérables réduisent le résultat réel. Les rebonds ne sont pas des dégâts gratuits sur la même cible.

Les **PV effectifs** mesurent les dégâts bruts supportés avant la mort, hors esquive, soins, bouclier de salle et secondes vies (Courage, Sursis).

### Ce qui s’additionne et ce qui se multiplie

- Attaque brute = base du héros à son niveau + Force + Intelligence + attaque de l’arme + attaque des trois bijoux.
- Attaque permanente = attaque brute × (1 + pourcentages d’équipement) × (1 + pourcentages de maîtrises) × (1 + pourcentages de passifs). Les bonus d’une même source s’additionnent ; les sources se multiplient.
- Attaque de run = attaque permanente × (1 + somme des bonus d’attaque des augments). Aucun augment ne réduit l’attaque en échange de défense.
- Dégâts d’un projectile = attaque de run × coefficient de l’arme × bonus de projectile (Perforation, Élan vital chargé) × malus indépendants de Salve, Battement triple et chaque Tir double × bonus finaux × éventuel critique. Le tir après coefficient d’arme constitue la référence à 100 %.
- Cadence = base × facteur d’attributs × facteur d’équipement × facteur de maîtrises × facteur de passifs × facteur des augments × facteur de l’arme.
- DPS frontal héros = dégâts moyens d’un projectile × poids des projectiles frontaux × salves × cadence.
- Critique moyen = 1 + chance critique × (coefficient critique − 1). Chance plafonnée à 100 % ; critique de base ×1,5. Couronne incisive convertit une part de la chance au-delà du plafond en dégâts critiques.
- Bonus finaux = (1 + 0,02 × nombre de Cœurs) × (1 + Audace + Reprise de souffle active + Élan offensif actif).
- Cinquième impact est un facteur moyen supplémentaire de ×1,06 sur le héros quand l’anneau correspondant est équipé et forgé.
- DPS familier = min(attaque propre × (1 + bonus permanents d’attaque), 100 % de l’attaque de run du héros) × bonus finaux / intervalle. Pas de critique du familier.
- DPS total = DPS héros + DPS familier. Les classes ajoutent 0 % à toutes ces sources.
- PV = (PV de base au niveau du héros + Vitalité + valeurs brutes des bijoux) × facteur d’équipement × facteur de maîtrises × facteur de passifs × facteur des augments. Égide multiplie le résultat après la somme des bonus de PV des autres augments.
- Défense = (base + Vitalité + valeurs brutes des bijoux/familiers) × facteur d’équipement × facteur de maîtrises × facteur de passifs × facteur des augments.
- Dégâts reçus = dégâts ennemis × facteur des augments × (1 + Audace) × (1 − réduction des maîtrises) × 100 / (100 + Défense).
- Les soins de combat par salle sont limités à 5 % des PV maximum × bonus de soins, budget fixé à l’entrée. Les cœurs au sol et Moisson vitale utilisent un soin garanti distinct ; les choix n’ajoutent aucun soin lié à leur rareté.

### Tir double, Salve et Battement triple

**Tir double** ajoute un projectile parallèle. **Salve** ajoute une répétition de l’attaque. **Battement triple**, légendaire, ajoute deux répétitions. Chacun applique son propre coefficient ×0,8 aux dégâts de tous les projectiles ; leurs réductions se multiplient et restent actives avec les autres légendaires.

Exemple avec 1 000 ATK et le Sceptre de cuivre : le coefficient d’arme porte le projectile à 1 500 dégâts, qui devient notre référence à 100 %. Les critiques et autres bonus finaux sont laissés de côté dans ce tableau.

| Choix | Projectiles par salve | Salves | Dégâts par projectile | Dégâts par attaque complète | Gain sur l’arme seule |
| --- | --- | --- | --- | --- | --- |
| Arme seule | 1 | 1 | 1 500 | 1 500 | ×1 |
| Tir double | 2 | 1 | 1 200 | 2 400 | ×1,6 |
| Tir double ×2 | 3 | 1 | 960 | 2 880 | ×1,92 |
| Salve | 1 | 2 | 1 200 | 2 400 | ×1,6 |
| Tir double + Salve | 2 | 2 | 960 | 3 840 | ×2,56 |
| Battement triple | 1 | 3 | 1 200 | 3 600 | ×2,4 |
| Battement triple + Salve | 1 | 4 | 960 | 3 840 | ×2,56 |
| Tir double + Battement triple | 2 | 3 | 960 | 5 760 | ×3,84 |
| Tir double + Battement triple + Salve | 2 | 4 | 768 | 6 144 | ×4,1 |

Avec Battement triple, Salve fait passer de 3 à 4 salves, avec 64 % des dégâts de base par projectile : **×1,0667**, soit **+6,67 % de DPS idéal** par rapport à Battement triple seul. Deux réductions de 20 % laissent **64 %** des dégâts ; l’ajout d’un Tir double en laisse **51,2 %**. Aucun légendaire n’annule ces réductions.

### Bases du héros et attributs

Au niveau 1 : 100 PV ; 10 Défense ; 10 attaque ; 1,6 tirs/s. Chaque niveau ajoute 0,5 % des PV initiaux et 1 % de l’attaque initiale, en plus des points à répartir. Au niveau maximal, le socle seul vaut 114,5 PV et 12,9 attaque.
Chaque niveau après le premier donne 5 points, jusqu’au niveau 30 : 145 points au total.

| Attribut | Effet par point |
| --- | --- |
| Force | +0,2 Attaque brute par point |
| Vitalité | +1 PV brut et +0,1 Défense brute par point |
| Agilité | +0,1 point de chance critique et +0,2 point de dégâts critiques par point |
| Intelligence | +0,06 Attaque brute et +0,1 % de cadence par point |
| Sagesse | +0,7 % de butin par point |

## Croissance des monstres

Le niveau global va de 1 à 35 : 5 mondes × 7 niveaux. Chaque tentative de campagne comporte 20 salles.

Avec p = niveau global − 1 et a = min(p, 7) : **facteur PV de niveau = 1,095^a × 1^(a × (a − 1) / 2) × 1,02^(p − a) × [1 + 2,3 × (1 − 0,45^p)]**.
**Facteur dégâts de niveau = 1,04^p × 1,0002^(p × (p − 1) / 2)**. Les non-boss appliquent aussi le coefficient global 1.

Le premier chapitre reste à ×1. Le renfort initial suit les premiers achats et passifs, puis tend vers ×3,3. La croissance des PV ralentit après le chapitre 8 pour suivre les rangs de progression plus espacés. Les dégâts gardent leur courbe distincte. Un changement de monde n’ajoute pas une seconde hausse cachée.

Dans une tentative : facteur PV = 1,045^(salle − 1) × produit des paliers franchis ; facteur dégâts = 1,02^(salle − 1) × produit de leurs paliers. Les deux commencent à ×1.
Entre deux salles : +4,5 % de PV et +2 % de dégâts, avec les hausses supplémentaires du tableau. Ces paliers s’appliquent à l’entrée des salles indiquées et ne donnent aucun choix d’augment supplémentaire.

Les facteurs sont bornés à la dernière campagne. Ils ne lisent jamais les achats, les morts ni le build du joueur.

### Facteurs par niveau, avant la salle

| Niveau | PV | Dégâts |
| --- | --- | --- |
| Monde 1 · Niveau 1 | ×1 | ×1 |
| Monde 1 · Niveau 2 | ×2,48 | ×1,04 |
| Monde 1 · Niveau 3 | ×3,4 | ×1,08 |
| Monde 1 · Niveau 4 | ×4,06 | ×1,13 |
| Monde 1 · Niveau 5 | ×4,61 | ×1,17 |
| Monde 1 · Niveau 6 | ×5,13 | ×1,22 |
| Monde 1 · Niveau 7 | ×5,66 | ×1,27 |
| Monde 2 · Niveau 1 | ×6,21 | ×1,32 |
| Monde 2 · Niveau 2 | ×6,35 | ×1,38 |
| Monde 2 · Niveau 3 | ×6,48 | ×1,43 |
| Monde 2 · Niveau 4 | ×6,61 | ×1,49 |
| Monde 2 · Niveau 5 | ×6,74 | ×1,56 |
| Monde 2 · Niveau 6 | ×6,88 | ×1,62 |
| Monde 2 · Niveau 7 | ×7,01 | ×1,69 |
| Monde 3 · Niveau 1 | ×7,16 | ×1,76 |
| Monde 3 · Niveau 2 | ×7,3 | ×1,84 |
| Monde 3 · Niveau 3 | ×7,44 | ×1,92 |
| Monde 3 · Niveau 4 | ×7,59 | ×2 |
| Monde 3 · Niveau 5 | ×7,74 | ×2,09 |
| Monde 3 · Niveau 6 | ×7,9 | ×2,18 |
| Monde 3 · Niveau 7 | ×8,06 | ×2,28 |
| Monde 4 · Niveau 1 | ×8,22 | ×2,38 |
| Monde 4 · Niveau 2 | ×8,38 | ×2,48 |
| Monde 4 · Niveau 3 | ×8,55 | ×2,59 |
| Monde 4 · Niveau 4 | ×8,72 | ×2,71 |
| Monde 4 · Niveau 5 | ×8,9 | ×2,83 |
| Monde 4 · Niveau 6 | ×9,07 | ×2,96 |
| Monde 4 · Niveau 7 | ×9,26 | ×3,09 |
| Monde 5 · Niveau 1 | ×9,44 | ×3,23 |
| Monde 5 · Niveau 2 | ×9,63 | ×3,38 |
| Monde 5 · Niveau 3 | ×9,82 | ×3,54 |
| Monde 5 · Niveau 4 | ×10,02 | ×3,7 |
| Monde 5 · Niveau 5 | ×10,22 | ×3,87 |
| Monde 5 · Niveau 6 | ×10,42 | ×4,05 |
| Monde 5 · Niveau 7 | ×10,63 | ×4,24 |

| Salle | Hausse PV supplémentaire | Hausse dégâts supplémentaire |
| --- | --- | --- |
| 5 | ×1,1 | ×1,05 |
| 10 | ×1,5 | ×1,05 |
| 15 | ×1,2 | ×1,05 |

### Facteurs par salle, à multiplier par ceux du niveau

| Salle | PV | Dégâts |
| --- | --- | --- |
| 1 | ×1 | ×1 |
| 2 | ×1,045 | ×1,02 |
| 3 | ×1,092 | ×1,04 |
| 4 | ×1,141 | ×1,061 |
| 5 | ×1,312 | ×1,137 |
| 6 | ×1,371 | ×1,159 |
| 7 | ×1,432 | ×1,182 |
| 8 | ×1,497 | ×1,206 |
| 9 | ×1,564 | ×1,23 |
| 10 | ×2,452 | ×1,318 |
| 11 | ×2,562 | ×1,344 |
| 12 | ×2,678 | ×1,371 |
| 13 | ×2,798 | ×1,398 |
| 14 | ×2,924 | ×1,426 |
| 15 | ×3,667 | ×1,527 |
| 16 | ×3,832 | ×1,558 |
| 17 | ×4,004 | ×1,589 |
| 18 | ×4,184 | ×1,621 |
| 19 | ×4,373 | ×1,653 |
| 20 | ×4,57 | ×1,686 |

### Élites, boss et modes annexes

- **Élite** : PV ×2 ; dégâts ×2. **Miniboss** : PV ×1,6 ; dégâts ×1. **Boss signature** : PV ×1,75 ; dégâts ×1,1.
- **Épreuve** : même facteur de niveau, PV ×2,5 × (1 + 1)^t, dégâts ×1 × (1 + 0,45)^t. t va de 0 à 1 pendant les rencontres.
- **Mine** : même facteur de niveau, PV ×0,75 × (1 + 2)^t, dégâts ×0,6 × (1 + 1)^t, t = temps / 300 s borné entre 0 et 1.
- **Boss de Mine** : facteur supplémentaire PV ×2 et dégâts ×0,8. En Mine et Épreuve, tous les boss appliquent aussi ×0,45 PV ; pas les coefficients de rang de la campagne.

Les évolutions de comportement accélèrent certains tirs/déplacements et ajoutent des salves à leurs seuils ; elles n’ajoutent pas une autre croissance des PV.

## Progression d’un équipement de fin de campagne

Cette comparaison conserve un ensemble fixe du dernier monde : Alambic souverain + Golem de forge + anneau/bracelet/collier du monde V, tous forgés au maximum. Elle sert à lire les étapes d’achat ; la fiche optimisée du début utilise une autre sélection.

Maîtrises = tous les rangs. Passifs = Vigueur, Célérité, Œil précis et Vitalité, chacun rang 2.
Les étapes s’ajoutent dans cet ordre : leur gain marginal dépend donc de ce qui est déjà acheté. Aucune double attribution d’un pourcentage.

| Étape | ATK | Impact moyen | DPS héros + familier | Gain sur l’étape précédente | PV | Défense |
| --- | --- | --- | --- | --- | --- | --- |
| Départ : baguette et homoncule, forge 0 | 14 | 14,14 | 22,62 + 2,5 = **25,12** | +0 % | 100 | 10 |
| Même baguette, forge maximum seulement | 21 | 21,21 | 33,94 + 2,5 = **36,44** | +45,02 % | 100 | 10 |
| Équipement complet de fin, forge maximum | 35,87 | 46,63 | 85,8 + 19,93 = **105,72** | +190,16 % | 162,5 | 19,5 |
| Puis niveau 30 et 145 points d’attributs | 51,11 | 67,44 | 127,81 + 20,83 = **148,64** | +40,59 % | 227 | 24,5 |
| Puis toutes les maîtrises | 95,83 | 133,73 | 266,12 + 39,06 = **305,18** | +105,32 % | 419,95 | 40,42 |
| Puis quatre passifs de statistiques au rang 2 | 105,41 | 150,94 | 324,4 + 42,97 = **367,37** | +20,38 % | 461,94 | 40,42 |
| Puis tous les Cœurs | 105,41 | 184,15 | 395,77 + 52,42 = **448,19** | +22 % | 461,94 | 40,42 |
| Puis effet d’anneau pleinement actif | 105,41 | 193,36 | 415,56 + 55,04 = **470,6** | +5 % | 461,94 | 40,42 |

Maîtrises seules sur le matériel de départ : DPS 51,43, soit +104,72 % par rapport au départ.

## Choix offensifs, mixtes ou défensifs

Même budget ordinaire par exemple : 6 rares, 3 épiques et un légendaire, soit 10 choix. Le légendaire bonus est désactivé dans ces références. Les offres restent aléatoires ; ces builds ne sont pas garantis.
La référence est le profil complet précédent, sans les bonus conditionnels d’anneau. Les boucliers et soins ne sont pas inclus dans les PV effectifs.

| Orientation | DPS | PV | Défense | PV effectifs | Coups bloqués par salle |
| --- | --- | --- | --- | --- | --- |
| Offensif | 4 642,32 (×10,36) | 461,94 | 40,42 | 682,82 (×1) | 0 |
| Equilibre | 1 896,38 (×4,23) | 762,2 | 50,53 | 1 495,65 (×2,19) | 0 |
| Defensif | 448,19 (×1) | 1 385,82 | 52,55 | 3 062,08 (×4,48) | 1 |

- **Offensif** : Salve, Tir double, Cadence fébrile, Cadence fébrile, Sceau de ruine, Pointe lucide, Encre mordante, Noyau pesant, Noyau pesant, Force cataclysmique.
- **Equilibre** : Salve, Tir double, Cadence fébrile, Peau de cuivre, Baume profond, Sceau de garde, Tir indélébile, Peau de pierre, Encre mordante, Courage indomptable.
- **Defensif** : Peau de cuivre, Peau de cuivre, Sceau de garde, Baume profond, Baume profond, Pas de brume, Peau de pierre, Garde rémanente, Tir indélébile, Égide souveraine.

## Pourquoi farmer

La campagne seule sans rejouer limite le budget de forge et de maîtrises. Les Épreuves sont l’unique source de nouveaux passifs et de Cœurs.

La Mine donne plus de Pierres par victoire, et les échecs avancés en rapportent déjà une partie. La progression permanente est conservée entre les tentatives.

La Mine donne aussi 24 XP de compte répartis sur ses 5 minutes de survie, même en cas d’échec, puis 8 XP supplémentaires pour le boss vaincu (32 au total avant bonus).

Un mur de statistiques signifie beaucoup de tirs pour tuer et très peu de coups supportés ; les augments de la tentative n’effacent pas un grand retard d’équipement.

Ce n’est pas une interdiction de lancer le niveau ni une preuve qu’un joueur sans aucun coup reçu ne pourra jamais le terminer. Une difficulté ressentie doit encore être validée en jouant.

### Rendement de la Mine, avant bonus de pierres

| Palier de campagne correspondant | Pierres par victoire complète |
| --- | --- |
| 1 | 140 |
| 8 | 560 |
| 15 | 980 |
| 22 | 1400 |
| 29 | 1820 |
| 35 | 2180 |


Forge complète d’un objet : 4970 Pierres. Cinq emplacements équipés : 24850 Pierres, hors achats sur d’anciens modèles.

Les prix exacts sont dans la [liste des items](liste_items.md) et la [liste des maîtrises](liste_maitrises.md).

## Contre-épreuve : accorder toutes les victoires sans farm

Cette comparaison accorde hypothétiquement toutes les victoires jusqu’au dernier niveau pour tester les limites du budget de campagne. Elle **ne prétend pas que ce joueur aurait réellement franchi les murs précédents**.

- **Campagne seule hypothétique** : une victoire complète accordée sur chacun des 34 premiers niveaux, sans répétition, Mine ni Épreuve.
- **Budget de base** : 6397 à 6775 Gouttes, 2822 Pierres, 1632 XP, soit niveau 20 et 95 points.
- Les bonus économiques, élites et échecs ne sont pas comptés. Les derniers modèles d’équipement sont accordés, sans coût de forge perdu sur les anciens : c’est un scénario explicite, pas une borne optimale.
- **Achats retenus** : 5405 Gouttes de maîtrises et 2665 Pierres. Arme forge 10, anneau et bracelet forge 8, collier forge 5, familier forge 1.
- **Attributs** : 25 Force, 35 Vitalité, 15 Agilité, 20 Intelligence. Aucun passif et aucun Cœur. Tous les achats sont finançables même avec les coffres minimum.
- **Profil développé** : l’ensemble fixe du dernier monde présenté plus haut, avec effet d’anneau à son maximum. Les deux profils restent sans augment pour comparer leurs fondations.

Dernière salle du dernier niveau : fragile 1 749,02 PV / 107,38 dégâts bruts ; boss 32 308,27 PV / 173,24 dégâts bruts.

| Profil | DPS | PV effectifs | Impacts pour tuer le fragile | Contacts de fragile supportés | Coups de boss supportés | Secondes de tir idéal sur le boss |
| --- | --- | --- | --- | --- | --- | --- |
| Campagne seule, achats ci-dessus | 139,5 | 357,22 | 25,88 | 3,33 | 2,06 | 231,6 |
| Profil développé par le farm | 470,6 | 682,82 | 9,05 | 6,36 | 3,94 | 68,65 |

Moins de 1 coup supporté signifie qu’un seul coup tue, hors Sursis. Le temps sur le boss est théorique, avant augments et temps d’esquive.

## Méthode et références consultées

Les nombres de ce document proviennent du jeu et des scénarios décrits ; aucun jeu extérieur ne fournit les coefficients. Les références servent à choisir la méthode d’équilibrage.

- [GEEvo — Rupp et Eckert, 2024](https://arxiv.org/abs/2404.18574) : simulation d’une économie avec des objectifs explicites de ressources et de dégâts dans le temps. Ici, cette approche motive la mesure conjointe des combats, achats et répétitions.
- [GDC — Matt Woodward, Balancing the Economy for Albion Online](https://gdcvault.com/play/1024070/Balancing-the-Economy-for-Albion) : définir des repères et des contraintes d’économie avant de régler les valeurs. Ici, les repères sont le nombre d’attaques, les coups supportés, la durée des boss et le temps d’amélioration.
- [Notes officielles Dead Cells, mise à jour 11](https://deadcells.com/patchnotes/11) : suppression de l’adaptation automatique des ennemis aux statistiques du joueur. Alambik conserve également des niveaux fixes : améliorer son build doit réellement faciliter un niveau déjà connu.

Les hypothèses d’activité de tir et de choix sont vérifiables et modifiables dans le modèle. Une réussite en deux tentatives et le ressenti du farm devront être confrontés à des parties sur téléphone ; les calculs ne remplacent pas cette mesure.

