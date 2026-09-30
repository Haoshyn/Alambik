# Liste mathématique

**Compte au maximum, avant les augments : 8 695,57 DPS permanents, 703,87 PV et 43,31 Défense.** Le matériel est celui optimisé pour le panier classique détaillé plus bas ; il reste identique pendant la comparaison.

**Répartition de 100 % de ce DPS permanent :** Attributs **18,1 %** ; Équipement **23,3 %** ; Maîtrises **21 %** ; Passifs **18,7 %** ; Cœurs **18,6 %** ; socle du héros à son niveau **0,2 %**. Les cinq sources et le socle de niveau partagent leurs synergies ; les augments sont exclus de cette répartition.
Cible : environ 20 % de DPS par source permanente sur ce compte complet, interactions comprises ; le contrôle accepte 18 à 24 % pour conserver l’utilité des cinq objets. Les proportions varient avec les achats, les passifs équipés et les attributs choisis ; les PV, la Défense et chaque statistique individuelle ne suivent pas ce partage de dégâts.

> **Avec les augments classiques illustratifs : 8 695,57 → 39 633,06 DPS, soit ×4,56.** La run ajoute **30 937,5 DPS**, ce qui représente **78,06 % du DPS final** ; le socle permanent en représente les 21,94 % restants.

Calcul : (39 633,06 − 8 695,57) / 39 633,06 = 1 − 1 / 4,5578 = 78,06 %. Par exemple, 1 000 → 3 000 DPS signifie que les augments ajoutent 2 000 DPS, soit 66,7 % du total final. Ce panier fixe est illustratif ; la simulation présentée plus loin mesure la dispersion des résultats avec les offres réelles.

## Fiche : socle permanent puis augments

Les contributions se calculent sans augment et s’additionnent au chiffre de départ. La colonne de droite montre ensuite le même build avec le panier classique illustratif. Un impact peut diminuer alors que le DPS monte grâce aux projectiles et aux salves supplémentaires.

| Statistique | Départ permanent | Sources permanentes : valeur et part du départ | Après les augments classiques |
| --- | --- | --- | --- |
| Attaque | **453,78** | Base : 12,9 (2,8 %)<br>Attributs : +115,98 (25,6 %)<br>Équipement : +122,36 (27 %)<br>Maîtrises : +131,23 (28,9 %)<br>Passifs : +71,31 (15,7 %) | **589,91** |
| Dégâts moyens par projectile du héros | **2 360,37** | Base : 12,9 (0,5 %)<br>Attributs : +460,15 (19,5 %)<br>Équipement : +526,17 (22,3 %)<br>Maîtrises : +536,95 (22,7 %)<br>Passifs : +340,96 (14,4 %)<br>Cœurs : +483,24 (20,5 %) | **1 854,86** |
| Attaques par seconde | **3,51** | Base : 1,6 (45,5 %)<br>Attributs : +0,32 (9 %)<br>Équipement : +0,53 (15,1 %)<br>Maîtrises : +0,12 (3,4 %)<br>Passifs : +0,95 (26,9 %) | **5,27** |
| DPS du héros | **8 295,41** | Base : 20,64 (0,2 %)<br>Attributs : +1 577,67 (19 %)<br>Équipement : +1 852,02 (22,3 %)<br>Maîtrises : +1 742,89 (21 %)<br>Passifs : +1 574,09 (19 %)<br>Cœurs : +1 528,09 (18,4 %) | **39 112,86** |
| DPS du familier | **400,16** | Équipement : +175,75 (43,9 %)<br>Maîtrises : +87,49 (21,9 %)<br>Passifs : +48,79 (12,2 %)<br>Cœurs : +88,12 (22 %) | **520,2** |
| DPS total | **8 695,57** | Base : 20,64 (0,2 %)<br>Attributs : +1 577,67 (18,1 %)<br>Équipement : +2 027,78 (23,3 %)<br>Maîtrises : +1 830,38 (21 %)<br>Passifs : +1 622,89 (18,7 %)<br>Cœurs : +1 616,21 (18,6 %) | **39 633,06** |
| PV maximum | **703,87** | Base : 114,5 (16,3 %)<br>Attributs : +94,75 (13,5 %)<br>Équipement : +138,89 (19,7 %)<br>Maîtrises : +199,88 (28,4 %)<br>Passifs : +155,85 (22,1 %) | **1 513,32** |
| Défense | **43,31** | Base : 10 (23,1 %)<br>Attributs : +6,63 (15,3 %)<br>Équipement : +14,91 (34,4 %)<br>Maîtrises : +11,78 (27,2 %) | **60,64** |

Le tir normal vaut **1 086,72**, le critique **2 114,92**, avec **58,31 %** de chance critique. La moyenne inclut aussi Cinquième impact si l’anneau choisi le possède. Une attaque envoie **2 projectile(s) frontal(aux) × 2 salves**. Les DPS supposent que tous touchent et que les effets conditionnels d’anneau sont actifs.

## Ordre réel des calculs

Le héros nu au niveau 30 possède **12,9 ATK** et **114,5 PV** avant de répartir ses 145 points. Ce socle de niveau est compté séparément des attributs.

L’attaque brute vaut **12,9 niveau + 40,23 attributs + 29,98 équipement = 83,11**. On applique ensuite les pourcentages de l’équipement, puis les maîtrises, les passifs et les augments. Les pourcentages s’additionnent à l’intérieur d’une source ; les facteurs des sources se multiplient.

| Statistique | Base brute, attributs inclus | Équipement | Maîtrises | Passifs | Augments | Résultat |
| --- | --- | --- | --- | --- | --- | --- |
| Attaque | 83,11 | ×1,3 | ×2,63 | ×1,6 | ×1,3 | **589,91** |
| PV | 237,79 | ×1 | ×1,85 | ×1,6 | ×2,15 | **1 513,32** |
| Défense | 26,25 | ×1 | ×1,65 | ×1 | ×1,4 | **60,64** |
| Cadence avant l’arme | 1,8194 | ×1,13 | ×1,05 | ×1,48 | ×1,5 | **4,79** |

Les valeurs affichées sont arrondies ; les calculs conservent la précision de chaque étape.

Pour la cadence, les attributs donnent ×1,14 avant les autres sources et l’arme ajoute ×1,1 : la cadence finale atteint 5,27 attaques/s. Les chances et les dégâts critiques s’additionnent en points ; la chance est plafonnée à 100 % après les augments.

Un projectile normal suit ensuite **589,91 ATK de run × 1,15 coefficient d’arme × 0,3833 malus de projectile × 1 bonus conditionnels × 2,65 Cœurs = 1 086,72 dégâts**. Les Cœurs sont le dernier facteur de dégâts ; ils ne modifient ni l’ATK de run, ni les PV, ni la Défense, ni la cadence.

Pour la moyenne, on applique la probabilité critique et l’effet moyen de l’anneau. Puis on multiplie par la cadence, les projectiles frontaux et les salves. Le familier utilise sa propre attaque de forge × le produit permanent des bonus d’attaque du héros, × le facteur d’attaque des augments ; ses tirs reçoivent les dégâts finaux et les Cœurs, sans critique ni salve du héros. Sa forge ne dépend plus de l’attaque de l’arme équipée.

## Ce que chaque source permanente apporte directement

| Source au plafond retenu | Bonus avant combinaison |
| --- | --- |
| Attributs répartis | +40,23 ATK brute ; +50 PV bruts ; +5 Défense brute ; +13,71 % cadence ; +12,31 points chance critique ; +24,62 points dégâts critiques |
| Cinq équipements, forge maximum | +29,98 ATK brute ; +73,29 PV bruts ; +11,25 Défense brute ; +30 % ATK ; +13 % cadence ; +10 points dégâts critiques. S’y ajoutent la forme et le rythme de l’arme, le tir du familier et l’effet d’anneau. |
| Toutes les maîtrises | +162,5 % ATK ; +85 % PV ; +65 % Défense ; +5 % cadence ; +22 points chance critique ; +10 points dégâts critiques ; +15 % soins. Dégâts subis −5 %. |
| Quatre passifs au rang maximum | +60 % ATK ; +60 % PV ; +48 % cadence ; +24 points chance critique |
| Tous les Cœurs | +165 % de dégâts finaux. |
| Sorcier ou Moine | Aucun bonus actuellement. |

Les autres effets de soins, collecte et économie sont détaillés par rang dans les [maîtrises](liste_maitrises.md) et les [passifs](liste_passifs.md). Ils ne sont pas transformés artificiellement en dégâts dans la fiche.

## Le profil utilisé

**Tout est au plafond de progression**, avec une répartition polyvalente des attributs et quatre passifs équipés. Ce n’est pas un maximum simultané de chaque statistique : privilégier l’attaque, les PV ou le rendement économique conduit à des choix différents.

Le matériel ci-dessous maximise le DPS frontal continu total parmi **6250 combinaisons d’équipements actuellement obtenables**, à attributs, passifs et augments identiques. Les bijoux historiques réservés aux anciennes sauvegardes sont exclus. Le meilleur matériel pour résister ou toucher une cible mobile peut être différent.

| Emplacement | Modèle | Forge | Statistiques et effet |
| --- | --- | --- | --- |
| Arme | Alambic souverain | 20 | +15,25 ATK brute. Tir 115 %, cadence +10 %. |
| Familier | Ondine de givre | 20 | 52,55 attaque propre, un tir toutes les 1,9 s. Larme de givre · héros : cadence +8 % |
| Anneau | Anneau · Air | 20 | Attaque brute +4,73 · PV bruts +73 · Vitesse d’attaque +5 %<br>Chaque attaque n° 5 inflige 50 % de dégâts supplémentaires. |
| Bracelet | Bracelet · Feu | 20 | Attaque brute +5 · Défense brute +11,25 · Attaque +5 %<br>La première blessure mortelle de l’aventure laisse le héros à 1 PV. |
| Collier | Collier · Feu | 20 | Attaque brute +5 · Attaque +15 % · Dégâts critiques +10 %<br>Attaque +10 % tant que le collier est équipé. |

**Passifs :** Vigueur rang 2, Célérité rang 2, Œil précis rang 2, Vitalité rang 2. **Cœurs :** 11. **Maîtrises :** tous les rangs des trois branches.

**Run classique illustrative :** 6 rares, 3 épiques et 1 légendaire, sans légendaire bonus. Elle mêle dégâts et survie ; les offres aléatoires ne garantissent pas cette combinaison et ce panier ne représente pas leur médiane.

