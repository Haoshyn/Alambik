# Liste des monstres

## Logique mathématique

- Les statistiques de base ci-dessous sont multipliées par le niveau de campagne puis par la salle. Voir la [liste mathématique](liste_mathematique.md) pour chaque coefficient.
- Les variantes des cinq mondes changent les noms et certaines attaques, pas la courbe de PV ni de dégâts de la famille.
- Un élite multiplie les PV par 2, les dégâts par 2 et la vitesse par 1,12.
- Les boss appliquent en plus leurs facteurs dédiés ; leurs motifs peuvent infliger une fraction des dégâts de base.
- Les dégâts indiqués sont avant la Défense et les réductions du héros. La vitesse est en pixels de simulation par seconde.

*Valeurs calculées depuis les données du jeu. Les arrondis ci-dessous servent à la lecture.*

## Rythme et esquive

La vitesse des tirs et la recharge progressent avec le niveau et l’avancée de la tentative, indépendamment du build. Les multiplicateurs ci-dessous s’appliquent aux profils de base ; les tirs ordinaires ajoutent ×1,5 en vitesse, les boss ×2,63. Les plafonds des ricochets et des allers-retours suivent aussi la progression.

| Niveau | Vitesse début × | Vitesse fin × | Recharge début × | Recharge fin × | Annonce × |
| --- | --- | --- | --- | --- | --- |
| 1 | 0,88 | 0,93 | 1,15 | 1,1 | 1,2 |
| 7 | 1,07 | 1,13 | 0,98 | 0,94 | 0,99 |
| 18 | 1,19 | 1,26 | 0,93 | 0,89 | 0,96 |
| 28 | 1,3 | 1,38 | 0,89 | 0,85 | 0,94 |
| 35 | 1,38 | 1,46 | 0,86 | 0,83 | 0,92 |

Les monstres ordinaires ajoutent ×1,05 en vitesse de déplacement et ×1,05 en cadence d’attaque et de récupération. Le Tison arbalétrier du monde Feu applique à la place une cadence ×0,9 : son intervalle d’attaque est divisé par ce coefficient. Ces ajustements précèdent la progression de niveau et les bonus d’élite.

Les poursuivants et les chargeurs appliquent ensuite ×0,9 à leur vitesse. La durée de leurs charges est divisée par ce coefficient pour conserver la même portée. Un chargeur annonce seulement un trajet capable de croiser la course prévue de sa cible après la préparation ; sinon, il se rapproche. Le déplacement rejoint le bout du segment réellement annoncé, sauf collision avec un obstacle.

Le premier boss de chaque niveau de campagne, à l’étage 5, reçoit ×0,7 PV après les coefficients habituels, avant le premier légendaire. Les boss suivants conservent leurs coefficients.

La sentinelle tire à 4 500 px/s avant coefficients. Dès le début de l’annonce, elle fixe une visée anticipant la course pendant sa préparation et tout le temps de vol, jusqu’à sa portée réelle. Une course régulière est menacée même au fond de la salle ; changer de direction ou se couvrir permet l’esquive. Chaque éventail garde un trait central.

Les boss apparaissent près du milieu, sur une place libre. Ils avancent, prennent un flanc ou tournent autour du joueur selon leur identité. Leurs motifs disponibles varient dans l’ordre selon la distance et les obstacles, sans répétition immédiate. Les mêlées ne s’arment qu’à portée et les approches ratées sont abandonnées.

Les tireurs utilisent la portée réelle de leurs projectiles sans attendre leur distance de placement ; les tireurs fuyards gardent leur recul. Les phaseurs se téléportent aussi de loin, vers une place libre annoncée. Les invocateurs appellent à distance et restent capables de tirer une fois leurs renforts épuisés.

Les chargeurs anticipent la course pendant la préparation et le trajet, dès le début de l’annonce et à chaque enchaînement. Les visées moins anticipées restent possibles si elles permettent réellement l’interception sur le segment libre. Une charge exige une cible atteignable et une voie libre, y compris après la préparation et avant un enchaînement. Le déplacement suit exactement le segment annoncé, limité par les murs et obstacles. Un ralentissement empêchant de couvrir ce segment avant le départ annule la charge ; après le départ, il allonge le trajet dans le temps sans raccourcir sa distance.

Les boomerangs des boss sont plus épais, saturés et bordés de sombre. Leur éventail compte 3 branches ; leur plafond de vitesse est 1 500 px/s avant progression, contre 625 px/s pour les monstres ordinaires. La portée totale couvre les deux trajets ; un mur provoque le retour.

