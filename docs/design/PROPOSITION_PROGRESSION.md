# Proposition chiffrée de progression — 18 septembre 2026

Statut : proposition, **non appliquée au jeu**. Calculs de formules et de budgets,
sans test, simulation de combat, tirage aléatoire, lancement Godot ou build.
Les paramètres actuels restent dans `data/` jusqu'à décision sur cette refonte.

## Diagnostic des règles actuelles

- Premier chapitre, première salle : un Encrier a `30 × 0,14 = 4,2 PV` ; le
  tir standard vaut `5,4926`. Il meurt déjà en un tir sans progression.
- Le héros commence avec `60,6489 PV`. Le petit coup de référence vaut
  `15 × 0,15 = 2,25`, soit environ 27 coups pour mourir, hors soins/boucliers.
- Les trois bijoux du premier monde, sans forge, additionnent `+100 % dégâts`
  et `+110 % PV`. Choisir simplement de les équiper donne donc une défense
  importante sans achat défensif.
- Les nœuds offensifs maximisés multiplient les dégâts par
  `2 × 2 × 2,5 × 2 × 3 × 2 × 3,5 = 420`, avant équipement et cadence.
  La défense maximale des seules maîtrises multiplie les PV effectifs par 1344.
- Force 5 coûte 81 gouttes cumulées et donne +50 % dégâts. Une victoire au
  premier chapitre rapporte 72–76 gouttes, hors bonus économiques.
- Les sorts utilisent actuellement les dégâts du tir courant ; augmenter la
  Force ou employer une arme à gros impact augmente aussi les sorts.
- La baguette royale a déjà `3 × 0,85 = 2,55` fois le DPS direct standard,
  avant explosion/rebond. Les armes sont aussi une source de puissance gratuite.
- Le niveau 30 est une référence dans les données, pas un plafond dans la
  boucle de gain d'XP. Les points à distribuer et les critiques ne sont pas
  actuellement implémentés dans le combat.

Sources : `data/reglages.gd`, `data/progression_statistiques.gd`,
`data/arbre_competences.gd`, `data/catalogue_objets.gd`,
`data/catalogue_projectiles.gd`, `scripts/stats.gd`, `scripts/salle.gd`,
`scripts/run.gd`, `autoload/reglages_joueur.gd`.

## Direction recommandée

La progression permanente donne une assise et une spécialisation. Les majeures
changent les possibilités du personnage ; les choix pendant la run construisent
ses synergies. Cible de conception : une bonne construction de run peut doubler
ou tripler l'efficacité du personnage qui vient d'entrer.

Cinq passages réussis constituent un scénario confortable, trois une voie plus
exigeante. Un passage reste possible pour un joueur très habile, sans prétendre
garantir cette faisabilité par le seul calcul. Aucun ennemi ne s'adapte au build
réel : les courbes sont fixées à partir de profils de référence.

## Compte et cinq attributs

Niveau 1 sans points, puis cinq points par niveau gagné, plafond 30 : **145 points**.
Les points restent acquis définitivement ; redistribution hors combat.

| Attribut | Bonus par unité d'attribut |
|---|---|
| Force | +2,5 % de dégâts physiques de base |
| Vitalité | +2,5 % de PV de base et +1,5 point d'armure |
| Sagesse | +0,5 % de gouttes et de pierres gagnées |
| Agilité | +0,2 point de chance critique et +0,5 point de dégâts critiques |
| Intelligence | +4 % de puissance des sorts et +1,2 % de hâte des sorts |

L'unité coûte 1 point pour les unités 1–20, 2 pour 21–40, 3 pour 41–60,
puis 4 pour 61–80. Le coût est lié à chaque attribut, pas à l'ordre des achats.
Les prix croissants encouragent la polyvalence sans interdire une spécialisation.

Exemple niveau 30 : Force 28, Vitalité 28, Sagesse 17, Agilité 23,
Intelligence 25. Coût `36 + 36 + 17 + 26 + 30 = 145`.
Tout investir en Force permet 66 unités pour 144 points, pas 145 unités.

Base proposée pour des valeurs lisibles : 100 PV, 20 dégâts physiques,
5 % de critique, critique à 150 %. Pas de vitesse de déplacement dans les attributs.