| Augment | Copies | Rareté | Effet cumulé |
| --- | --- | --- | --- |
| Salve | 1 | Rare | +1 salve par attaque<br>Dégâts de chaque projectile ×0,7<br>Alternative à Battement triple · les deux augments ne se cumulent pas<br>Les gains de cadence et de tirs multiples s’additionnent ; les cumuls atténuent la puissance des impacts |
| Tir double | 1 | Rare | Dégâts de chaque projectile ×0,7<br>Les copies partagent leur puissance ; une nouvelle copie ne multiplie pas les pertes<br>Les gains de cadence et de tirs multiples s’additionnent ; les cumuls atténuent la puissance des impacts<br>+1 projectile frontal parallèle par salve |
| Peau de cuivre | 1 | Rare | PV max +30 %<br>Défense +20 % |
| Baume profond | 1 | Rare | Attaque +10 %<br>PV max +25 %<br>Soins reçus +35 %<br>Les bonus directs d’attaque et de projectile des augments s’additionnent |
| Sceau de garde | 1 | Rare | Dégâts subis −25 % |
| Cadence fébrile | 1 | Rare | Cadence +30 %<br>Les gains de cadence et de tirs multiples s’additionnent ; les cumuls atténuent la puissance des impacts |
| Tir indélébile | 1 | Épique | Vitesse des projectiles +20 %<br>Dégâts des projectiles +35 %<br>Les bonus directs d’attaque et de projectile des augments s’additionnent<br>Poursuit la cible à travers les murs et les autres ennemis |
| Peau de pierre | 1 | Épique | PV max +40 %<br>Dégâts subis −5 % |
| Encre mordante | 1 | Épique | Dégâts des projectiles +40 %<br>Les bonus directs d’attaque et de projectile des augments s’additionnent |
| Courage indomptable | 1 | Légendaire | Attaque +20 %<br>Cadence +20 %<br>PV max +20 %<br>Défense +20 %<br>Les gains de cadence et de tirs multiples s’additionnent ; les cumuls atténuent la puissance des impacts<br>Les bonus directs d’attaque et de projectile des augments s’additionnent<br>Une seconde vie à 100 % des PV, une seule fois par tentative |

## Attributs : le vrai maximum disponible

Au niveau **30**, le compte possède **145 points à répartir au total**. On peut tous les placer dans un attribut, mais les maxima de la dernière colonne ne sont pas cumulables. La fiche utilise tous les points ; leurs bonus bruts sont renforcés ensuite par les maîtrises et les passifs.

Les attributs offensifs prennent progressivement leur puissance avec le niveau du héros. Leur rendement décroît quand on concentre davantage de points dans le même attribut ; la Vitalité et la Sagesse gardent leur calcul par point.

Pour Force, Agilité et Intelligence, le poids de p points vaut **2 × 40 × p / (40 + p)**. Au niveau n, on le multiplie par **0,25 + (1 − 0,25) × ((n − 1) / (30 − 1))²**, puis par le coefficient de l’attribut. Le gain d’un point est la différence entre p + 1 et p au même niveau, pas un bonus constant par point.

| Attribut | Points du profil | Bonus dans cette fiche | Gain du prochain point au même niveau | Maximum individuel : 145 points |
| --- | --- | --- | --- | --- |
| Force | 40 | +32 ATK brute | +0,4 ATK brute | +50,16 ATK brute |
| Vitalité | 50 | +50 PV bruts ; +5 Défense brute | +1 PV bruts ; +0,1 Défense brute | +145 PV bruts ; +14,5 Défense brute |
| Agilité | 25 | +12,31 points chance critique ; +24,62 points dégâts critiques | +0,3 points chance critique ; +0,6 points dégâts critiques | +25,08 points chance critique ; +50,16 points dégâts critiques |
| Intelligence | 30 | +8,23 ATK brute ; +13,71 % cadence | +0,15 ATK brute ; +0,26 % cadence | +15,05 ATK brute ; +25,08 % cadence |
| Sagesse | 0 | Aucun bonus | +0,7 % butin | +101,5 % butin |

Dans Héros, le total acquis et le gain du prochain point utilisent Personnage.bonus au niveau courant. Les valeurs affichées sont arrondies à trois décimales ; les calculs gardent leur précision. Les ATK, PV et Défense bruts sont renforcés ensuite par les autres sources. Les points de critique s’ajoutent avant le plafond de chance.

## Retrait d’une source permanente, sans augment

On retire une source permanente entière et on garde tous les autres choix identiques, sans réoptimiser et sans aucun augment. Retirer l’équipement signifie arme, familier et bijoux absents ; le socle du héros reste capable d’un tir simple pour mesurer les contributions.

| Source retirée | DPS restant | Perte de DPS total | PV restants | Défense restante |
| --- | --- | --- | --- | --- |
| Attributs | 3 606,9 | 58,52 % | 555,87 | 35,06 |
| Équipement | 2 496,76 | 71,29 % | 486,92 | 24,75 |
| Maîtrises | 2 687,95 | 69,09 % | 380,47 | 26,25 |
| Passifs | 3 240,57 | 62,73 % | 439,92 | 43,31 |
| Cœurs | 3 281,35 | 62,26 % | 703,87 | 43,31 |

### Comment lire les proportions

Pour les cinq sources permanentes, on mesure chaque source dans les 120 ordres possibles et on moyenne son apport. Ce partage de Shapley répartit les synergies entre équipement, attributs, maîtrises, passifs et Cœurs. Ces contributions, plus le socle du héros, retombent exactement sur le DPS permanent sans augments.

Le gain des augments répond à une autre question : combien de DPS a été ajouté pendant la run au même build ? Il vaut DPS final − DPS permanent, et sa part du DPS final vaut 1 − 1 / multiplicateur de run. Il ne fait pas partie des 100 % de sources permanentes.

La colonne de contribution est une répartition du socle, pas une prévision de nerf. Le tableau de retrait garde les augments absents et retire une source permanente entière. Ces pertes se chevauchent et ne s’additionnent pas ; elles ne prédisent pas directement l’effet d’un nerf de 10 %.

## Progression des impacts et valeur de chaque investissement

Les dégâts ci-dessous sont ceux d’un impact normal, sans critique ni augment. Le héros nu commence à 10 ; la baguette de départ ajoute 4 ATK brute. La fin utilise le compte complet décrit plus haut, avec ses achats et conditions d’anneau.

| Profil sans augment | Impact normal | Impact critique | DPS total |
| --- | --- | --- | --- |
| Héros nu, niveau 1 | 10 | 15 | 16 |
| Départ équipé, forge 0 | 14 | 21 | 25,96 |
| Compte complet de référence | 1 382,88 | 2 691,3 | 8 695,57 |

L’impact normal de ce compte complet représente **×138,29** celui du héros nu et **×98,78** celui du départ équipé. Ce repère n’est pas un plafond : un build spécialisé ou une arme lente change l’impact et la cadence.

### Utilité des cinq emplacements

On enlève un seul objet et on garde tous les autres choix identiques. Les pertes se chevauchent et ne s’additionnent pas. Le familier inclut son tir et son bonus au héros ; les PV effectifs excluent Sursis, les soins et les esquives.

| Objet retiré | DPS permanent restant | DPS permanent perdu | DPS perdu avec augments classiques | PV effectifs perdus |
| --- | --- | --- | --- | --- |
| Arme | 5 754,32 | 33,82 % | 34,99 % | 0 % |
| Familier | 7 708,12 | 11,36 % | 8,3 % | 0 % |
| Anneau | 7 197,67 | 17,23 % | 17,82 % | 30,82 % |
| Bracelet | 7 881,27 | 9,36 % | 9,55 % | 12,95 % |
| Collier | 6 383,64 | 26,59 % | 26,84 % | 0 % |

### Ce que paie la forge de chaque objet

Comparaison de forge 0 au maximum sur le même compte complet. Tous les autres objets restent au maximum. Les effets débloqués par la forge sont inclus ; la survie de Sursis reste décrite séparément dans la liste des items.

| Objet forgé | DPS ajouté | Gain de DPS total | Gain de PV effectifs |
| --- | --- | --- | --- |
| Arme | 1 027,31 | 13,4 % | 0 % |
| Familier | 340,56 | 4,08 % | 0 % |
| Anneau | 968,66 | 12,54 % | 33,08 % |
| Bracelet | 249,52 | 2,95 % | 9,45 % |
| Collier | 1 548,92 | 21,67 % | 0 % |

### Valeur d’un choix d’augment

Chaque ligne ajoute une seule copie à un profil sans augment. Les gains sont relatifs au même profil avant le choix : ils ne s’additionnent pas entre lignes. La seconde copie est comparée à la première déjà acquise. Départ et fin utilisent exactement les mêmes règles de combat.

Un 0 % de DPS ou de PV effectifs ne signifie pas un effet absent : les trajectoires, dégâts multicibles, mobilité, soins, boucliers, résurrections et gains économiques sont indiqués dans la colonne d’utilité, sans leur inventer une conversion en DPS monocible. Trait périodique et météorite comptent un impact à chaque déclenchement sur une cible immobile, sans prime de zone ; le contact des satellites est exclu.

| Augment | Rareté | DPS au départ | DPS au compte complet | PV effectifs au compte complet | Gain de la 2e copie au compte complet | Utilité hors mesure |
| --- | --- | --- | --- | --- | --- | --- |
| Avidité | Rare | 20 % | 20 % | 0 % | Unique | XP de run et Gouttes |
| Battement triple | Légendaire | 57,49 % | 62,01 % | 0 % | Unique | — |
| Baume profond | Rare | 10 % | 10 % | 25 % | 9,09 % DPS ; 20 % PV effectifs | Soins reçus |
| Cadence fébrile | Rare | 26,53 % | 28,62 % | 0 % | 22,25 % DPS ; 0 % PV effectifs | — |
| Courage indomptable | Légendaire | 41,23 % | 42,9 % | 27,25 % | Unique | Une seconde vie complète |
| Couronne incisive | Légendaire | 40,99 % | 63,38 % | 0 % | Unique | — |
| Égide souveraine | Légendaire | 0 % | 0 % | 66,67 % | Unique | Soin complet à l’acquisition |
| Élan vital | Épique | 20 % | 20 % | 0 % | Unique | Bonus sur l’attaque chargée après déplacement |
| Encrage vif | Rare | 41,85 % | 29,32 % | 0 % | 24,01 % DPS ; 0 % PV effectifs | Trait périodique en mouvement ; projectiles plus rapides |
| Encre mordante | Épique | 35,38 % | 38,16 % | 0 % | Unique | — |
| Force cataclysmique | Légendaire | 60 % | 60 % | 0 % | Unique | — |
| Garde rémanente | Épique | 0 % | 0 % | 40 % | Unique | Un coup bloqué par salle |
| Traque alchimique | Rare | 29,34 % | 32,4 % | 0 % | Unique | Suivi des cibles mobiles |
| Noyau pesant | Épique | 45 % | 45 % | 0 % | 31,03 % DPS ; 0 % PV effectifs | — |
| Pas de brume | Rare | 0 % | 0 % | 20 % | 0 % DPS ; 16,67 % PV effectifs | Mobilité et invulnérabilité après blessure |
| Peau de cuivre | Rare | 0 % | 0 % | 37,86 % | 0 % DPS ; 30,09 % PV effectifs | — |
| Peau de pierre | Épique | 0 % | 0 % | 47,37 % | Unique | — |
| Perforation | Épique | 17,69 % | 19,08 % | 0 % | Unique | Traverse les ennemis ; rebonds limités avec perte |
| Pointe lucide | Rare | 20,49 % | 38,11 % | 0 % | 27,6 % DPS ; 0 % PV effectifs | — |
| Ricochet | Épique | 30,96 % | 33,39 % | 0 % | Unique | Dégâts sur d’autres cibles |
| Salve | Rare | 35,38 % | 38,16 % | 0 % | Unique | — |
| Satellites alchimiques | Rare | 20 % | 20 % | 0 % | Unique | Contact des cercles, même en mouvement ; sans critique ni salve |
| Sceau de garde | Rare | 0 % | 0 % | 33,33 % | Unique | — |
| Sceau de ruine | Rare | 36,18 % | 24,15 % | 0 % | Unique | Météorite en mouvement ; dégâts de zone |
| Éventail | Épique | 8,84 % | 9,54 % | 0 % | 8,71 % DPS ; 0 % PV effectifs | Dégâts diagonaux sur d’autres cibles |
| Tir double | Rare | 35,38 % | 38,16 % | 0 % | 27,62 % DPS ; 0 % PV effectifs | — |
| Tir indélébile | Épique | 30,96 % | 33,39 % | 0 % | Unique | Traverse murs et ennemis ; poursuite |