Les tirs lents partent sans tracé préalable. Une annonce est requise dès 1 200 px/s de vitesse réelle, ou si le temps avant impact est inférieur à 0,4 s après prise en compte des hitboxes. La règle suit la progression et les plafonds des trajectoires. Les impacts de zone et les frappes préparées gardent leur avertissement ; tout monstre ou boss vivant blesse dès le contact physique, même gelé, après son apparition. Les murs protègent du contact et les cadavres ne blessent pas.

Quand elle est nécessaire, l’annonce ordinaire dure au moins 0,6 s, celle d’une salve de boss 0,65 s. La visée annoncée reste verrouillée jusqu’au départ.

Le tisseur lance 2 rubans sans annonce ni anticipation : écart 150 px, amplitude 96 px, fréquence initiale 1,02 Hz. La fréquence suit ensuite la hausse de vitesse. Il recule si le temps de vol devient inférieur à 0,4 s ; son passage reste ouvert à tous les niveaux.

Salle de référence : 1 197 × 1 995 px ; zoom caméra 0,9975. Les variantes de forme appliquent leurs proportions à cette taille.

## Encrier rampant

**Rang :** fragile.

| Statistique | Valeur de base |
| --- | --- |
| Points de vie | 36 PV |
| Dégâts | 15 dégâts |
| Vitesse | 401,85 px/s |
| Contact du corps | Dégâts immédiats ; délai entre contacts 1 s |
| Dégâts du projectile | 60 % des dégâts de base |

### Variantes par monde

| Monde | Nom de la variante |
| --- | --- |
| Encre | Bavure affamée |
| Terre | Éclat trotteur |
| Eau | Goutte mordante |
| Air | Bourrasque vive |
| Feu | Escarbille vorace |

## Plume-sentinelle

**Rang :** commun.

| Statistique | Valeur de base |
| --- | --- |
| Points de vie | 46 PV |
| Dégâts | 20 dégâts |
| Vitesse | 0 px/s |
| Intervalle d’attaque | 1,7 s |
| Contact du corps | Dégâts immédiats ; délai entre contacts 1 s |
| Dégâts du projectile | 75 % des dégâts de base |
| Projectile | Pointe de plume |
| Vitesse du projectile | 4 500 px/s avant coefficients |
| Rayon de collision | 10 px |
| Longueur de collision | 66 px |
| Trajectoire | Droite |
| Rebonds sur les murs | 0 |

### Variantes par monde

| Monde | Nom de la variante |
| --- | --- |
| Encre | Plume de guet |
| Terre | Obélisque lance-éclats |
| Eau | Aiguille des marées |
| Air | Girouette sifflante |
| Feu | Tison arbalétrier |

## Tache véloce

**Rang :** fragile.

| Statistique | Valeur de base |
| --- | --- |
| Points de vie | 32 PV |
| Dégâts | 17 dégâts |
| Vitesse | 684 px/s |
| Contact du corps | Dégâts immédiats ; délai entre contacts 1 s |
| Durée de charge en terrain libre | 1,25 s ; trajet annoncé arrêté au premier mur ou obstacle |
| Portée de déclenchement | 1 145,26 px avant coefficients de niveau et ralentissements, hitboxes comprises |

### Variantes par monde

| Monde | Nom de la variante |
| --- | --- |
| Encre | Trait fulgurant |
| Terre | Dard de silex |
| Eau | Anguille de verre |
| Air | Flèche de rafale |
| Feu | Mèche filante |

## Scribe essaimeur

**Rang :** costaud.

| Statistique | Valeur de base |
| --- | --- |
| Points de vie | 82 PV |
| Dégâts | 22 dégâts |
| Vitesse | 205 px/s |
| Intervalle d’attaque | 2,95 s |
| Contact du corps | Dégâts immédiats ; délai entre contacts 1 s |
| Dégâts du projectile | 45 % des dégâts de base |
| Projectile | Graine de papier |
| Vitesse du projectile | 520 px/s avant coefficients |
| Rayon de collision | 14 px |
| Longueur de collision | 28 px |
| Trajectoire | Droite |
| Rebonds sur les murs | 0 |

### Variantes par monde

| Monde | Nom de la variante |
| --- | --- |
| Encre | Masque copiste |
| Terre | Nid de gravats |
| Eau | Conque féconde |
| Air | Nichoir des souffles |
| Feu | Couveuse de braises |

## Folio orbiteur

**Rang :** commun.