## Composition des bonus

Les bonus de même nature des nœuds s'additionnent. On supprime les doublements
successifs. Les trois multiplicateurs restants ont des rôles explicites :

```text
Dégâts physiques = 20 × (1 + 0,025 × Force)
                  × (1 + bonus dégâts des maîtrises + bonus dégâts des bijoux)
Dégâts moyens par impact = dégâts physiques × [1 + C × (M − 1)]

PV = 100 × (1 + 0,025 × Vitalité)
         × (1 + bonus PV des maîtrises + bonus PV des bijoux)
Armure = 1,5 × Vitalité + armure des maîtrises + autres apports d'armure
Réduction d'armure = Armure / (100 + Armure)
PV effectifs = PV × (1 + Armure / 100)

Puissance des sorts = 20 × (1 + 0,04 × Intelligence)
                     × (1 + bonus de puissance magique dédiés)
Recharge = recharge de base / (1 + hâte totale)
```

`C` est une probabilité entre 0 et 1 ; `M` le multiplicateur critique.
La recharge garde un plancher global à 45 % de la recharge de base.
Force et dégâts physiques ne sont pas réappliqués à la puissance magique.
Un sort garde son coefficient, sa zone et ses effets propres.

Sagesse et bonus économiques des maîtrises s'additionnent dans un seul facteur.
L'XP de compte ne reçoit pas ce bonus : pas de double accélération ressources/points.
Les soins, boucliers et effets conditionnels ne sont pas inclus dans les PV
effectifs de référence ; leur valeur se budgète séparément.

## Maîtrises à choix

Trois branches, dix paliers chacune. À chaque palier, choix exclusif gauche/droite.
Prérequis : un rang au palier précédent. Niveaux de compte requis :
`1, 4, 7, 10, 13, 16, 19, 22, 25, 28`.
Les paliers 3, 6 et 9 sont des pouvoirs à achat unique ; les autres ont cinq rangs.
Pas de cadence d'attaque dans les maîtrises permanentes.

Exemple d'alternatives offensives :

| Palier | Gauche | Droite |
|---|---|---|
| 1 | Dégâts | Chance critique |
| 2 | Chance critique | Dégâts critiques |
| 3 | Pluie d'étoiles | Ricochet conditionnel |
| 4 | Dégâts critiques | Dégâts |
| 5 | Dégâts | Chance critique |
| 6 | Marque qui éclate après plusieurs impacts | Fragmentation après élimination |
| 7 | Chance critique | Dégâts critiques |
| 8 | Dégâts critiques | Dégâts |
| 9 | Zone persistante après un sort | Salve chargée après une esquive |
| 10 | Dégâts | Chance critique |

Un rang de statistique offensive donne +2 % dégâts, +2 points de chance critique,
ou +4 points de dégâts critiques selon le choix. Maximum des seules maîtrises :
**+50 points de chance critique**, en renonçant à plusieurs bonus de dégâts.
Avec 5 % de base, Agilité 66 et jusqu'à 15 points sur un équipement spécialisé,
le maximum permanent est 83,2 %. La run peut compléter jusqu'à 100 %.
Le bonus critique des bijoux remplace une partie de leur budget, il n'est pas gratuit.