### Rendements réduits par les cumuls

Les bonus directs d'attaque et de projectile s'additionnent, tout comme les gains de débit des tirs multiples et de cadence. Salve et Battement triple sont exclusifs. Les critiques retirent le croisement entre les bonus de choix distincts. Le rendement dépend donc des choix déjà faits. Ces cas rendent visible le gain marginal d’une acquisition.

| Déjà acquis | Choix ajouté | Gain de DPS total |
| --- | --- | --- |
| battement_triple | Tir double | 23,55 % |
| tir_multiple | Tir double | 27,62 % |
| couronne_incisive, pointe_lucide | Pointe lucide | 13 % |

## La puissance gagnée pendant une tentative

**Un nouveau héros faisant des choix mixtes atteint en médiane ×2,75 DPS en salle 10 et ×4,62 en salle 20.** Les PV effectifs passent à ×3,67 en fin de run. Ces résultats viennent de 384 tirages par orientation, avec les offres réelles du jeu, sans relance.

Chaque run reçoit 10 choix : un légendaire garanti au niveau 5, 3 épiques placés sans remise parmi les autres niveaux et des rares ailleurs. Le tirage réel ajoute avec exactement 10 % de probabilité un second légendaire, en remplacement d’un rare ou d’un épique. Tous les niveaux hors 5 sont éligibles, y compris le premier ; la probabilité marginale est donc 1,11 % par niveau éligible. Le total reste 10 choix, avec au plus deux légendaires et 2 ou 3 épiques lorsqu’il y en a deux.

Les distributions ci-dessous incluent ce bonus. Les paniers fixes et les parcours de référence le désactivent pour comparer des runs ordinaires à un légendaire ; leurs offres restent aléatoires et les monstres conservent leurs courbes fixes.

L’orientation mixte choisit le meilleur compromis immédiat : **55 % du gain logarithmique de DPS + 45 % du gain logarithmique de PV effectifs**. Elle ne connaît pas les prochaines offres. Tout offensif utilise 100/0, offensif prudent 85/15 et défensif 20/80. Cela décrit des choix cohérents, pas la façon de jouer de chaque personne.

Les soins, secondes vies, esquives, boucliers, mobilité et dégâts sur plusieurs cibles ne sont pas valorisés par ce score. Le bonus d’Élan vital après déplacement n’est pas inclus dans ce DPS de tir continu. Les résultats restent un modèle de puissance : ils ne prédisent pas les dégâts réellement évités ni une probabilité de victoire.

**P10–P90** encadre les 80 % centraux des tirages. Les dégâts sont monocibles idéaux, tous les tirs frontaux touchent. Le familier est inclus ; le héros tire en continu.

| Choix | DPS final médian / début | DPS P10–P90 | PV effectifs / début | Contacts de fragile supportés salle 19, sans soin |
| --- | --- | --- | --- | --- |
| Tout offensif | ×8,41 | ×7,38–9,45 | ×1 | 4,21 |
| Offensif prudent | ×8,4 | ×7,33–9,44 | ×1 | 4,21 |
| Équilibré | ×4,62 | ×3,68–5,67 | ×3,67 | 15,43 |
| Défensif | ×2,81 | ×1,97–3,78 | ×5,25 | 22,09 |

### Courbe d’une run au premier niveau de campagne

Le héros commence avec la Baguette d’acier et l’Homoncule, sans attribut, maîtrise, passif, Cœur ni forge. Les colonnes indiquent les statistiques **pendant le combat** : les niveaux des salles précédentes sont reçus, le choix de fin de salle ne l’est pas. Aucun choix supplémentaire ne précède un boss.

| Salle | DPS mixte médian | DPS P10–P90 | PV effectifs mixtes | PV monstres | Dégâts monstres |
| --- | --- | --- | --- | --- | --- |
| 1 | ×1 | ×1–1 | ×1 | ×1 | ×1 |
| 2 | ×1,35 | ×1–1,42 | ×1 | ×1,21 | ×1,02 |
| 3 | ×1,35 | ×1–1,42 | ×1 | ×1,35 | ×1,05 |
| 4 | ×1,45 | ×1,35–1,87 | ×1,33 | ×2,2 | ×1,07 |
| 5 | ×1,84 | ×1,42–2,35 | ×1,4 | ×2,46 | ×1,15 |
| 6 | ×1,84 | ×1,42–2,35 | ×1,4 | ×2,76 | ×1,18 |
| 7 | ×2,21 | ×1,73–2,53 | ×1,47 | ×3,09 | ×1,2 |
| 8 | ×2,21 | ×1,73–2,53 | ×1,47 | ×3,46 | ×1,23 |
| 9 | ×2,39 | ×1,84–3,11 | ×2,22 | ×4,49 | ×1,26 |
| 10 | ×2,75 | ×2,21–3,49 | ×2,53 | ×4,85 | ×1,35 |
| 11 | ×2,75 | ×2,21–3,49 | ×2,53 | ×5,23 | ×1,38 |
| 12 | ×3,07 | ×2,4–3,91 | ×2,94 | ×5,65 | ×1,42 |
| 13 | ×3,07 | ×2,4–3,91 | ×2,94 | ×6,1 | ×1,45 |
| 14 | ×3,52 | ×2,79–4,54 | ×3,11 | ×6,59 | ×1,48 |
| 15 | ×3,52 | ×2,79–4,54 | ×3,11 | ×7,83 | ×1,59 |
| 16 | ×3,52 | ×2,79–4,54 | ×3,11 | ×8,46 | ×1,63 |
| 17 | ×4,05 | ×3,24–5,05 | ×3,27 | ×9,13 | ×1,67 |
| 18 | ×4,05 | ×3,24–5,05 | ×3,27 | ×9,87 | ×1,7 |
| 19 | ×4,05 | ×3,24–5,05 | ×3,27 | ×10,65 | ×1,74 |
| 20 | ×4,62 | ×3,68–5,67 | ×3,67 | ×11,51 | ×1,78 |

| Monstre | PV salle 1 | Tirs normaux nécessaires salle 1 | Même arme sans augment salle 19 |
| --- | --- | --- | --- |
| Encrier rampant | 36 | 3 | 28 |
| Plume-sentinelle | 46 | 4 | 36 |
| Tache véloce | 32 | 3 | 25 |
| Sceau-bélier | 116 | 9 | 89 |

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

## Terrains des cinq mondes

Ces terrains apparaissent dans certaines salles ordinaires de campagne. Ils laissent libres l’entrée, la sortie et le passage central ; les salles de boss et les modes annexes gardent leur configuration. Les flaques ont des contours et des tailles variables, identiques entre deux visites de la même salle.

| Monde | Effet sur le héros |
| --- | --- |
| Encre | Vitesse à 45 % dans la flaque ; tirs conservés |
| Terre | Vitesse de 70 % à 40 % en 1,5 s ; retour à la normale en sortant |
| Eau | Vitesse à 50 % dans la flaque ; tirs conservés |
| Air | Poussée jusqu’à 30 % de la vitesse : 70 % face au vent, 130 % vent dans le dos, à pleine commande |
| Feu | 6 % des PV maximum en dégâts bruts toutes les 1,2 s ; défense, bouclier et invulnérabilité habituels |

Délai d’entrée en salle : 1,5 s. Les effets cessent à l’ouverture du portail. Les ralentissements ne s’additionnent pas entre flaques.

Vent : 7 s de calme puis 4 s de rafale, avec une indication de direction 0,8 s avant. La poussée monte en 0,6 s et retombe en 0,8 s. La direction change entre les rafales ; le vent déplace aussi un héros à l’arrêt, sans annuler son tir automatique ni traverser les obstacles. Les effets réduits figent seulement le déplacement des traits visuels.

## Retour offensif après les premières Épreuves

24 comptes avec graines fixes : échec imposé en salle 9 du chapitre 1, puis victoire au même chapitre, suivie de zéro, cinq ou six victoires dans l’Épreuve 1. Ces victoires sont les hypothèses du scénario demandé ; aucun taux de réussite humain n’est déduit.

Tous les points d’attribut vont en Force. Les achats maximisent le gain de DPS par coût, avec les seules ressources effectivement reçues ; l’équipement privilégie le DPS. Le compte repart sans augment à chaque tentative. Les offres d’augments suivent la politique tout offensive (100 % dégâts, 0 % résistance), avec une seule légendaire garantie. Une offre sans gain offensif peut donner une défense incidente.

Le build offensif doit gagner du temps de combat sans banaliser les éliminations en une attaque. Les courbes fixes des ennemis sont recalibrées avec la puissance permanente et les augments. Aucun nombre minimum de coups ni ajustement au build ne s'applique en jeu.

Les chapitres du tableau sont testés séparément avec le même compte après le farm, sans ajouter les récompenses des chapitres intermédiaires. Les résultats sont des médianes. Le taux d’élimination concerne les formes ordinaires des monstres prévus par les vagues, sans transformation en élite, sans critique, sans rebond ni dégâts gratuits du familier.

Un projectile désigne un seul impact. Une attaque complète additionne les salves et projectiles frontaux qui touchent la même cible. Le temps du boss inclut le familier et les critiques moyens, à 70 % du DPS théorique ; il reste une estimation de débit.

| Victoires Épreuve 1 | Chapitre | DPS permanent | Projectiles à l’entrée | Monstres en 1 projectile | Monstres en 1 attaque | Boss final, s | Contacts minimum |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 0 | 2 | 43,8 | 2 | 0 % | 0 % | 12,7 | 1,9 |
| 0 | 3 | 43,8 | 3 | 0 % | 0 % | 16,7 | 1,8 |
| 0 | 4 | 43,8 | 3 | 0 % | 0 % | 19,3 | 1,7 |
| 0 | 7 | 43,8 | 5 | 0 % | 0 % | 59,9 | 1,5 |
| 5 | 2 | 62,7 | 2 | 0 % | 0,8 % | 9 | 1,9 |
| 5 | 3 | 62,7 | 2 | 0 % | 0 % | 11,8 | 1,8 |
| 5 | 4 | 62,7 | 2 | 0 % | 0 % | 13,6 | 1,7 |
| 5 | 7 | 62,7 | 3 | 0 % | 0 % | 42,3 | 1,5 |
| 6 | 2 | 64,5 | 2 | 0 % | 0,8 % | 8,8 | 1,9 |
| 6 | 3 | 64,5 | 2 | 0 % | 0 % | 11,5 | 1,8 |
| 6 | 4 | 64,5 | 2 | 0 % | 0 % | 13,3 | 1,7 |
| 6 | 7 | 64,5 | 3 | 0 % | 0 % | 41,3 | 1,5 |

### Enchaîner réellement les chapitres après six Épreuves

Cette fois, les achats et récompenses sont conservés entre deux chapitres. Le personnage continue à investir uniquement en dégâts permanents.

| Chapitre | Monstres en 1 attaque | Boss final, s | Contacts minimum |
| --- | --- | --- | --- |
| 2 | 0,8 % | 8,8 | 1,9 |
| 3 | 0,8 % | 9,1 | 1,8 |
| 4 | 0 % | 9,5 | 1,8 |
| 5 | 0 % | 9,1 | 1,8 |
| 6 | 0 % | 12,2 | 1,8 |
| 7 | 1,2 % | 22,8 | 1,7 |
| 8 | 3,2 % | 10,7 | 1,7 |