| Statistique | Valeur de base |
| --- | --- |
| Points de vie | 46 PV |
| Dégâts | 27 dégâts |
| Vitesse | 280 px/s |
| Intervalle d’attaque | 1,55 s |
| Contact du corps | Dégâts immédiats ; délai entre contacts 1 s |
| Dégâts du projectile | 62,5 % des dégâts de base |
| Projectile | Feuillet boomerang |
| Vitesse du projectile | 420 px/s avant coefficients |
| Rayon de collision | 20 px |
| Longueur de collision | 40 px |
| Trajectoire | Aller-retour sur un axe fixe |
| Rebonds sur les murs | 0 |
| Demi-tour | Après 850 px ou au premier mur ; arrêt 0,22 s avant retour |

### Variantes par monde

| Monde | Nom de la variante |
| --- | --- |
| Encre | Feuillet satellite |
| Terre | Galet gravitant |
| Eau | Nautile dérivant |
| Air | Anneau des vents |
| Feu | Roue de scories |

## Sceau-bélier

**Rang :** costaud.

| Statistique | Valeur de base |
| --- | --- |
| Points de vie | 116 PV |
| Dégâts | 33 dégâts |
| Vitesse | 627 px/s |
| Contact du corps | Dégâts immédiats ; délai entre contacts 1 s |
| Durée de charge en terrain libre | 1,6 s ; trajet annoncé arrêté au premier mur ou obstacle |
| Portée de déclenchement | 1 346,22 px avant coefficients de niveau et ralentissements, hitboxes comprises |

### Variantes par monde

| Monde | Nom de la variante |
| --- | --- |
| Encre | Tampon cuirassé |
| Terre | Bélier de schiste |
| Eau | Carapace des flots |
| Air | Heurtoir céleste |
| Feu | Creuset chargeur |

## Marge harceleuse

**Rang :** commun.

| Statistique | Valeur de base |
| --- | --- |
| Points de vie | 36 PV |
| Dégâts | 23 dégâts |
| Vitesse | 340 px/s |
| Intervalle d’attaque | 1,45 s |
| Contact du corps | Dégâts immédiats ; délai entre contacts 1 s |
| Dégâts du projectile | 60 % des dégâts de base |
| Projectile | Épine de ruban |
| Vitesse du projectile | 1 150 px/s avant coefficients |
| Rayon de collision | 10 px |
| Longueur de collision | 48 px |
| Trajectoire | Droite |
| Rebonds sur les murs | 0 |

### Variantes par monde

| Monde | Nom de la variante |
| --- | --- |
| Encre | Ruban frondeur |
| Terre | Liane de quartz |
| Eau | Nageoire cracheuse |
| Air | Écharpe de mistral |
| Feu | Salamandre d’encre |

## Miroir d’encre

**Rang :** costaud.

| Statistique | Valeur de base |
| --- | --- |
| Points de vie | 100 PV |
| Dégâts | 30 dégâts |
| Vitesse | 190 px/s |
| Intervalle d’attaque | 2,35 s |
| Contact du corps | Dégâts immédiats ; délai entre contacts 1 s |
| Dégâts du projectile | 50 % des dégâts de base |
| Projectile | Carreau à ricochet |
| Vitesse du projectile | 300 px/s avant coefficients |
| Rayon de collision | 18 px |
| Longueur de collision | 36 px |
| Trajectoire | Droite |
| Rebonds sur les murs | 1 |

### Variantes par monde

| Monde | Nom de la variante |
| --- | --- |
| Encre | Rosace réfléchissante |
| Terre | Géode rayonnante |
| Eau | Perle à facettes |
| Air | Cadran des rafales |
| Feu | Lentille ardente |

## Cachet phaseur

**Rang :** commun.

| Statistique | Valeur de base |
| --- | --- |
| Points de vie | 44 PV |
| Dégâts | 26 dégâts |
| Vitesse | 255 px/s |
| Intervalle d’attaque | 2,55 s |
| Contact du corps | Dégâts immédiats ; délai entre contacts 1 s |
| Dégâts du projectile | 55 % des dégâts de base |
| Projectile | Losange fendu |
| Vitesse du projectile | 820 px/s avant coefficients |
| Rayon de collision | 13 px |
| Longueur de collision | 38 px |
| Trajectoire | Droite |
| Rebonds sur les murs | 0 |

### Variantes par monde

| Monde | Nom de la variante |
| --- | --- |
| Encre | Cachet furtif |
| Terre | Scarabée des failles |
| Eau | Méduse intermittente |
| Air | Nœud de courant |
| Feu | Étincelle fugitive |