Défense : +2 % PV ou +2 points d'armure par rang de statistique, avec des
pouvoirs conditionnels aux paliers majeurs (protection après un sort, prévention
d'un coup fatal avec recharge, récupération conditionnelle). Aucun doublement.
Profil de référence : trois nœuds PV et quatre d'armure, soit +30 % PV/+40 armure.

Utilitaire : plafonner le cumul statistique à +25 % de gouttes/pierres par
ressource ; réserver les majeures à des changements comme relance, choix
supplémentaire ou second emplacement passif. Pas de hausse automatique de cadence.
Les alternatives précises défensives/utilitaires restent à choisir avant implémentation.

Exemple de budget d'un pouvoir : 10 % de chance par attaque émise de produire
trois étoiles à 35 % des dégâts chacune. Si toutes touchent la même cible,
le supplément moyen est au plus `0,10 × 3 × 0,35 = 10,5 %`, avant une recharge
interne de 2 s. Un multitir n'effectue pas un jet par projectile ; les étoiles
ne déclenchent pas d'autres pouvoirs. Le budget des trois majeures offensives
vise au plus +30 % de DPS mono cumulé, avec leur intérêt principal en situation.

Coûts de base par palier : `40, 60, 100, 175, 300, 500, 850, 1400, 2300, 3800`.
Rang statistique suivant : `arrondi(base × 1,6^rangs_déjà_achetés)`.
Pouvoir majeur : `4 × base`. Total d'une route complète : **116 340 gouttes**,
soit **349 020** pour les trois branches. La réinitialisation rembourse les achats
effectifs ; un changement de version ne doit pas effacer la monnaie investie.

## Équipement et forge

Trois bijoux, chacun doté d'un budget 0,25 réparti entre offense et défense.
Si `a` est sa part offensive : dégâts `0,25a`, PV `0,50(1−a)`.
Exemples sans forge : offensif `a=0,8` (+20 % dégâts/+10 % PV),
équilibré `a=0,5` (+12,5 % dégâts/+25 % PV), défensif `a=0,2`
(+5 % dégâts/+40 % PV). Les spécialisations magiques/critiques consomment ce
même budget ; elles demandent une conversion dédiée avant implémentation.

Forge 0–30, multiplicateur des bonus `1 + 0,045 × niveau_forge`.
Le monde d'origine change les effets/allocations, pas la puissance gratuite.
Conserver les pouvoirs propres aux objets mais leur attribuer un budget : ne
pas supposer qu'ils n'ajoutent aucun DPS, soin ou protection.

Prix du prochain rang de forge, pour `g` rangs déjà acquis :
`arrondi(24 × 1,12^min(g,10) × 1,18^max(0,g−10))`.
Trois bijoux au niveau 30 coûtent **34 050 pierres** au total.
Changement de bijou : préserver ou transférer l'investissement pour ne pas
transformer un nouveau style en retour forcé au farm.

Les armes doivent également être normalisées : DPS direct comparable pour les
armes mono, moindre pour celles qui gagnent beaucoup en zone/perforation.
Les chiffres ci-dessous emploient une arme de référence, sans effet de bijou
conditionnel, sans majeure déclenchée, sans passif et sans amélioration de run.

## Budget de trois ou cinq passages

Hypothèses : victoires complètes, trente chapitres, onze Épreuves, une Mine
à chaque palier 3–29. La Mine actuelle suit automatiquement l'avancement ;
ce calcul ne suppose pas qu'un sélecteur de 27 Mines existe déjà.

Conserver les revenus de base : campagne moyenne `74 × 1,20^palier` gouttes ;
Mine `arrondi(25 × 1,12^palier)` pierres. La table exclut volontairement tous
les bonus économiques et les petites gouttes des Épreuves (environ 412,5
supplémentaires pour cinq victoires à chacun des onze niveaux).

XP proposée : 60 par victoire de campagne, 30 par Mine complète, 30 par Épreuve
complète. Le prix du passage du niveau `L` à `L+1` est :
`arrondi(40 + 5(L−1) + 1,5(L−1)²)`. Total niveau 30 : **14 768 XP**.
Les défaites conservent une récompense proportionnelle au contenu effectivement
terminé ; elles ne sont pas incluses dans les budgets de victoires ci-dessous.

| Passages par palier, annexes comprises | 1 | 3 | 5 |
|---|---:|---:|---:|
| Victoires totales | 68 | 204 | 340 |
| Gouttes de campagne, environ | 87 459 | 262 378 | 437 296 |
| Pierres | 5 947 | 17 841 | 29 735 |
| XP de compte | 2 940 | 8 820 | 14 700 |
| Niveau de compte | 16 | 24 | 29 |
| Points distribuables | 75 | 115 | 140 |
| Forge égale finançable sur trois bijoux | 19 | 26 | 29 |

Cinq passages financent toutes les maîtrises choisies, presque le niveau 30,
et les trois bijoux 29. Deux victoires de campagne supplémentaires suffisent
pour les 68 XP manquants. Sans bonus économiques, sept Mines au dernier palier
financent le reste de forge (669 pierres chacune). Sagesse/utilitaire raccourcissent
ce complément : il n'est pas imposé à tous les profils.

Trois passages financent environ 75 % du coût total des maîtrises. Cela ne
signifie pas 75 % de puissance : les derniers rangs coûtent beaucoup plus cher.
Cinq passages dans chaque Mine représentent à eux seuls **11 h 15**, hors boss.
Ce scénario doit rester un repère confortable, pas une obligation de complétion.
Les cinq victoires par Épreuve garantissent au moins un drop, pas chaque sort
de sa liste ni son rang maximal : les budgets n'impliquent pas des sorts maxés.

## Exemple de compromis, et courbe ennemie proposée

Au niveau 30 et forge 29, comparaison de deux choix volontaires :

| Hors bonus de run et effets conditionnels | Polyvalent | Tout offensif |
|---|---:|---:|
| Force / Vitalité / Sagesse / Agilité / Intelligence | 28 / 28 / 17 / 23 / 25 | 66 / 0 / 0 / 0 / 0, 1 point libre |
| Maîtrises dégâts / critique / dégâts critiques | +30 % / +30 pts / +20 pts | +50 % / +20 pts / +0 pt |
| Bijoux | trois équilibrés | trois offensifs |
| Maîtrises PV / armure | +30 % / +40 | aucun investissement |
| Dégât normal | 73,59 | 152,80 |
| Chance critique / multiplicateur | 39,6 % / 1,815 | 25 % / 1,5 |
| Dégât moyen par impact | 97,34 | 171,90 |
| PV affichés | 514,89 | 169,15 |
| PV effectifs contre dégâts soumis à armure | 937,10 | 169,15 |

Le profil offensif néglige volontairement la défense ; ce n'est pas présenté
comme une allocation optimale de toutes les ressources disponibles.
Contre un ennemi ordinaire de 220,77 PV, il tue en deux coups normaux ou un
critique. Un ennemi léger de 132,46 PV meurt toujours en un coup normal.
Le polyvalent tue l'ordinaire en trois coups normaux ou deux critiques.
À 156,18 dégâts bruts par coup, le polyvalent tient environ six coups contre
deux pour l'offensif ; une attaque lourde à ×1,3 tue ce dernier en un coup.

Points d'ancrage proposés pour un ennemi ordinaire de référence en début de salle :

| Palier de campagne (index interne) | PV de référence | Dégât du coup de référence |
|---|---:|---:|
| 0, début monde 1 | 60 | 12,5 |
| 3, entrée monde 2 | 106,125 | 47,316 |
| 29, fin de campagne | 220,766 | 156,183 |

L'ancrage monde 2 correspond à un profil finançable : compte 11, attributs
`10/12/8/10/10`, bijoux équilibrés sans forge, +4 % dégâts, +4 pts critique,
+4 % PV et +4 armure en maîtrises. Deux branches avec deux rangs aux deux
premiers nœuds et une majeure coûtent `660 × 2` ; un rang utilitaire coûte 40,
soit 1360 gouttes, couvertes par les 1347 de campagne et environ 75 des Épreuves.
Ce profil a 283,89 PV effectifs, soit six coups de référence ; il ne suppose
ni équipement défensif exceptionnel ni effet protecteur déclenché.

Entre deux ancrages `(p0,v0)` et `(p1,v1)`, interpolation fixe exponentielle :
`v(p) = v0 × (v1/v0)^((p−p0)/(p1−p0))`. Les variantes de monstres gardent des
budgets distincts (léger, standard, robuste). Les boss doivent recevoir leur
propre budget de durée de combat ; ne pas conserver aveuglément leurs anciens
coefficients après cette réduction de la puissance permanente.

Ces ancrages sont une proposition de départ, pas une difficulté ressentie
validée. Ils cadrent la progression avant effets, contrôle, temps passé à
esquiver, précision réelle, densité, soins et synergies de run. L'implémentation
devra inclure ces budgets, la migration remboursée, le reset, l'UI et les choix
majeurs ; remplacer seulement quelques constantes laisserait un système incohérent.