Sans autre farm après les six Épreuves, **0 comptes sur 24** ne rencontrent aucun boss dépassant 120 secondes sur les 35 chapitres. Cela mesure uniquement leur puissance de tir, en supposant qu’ils survivent.

Parmi les comptes qui rencontrent ce seuil de durée, le premier apparaît au chapitre médian **18,5 [P10 17 ; P90 20]**.

Ce parcours offensif ignore volontairement le seuil de trois contacts pour isoler la puissance de tir. Les contacts minimum ci-dessus retiennent le monstre ordinaire le plus dangereux rencontré, hors élites. Les soins, esquives et blessures ne sont pas simulés.

Le scénario de six niveaux d’Épreuve successifs s’arrête désormais après le premier : vaincre une Épreuve ne suffit plus, la campagne doit aussi avoir atteint son palier. Rejouer le niveau accessible reste autorisé.

## Progression ordinaire, deux défenses et sur-farm

24 comptes par scénario, avec les mêmes graines. Tous commencent par l'échec en salle 9 puis la victoire au premier chapitre. Le parcours ordinaire enchaîne ensuite la campagne, équilibré ou tout offensif. Retour Épreuves ajoute six victoires à l'Épreuve 1. Sur-farm ajoute cinq Épreuves et six victoires supplémentaires au chapitre 1, avant de reprendre le chapitre 2.

Chaque victoire est supposée : ces résultats mesurent la puissance du compte, pas un taux de réussite humain. Les ressources et achats sont conservés entre chapitres et viennent du vrai butin. Aucune maîtrise, forge ou pièce d'équipement maximale n'est accordée gratuitement.

Le cas « Offensif + deux défenses » reprend le même compte offensif, mais remplace son choix légendaire par Égide et un choix épique par Peau de pierre, après leurs niveaux réels. Le nombre de choix, les raretés et les limites de copies sont conservés ; ces deux remplacements sont un stress volontaire, sans prétendre qu'ils figurent toujours dans les offres.

Une attaque additionne ses salves et tous ses projectiles frontaux sur la même cible. Les critiques sont calculés par une loi binomiale : chaque salve a son propre tirage, commun à ses projectiles. Les effets périodiques, rebonds, familier et Élan vital chargé ne donnent pas d'élimination gratuite dans ce taux. Les contrôles stricts des rares portent sur la phase sans épique ni légendaire ; les raretés supérieures peuvent produire une run exceptionnelle. Les élites sont exclues, ce qui privilégie les éliminations faciles.

Les lignes donnent des médianes de comptes, plus le P90 du taux avec critiques pour montrer les tirages favorables. Contacts équivalents = PV effectifs / dégâts bruts : 2,3 signifie mort au troisième coup identique, sans soin, esquive, bouclier ou seconde vie. Ce tableau prend le monstre médian ; le minimum est conservé dans les mesures détaillées. Le boss inclut familier et critiques moyens, avec 70 % de tir utile.

| Parcours | Chapitre | Attaques par monstre | En 1 attaque normale | Avec critiques : médiane / P90 | Contacts équivalents | Boss final, s |
| --- | --- | --- | --- | --- | --- | --- |
| Équilibré | 2 | 5 | 0 % | 0 % / 0 % | 9,7 | 27,7 |
| Équilibré | 3 | 4 | 0 % | 0 % / 0 % | 10,2 | 28 |
| Équilibré | 7 | 5 | 0 % | 0 % / 0,3 % | 12,1 | 73,9 |
| Équilibré | 14 | 12 | 0 % | 0 % / 0 % | 8,3 | 135,2 |
| Équilibré | 35 | 37 | 0 % | 0 % / 0 % | 3,8 | 537,1 |
| Offensif | 2 | 3 | 0 % | 0 % / 0,8 % | 4,4 | 12,7 |
| Offensif | 3 | 3 | 0 % | 0,2 % / 2,2 % | 4,2 | 12,9 |
| Offensif | 7 | 3 | 0 % | 0,4 % / 3,9 % | 4,1 | 31,9 |
| Offensif | 14 | 6 | 0 % | 0 % / 0 % | 2,1 | 49,7 |
| Offensif | 35 | 20 | 0 % | 0 % / 0 % | 0,7 | 239,1 |
| Offensif + deux défenses | 2 | 4 | 0 % | 0 % / 0,1 % | 8,8 | 19,8 |
| Offensif + deux défenses | 3 | 4,3 | 0 % | 0 % / 0,2 % | 8,7 | 20,3 |
| Offensif + deux défenses | 7 | 5 | 0 % | 0,2 % / 0,5 % | 7,8 | 50,1 |
| Offensif + deux défenses | 14 | 9 | 0 % | 0 % / 0 % | 4,3 | 73,8 |
| Offensif + deux défenses | 35 | 26,5 | 0 % | 0 % / 0 % | 1,4 | 375,2 |
| Retour Épreuves | 2 | 3 | 0,8 % | 5,3 % / 14,4 % | 4,4 | 8,8 |
| Retour Épreuves | 3 | 2,5 | 0,8 % | 6 % / 17,4 % | 4,3 | 9,1 |
| Retour Épreuves | 7 | 2 | 1,2 % | 8,3 % / 26,2 % | 4 | 22,8 |
| Retour Épreuves | 14 | 4 | 0 % | 0 % / 0 % | 2,2 | 34,5 |
| Retour Épreuves | 35 | 14 | 0 % | 0 % / 0 % | 0,7 | 160,8 |
| Sur-farm offensif | 2 | 2 | 25,4 % | 63 % / 76,5 % | 5,2 | 4,8 |
| Sur-farm offensif | 3 | 2 | 9,1 % | 37,8 % / 57,3 % | 5 | 6,2 |
| Sur-farm offensif | 7 | 3 | 2,4 % | 6,7 % / 58,7 % | 4,4 | 15,8 |
| Sur-farm offensif | 14 | 4 | 0 % | 0 % / 0,2 % | 2,2 | 29,3 |
| Sur-farm offensif | 35 | 13 | 0 % | 0 % / 0 % | 0,7 | 155,6 |

### Annexes à leur premier déblocage

Même compte après le chapitre 1 pour l'Épreuve 1, puis après le chapitre 3 pour la Mine 1, sans farm supplémentaire. Médianes des comptes. Les contacts prennent le boss le plus dangereux de l'Épreuve, ou le minimum contre un Encrier rampant pendant la Mine ; ils ne modélisent pas les collisions ni les soins. Les choix d'augments suivent la politique du compte.

| Parcours | Annexe | Contacts équivalents | Boss final, s |
| --- | --- | --- | --- |
| Équilibré | Épreuve 1 | 5,7 | 12,2 |
| Équilibré | Mine 1 | 11,7 | 55,8 |
| Offensif | Épreuve 1 | 4,3 | 8,1 |
| Offensif | Mine 1 | 5,2 | 27,3 |

### Budget des bonus offensifs et défensifs

Comparaison d'un seul choix de même rareté sur le héros initial. Les rares visent une utilité comparable ; effets périodiques mesurés sur une cible immobile, sans prime multicible. Les épiques et légendaires gardent une puissance supérieure. Les multiplicateurs de survie excluent le soin immédiat d'Égide.

| Choix offensif | DPS héros | Choix défensif | PV effectifs |
| --- | --- | --- | --- |
| Cadence fébrile | ×1,3 | Sceau de garde | ×1,33 |
| Noyau pesant | ×1,45 | Peau de pierre | ×1,47 |
| Force cataclysmique | ×1,6 | Égide souveraine | ×1,67 |

Égide et Peau de pierre ensemble : **×2,46 PV effectifs**, en consommant un choix légendaire et un choix épique. Les deux effets ne donnent pas de DPS.

## Entrée des niveaux et rendement des achats

Le cas de départ reprend un héros niveau 4, Baguette d’acier forge 1 et Force maîtrisée rang 6. Ses points d’attribut restent non dépensés ; il n’a ni bijou, passif, Cœur ni augment. Les attaques sont normales, sans critique ni contribution du familier. Les quatre premières salles sont aussi mesurées sans aucun augment pour vérifier leur accessibilité indépendamment du hasard.

| Monstre du niveau 2, salle 1 | PV | Dégâts par attaque | Attaques nécessaires |
| --- | --- | --- | --- |
| Encrier rampant | 41,91 | 18,97 | 3 |
| Plume-sentinelle | 53,55 | 18,97 | 3 |
| Tache véloce | 37,25 | 18,97 | 2 |

| Achat depuis ce profil | Coût dans sa monnaie | Dégâts par tir | Gain par tir | Gain de DPS total |
| --- | --- | --- | --- | --- |
| Arme 1 → 2 | 40 | 20,21 | +6,54 % | +5,84 % |
| Arme 1 → 5 | 250 | 21,51 | +13,4 % | +11,97 % |
| Force maîtrisée 6 → 10 | 120 | 21,42 | +12,9 % | +12,9 % |

Le coût d’une arme est payé en Pierres, celui d’une maîtrise en Gouttes. Les autres statistiques et l’équipement restent identiques pendant ces comparaisons.

### Campagne seule avec quelques reprises

4 comptes équilibrés avec les mêmes graines de référence. Le premier monde ne contient aucune reprise ajoutée. Le scénario reprend ensuite des niveaux déjà terminés : 1 reprise(s) du niveau 14, 2 reprise(s) du niveau 21, 3 reprise(s) du niveau 28, 5 reprise(s) du niveau 34. Ce calendrier est une hypothèse de mesure, jamais une obligation ni un nombre d’essais prédit pour le joueur.

Les victoires sont supposées pour isoler l’économie ; les butins, possessions, coûts et achats sont réels. Pendant une reprise destinée aux dégâts, les achats et augments privilégient l’attaque ; les attributs déjà répartis restent identiques. Les premières salles sont mesurées sans augment, les durées de boss utilisent ensuite les vrais tirages de run et les mêmes hypothèses de tir utile que les autres simulations.

| Niveau | Attaques d’entrée sans augment | P90 | DPS permanent | Boss final, s |
| --- | --- | --- | --- | --- |
| 2 | 3 | 3 | 38,86 | 22,5 |
| 7 | 3 | 3,7 | 75,49 | 60,5 |
| 14 | 6,5 | 7,7 | 118,91 | 113 |
| 21 | 9 | 9 | 186,44 | 172,1 |
| 28 | 13 | 14,4 | 300,27 | 300,9 |
| 35 | 17 | 17 | 551,37 | 351,4 |

Ce stress n’effectue aucune Mine ni Épreuve : il ne reçoit aucun passif ni Cœur, et manque de budget de forge. Il montre le retard accumulé si ces sources sont omises ; ses victoires supposées ne signifient pas que ce compte peut terminer la campagne.

### Entrées après renforcement réellement financé

Les trois comptes du parcours conditionnel reçoivent uniquement les coffres des salles validées, puis financent les activités et achats choisis aux murs. Le tableau prend leur état avant la tentative victorieuse. Les quatre premières salles restent mesurées sans augment. Le temps par monstre tient compte de la cadence, des critiques et du familier, à la même activité de tir que les autres modèles ; les attaques normales les excluent.