## Fuseau tisseur

**Rang :** costaud.

| Statistique | Valeur de base |
| --- | --- |
| Points de vie | 76 PV |
| Dégâts | 26 dégâts |
| Vitesse | 260 px/s |
| Intervalle d’attaque | 1,85 s |
| Contact du corps | Dégâts immédiats ; délai entre contacts 1 s |
| Dégâts du projectile | 62,5 % des dégâts de base |
| Projectile | Fil torsadé |
| Vitesse du projectile | 600 px/s avant coefficients |
| Rayon de collision | 11 px |
| Longueur de collision | 38 px |
| Trajectoire | Ondulation |
| Rebonds sur les murs | 0 |

### Variantes par monde

| Monde | Nom de la variante |
| --- | --- |
| Encre | Fuseau traceur |
| Terre | Tresse de racines |
| Eau | Serpentin des eaux |
| Air | Vrille des hauteurs |
| Feu | Filament de forge |

## Fiole volatile

**Rang :** fragile.

| Statistique | Valeur de base |
| --- | --- |
| Points de vie | 32 PV |
| Dégâts | 28 dégâts |
| Vitesse | 225 px/s |
| Intervalle d’attaque | 3,2 s |
| Contact du corps | Dégâts immédiats ; délai entre contacts 1 s |
| Dégâts du projectile | 45 % des dégâts de base |

### Variantes par monde

| Monde | Nom de la variante |
| --- | --- |
| Encre | Ampoule de rature |
| Terre | Mortier de glaise |
| Eau | Cloche des profondeurs |
| Air | Ballon d’orage |
| Feu | Alambic incandescent |

## La Rature

**Rang :** miniboss.

| Statistique | Valeur de base |
| --- | --- |
| Points de vie | 270 PV |
| Dégâts | 18 dégâts |
| Vitesse | 260 px/s |
| Intervalle d’attaque | 1,2 s |
| Contact du corps | Dégâts immédiats ; délai entre contacts 1 s |
| Déplacement | Approche directe vers le joueur |
| Distance recherchée | 290 px |
| Déplacement entre motifs de tir | 1 s |
| Portée totale des projectiles | 5 600 px |
| Projectile | Griffe de rature |
| Vitesse du projectile | 470 px/s avant coefficients |
| Rayon de collision | 14 px |
| Longueur de collision | 54 px |
| Trajectoire | Droite |
| Rebonds sur les murs | 0 |

### Attaque au contact : Balayage de griffes

Approche limitée et abandonnée si le joueur reste inaccessible. L’annonce commence à portée, avec une visée verrouillée et une seule frappe. Le boss reste immobile pendant sa récupération ; aucune salve simultanée.

| Paramètre | Valeur |
| --- | --- |
| Approche maximale | 1,35 s |
| Annonce | 0,6 s |
| Portée depuis le centre | 215 px |
| Angle de frappe | 153° |
| Récupération immobile | 1,1 s |

## La Faute vive

**Rang :** miniboss.

| Statistique | Valeur de base |
| --- | --- |
| Points de vie | 280 PV |
| Dégâts | 19 dégâts |
| Vitesse | 285 px/s |
| Intervalle d’attaque | 1,2 s |
| Contact du corps | Dégâts immédiats ; délai entre contacts 1 s |
| Déplacement | Approche par le flanc vers le joueur |
| Distance recherchée | 420 px |
| Déplacement entre motifs de tir | 1,15 s |
| Portée totale des projectiles | 5 600 px |
| Projectile | Parenthèse de retour |
| Vitesse du projectile | 600 px/s avant coefficients |
| Rayon de collision | 26 px |
| Longueur de collision | 52 px |
| Trajectoire | Aller-retour sur un axe fixe |
| Rebonds sur les murs | 0 |
| Demi-tour | Après 2 000 px ou au premier mur ; arrêt 0,22 s avant retour |
| Salve de boomerangs | 3 branches en éventail dirigé vers le joueur |

## Le Correcteur

**Rang :** miniboss.

| Statistique | Valeur de base |
| --- | --- |
| Points de vie | 300 PV |
| Dégâts | 15 dégâts |
| Vitesse | 220 px/s |
| Intervalle d’attaque | 1,2 s |
| Contact du corps | Dégâts immédiats ; délai entre contacts 1 s |
| Déplacement | Approche directe vers le joueur |
| Distance recherchée | 290 px |
| Déplacement entre motifs de tir | 1 s |
| Portée totale des projectiles | 5 600 px |
| Projectile | Croix de correction |
| Vitesse du projectile | 410 px/s avant coefficients |
| Rayon de collision | 21 px |
| Longueur de collision | 42 px |
| Trajectoire | Droite |
| Rebonds sur les murs | 0 |

## La Reliure affamée

**Rang :** miniboss.

| Statistique | Valeur de base |
| --- | --- |
| Points de vie | 285 PV |
| Dégâts | 18 dégâts |
| Vitesse | 245 px/s |
| Intervalle d’attaque | 1,2 s |
| Contact du corps | Dégâts immédiats ; délai entre contacts 1 s |
| Déplacement | Approche directe vers le joueur |
| Distance recherchée | 290 px |
| Déplacement entre motifs de tir | 1 s |
| Portée totale des projectiles | 5 600 px |
| Projectile | Dent de reliure |
| Vitesse du projectile | 440 px/s avant coefficients |
| Rayon de collision | 16 px |
| Longueur de collision | 46 px |
| Trajectoire | Droite |
| Rebonds sur les murs | 0 |

### Attaque au contact : Morsure de reliure

Approche limitée et abandonnée si le joueur reste inaccessible. L’annonce commence à portée, avec une visée verrouillée et une seule frappe. Le boss reste immobile pendant sa récupération ; aucune salve simultanée.

| Paramètre | Valeur |
| --- | --- |
| Approche maximale | 1,65 s |
| Annonce | 0,65 s |
| Portée depuis le centre | 245 px |
| Angle de frappe | 108° |
| Récupération immobile | 1,2 s |

## La Virgule noire

**Rang :** miniboss.

| Statistique | Valeur de base |
| --- | --- |
| Points de vie | 260 PV |
| Dégâts | 17 dégâts |
| Vitesse | 300 px/s |
| Intervalle d’attaque | 1,2 s |
| Contact du corps | Dégâts immédiats ; délai entre contacts 1 s |
| Déplacement | Cercle mobile vers le joueur |
| Distance recherchée | 530 px |
| Déplacement entre motifs de tir | 0,9 s |
| Portée totale des projectiles | 5 600 px |
| Projectile | Virgule tournante |
| Vitesse du projectile | 640 px/s avant coefficients |
| Rayon de collision | 24 px |
| Longueur de collision | 48 px |
| Trajectoire | Aller-retour sur un axe fixe |
| Rebonds sur les murs | 0 |
| Demi-tour | Après 2 000 px ou au premier mur ; arrêt 0,22 s avant retour |
| Salve de boomerangs | 3 branches en éventail dirigé vers le joueur |

## L’Index brisé

**Rang :** miniboss.

| Statistique | Valeur de base |
| --- | --- |
| Points de vie | 320 PV |
| Dégâts | 20 dégâts |
| Vitesse | 235 px/s |
| Intervalle d’attaque | 1,2 s |
| Contact du corps | Dégâts immédiats ; délai entre contacts 1 s |
| Déplacement | Approche par le flanc vers le joueur |
| Distance recherchée | 420 px |
| Déplacement entre motifs de tir | 1,15 s |
| Portée totale des projectiles | 5 600 px |
| Projectile | Flèche à encoche |
| Vitesse du projectile | 960 px/s avant coefficients |
| Rayon de collision | 11 px |
| Longueur de collision | 68 px |
| Trajectoire | Droite |
| Rebonds sur les murs | 0 |

## La Marge hurlante

**Rang :** miniboss.

| Statistique | Valeur de base |
| --- | --- |
| Points de vie | 275 PV |
| Dégâts | 18 dégâts |
| Vitesse | 275 px/s |
| Intervalle d’attaque | 1,2 s |
| Contact du corps | Dégâts immédiats ; délai entre contacts 1 s |
| Déplacement | Approche par le flanc vers le joueur |
| Distance recherchée | 420 px |
| Déplacement entre motifs de tir | 1,15 s |
| Portée totale des projectiles | 5 600 px |
| Projectile | Onde ouverte |
| Vitesse du projectile | 290 px/s avant coefficients |
| Rayon de collision | 24 px |
| Longueur de collision | 48 px |
| Trajectoire | Ondulation |
| Rebonds sur les murs | 0 |

## L’Enlumineur fou

**Rang :** miniboss.