| Niveau | Attaques normales à l’entrée | Temps par monstre, s | DPS permanent | Boss final, s |
| --- | --- | --- | --- | --- |
| 14 | 3 | 2 | 264,22 | 55,1 |
| 21 | 3 | 1,7 | 664,29 | 41 |
| 28 | 4 | 1,4 | 1 678,48 | 54,8 |
| 35 | 5 | 1,8 | 2 762,31 | 46,3 |

| Niveau rejoué | Reprises | Gain médian de DPS permanent | Variation de PV effectifs |
| --- | --- | --- | --- |
| 14 | 1 | +4,34 % | 0 % |
| 21 | 2 | +5,38 % | −2,35 % |
| 28 | 3 | +23,17 % | −7,01 % |
| 34 | 5 | +21,1 % | 1,59 % |

Ces gains comparent le compte juste avant et juste après les reprises, sans augment. Ils incluent uniquement les achats financés et le butin effectivement reçu. Une amélioration déjà acquise profite aussi aux anciennes armes et maîtrises sauvegardées. Le ressenti et le nombre de répétitions souhaitable restent à vérifier sur téléphone.

## Durée des boss avec un build équilibré

**Cibles approximatives au niveau attendu : 15–45 secondes pour un boss ordinaire, 25–60 secondes pour le boss de fin de monde.** Des augments favorables aux dégâts rapprochent du bas, des tirages défavorables rapprochent du haut. Le full offensif et le sur-farm peuvent aller plus vite ; un compte sous-équipé peut dépasser ces repères.

Les PV sont fixes. Aucun chronomètre, plafond de dégâts ou ajustement au héros ne force un combat dans ces intervalles. Les critères de confort du parcours utilisent leur borne haute pour mesurer le renforcement nécessaire ; ce sont des règles du modèle hors jeu.

Pour chaque fin de monde, 3 comptes ont réellement payé leur équipement et leurs améliorations avec les coffres du parcours conditionnel. Leur configuration précédant la première victoire est rejouée sur 24 autres tirages équilibrés, sans filtrer les échecs et sans légendaire bonus. Les quatre boss sont mesurés, avec les augments disponibles avant leur salle.

Le temps estimé = PV du boss / (DPS × 70 % de tir utile), familier et critiques moyens inclus. Il exclut annonces et menus. P25 et P75 décrivent des tirages assez favorables ou défavorables aux dégâts ; P10–P90 montre une dispersion plus large. Ces quantiles ne sont pas des durées garanties, ni une mesure en partie.

| Niveau | Salle | Boss | Cible, s | P25, s | Médiane, s | P75, s | P10–P90, s |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Monde 1 · Niveau 7 | 5 | Ordinaire | 15–45 | 18 | 21,1 | 25,9 | 16,5–28,9 |
| Monde 1 · Niveau 7 | 10 | Ordinaire | 15–45 | 20,1 | 25,9 | 34 | 17,3–40,6 |
| Monde 1 · Niveau 7 | 15 | Ordinaire | 15–45 | 22,6 | 27 | 33,9 | 18,9–40,2 |
| Monde 1 · Niveau 7 | 20 | Fin de monde | 25–60 | 39 | 48,4 | 58,3 | 32,5–69,3 |
| Monde 2 · Niveau 7 | 5 | Ordinaire | 15–45 | 24,1 | 28,4 | 34,4 | 20,7–37,7 |
| Monde 2 · Niveau 7 | 10 | Ordinaire | 15–45 | 27 | 33,5 | 41,9 | 22,3–46,1 |
| Monde 2 · Niveau 7 | 15 | Ordinaire | 15–45 | 28,7 | 35,5 | 42,6 | 24–50,9 |
| Monde 2 · Niveau 7 | 20 | Fin de monde | 25–60 | 42,4 | 51,7 | 62,1 | 36,8–70,5 |
| Monde 3 · Niveau 7 | 5 | Ordinaire | 15–45 | 24,1 | 28,2 | 33,1 | 21,6–37 |
| Monde 3 · Niveau 7 | 10 | Ordinaire | 15–45 | 25,3 | 31,4 | 39,8 | 20,8–51 |
| Monde 3 · Niveau 7 | 15 | Ordinaire | 15–45 | 29 | 35,6 | 43,6 | 23,9–53,1 |
| Monde 3 · Niveau 7 | 20 | Fin de monde | 25–60 | 40,4 | 49,3 | 58,3 | 34,5–70,8 |
| Monde 4 · Niveau 7 | 5 | Ordinaire | 15–45 | 18,3 | 24,8 | 31,1 | 16,7–33,5 |
| Monde 4 · Niveau 7 | 10 | Ordinaire | 15–45 | 19,7 | 26,7 | 34,2 | 17,5–41,7 |
| Monde 4 · Niveau 7 | 15 | Ordinaire | 15–45 | 21,5 | 27,4 | 34,9 | 17–39,7 |
| Monde 4 · Niveau 7 | 20 | Fin de monde | 25–60 | 40,7 | 50,6 | 61,9 | 33,9–73,9 |
| Monde 5 · Niveau 7 | 5 | Ordinaire | 15–45 | 30 | 34,5 | 36 | 27,4–37 |
| Monde 5 · Niveau 7 | 10 | Ordinaire | 15–45 | 31,6 | 34,9 | 40,2 | 24,4–47,1 |
| Monde 5 · Niveau 7 | 15 | Ordinaire | 15–45 | 32,6 | 36,8 | 41,9 | 29,5–47,8 |
| Monde 5 · Niveau 7 | 20 | Fin de monde | 25–60 | 53,2 | 58,8 | 68,6 | 50,3–75,6 |


## Écart entre un build mixte et les combos offensifs

Même équipement et progression permanente dans chaque comparaison. Le mixte possède une Égide, six rares dont Cadence, Encrage et Traque, puis Encre mordante et deux épiques défensifs : quatre choix offensifs ordinaires, sans Salve ni Tir double. Les autres cas utilisent six rares, trois épiques et une seule légendaire, avec les limites de copies du jeu.

La borne idéale additionne tous les tirs, y compris les diagonales guidées, sur une seule cible. Elle exagère la précision réelle pour éprouver le cumul le plus favorable. Une tentative sans aucun choix offensif conserve logiquement moins de dégâts et n'est pas cette référence. Aucun plafond de DPS n'est appliqué en jeu.

| Choix de run | DPS idéal / mixte au départ | DPS idéal / mixte au compte complet |
| --- | --- | --- |
| Mixte sans combo | ×1 | ×1 |
| Offensif frontal / Courage indomptable | ×3,06 | ×3,66 |
| Offensif frontal / Couronne incisive | ×3,59 | ×4,41 |
| Offensif frontal / Égide souveraine | ×2,63 | ×3,15 |
| Offensif frontal / Force cataclysmique | ×3,32 | ×3,97 |
| Diagonales guidées / Battement triple | ×3,16 | ×3,83 |
| Diagonales guidées / Courage indomptable | ×3,06 | ×3,69 |
| Diagonales guidées / Couronne incisive | ×3,46 | ×4,21 |
| Diagonales guidées / Égide souveraine | ×2,54 | ×3,07 |
| Diagonales guidées / Force cataclysmique | ×3,45 | ×4,16 |


## Effort pour atteindre les cinq plafonds

La cible porte aussi sur le temps de progression : les cinq plafonds doivent rester dans une même période, avec au plus 20 % d’écart de temps total dans les parcours de référence. La vérification ajoute 0,5 point de pourcentage de tolérance de mesure, car les plafonds sont relevés après des activités entières. Le niveau maximum du héros doit rester à moins de 10 % du temps nécessaire aux dernières maîtrises. Ces marges contrôlent un modèle de progression ; elles ne garantissent pas le temps d’un joueur.

Chaque compte part de zéro, paie tous ses achats et conserve les anciennes forges. Le scénario comprend l’échec initial en salle 9, puis les 35 chapitres. Campagne prioritaire réserve les annexes à la fin ; Mixte ajoute une Mine et une Épreuve tous les trois chapitres quand elles sont accessibles. Les victoires sont supposées pour comparer l’économie, avec les vrais tirages, garanties, bonus économiques et durées de combat du modèle.

Ensuite, chaque cycle peut contenir deux replays du dernier chapitre, une Mine et trois Épreuves. Une activité n’est répétée que si sa progression manque encore : continuer à récolter une monnaie après avoir tout acheté fausserait la comparaison. Ce calendrier est une hypothèse de farm, pas une obligation de jeu.

Le maximum signifie : niveau 30 et tous ses points, les cinq emplacements équipés forge 20, les trois arbres complets, les 16 passifs rang 2 et leurs statistiques arrivées à maturité, puis les 11 Cœurs. Forger toute la collection d’armes et de bijoux dépasse ce build complet et reste un objectif supplémentaire.

Les étapes 50 et 75 % comptent le budget d’XP consommé, le coût courant des rangs possédés en forge et maîtrises, ou les acquisitions pour passifs et Cœurs. Ce ne sont pas des pourcentages de DPS. Les statistiques des passifs continuent de croître avec le héros, même après l’obtention des cartes.

Budgets complets avant bonus de récompense : 4612 XP, 24825 Gouttes, 24850 Pierres pour cinq objets, 32 acquisitions de passifs et 11 Cœurs. Les Pierres investies dans les anciens objets ne sont jamais transférées ni remboursées par le scénario.

### Campagne prioritaire

Médianes de 2 comptes ; temps cumulé depuis le compte neuf, en heures. Tir utile, choix et transitions suivent les mêmes hypothèses que les autres parcours.

| Famille | 50 % | 75 % | Maximum |
| --- | --- | --- | --- |
| Héros / attributs | 41,67 | 47,02 | 49,19 |
| Équipement actif | 43,54 | 45,72 | 47,07 |
| Trois arbres de maîtrises | 40,92 | 45,82 | 48,44 |
| Passifs complets | 47,49 | 48,49 | 49,19 |
| Cœurs de mana | 43,59 | 46,24 | 48,51 |

### Mixte

Médianes de 2 comptes ; temps cumulé depuis le compte neuf, en heures. Tir utile, choix et transitions suivent les mêmes hypothèses que les autres parcours.

| Famille | 50 % | 75 % | Maximum |
| --- | --- | --- | --- |
| Héros / attributs | 18,77 | 24,91 | 27,53 |
| Équipement actif | 18,25 | 21,86 | 23,61 |
| Trois arbres de maîtrises | 21,09 | 25,06 | 27,11 |
| Passifs complets | 23,63 | 26,14 | 27,53 |
| Cœurs de mana | 19,58 | 22,75 | 26,85 |

Le ressenti des premiers niveaux, la rentabilité du farm tardif et ces durées restent à confirmer sur téléphone. Un joueur privilégiant exclusivement un mode fera avancer les sources correspondantes plus vite ; les plafonds ne sont jamais verrouillés entre eux.

## Durée des runs, reprises et progression d’un compte neuf

Ces parcours appliquent les offres d’augments, les vagues, les coûts et les coffres du jeu. La référence utilise 10 choix sans légendaire bonus : 6 rares, 3 épiques et le légendaire garanti au niveau 5. Le bonus de 10 % par run reste inclus dans les distributions de puissance précédentes ; la progression de référence ne compte jamais sur deux légendaires. Les Épreuves gardent leurs quatre choix après boss.

Ils mesurent un modèle de puissance et de temps, sans simuler les déplacements ni prédire les victoires d’un joueur. Les 35 chapitres restent conditionnels aux critères de confort définis ci-dessous.

### Durée d’une run complète