| Statistique | Valeur de base |
| --- | --- |
| Points de vie | 305 PV |
| Dégâts | 19 dégâts |
| Vitesse | 230 px/s |
| Intervalle d’attaque | 1,2 s |
| Contact du corps | Dégâts immédiats ; délai entre contacts 1 s |
| Déplacement | Cercle mobile vers le joueur |
| Distance recherchée | 530 px |
| Déplacement entre motifs de tir | 0,9 s |
| Portée totale des projectiles | 5 600 px |
| Projectile | Étoile enluminée |
| Vitesse du projectile | 340 px/s avant coefficients |
| Rayon de collision | 22 px |
| Longueur de collision | 44 px |
| Trajectoire | Droite |
| Rebonds sur les murs | 0 |

## Le Signet sanglant

**Rang :** miniboss.

| Statistique | Valeur de base |
| --- | --- |
| Points de vie | 295 PV |
| Dégâts | 21 dégâts |
| Vitesse | 310 px/s |
| Intervalle d’attaque | 1,2 s |
| Contact du corps | Dégâts immédiats ; délai entre contacts 1 s |
| Déplacement | Approche directe vers le joueur |
| Distance recherchée | 290 px |
| Déplacement entre motifs de tir | 1 s |
| Portée totale des projectiles | 5 600 px |
| Projectile | Sceau de cire |
| Vitesse du projectile | 380 px/s avant coefficients |
| Rayon de collision | 23 px |
| Longueur de collision | 46 px |
| Trajectoire | Droite |
| Rebonds sur les murs | 0 |

### Attaque au contact : Entaille du signet

Approche limitée et abandonnée si le joueur reste inaccessible. L’annonce commence à portée, avec une visée verrouillée et une seule frappe. Le boss reste immobile pendant sa récupération ; aucune salve simultanée.

| Paramètre | Valeur |
| --- | --- |
| Approche maximale | 1,3 s |
| Annonce | 0,55 s |
| Portée depuis le centre | 230 px |
| Angle de frappe | 117° |
| Récupération immobile | 1,15 s |

## Le Copiste aveugle

**Rang :** miniboss.

| Statistique | Valeur de base |
| --- | --- |
| Points de vie | 330 PV |
| Dégâts | 16 dégâts |
| Vitesse | 210 px/s |
| Intervalle d’attaque | 1,2 s |
| Contact du corps | Dégâts immédiats ; délai entre contacts 1 s |
| Déplacement | Approche par le flanc vers le joueur |
| Distance recherchée | 420 px |
| Déplacement entre motifs de tir | 1,15 s |
| Portée totale des projectiles | 5 600 px |
| Projectile | Double page |
| Vitesse du projectile | 520 px/s avant coefficients |
| Rayon de collision | 15 px |
| Longueur de collision | 54 px |
| Trajectoire | Droite |
| Rebonds sur les murs | 0 |

## L’Archiscribe des Encres

**Rang :** signature.

| Statistique | Valeur de base |
| --- | --- |
| Points de vie | 360 PV |
| Dégâts | 18 dégâts |
| Vitesse | 235 px/s |
| Intervalle d’attaque | 1,2 s |
| Contact du corps | Dégâts immédiats ; délai entre contacts 1 s |
| Déplacement | Approche par le flanc vers le joueur |
| Distance recherchée | 420 px |
| Déplacement entre motifs de tir | 1,15 s |
| Portée totale des projectiles | 5 600 px |
| Projectile | Orbe d’écriture |
| Vitesse du projectile | 350 px/s avant coefficients |
| Rayon de collision | 30 px |
| Longueur de collision | 60 px |
| Trajectoire | Droite |
| Rebonds sur les murs | 0 |

## Le Roi des Braises

**Rang :** signature.

| Statistique | Valeur de base |
| --- | --- |
| Points de vie | 380 PV |
| Dégâts | 22 dégâts |
| Vitesse | 295 px/s |
| Intervalle d’attaque | 1,2 s |
| Contact du corps | Dégâts immédiats ; délai entre contacts 1 s |
| Déplacement | Approche directe vers le joueur |
| Distance recherchée | 290 px |
| Déplacement entre motifs de tir | 1 s |
| Portée totale des projectiles | 5 600 px |
| Projectile | Soleil de braise |
| Vitesse du projectile | 310 px/s avant coefficients |
| Rayon de collision | 34 px |
| Longueur de collision | 68 px |
| Trajectoire | Droite |
| Rebonds sur les murs | 0 |

### Attaque au contact : Marteau de braise

Approche limitée et abandonnée si le joueur reste inaccessible. L’annonce commence à portée, avec une visée verrouillée et une seule frappe. Le boss reste immobile pendant sa récupération ; aucune salve simultanée.

| Paramètre | Valeur |
| --- | --- |
| Approche maximale | 1,6 s |
| Annonce | 0,8 s |
| Portée depuis le centre | 255 px |
| Angle de frappe | 360° |
| Récupération immobile | 1,4 s |

## La Reine du Givre

**Rang :** signature.

| Statistique | Valeur de base |
| --- | --- |
| Points de vie | 400 PV |
| Dégâts | 19 dégâts |
| Vitesse | 215 px/s |
| Intervalle d’attaque | 1,2 s |
| Contact du corps | Dégâts immédiats ; délai entre contacts 1 s |
| Déplacement | Cercle mobile vers le joueur |
| Distance recherchée | 530 px |
| Déplacement entre motifs de tir | 0,9 s |
| Portée totale des projectiles | 5 600 px |
| Projectile | Cristal de marée |
| Vitesse du projectile | 500 px/s avant coefficients |
| Rayon de collision | 14 px |
| Longueur de collision | 72 px |
| Trajectoire | Ondulation |
| Rebonds sur les murs | 0 |

## Le Maître des Orages

**Rang :** signature.

| Statistique | Valeur de base |
| --- | --- |
| Points de vie | 390 PV |
| Dégâts | 23 dégâts |
| Vitesse | 270 px/s |
| Intervalle d’attaque | 1,2 s |
| Contact du corps | Dégâts immédiats ; délai entre contacts 1 s |
| Déplacement | Approche par le flanc vers le joueur |
| Distance recherchée | 420 px |
| Déplacement entre motifs de tir | 1,15 s |
| Portée totale des projectiles | 5 600 px |
| Projectile | Éclair fourchu |
| Vitesse du projectile | 900 px/s avant coefficients |
| Rayon de collision | 12 px |
| Longueur de collision | 72 px |
| Trajectoire | Droite |
| Rebonds sur les murs | 0 |

## L’Hydre des Venins

**Rang :** signature.

| Statistique | Valeur de base |
| --- | --- |
| Points de vie | 420 PV |
| Dégâts | 21 dégâts |
| Vitesse | 225 px/s |
| Intervalle d’attaque | 1,2 s |
| Contact du corps | Dégâts immédiats ; délai entre contacts 1 s |
| Déplacement | Approche directe vers le joueur |
| Distance recherchée | 290 px |
| Déplacement entre motifs de tir | 1 s |
| Portée totale des projectiles | 5 600 px |
| Projectile | Trèfle de venin |
| Vitesse du projectile | 370 px/s avant coefficients |
| Rayon de collision | 26 px |
| Longueur de collision | 52 px |
| Trajectoire | Droite |
| Rebonds sur les murs | 0 |

## Le Chœur infini

**Rang :** signature.

| Statistique | Valeur de base |
| --- | --- |
| Points de vie | 410 PV |
| Dégâts | 22 dégâts |
| Vitesse | 250 px/s |
| Intervalle d’attaque | 1,2 s |
| Contact du corps | Dégâts immédiats ; délai entre contacts 1 s |
| Déplacement | Cercle mobile vers le joueur |
| Distance recherchée | 530 px |
| Déplacement entre motifs de tir | 0,9 s |
| Portée totale des projectiles | 5 600 px |
| Projectile | Diapason errant |
| Vitesse du projectile | 400 px/s avant coefficients |
| Rayon de collision | 15 px |
| Longueur de collision | 48 px |
| Trajectoire | Ondulation |
| Rebonds sur les murs | 0 |

## Le Souverain des Ombres

**Rang :** signature.

| Statistique | Valeur de base |
| --- | --- |
| Points de vie | 440 PV |
| Dégâts | 24 dégâts |
| Vitesse | 285 px/s |
| Intervalle d’attaque | 1,2 s |
| Contact du corps | Dégâts immédiats ; délai entre contacts 1 s |
| Déplacement | Approche par le flanc vers le joueur |
| Distance recherchée | 420 px |
| Déplacement entre motifs de tir | 1,15 s |
| Portée totale des projectiles | 5 600 px |
| Projectile | Croissant obscur |
| Vitesse du projectile | 640 px/s avant coefficients |
| Rayon de collision | 30 px |
| Longueur de collision | 60 px |
| Trajectoire | Aller-retour sur un axe fixe |
| Rebonds sur les murs | 0 |
| Demi-tour | Après 2 100 px ou au premier mur ; arrêt 0,22 s avant retour |
| Salve de boomerangs | 3 branches en éventail dirigé vers le joueur |