Huit graines fixes servent à décrire la dispersion des offres. Le compte du retry reçoit seulement le butin de huit salles et d’un boss après une défaite imposée en salle 9, puis paie ses améliorations. Chaque run reprend sans augment.

| Situation | Run : médiane [P10–P90], min | Boss final : secondes | Contacts minimum équivalents |
| --- | --- | --- | --- |
| Compte neuf, chapitre 1 | 15,2 [13,4–17,5] | 31,5 [28–40,7] | 7 [6,7–7,3] |
| Même chapitre après la première défaite | 14 [12,3–16,3] | 29 [25,2–37,4] | 7,2 [6,4–7,4] |
| Permanent maximum, chapitre 35 | 7,1 [6,8–7,9] | 18,6 [17,7–26,5] | 8 [7,6–8,3] |

Avec le panier classique fixe au maximum, le boss final du chapitre 35 représente **24,5 secondes** à 70 % de tir utile, pour 39 633,1 DPS théoriques. La cohorte ci-dessus utilise les vrais choix proposés au fil des runs, donc peut obtenir d’autres résultats.

| Tir utile, vagues et boss | Compte neuf, min | Retry, min | Maximum chapitre 35, min |
| --- | --- | --- | --- |
| 50 % | 19,3 [16,9–22,4] | 17,7 [15,5–20,8] | 8,6 [8,1–9,6] |
| 80 % | 12,9 [11,4–14,8] | 11,9 [10,5–13,8] | 6,3 [6–7] |

### Parcours et premier besoin de renforcement

Sans annexe ni replay volontaire après la première défaite, huit comptes rencontrent leur premier seuil de confort au chapitre médian **6 [P10 1 ; P90 9]**. Ces rangs de chapitre décrivent les huit exemples ; ils ne sont pas une probabilité de défaite.

| Méthode | Chapitres validés par le modèle | Niveau du compte | Runs campagne / Mine / Épreuve | Temps total, min | Plus long farm, min | Plus long farm + échecs, min |
| --- | --- | --- | --- | --- | --- | --- |
| Sans farm | 6 | 10 | 8 / 0 / 0 | 155,8 | 0 | 0 |
| Lots selon le gain attendu, choix équilibrés | 35 | 24 | 49 / 3 / 36 | 855,4 | 18,1 | 58,3 |
| Choix défensifs après un manque de survie | 35 | 24 | 49 / 3 / 36 | 855,4 | 18,1 | 58,3 |
| Comparatif imposé : 3 replays + 3 Mines + 3 Épreuves | 35 | 28 | 64 / 21 / 21 | 1 092,5 | 73,8 | 99,3 |

Le comparatif de neuf runs impose volontairement un gros lot : il ne constitue pas une obligation de jeu. La politique équilibrée reste la référence ; toutes les victoires et défaites du tableau pilotent réellement les coffres reçus.

| Graine du compte équilibré | Chapitres | Niveau final | Farm maximum, min | Farm + échecs maximum, min |
| --- | --- | --- | --- | --- |
| 20260927 | 35 | 24 | 18,1 | 58,3 |
| 20261936 | 35 | 24 | 23,2 | 70,4 |
| 20262945 | 35 | 24 | 21,2 | 38,7 |

Avec le seuil fixe de sensibilité à 90 secondes, plus permissif que les cibles de campagne, le compte de référence sans farm rencontre ce critère dès le chapitre 11. Le choix du seuil change le diagnostic ; aucune formule ne garantit une réussite en deux essais.

### Compte de référence : ce qui finance chaque chapitre

Les achats indiquent des rangs de maîtrise / forge effectivement payés pendant le chapitre et ses lots. La durée distingue le farm des tentatives du chapitre. Le tableau donne le temps du boss final et le minimum de contacts équivalents sur l’essai validé par le modèle.

| Chapitre | Niveau | Achats M / F | Mines / Épreuves / replays | Farm, min | Tentatives, min | Boss final, s | Contacts minimum |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 1 → 4 | 6 / 2 | 0 / 0 / 0 | 0 | 20,2 | 29,7 | 7,3 |
| 2 | 4 → 6 | 3 / 1 | 0 / 0 / 0 | 0 | 18,1 | 22,9 | 6,5 |
| 3 | 6 → 7 | 3 / 1 | 0 / 0 / 0 | 0 | 18,2 | 24,2 | 6,3 |
| 4 | 7 → 8 | 5 / 2 | 0 / 0 / 0 | 0 | 24,2 | 39,8 | 7,7 |
| 5 | 8 → 9 | 4 / 1 | 0 / 0 / 0 | 0 | 27,4 | 31,8 | 8,5 |
| 6 | 9 → 9 | 5 / 2 | 0 / 0 / 0 | 0 | 20,9 | 28,4 | 8,9 |
| 7 | 9 → 12 | 7 / 3 | 0 / 6 / 0 | 5,7 | 67,6 | 36,6 | 10,1 |
| 8 | 12 → 12 | 3 / 1 | 0 / 0 / 0 | 0 | 19,3 | 23,9 | 10,5 |
| 9 | 12 → 13 | 3 / 1 | 0 / 0 / 0 | 0 | 25,7 | 35,4 | 9,7 |
| 10 | 13 → 13 | 3 / 1 | 0 / 0 / 0 | 0 | 21,3 | 38 | 7,3 |
| 11 | 13 → 15 | 14 / 3 | 0 / 12 / 0 | 11,1 | 63,8 | 27 | 8,9 |
| 12 | 15 → 16 | 3 / 2 | 0 / 0 / 0 | 0 | 17,6 | 26,7 | 8,6 |
| 13 | 16 → 16 | 3 / 2 | 0 / 0 / 0 | 0 | 20,8 | 38,3 | 7,8 |
| 14 | 16 → 16 | 3 / 1 | 0 / 0 / 0 | 0 | 21,1 | 54 | 7,1 |
| 15 | 16 → 17 | 3 / 2 | 0 / 0 / 0 | 0 | 16,4 | 33,9 | 5,8 |
| 16 | 17 → 17 | 3 / 2 | 0 / 0 / 0 | 0 | 17,8 | 36,8 | 5,6 |
| 17 | 17 → 17 | 3 / 1 | 0 / 0 / 0 | 0 | 18,7 | 30,2 | 5,9 |
| 18 | 17 → 18 | 2 / 1 | 0 / 0 / 0 | 0 | 21,4 | 42,4 | 5,4 |
| 19 | 18 → 18 | 7 / 3 | 0 / 3 / 0 | 2,6 | 25,1 | 34,3 | 5,3 |
| 20 | 18 → 19 | 12 / 3 | 0 / 6 / 0 | 5,6 | 46,2 | 27,2 | 5,6 |
| 21 | 19 → 19 | 4 / 2 | 0 / 0 / 0 | 0 | 14,8 | 41 | 4,7 |
| 22 | 19 → 20 | 3 / 2 | 0 / 0 / 0 | 0 | 14,5 | 26 | 5,4 |
| 23 | 20 → 20 | 4 / 1 | 0 / 0 / 0 | 0 | 14,5 | 31,7 | 5,4 |
| 24 | 20 → 20 | 3 / 1 | 0 / 0 / 0 | 0 | 19,2 | 35,8 | 5,5 |
| 25 | 20 → 20 | 3 / 1 | 0 / 0 / 0 | 0 | 13,8 | 25,5 | 5,1 |
| 26 | 20 → 21 | 3 / 3 | 0 / 0 / 0 | 0 | 17,5 | 34,7 | 5,2 |
| 27 | 21 → 21 | 3 / 1 | 0 / 0 / 0 | 0 | 17,4 | 38,3 | 5,2 |
| 28 | 21 → 22 | 7 / 5 | 0 / 6 / 0 | 5,6 | 38,2 | 55,2 | 4,9 |
| 29 | 22 → 22 | 3 / 1 | 0 / 0 / 0 | 0 | 15,8 | 32,3 | 5,1 |
| 30 | 22 → 23 | 5 / 44 | 3 / 0 / 0 | 18,1 | 26,8 | 39 | 5,1 |
| 31 | 23 → 23 | 3 / 0 | 0 / 0 / 0 | 0 | 16,1 | 34,3 | 6 |
| 32 | 23 → 23 | 3 / 1 | 0 / 0 / 0 | 0 | 15,9 | 34,2 | 5,9 |
| 33 | 23 → 23 | 3 / 1 | 0 / 0 / 0 | 0 | 14,8 | 29,1 | 5,6 |
| 34 | 23 → 23 | 2 / 0 | 0 / 0 / 0 | 0 | 13,6 | 34,3 | 4,9 |
| 35 | 23 → 24 | 5 / 1 | 0 / 3 / 0 | 2,4 | 19,8 | 42,3 | 5,7 |

### Temps supplémentaire aux seuils de confort

Le farm inclut les replays terminés ou ratés du chapitre précédent. Les échecs ci-dessous concernent le chapitre en cours. Leur somme exclut la tentative finalement réussie. Le gain de puissance compare le compte avant le premier lot et après le dernier lot, sans augment.

| Chapitre | Mines / Épreuves / replays | Farm, min | Échecs, min | Somme avant succès, min | Gain DPS / PV effectifs |
| --- | --- | --- | --- | --- | --- |
| 7 | 0 / 6 / 0 | 5,7 | 50,6 | 56,3 | ×1,39 / ×1,14 |
| 11 | 0 / 12 / 0 | 11,1 | 47,2 | 58,3 | ×1,62 / ×1,19 |
| 19 | 0 / 3 / 0 | 2,6 | 7,5 | 10 | ×1,1 / ×1 |
| 20 | 0 / 6 / 0 | 5,6 | 30,4 | 36 | ×1,29 / ×1,04 |
| 28 | 0 / 6 / 0 | 5,6 | 22,7 | 28,2 | ×1,16 / ×1,01 |
| 30 | 3 / 0 / 0 | 18,1 | 11,6 | 29,7 | ×1,36 / ×1,19 |
| 35 | 0 / 3 / 0 | 2,4 | 5,8 | 8,2 | ×1,07 / ×1 |

### Hypothèses et limites