### Attaque au contact : Fauchage d’ombre

Approche limitée et abandonnée si le joueur reste inaccessible. L’annonce commence à portée, avec une visée verrouillée et une seule frappe. Le boss reste immobile pendant sa récupération ; aucune salve simultanée.

| Paramètre | Valeur |
| --- | --- |
| Approche maximale | 1,35 s |
| Annonce | 0,65 s |
| Portée depuis le centre | 255 px |
| Angle de frappe | 162° |
| Récupération immobile | 1,25 s |

## Le Gardien des Runes

**Rang :** signature.

| Statistique | Valeur de base |
| --- | --- |
| Points de vie | 460 PV |
| Dégâts | 23 dégâts |
| Vitesse | 205 px/s |
| Intervalle d’attaque | 1,2 s |
| Contact du corps | Dégâts immédiats ; délai entre contacts 1 s |
| Déplacement | Approche directe vers le joueur |
| Distance recherchée | 290 px |
| Déplacement entre motifs de tir | 1 s |
| Portée totale des projectiles | 5 600 px |
| Projectile | Bloc runique |
| Vitesse du projectile | 240 px/s avant coefficients |
| Rayon de collision | 32 px |
| Longueur de collision | 64 px |
| Trajectoire | Droite |
| Rebonds sur les murs | 2 |

### Attaque au contact : Poing de schiste

Approche limitée et abandonnée si le joueur reste inaccessible. L’annonce commence à portée, avec une visée verrouillée et une seule frappe. Le boss reste immobile pendant sa récupération ; aucune salve simultanée.

| Paramètre | Valeur |
| --- | --- |
| Approche maximale | 2 s |
| Annonce | 0,8 s |
| Portée depuis le centre | 285 px |
| Angle de frappe | 144° |
| Récupération immobile | 1,5 s |

## Le Dévoreur du Néant

**Rang :** signature.

| Statistique | Valeur de base |
| --- | --- |
| Points de vie | 490 PV |
| Dégâts | 25 dégâts |
| Vitesse | 275 px/s |
| Intervalle d’attaque | 1,2 s |
| Contact du corps | Dégâts immédiats ; délai entre contacts 1 s |
| Déplacement | Approche directe vers le joueur |
| Distance recherchée | 290 px |
| Déplacement entre motifs de tir | 1 s |
| Portée totale des projectiles | 5 600 px |
| Projectile | Anneau du vide |
| Vitesse du projectile | 270 px/s avant coefficients |
| Rayon de collision | 35 px |
| Longueur de collision | 70 px |
| Trajectoire | Droite |
| Rebonds sur les murs | 0 |

### Attaque au contact : Morsure du néant

Approche limitée et abandonnée si le joueur reste inaccessible. L’annonce commence à portée, avec une visée verrouillée et une seule frappe. Le boss reste immobile pendant sa récupération ; aucune salve simultanée.

| Paramètre | Valeur |
| --- | --- |
| Approche maximale | 1,65 s |
| Annonce | 0,75 s |
| Portée depuis le centre | 275 px |
| Angle de frappe | 126° |
| Récupération immobile | 1,4 s |

## Le Grand Alambic

**Rang :** signature.

| Statistique | Valeur de base |
| --- | --- |
| Points de vie | 520 PV |
| Dégâts | 25 dégâts |
| Vitesse | 240 px/s |
| Intervalle d’attaque | 1,2 s |
| Contact du corps | Dégâts immédiats ; délai entre contacts 1 s |
| Déplacement | Approche directe vers le joueur |
| Distance recherchée | 290 px |
| Déplacement entre motifs de tir | 1 s |
| Portée totale des projectiles | 5 600 px |
| Projectile | Globe alchimique |
| Vitesse du projectile | 250 px/s avant coefficients |
| Rayon de collision | 38 px |
| Longueur de collision | 76 px |
| Trajectoire | Droite |
| Rebonds sur les murs | 1 |

### Attaque au contact : Choc du creuset

Approche limitée et abandonnée si le joueur reste inaccessible. L’annonce commence à portée, avec une visée verrouillée et une seule frappe. Le boss reste immobile pendant sa récupération ; aucune salve simultanée.

| Paramètre | Valeur |
| --- | --- |
| Approche maximale | 1,8 s |
| Annonce | 0,85 s |
| Portée depuis le centre | 280 px |
| Angle de frappe | 360° |
| Récupération immobile | 1,5 s |