- Les temps sont des estimations de débit, pas des mesures de joueurs : 65 % du DPS théorique sert aux vagues et 70 % au boss ; sensibilité affichée à 50 % et 80 %.
- Les PV et dégâts viennent des catalogues, des vraies Vagues et des courbes fixes du runtime. Le DPS inclut le familier et tous les tirs frontaux ; utilité multicible, invocations, dégâts perdus et soins ne sont pas simulés séparément.
- Les vagues sont nettoyées successivement : annonce d'apparition et délai de nettoyage réels. Les départs forcés de vagues peuvent les faire se chevaucher dans le jeu ; ce petit temps d'attente constitue ici une borne prudente.
- Les élites sont tirés avec la graine de salle réelle, au plus un par vague nettoyée. Les renforts invoqués ne donnent aucune récompense inventée.
- Un choix prend 4 secondes et une transition 2 secondes. Marcher jusqu'aux portails, lire les menus et faire les achats ne sont pas chronométrés.
- En campagne, un mur du modèle suit la borne haute de la cible du rang de boss ; les annexes gardent leur seuil propre. Une réserve entière supportant moins de trois contacts d'un Encrier rampant de la salle est aussi un mur. Le modèle ne prédit ni mort humaine ni nombre d'essais nécessaire.
- Le parcours commence par une défaite imposée en salle 9 : seules huit salles et un boss paient. Le retry réutilise le compte amélioré mais repart sans augment.
- Chaque victoire de parcours est une décision du modèle selon ces seuils ; les coffres utilisent ensuite le vrai booléen victoire et les seules salles validées. Les tirages, garanties, accès et coûts sont ceux du jeu.
- Les lots adaptatifs contiennent trois Mines, trois Épreuves ou deux replays d'un chapitre déjà terminé. Le comparatif mixte impose trois replays, trois Mines puis trois Épreuves avant de réessayer. Un bloc dépassant 40 minutes est signalé ; vingt cycles servent de limite de diagnostic, sans inventer une victoire.
- La Mine dure réellement 300 secondes avant son boss. Un modèle continu de dégâts abat sa file de monstres, respecte son plafond, ramasse leur XP et choisit les offres légales ; les blessures ne sont pas simulées.
- L'allocation progressive vise 40 Force, 50 Vitalité, 25 Agilité et 30 Intelligence. Les achats maximisent le gain logarithmique par coût, avec un poids explicite pour les ressources. Aucun objet manquant ni rang de forge n'est offert.
- Une défaite conventionnelle dure la moitié du combat concerné, plafonnée au seuil du rang de boss ; ce temps d'échec est une hypothèse et n'est pas une mesure de survie. Les contacts des Épreuves utilisent leur boss, ceux de la campagne et de la Mine utilisent l'Encrier rampant.
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
- Dégâts d’un projectile = attaque permanente × (1 + bonus directs d'attaque et de projectile des augments) × coefficient de l’arme × puissance des tirs cumulés × bonus finaux × éventuel critique. Élan vital chargé renforce toute l’attaque suivante. Le tir après coefficient d’arme constitue la référence à 100 %.
- Cadence = base × facteur d’attributs × facteur d’équipement × facteur de maîtrises × facteur de passifs × facteur des augments × facteur de l’arme.
- DPS frontal héros = dégâts moyens d’un projectile × poids des projectiles frontaux × salves × cadence.
- Critique moyen = 1 + chance critique × (coefficient critique − 1). Chance plafonnée à 100 % ; critique de base ×1,5. Couronne incisive convertit une part de la chance au-delà du plafond en dégâts critiques.
- Pour les augments de critique, A = somme des chances ajoutées, D = somme des puissances ajoutées et K = A × D − somme(chance du choix × puissance du même choix). Avec Q la chance finale et B la chance permanente, la puissance ajoutée vaut D − K × (Q − B) / (A × Q), avant conversion de l'excédent. Si A ou Q est nul, il n'y a pas de correction. Ce calcul conserve chaque gain individuel et retire le croisement entre choix distincts.
- Bonus finaux = (1 + 0,15 × nombre de Cœurs) × (1 + Audace + Reprise de souffle active + Élan offensif actif).
- Cinquième impact est un facteur moyen supplémentaire de ×1,1 sur le héros quand l’anneau correspondant est équipé et forgé.
- DPS familier = attaque propre × facteur permanent d’attaque × facteur d’attaque des augments × bonus finaux / intervalle. Chaque rang de forge reste utile. Pas de critique ni de salve du héros.
- DPS total = DPS frontal héros + DPS périodique + DPS familier. Les classes ajoutent 0 % à toutes ces sources.
- Traits périodiques et météorites : attaque de run × coefficient propre × bonus finaux / intervalle, sur une cible immobile touchée à chaque déclenchement. Sans coefficient d’arme, critique, salve, diagonale, rebond ou Cinquième impact ; aucune prime de zone n’est ajoutée.
- Satellites alchimiques : 30 % de l’attaque de run par contact, sans coefficient d’arme, critique, salve, diagonale ou rebond, puis bonus finaux. Les 2 cercles partagent un délai de 0,6 s par ennemi. Leur contact est exclu des DPS à distance des tableaux, comme la charge d’Élan vital ; le bonus permanent d’attaque reste inclus.
- PV = (PV de base au niveau du héros + Vitalité + valeurs brutes des bijoux) × facteur d’équipement × facteur de maîtrises × facteur de passifs × facteur des augments. Égide multiplie le résultat après la somme des bonus de PV des autres augments.
- Défense = (base + Vitalité + valeurs brutes des bijoux/familiers) × facteur d’équipement × facteur de maîtrises × facteur de passifs × facteur des augments.
- Dégâts reçus = dégâts ennemis × facteur des augments × (1 + Audace) × (1 − réduction des maîtrises) × 100 / (100 + Défense).
- Les soins de combat par salle sont limités à 5 % des PV maximum × bonus de soins, budget fixé à l’entrée. Les cœurs au sol et Moisson vitale utilisent un soin garanti distinct ; les choix n’ajoutent aucun soin lié à leur rareté.

### Tir double, Salve et Battement triple

**Tir double** ajoute un projectile parallèle ; seul, une copie applique ×0,7 et deux copies ×0,6 aux dégâts de chaque projectile. **Salve** ajoute une répétition et applique ×0,7. **Battement triple**, légendaire, ajoute deux répétitions à ×0,55. Les deux variantes de salves sont exclusives. Un ancien inventaire possédant les deux conserve seulement les trois salves atténuées du légendaire, sans gain supplémentaire.

Avec S salves de puissance P, F tirs frontaux de puissance Q et C le multiplicateur de cadence de run, le débit frontal relatif vaut **S × P + F × Q + C − 2**. La puissance de chaque impact vaut ce débit divisé par S × F × C. Les gestes et projectiles sont conservés ; leurs gains s'additionnent. Il n'y a aucun plafond de dégâts.

Exemple avec 1 000 ATK et le Sceptre de cuivre : le coefficient d’arme porte le projectile à 1 500 dégâts, qui devient notre référence à 100 %. Les critiques et autres bonus finaux sont laissés de côté dans ce tableau.

| Choix | Projectiles par salve | Salves | Dégâts par projectile | Dégâts par attaque complète | Gain sur l’arme seule |
| --- | --- | --- | --- | --- | --- |
| Arme seule | 1 | 1 | 1 500 | 1 500 | ×1 |
| Tir double | 2 | 1 | 1 050 | 2 100 | ×1,4 |
| Tir double ×2 | 3 | 1 | 900 | 2 700 | ×1,8 |
| Salve | 1 | 2 | 1 050 | 2 100 | ×1,4 |
| Tir double + Salve | 2 | 2 | 675 | 2 700 | ×1,8 |
| Battement triple | 1 | 3 | 825 | 2 475 | ×1,65 |
| Battement triple + Salve | 1 | 3 | 825 | 2 475 | ×1,65 |
| Tir double + Battement triple | 2 | 3 | 512,5 | 3 075 | ×2,05 |
| Tir double + Battement triple + Salve | 2 | 3 | 512,5 | 3 075 | ×2,05 |

Avec Battement triple, Salve fait passer de 3 à 3 salves, avec 55 % des dégâts de base par projectile : **×1**, soit **+0 % de DPS idéal** par rapport à Battement triple seul. Le choix reste utile dans les deux ordres d’acquisition.

### Bases du héros et attributs

Au niveau 1 : 100 PV ; 10 Défense ; 10 attaque ; 1,6 tirs/s. Chaque niveau ajoute 0,5 % des PV initiaux et 1 % de l’attaque initiale, en plus des points à répartir. Au niveau maximal, le socle seul vaut 114,5 PV et 12,9 attaque.
Chaque niveau après le premier donne 5 points, jusqu’au niveau 30 : 145 points au total.
Pour un attribut offensif recevant p points : poids effectif = 2 × 40 × p / (40 + p). Son bonus vaut coefficient du catalogue × poids effectif × croissance du héros. La Vitalité et la Sagesse conservent leur calcul linéaire.
Avec t = (niveau − 1) / (30 − 1), la croissance des attributs offensifs vaut 0,25 + (1 − 0,25) × t² ; celle des statistiques de passifs vaut 0,1667 + (1 − 0,1667) × t². Les bonus de rang restent proportionnels au rang acquis ; les pouvoirs conditionnels et utilitaires des passifs conservent leurs règles.

| Attribut | Effet des points |
| --- | --- |
| Force | Attaque brute ; gains progressifs avec le niveau et les points. |
| Vitalité | PV et Défense bruts ; gains constants par point. |
| Agilité | Chance et dégâts critiques ; gains progressifs avec le niveau et les points. |
| Intelligence | Attaque brute et cadence ; gains progressifs avec le niveau et les points. |
| Sagesse | Butin supplémentaire ; gains constants par point. |

## Croissance des monstres

Le niveau global va de 1 à 35 : 5 mondes × 7 niveaux. Chaque tentative de campagne comporte 20 salles.

Avec p = niveau global − 1 et a = min(p, 7) : **facteur PV de niveau = 1,045^a × 1^(a × (a − 1) / 2) × 1,11^(p − a) × [1 + 1,9 × (1 − 0,94^(p^1,5))]**.
Avec b = max(p − 7, 0), **facteur dégâts de niveau = 1,04^p × 1,0002^(p × (p − 1) / 2) × [1 + 1,2 × (1 − 0,9^b)]**. Les non-boss appliquent aussi le coefficient global 1.

Le premier chapitre reste à ×1. Le renfort arrive progressivement, puis tend vers ×2,9. La croissance composée des niveaux suivants laisse davantage de place au renforcement vers la fin de campagne. Les dégâts gardent leur courbe distincte. Un changement de monde n’ajoute pas une seconde hausse cachée.

Dans une tentative, les PV ordinaires croissent de +12 % par salle jusqu'à la salle du légendaire garanti, puis de +8 % par salle. Les paliers du tableau s'ajoutent à cette courbe fixe. Les dégâts gardent le facteur 1,023^(salle − 1) × produit de leurs paliers. Les deux commencent à ×1.
La pente des PV change après la salle 8, que le choix légendaire soit offensif ou défensif. Les dégâts gagnent +2,3 % entre deux salles, avec les hausses supplémentaires du tableau. Ces paliers s’appliquent à l’entrée des salles indiquées et ne donnent aucun choix d’augment supplémentaire.
Les boss de campagne ajoutent un renfort de niveau [1 + 1,1 × (1 − 0,93^b)], puis leur propre croissance de PV par salle : 1,045^(salle − 1), avec leurs propres paliers dans le tableau. Ils conservent ainsi des durées de combat distinctes de l’endurance des monstres ordinaires. Le renfort de dégâts après le premier monde rend les investissements en résistance utiles ; il tend vers ×2,2 sans s’emballer.
Le premier boss, à l’étage 5 de chaque niveau, ajoute ×0,7 à ses PV pour alléger le combat avant le premier légendaire. Ce facteur concerne la campagne et figure dans les calculs de progression et les simulations ; les boss des autres étages et des annexes gardent leur endurance.

Les facteurs sont bornés à la dernière campagne. Ils ne lisent jamais les achats, les morts ni le build du joueur.

### Facteurs par niveau, avant la salle

| Niveau | PV ordinaires | PV boss | Dégâts |
| --- | --- | --- | --- |
| Monde 1 · Niveau 1 | ×1 | ×1 | ×1 |
| Monde 1 · Niveau 2 | ×1,16 | ×1,16 | ×1,04 |
| Monde 1 · Niveau 3 | ×1,43 | ×1,43 | ×1,08 |
| Monde 1 · Niveau 4 | ×1,74 | ×1,74 | ×1,13 |
| Monde 1 · Niveau 5 | ×2,08 | ×2,08 | ×1,17 |
| Monde 1 · Niveau 6 | ×2,43 | ×2,43 | ×1,22 |
| Monde 1 · Niveau 7 | ×2,78 | ×2,78 | ×1,27 |
| Monde 2 · Niveau 1 | ×3,12 | ×3,12 | ×1,32 |
| Monde 2 · Niveau 2 | ×3,67 | ×3,96 | ×1,54 |
| Monde 2 · Niveau 3 | ×4,26 | ×4,9 | ×1,76 |
| Monde 2 · Niveau 4 | ×4,9 | ×5,95 | ×1,98 |
| Monde 2 · Niveau 5 | ×5,58 | ×7,13 | ×2,2 |
| Monde 2 · Niveau 6 | ×6,32 | ×8,43 | ×2,42 |
| Monde 2 · Niveau 7 | ×7,12 | ×9,88 | ×2,64 |
| Monde 3 · Niveau 1 | ×7,98 | ×11,48 | ×2,87 |
| Monde 3 · Niveau 2 | ×8,93 | ×13,26 | ×3,1 |
| Monde 3 · Niveau 3 | ×9,97 | ×15,23 | ×3,33 |
| Monde 3 · Niveau 4 | ×11,11 | ×17,42 | ×3,57 |
| Monde 3 · Niveau 5 | ×12,37 | ×19,85 | ×3,81 |
| Monde 3 · Niveau 6 | ×13,75 | ×22,55 | ×4,06 |
| Monde 3 · Niveau 7 | ×15,29 | ×25,55 | ×4,31 |
| Monde 4 · Niveau 1 | ×16,98 | ×28,9 | ×4,58 |
| Monde 4 · Niveau 2 | ×18,86 | ×32,62 | ×4,85 |
| Monde 4 · Niveau 3 | ×20,94 | ×36,77 | ×5,13 |
| Monde 4 · Niveau 4 | ×23,25 | ×41,39 | ×5,42 |
| Monde 4 · Niveau 5 | ×25,82 | ×46,52 | ×5,72 |
| Monde 4 · Niveau 6 | ×28,66 | ×52,24 | ×6,03 |
| Monde 4 · Niveau 7 | ×31,81 | ×58,61 | ×6,35 |
| Monde 5 · Niveau 1 | ×35,32 | ×65,7 | ×6,69 |
| Monde 5 · Niveau 2 | ×39,2 | ×73,59 | ×7,04 |
| Monde 5 · Niveau 3 | ×43,51 | ×82,36 | ×7,41 |
| Monde 5 · Niveau 4 | ×48,3 | ×92,12 | ×7,79 |
| Monde 5 · Niveau 5 | ×53,61 | ×102,98 | ×8,19 |
| Monde 5 · Niveau 6 | ×59,51 | ×115,05 | ×8,61 |
| Monde 5 · Niveau 7 | ×66,06 | ×128,48 | ×9,04 |

| Salle | Hausse PV ordinaires | Hausse PV boss | Hausse dégâts supplémentaire |
| --- | --- | --- | --- |
| 2 | ×1,08 | ×1 | ×1 |
| 3 | ×1 | ×1,08 | ×1 |
| 4 | ×1,45 | ×1 | ×1 |
| 5 | ×1 | ×1,15 | ×1,05 |
| 9 | ×1,2 | ×1 | ×1 |
| 10 | ×1 | ×1,05 | ×1,05 |
| 15 | ×1,1 | ×1,1 | ×1,05 |

### Facteurs par salle, à multiplier par ceux du niveau

| Salle | PV ordinaires | PV boss | Dégâts |
| --- | --- | --- | --- |
| 1 | ×1 | ×1 | ×1 |
| 2 | ×1,21 | ×1,045 | ×1,023 |
| 3 | ×1,355 | ×1,179 | ×1,047 |
| 4 | ×2,2 | ×1,232 | ×1,071 |
| 5 | ×2,464 | ×1,037 | ×1,15 |
| 6 | ×2,76 | ×1,548 | ×1,176 |
| 7 | ×3,091 | ×1,617 | ×1,203 |
| 8 | ×3,462 | ×1,69 | ×1,231 |
| 9 | ×4,487 | ×1,766 | ×1,259 |
| 10 | ×4,846 | ×1,938 | ×1,353 |
| 11 | ×5,233 | ×2,025 | ×1,384 |
| 12 | ×5,652 | ×2,116 | ×1,416 |
| 13 | ×6,104 | ×2,212 | ×1,448 |
| 14 | ×6,592 | ×2,311 | ×1,482 |
| 15 | ×7,832 | ×2,657 | ×1,592 |
| 16 | ×8,458 | ×2,776 | ×1,628 |
| 17 | ×9,135 | ×2,901 | ×1,666 |
| 18 | ×9,866 | ×3,032 | ×1,704 |
| 19 | ×10,655 | ×3,168 | ×1,743 |
| 20 | ×11,507 | ×3,311 | ×1,783 |

### Élites, boss et modes annexes

- **Élite** : PV ×2 ; dégâts ×2. **Miniboss** : PV ×3,19 ; dégâts ×1. **Boss signature** : PV ×3,5 avant coefficient propre au monde ; dégâts ×1,1.
- **Épreuve** : même facteur de niveau, PV ×2,5 × (1 + 1)^t, dégâts ×1 × (1 + 0,45)^t. t va de 0 à 1 pendant les rencontres.
- **Mine** : même facteur de niveau, PV ×0,75 × (1 + 2)^t, dégâts ×0,64 × (1 + 1)^t, t = temps / 300 s borné entre 0 et 1.
- **Boss de Mine** : facteur supplémentaire PV ×12 et dégâts ×0,8. En Mine et Épreuve, tous les boss appliquent aussi ×0,45 PV ; pas les coefficients de rang de la campagne.

Les évolutions de comportement accélèrent certains tirs/déplacements et ajoutent des salves à leurs seuils ; elles n’ajoutent pas une autre croissance des PV.

| Monde | Boss signature | Coefficient propre de PV en campagne | Facteur de rang final, hors niveau et salle |
| --- | --- | --- | --- |
| Encre | L’Archiscribe des Encres | ×1,4 | ×4,9 |
| Terre | Le Gardien des Runes | ×0,9 | ×3,15 |
| Eau | La Reine du Givre | ×0,95 | ×3,32 |
| Air | Le Maître des Orages | ×1,3 | ×4,55 |
| Feu | Le Roi des Braises | ×1,2 | ×4,2 |


## Progression d’un équipement de fin de campagne

Cette comparaison conserve un ensemble fixe du dernier monde : Alambic souverain + Golem de forge + anneau/bracelet/collier du monde V, tous forgés au maximum. Elle sert à lire les étapes d’achat ; la fiche optimisée du début utilise une autre sélection.

Maîtrises = tous les rangs. Passifs = Vigueur, Célérité, Œil précis et Vitalité, chacun rang 2.
Les étapes s’ajoutent dans cet ordre : leur gain marginal dépend donc de ce qui est déjà acheté. Aucune double attribution d’un pourcentage.

| Étape | ATK | Impact moyen | DPS héros + familier | Gain sur l’étape précédente | PV | Défense |
| --- | --- | --- | --- | --- | --- | --- |
| Départ : baguette et homoncule, forge 0 | 14 | 14,35 | 22,96 + 3 = **25,96** | +0 % | 100 | 10 |
| Même baguette, forge maximum seulement | 22,3 | 22,86 | 36,57 + 3 = **39,57** | +52,43 % | 100 | 10 |
| Équipement complet de fin, forge maximum | 54,34 | 62,49 | 109,98 + 46,87 = **156,86** | +296,39 % | 177,5 | 25,25 |
| Puis niveau 30 et 145 points d’attributs | 112,56 | 142,93 | 286,05 + 46,87 = **332,93** | +112,25 % | 242 | 30,25 |
| Puis toutes les maîtrises | 295,48 | 450,1 | 945,86 + 123,04 = **1 068,91** | +221,06 % | 447,7 | 49,91 |
| Puis quatre passifs de statistiques au rang 2 | 472,77 | 843,62 | 2 623,77 + 196,87 = **2 820,64** | +163,88 % | 716,31 | 49,91 |
| Puis tous les Cœurs | 472,77 | 2 235,6 | 6 953 + 521,7 = **7 474,7** | +165 % | 716,31 | 49,91 |
| Puis effet d’anneau pleinement actif | 472,77 | 2 459,16 | 7 648,3 + 573,87 = **8 222,17** | +10 % | 716,31 | 49,91 |

Maîtrises seules sur le matériel de départ : DPS 79,62, soit +206,69 % par rapport au départ.

## Choix offensifs, mixtes ou défensifs

Même budget ordinaire par exemple : 6 rares, 3 épiques et un légendaire, soit 10 choix. Le légendaire bonus est désactivé dans ces références. Les offres restent aléatoires ; ces builds ne sont pas garantis.
La référence est le profil complet précédent, sans les bonus conditionnels d’anneau. Les boucliers et soins ne sont pas inclus dans les PV effectifs.

| Orientation | DPS | PV | Défense | PV effectifs | Coups bloqués par salle |
| --- | --- | --- | --- | --- | --- |
| Offensif | 74 651,73 (×9,99) | 716,31 | 49,91 | 1 130,35 (×1) | 0 |
| Equilibre | 33 461,61 (×4,48) | 1 540,07 | 69,88 | 3 865,14 (×3,42) | 0 |
| Defensif | 11 403,19 (×1,53) | 3 330,85 | 69,88 | 9 288,33 (×8,22) | 1 |

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

Dernière salle du dernier niveau : fragile 27 365,95 PV / 241,87 dégâts bruts ; boss 678 873,24 PV / 390,21 dégâts bruts.

| Profil | DPS | PV effectifs | Impacts pour tuer le fragile | Contacts de fragile supportés | Coups de boss supportés | Secondes de tir idéal sur le boss |
| --- | --- | --- | --- | --- | --- | --- |
| Campagne seule, achats ci-dessus | 284,42 | 387,93 | 193,14 | 1,6 | 0,99 | 2 386,9 |
| Profil développé par le farm | 8 222,17 | 1 130,35 | 11,13 | 4,67 | 2,9 | 82,57 |

Moins de 1 coup supporté signifie qu’un seul coup tue, hors Sursis. Le temps sur le boss est théorique, avant augments et temps d’esquive.

## Méthode et références consultées

Les nombres de ce document proviennent du jeu et des scénarios décrits ; aucun jeu extérieur ne fournit les coefficients. Les références servent à choisir la méthode d’équilibrage.

- [GEEvo — Rupp et Eckert, 2024](https://arxiv.org/abs/2404.18574) : simulation d’une économie avec des objectifs explicites de ressources et de dégâts dans le temps. Ici, cette approche motive la mesure conjointe des combats, achats et répétitions.
- [GDC — Matt Woodward, Balancing the Economy for Albion Online](https://gdcvault.com/play/1024070/Balancing-the-Economy-for-Albion) : définir des repères et des contraintes d’économie avant de régler les valeurs. Ici, les repères sont le nombre d’attaques, les coups supportés, la durée des boss et le temps d’amélioration.
- [Notes officielles Dead Cells, mise à jour 11](https://deadcells.com/patchnotes/11) : suppression de l’adaptation automatique des ennemis aux statistiques du joueur. Alambik conserve également des niveaux fixes : améliorer son build doit réellement faciliter un niveau déjà connu.

Les hypothèses d’activité de tir et de choix sont vérifiables et modifiables dans le modèle. Une réussite en deux tentatives et le ressenti du farm devront être confrontés à des parties sur téléphone ; les calculs ne remplacent pas cette mesure.

