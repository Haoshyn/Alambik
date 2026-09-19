# REFONTE GAME DESIGN — SOURCE DE VÉRITÉ ACTUELLE

## 0. CONTEXTE CRITIQUE POUR L'IMPLÉMENTATION

**Décision du propriétaire du 19 septembre 2026, prioritaire sur les passes précédentes :** équilibrage global pour environ 12 h jusqu'à la première fin des 5 mondes, avec des gains lisibles. Maîtrises ATK/PV additives à 5/7,5/10/12,5 % par rang ; forge +2,5 points par niveau. Dix niveaux de run : quatre rares garantis à des niveaux aléatoires, six communs avec seulement soin 30 %, ATK +10 % ou PV max +10 %. Épiques avant les étages 5/10/15, avec soin de 30 %. Sorts proportionnels à l'ATK, deux augments de sorts rares (+25 % dégâts, −15 % récupération) et un épique (+75 % dégâts, +25 % rayon actif), disponible aux trois paliers épiques. Précision du propriétaire : aucune rareté légendaire ; les 12 h incluent plusieurs reprises pour farmer, améliorer le personnage et progresser. Les valeurs actives sont dans `data/` ; résumé et limites dans `docs/CURRENT.md`. Relecture uniquement, sans lancement de jeu.

**Précision suivante du 16 septembre :** « 60–70 dégâts » était indicatif. Calibrer l’entrée du monde 3 sur les ressources et objets accessibles après deux à trois passages par chapitre. Butin à chance 1/X avec garantie au Xe coffre éligible : objets 1/3 (garantie à 3), sorts 1/5 (garantie à 5), remise à zéro au drop. Détails : `docs/ops/ECONOMIE_MONDE3_ET_GARANTIES.md`.

**Décision du propriétaire du 16 septembre 2026, prioritaire sur les passes précédentes :** premier chapitre accessible sans équipement, premier bijou garanti à la victoire, puis croissance exponentielle plus exigeante. Bijoux sans cadence, un seul pouvoir au niveau 10, forge possible au-delà pour les statistiques seules et à coût exponentiel ; les nouveaux objets proposent des alternatives de même budget. Dix baguettes, une par monde, les dernières pouvant être plus fortes. Maîtrises en trois branches : deux nœuds de statistiques à dix rangs puis un majeur à rang unique (positions 3/6/9), utilitaire centré sur les ressources. Cadence de base réduite de 20 % à titre d’interprétation et gains de cadence limités. Rangs des sorts conservés avec faibles gains ; Réserve d’ultime renforcée. Petit tutoriel non bloquant, lancement direct du chapitre touché et aperçus de butin illustrés/interactifs. Détails : `docs/ops/PROGRESSION_STATISTIQUES.md` et `docs/ops/EFFETS_BIJOUX.md`.

**Décision du propriétaire du 14 septembre 2026, prioritaire sur les règles ci-dessous :** les sorts actifs et ultimes récupèrent avec le temps de jeu, jamais avec les impacts ou éliminations. Les invocations de boss sont fragiles, espacées et plafonnées. Les Épreuves de magie ont des niveaux et des tables de sorts locales ; aucun augment initial, un choix entre les boss. Toute fin d’aventure, abandon compris, ouvre un coffre interactif, vide sans salle terminée. Chaque salle le remplit et les boss augmentent son rang ; objets et sorts aléatoires exigent une victoire finale. Les loots sont consultables avec « ! » dans la sélection du mode/niveau. Les maîtrises offensives ont une progression multiplicative forte et les PV ennemis suivent une courbe fixe par chapitre. Voir `docs/ops/COFFRES_EPREUVES_RECHARGES.md` pour les valeurs intégrées et les validations. Les deux cadeaux de campagne existants sont conservés et annoncés dans les loots.

**Décision du propriétaire du 13 septembre 2026 :** abandonner les fusions élémentaires expérimentales. La version actuelle utilise des augmentations classiques, des haltes de soin à 50 %, des armes à ratios sans statistiques permanentes, des sorts ciblés en pause rechargés par impacts et quatre ultimes maximum par run. Héros compact, menaces annoncées et progression initiale accélérée. Cette décision remplace les règles élémentaires et de fusion ci-dessous, y compris pour les Épreuves. Voir `docs/ops/REWORK_ARCADE.md` pour les règles intégrées, les mesures et les limites.

Le jeu existe déjà et possède une base jouable de type Archero-like.

**CE DOCUMENT NE DÉCRIT PAS UN JEU À RECRÉER.**

Il décrit les modifications de game design à appliquer progressivement au jeu existant.

### Règle absolue

Avant toute modification :

1. inspecter l'architecture existante ;
2. identifier les systèmes déjà présents ;
3. conserver ce qui fonctionne et correspond à cette vision ;
4. adapter les systèmes existants plutôt que les réécrire ;
5. ne jamais lancer une refonte globale sans nécessité technique réelle ;
6. isoler les changements pour pouvoir les tester indépendamment.

Le gameplay de base du héros existe déjà et est globalement satisfaisant.

Les gros chantiers sont surtout :

* structure des runs ;
* Améliorations ;
* Alambic ;
* progression ;
* équilibrage ;
* patterns ennemis ;
* miniboss ;
* boss ;
* économie.

Les patterns des monstres devront être repris **un par un dans une phase ultérieure**.

---

# 1. PHILOSOPHIE GÉNÉRALE

Le jeu doit être un Archero-like :

* très fluide ;
* agréable immédiatement ;
* relativement simple à comprendre ;
* beaucoup plus profond lorsqu'on commence à theorycraft ;
* plus compact qu'Archero ;
* plus généreux ;
* légèrement orienté farm ;
* fortement orienté skill ;
* sans mécanique artificielle destinée à ralentir le joueur.

Le joueur doit avoir la sensation que :

**même quelques minutes de jeu représentent un petit progrès vers la fin.**

Le jeu doit respecter le temps du joueur.

---

# 2. SKILL VS FARM

Principe fondamental :

**le skill permet de progresser plus vite ; le farm permet de réduire progressivement la difficulté.**

Un excellent joueur doit pouvoir battre du contenu en étant fortement sous-équipé.

Un joueur moins performant doit pouvoir :

* retenter ;
* gagner XP et ressources ;
* améliorer son compte ;
* revenir progressivement plus puissant ;
* finir par franchir l'obstacle sans devoir devenir un expert mécanique.

La progression doit être rapide au début : une tentative ratée en salle 20 doit
financer environ deux petits rangs de maîtrise, voire davantage sur les tout
premiers achats. Au chapitre 1, 19 salles terminées et trois boss vaincus donnent
56–59 Gouttes hors bonus. Cela permet par exemple de passer Force et Constitution
du rang 0 au rang 2 pour 50 Gouttes au total, ou du rang 5 au rang 6 pour le même
prix. Le rythme ralentit avec les maîtrises avancées : quelques tentatives utiles
mais ratées doivent alors généralement financer un petit gain permanent. Les
pouvoirs majeurs demandent davantage d'épargne. Une mort avant toute salle
terminée ne rapporte rien.
Le bilan rappelle une maîtrise ou un bijou équipé améliorable avec les ressources
déjà disponibles, sans effectuer l'achat à la place du joueur.

Cependant :

**le farm ne doit jamais supprimer totalement l'esquive.**

Même avec énormément de progression permanente, le jeu reste un jeu d'esquive.

Exemple conceptuel :

* victoire difficile sur un chapitre ;
* tentative immédiate du suivant = extrêmement difficile mais possible ;
* ~20 min de farm = différence déjà perceptible ;
* ~1 h 30 de farm = chapitre sensiblement plus confortable.

Ces durées ne sont PAS des valeurs finales d'équilibrage.

Un excellent joueur peut éventuellement avancer environ 1 à 2 mondes sans réellement farmer.

En revanche, ignorer longtemps :

* le farm de campagne ;
* la Mine ;
* les Épreuves rituelles ;

doit progressivement rendre l'avancée extrêmement difficile.

---

# 3. MONÉTISATION / FOMO

Le jeu ne doit contenir **aucun avantage gameplay payant**.

Si le jeu fonctionne commercialement, la seule monétisation envisagée est :

**cosmétiques / skins.**

À NE PAS introduire :

* énergie ;
* tickets limitant les runs ;
* quotidiennes obligatoires ;
* streak de connexion ;
* bonus nécessitant une connexion quotidienne ;
* système où l'absence fait perdre des ressources ;
* publicité donnant des avantages ;
* revive payant ;
* équipement exclusif payant ;
* doublons obligatoires.

Le joueur doit pouvoir quitter le jeu plusieurs semaines puis revenir sans avoir l'impression d'avoir raté quelque chose.

Un éventuel système de récompense AFK n'est PAS décidé.

S'il existe un jour, il devra récompenser le retour sans créer d'obligation de connexion.

---

# 4. CAMPAGNE

## Structure

La campagne cible :

**5 mondes × 7 chapitres = 35 chapitres.**

Mondes actifs, dans l’ordre : Encre, Terre, Eau, Air et Feu.

Chaque monde représente une vraie identité visuelle et mécanique.

Les 7 chapitres d'un même monde mutualisent volontairement beaucoup de contenu afin de garder un scope de développement raisonnable.

La puissance ennemie augmente progressivement sur les 35 chapitres, sans saut
spécifique au changement de monde et sans adaptation à l’équipement porté.
Les différences de dégâts entre espèces et entre contact et projectiles sont
conservées. Les nouveaux motifs arrivent à l’intérieur des mondes, après leur
prise en main. Maîtrises et forge gardent leurs bonus acquis ; leurs coûts
successifs sont adoucis pour rendre la progression permanente plus régulière.

---

# 5. IDENTITÉ DES MONDES

Chaque monde possède :

* une direction artistique propre ;
* une mécanique environnementale signature ;
* un pool principal de monstres ;
* des miniboss ;
* un boss signature.

La mécanique environnementale apparaît **régulièrement mais pas systématiquement**.

Direction retenue : grandes arènes rectangulaires, contours légèrement variés,
centre dégagé, obstacles latéraux et murs discontinus ou absents visuellement.
Les bords sans muret restent signalés par le rebord du sol. Un parcours fixe de
20 étages combine neuf contours, dont des coins plus arrondis, avec zéro à quatre
petits obstacles : murets droits ou en L, piliers, rochers, caisses ou livres.
Nombre, taille, forme, type, emplacement et effets de terrain sont identiques
lorsqu’on rejoue le même étage du même chapitre. Aucune graine de run ne change
la carte ; les chapitres emploient des déclinaisons fixes de ces compositions.
Encre ouvre la campagne sans effet de terrain pour apprendre les bases.
Terre : sables mouvants qui ralentissent d’abord très peu puis progressivement
plus tant qu’on reste dedans, avec récupération à la sortie. Eau : flaques
légèrement ralentissantes où les tirs sont interdits. Air : vent qui accélère
la marche dans son sens et la freine à contre-vent, sans pousser à l’arrêt ;
un petit effet directionnel montre son sens, sans tornades. Feu : flaques de
lave infligeant des dégâts. Les flaques restent contournables ; les salles de
boss restent sans effets de terrain dans cette passe.

Exemple :

Monde volcanique → coulées de lave dans certaines rencontres.

La mécanique d'un monde :

* peut modifier certaines salles ;
* peut modifier certaines vagues ;
* peut produire des variantes de miniboss ;
* disparaît au monde suivant.

Le but est de renouveler le gameplay sans empiler définitivement cinq couches de mécaniques.

---

# 6. PROGRESSION DES MONSTRES DANS UN MONDE

Cible actuelle :

### Chapitre 1

Environ **4 types de monstres**.

### Chapitre 2

Environ **5 types**.

### Chapitre 7

Environ **6 types**.

L’introduction des types de monstres est étalée sur les sept chapitres, en réutilisant le bestiaire du monde.

La difficulté augmente aussi via :

* augmentation des statistiques ;
* augmentation du nombre d'ennemis ;
* vagues plus denses ;
* compositions plus complexes.

La difficulté ne doit PAS uniquement être produite par des ennemis devenant des sacs à PV.

Les nouveaux monstres devront créer de nouvelles interactions avec les anciens.

---

# 7. RENCONTRES

Les rencontres ne doivent pas être entièrement procédurales.

Principe retenu :

**rencontres principalement conçues à la main + quelques variantes contrôlées.**

Une salle doit posséder une identité relativement stable.

Certaines variantes peuvent modifier :

* positions de spawn ;
* ordre d'une vague ;
* quelques ennemis ;
* composition secondaire.

Le joueur peut donc apprendre les chapitres tout en évitant une répétition parfaitement identique.

Le hasard principal d'une run doit venir du build, pas de rencontres complètement imprévisibles.

---

# 8. STRUCTURE D'UN CHAPITRE

Un chapitre contient :

**20 salles.**

Objectifs de durée lorsque le joueur possède une puissance appropriée :

### Chapitres 1 à 6

Environ **12 minutes**.

### Chapitre 7

Environ **16 minutes**.

La cible de première complétion des 35 chapitres est d'environ **12 heures** :
7 h 20 de victoires théoriques et 4 h 40 de reprises et de farm. Les tentatives
répétées financent les maîtrises, la forge et les sorts nécessaires à la suite :
la cible inclut cette progression entre les essais. Les Gouttes augmentent de
7,5 % par chapitre ; les tentatives ratées rémunèrent leurs salles terminées.
Ce budget reste théorique.
Le temps de clean théorique est volontairement plus court : le joueur habile
avance plus vite et le farm compense une partie du manque de skill.

Ces valeurs sont des cibles de rythme, pas des limites artificielles.

Un joueur très puissant doit pouvoir finir un ancien chapitre beaucoup plus rapidement.
Un compte totalement maxé doit même être clairement overkill pour la campagne :
le contenu exigeant de ce profil appartient aux modes annexes et au post-game.

Le jeu ne doit jamais ralentir artificiellement un joueur qui clean extrêmement vite.

---

# 9. SYSTÈME DE VAGUES

Les salles utilisent principalement des combats à plusieurs vagues.

Cible actuelle de densité pour une salle normale :

* **3 vagues** sur l'essentiel du chapitre ;
* **4 vagues** sur les salles normales 18 et 19 ;
* **4 ennemis maximum par vague** afin de conserver des menaces lisibles ;
* environ **150 à 165 ennemis communs écrits par chapitre**, avant invocations ;
* si une vague survit, la suivante peut arriver après environ **7 secondes**.

Cette densité sert d'abord à augmenter la durée, la variété des décisions et la
pression. Elle doit remplacer une partie du scaling de PV, pas s'y ajouter.

Le système est hybride :

### Cas A — joueur très puissant

La vague est entièrement détruite.

→ la suivante commence immédiatement.

### Cas B — joueur lent

La vague n'est pas terminée après un certain timer.

→ la vague suivante peut apparaître malgré les ennemis encore vivants.

Conséquences :

* un joueur puissant n'attend jamais inutilement ;
* un manque de DPS augmente naturellement la pression ;
* il n'est pas nécessaire de simplement gonfler les PV pour augmenter la difficulté.

Attention lors de l'équilibrage :

éviter un effet boule de neige trop brutal où une légère faiblesse de DPS provoque immédiatement une accumulation impossible à rattraper.

---

# 10. TRANSITIONS ENTRE SALLES

Une fois une salle terminée :

le joueur peut passer à la suivante **immédiatement**.

Pas de :

* longue marche jusqu'à une porte ;
* transition lente ;
* écran de chargement perceptible ;
* animation inutile.

Le jeu doit donner une sensation de continuité et de rapidité.

---

# 11. PALIERS 5 / 10 / 15 / 20

Les salles :

**5 / 10 / 15 / 20**

sont des paliers majeurs.

## Salles 5 / 10 / 15

Le joueur entre d'abord dans une **pré-salle**.

Cette pré-salle propose trois pouvoirs épiques, puis rend 30 % des PV max.
Apothéose est un épique de sorts admissible aux trois paliers.
Le soin est identique quelle que soit l'augmentation retenue.

Puis :

→ combat contre un miniboss.

## Salle 20

Pas d'Alambic.

### Chapitres 1 à 6

Miniboss final / rencontre finale renforcée.

### Chapitre 7

**Boss signature du monde.**

Il existe donc :

**5 boss signature principaux au total.**

Un boss signature doit constituer un vrai pic de difficulté. Sa puissance ne doit pas venir uniquement d'une barre de PV : la cible actuelle combine une endurance nettement supérieure, des projectiles plus rapides, davantage de pression entre les salves et moins de temps mort. En budget de rencontre, il doit être de l'ordre de **quatre à cinq fois plus exigeant** que l'ancien prototype, sans multiplier chaque statistique par cinq.

Ses attaques restent télégraphiées et doivent toujours laisser des trajectoires ou fenêtres d'esquive lisibles. Les projectiles générés depuis un bord de l'arène doivent naître à l'intérieur des collisions afin qu'un pattern ne s'annule jamais instantanément contre le mur qui l'a créé.

Les miniboss servent de paliers intermédiaires plus menaçants qu'une vague normale. La cible demandée pour les combats de boss de début de campagne est désormais **30 à 45 secondes**, avec un build de débutant et des interruptions de tir pour se déplacer. Les signatures se distinguent aussi par leurs motifs et leur pression. Cette durée reste un objectif de réglage, pas un verrou imposé aux builds puissants. Les mesures et leurs limites sont consignées dans `docs/ops/EQUILIBRAGE_AUGMENTATIONS.md`.

Les miniboss peuvent être réutilisés mais recevoir de petites modifications correspondant au monde actuel.

---

# 12. NIVEAU DE RUN

Le niveau de run est distinct du niveau de compte et recommence à chaque chapitre.
La campagne donne dix montées de niveau avant le boss final. Quatre niveaux sont
choisis aléatoirement sans remise au début de la run pour proposer des rares ;
les six autres sont communs. Les rares incluent Homing et les spécialisations.
Une relance conserve la rareté du niveau.

L'XP permet de gagner le choix pendant une salle ; sa fin garantit les paliers
aux salles 1/3/4/6/8/9/11/13/16/19. Les trois offres épiques des étages 5/10/15
s'ajoutent aux dix niveaux, sans consommer l'un des quatre rares.

---

# 13. LEVEL-UP

Le combat se met en pause et le joueur retient une augmentation.
Un niveau commun propose toujours les trois choix suivants :

* rendre 30 % des PV maximum ;
* ajouter 10 % d'attaque de base à la run ;
* ajouter 10 % de PV maximum de base, sans soin immédiat.

Les gains ATK/PV se cumulent sans rendement décroissant. Un niveau rare propose
des spécialisations uniques disponibles ; jamais de soin comme quatrième option.
Aucun niveau ne donne de soin automatique. Les offres épiques
rendent 30 % des PV max avec le pouvoir choisi.

Les Maîtrises et Héritage réactif donnent des relances. Les choix communs étant
fixes, ils ne consomment pas de relance.

---

# 14. ALAMBIC — MÉCANIQUE CENTRALE

L'Alambic est la mécanique signature du jeu.

Il apparaît exactement :

**avant les salles 5, 10 et 15.**

Donc :

**3 utilisations maximum par chapitre.**

---

# 15. SOIN DE L'ALAMBIC

Lorsqu'un Alambic est utilisé :

**le héros récupère 20 % de ses PV maximum.**

C'est la principale source de soin garantie/native de la structure d'une run.

Cela ne signifie PAS qu'aucun Amélioration, équipement ou Passif ne peut produire du soin.

Exemple :

Régénération reste un Amélioration possible.

---

# 16. FONCTIONNEMENT DE L'ALAMBIC

Lors de chaque utilisation :

1. le joueur récupère 20 % de ses PV max ;
2. l'Alambic génère **un Élément aléatoire** ;
3. le joueur choisit l'un de ses Améliorations ;
4. cet Amélioration fusionne avec l'Élément ;
5. l'Amélioration conserve son effet original ;
6. il gagne en plus une transformation correspondant à l'Élément.

IMPORTANT :

**les Éléments ne sont PAS des Améliorations standards.**

Ils n'apparaissent jamais lors des level-ups.

Ils existent exclusivement via l'Alambic.

---

# 17. PHILOSOPHIE DES ÉLÉMENTS

L'Élément n'a PAS un comportement universel.

Son effet dépend de la famille d'Amélioration avec laquelle il est fusionné.

C'est un point critique.

Exemple :

**Feu × Projectile**

peut provoquer une brûlure.

Mais :

**Feu × Héros**

ne signifie PAS que les attaques du héros brûlent.

Il provoque une transformation du héros de type Phénix.

Ne jamais appliquer automatiquement la propriété offensive d'un Élément lorsqu'il est fusionné avec un Amélioration défensif/Héros.

---

# 18. FAMILLES D'AMÉLIORATIONS

Trois familles principales actuellement retenues :

1. **Projectile**
2. **Héros**
3. **Phénomène**

Les Éléments constituent un système séparé réservé à l'Alambic.

---

# 19. ÉLÉMENT × PROJECTILE

Règle générale :

**le projectile devient vecteur de l'Élément.**

L'Élément ajoute donc sa propriété offensive aux attaques correspondantes.

Les valeurs exactes restent à équilibrer.

---

# 20. ÉLÉMENT × PHÉNOMÈNE

Règle générale :

**le Phénomène devient vecteur de l'Élément.**

Cependant, l'intensité du proc doit dépendre de la fréquence naturelle du Phénomène.

Exemple :

un Familier qui attaque très rapidement peut appliquer fréquemment un petit effet.

Un Météore qui tombe rarement peut provoquer un effet élémentaire beaucoup plus violent.

Objectif :

éviter qu'une mécanique rapide soit automatiquement meilleure qu'une mécanique lente.

---

# 21. ÉLÉMENT × HÉROS

Règle générale :

**l'Élément transforme directement le héros.**

La transformation dépend principalement de l'Élément.

Le système ne doit PAS nécessiter une transformation différente pour chacune des combinaisons :

Égide × Feu
Régénération × Feu
Avidité × Feu
etc.

Si un Amélioration Héros est fusionné avec Feu :

* l'Amélioration Héros original continue de fonctionner ;
* le héros reçoit la transformation Feu.

Cela permet de garder un système compréhensible et raisonnable à produire.

---

# 22. ÉLÉMENTS — LISTE ACTUELLE

Pool actuellement envisagé :

* Feu ;
* Eau ;
* Air ;
* Terre ;
* Lumière ;
* Ténèbres.

**Foudre doit probablement être ajoutée.**

D'autres éléments pourront être ajoutés plus tard.

Le pool final n'est PAS encore verrouillé.

---

# 23. PROPRIÉTÉS OFFENSIVES ACTUELLEMENT ENVISAGÉES

Ces propriétés concernent surtout les fusions :

* Élément × Projectile ;
* Élément × Phénomène.

Elles ne doivent PAS être automatiquement réutilisées pour Élément × Héros.

## Feu

Orientation :

**DoT cumulatif.**

Direction actuelle :

* chaque proc applique une brûlure ;
* durée cible actuellement envisagée : ~4 secondes ;
* plusieurs brûlures peuvent être présentes simultanément ;
* dégâts relatifs à l'ATK.

Valeurs exactes : À ÉQUILIBRER.

## Eau

Orientation :

**contrôle + vulnérabilité.**

Un ennemi Mouillé :

* est ralenti ;
* reçoit davantage de dégâts.

Valeurs : À ÉQUILIBRER.

## Air

Direction actuelle :

* projectiles plus rapides ;
* effet de burst différé.

Une précédente version utilisait un déclenchement de foudre environ 1 seconde après l'attaque, non stackable.

ATTENTION :

comme Foudre doit probablement devenir un Élément indépendant, l'identité finale de l'Air doit être retravaillée.

**À CONCEVOIR.**

## Terre

Direction actuelle :

* projectile plus lent ;
* impact plus puissant.

Mécanique spéciale proposée :

le premier proc Terre sur un ennemi applique un état annulant sa prochaine attaque.

Une seule activation par ennemi.

**À TESTER**, particulièrement sur boss/miniboss.

## Lumière

Direction actuelle :

**sustain / vol de vie.**

Les procs donnent une possibilité de récupérer de la vie.

À équilibrer.

## Ténèbres

Direction actuelle :

**très gros dégâts ponctuels / variance élevée.**

Doit être plus intéressant qu'un simple « critique avec un autre nom ».

À approfondir.

## Foudre

À CONCEVOIR.

---

# 24. TRANSFORMATIONS ÉLÉMENT × HÉROS

Les valeurs suivantes sont des directions de design et non encore des valeurs finales.

## Feu — Phénix

Transformation orientée résurrection répétée.

Piste actuelle :

* environ 3 résurrections par run ;
* retour avec une quantité moyenne de PV.

Exemple cible :

plusieurs secondes chances, mais chacune moins forte qu'une résurrection Eau.

## Eau

Résurrection très qualitative.

Piste :

* 1 résurrection ;
* retour à 100 % PV.

## Air

Piste :

* résurrection à PV moyens ;
* bonus supplémentaire à définir.

À CONCEVOIR.

## Terre

Piste :

* résurrection ;
* forte augmentation de tankyness.

## Lumière

Piste :

* résurrection à PV moyens ;
* apparition d'une auréole ;
* gros buff de statistiques après le retour.

## Ténèbres

Direction différente :

**pas nécessairement de résurrection.**

À la place :

très forte augmentation offensive.

Le joueur échange donc la sécurité contre la puissance.

---

# 25. AMÉLIORATIONS PROJECTILE — POOL ACTUEL

Le pool n'est PAS définitif.

Quelques Améliorations supplémentaires seront probablement ajoutés plus tard.

## Tir multiple

Ajoute un projectile tiré simultanément.

Le gain ne doit PAS doubler gratuitement le DPS.

Chaque projectile doit donc perdre une partie de ses dégâts.

Direction actuelle :

**réduire uniquement les dégâts par projectile**, sans réduire automatiquement la vitesse d'attaque.

Valeur exacte : À ÉQUILIBRER.

## Salve

Ajoute une nouvelle séquence de tir après la première.

Même philosophie :

les dégâts individuels sont réduits afin que le DPS augmente fortement mais ne soit pas multiplié gratuitement par 2.

Valeur : À ÉQUILIBRER.

## Ricochet

Les projectiles peuvent rebondir d'un ennemi vers un autre.

## Perforation

Les projectiles traversent les ennemis.

## Fragmentation

Lorsqu'un projectile touche, il produit plusieurs projectiles secondaires.

## Homing

Les projectiles peuvent suivre/rechercher leurs cibles.

---

# 26. SYNERGIES NATURELLES ENTRE AMÉLIORATIONS

Point très important :

les Améliorations peuvent produire des interactions extrêmement puissantes **sans passer par l'Alambic**.

Exemple :

Perforation + Homing.

Le projectile traverse une cible puis peut continuer à corriger sa trajectoire.

Autre exemple :

Ricochet + Fragmentation.

Les interactions entre projectiles secondaires et trajectoires peuvent produire énormément de dégâts.

Une combinaison du type :

Homing + Perforation + Fragmentation

peut devenir pratiquement autowin contre certaines grosses vagues tout en étant moins dominante contre un boss.

**C'est volontaire.**

Le jeu autorise les builds broken.

Objectif :

le joueur doit parfois avoir le sentiment d'avoir trouvé une combinaison complètement absurde.

L'équilibrage doit empêcher qu'UNE combinaison soit systématiquement la meilleure dans toutes les situations.

Il ne doit PAS empêcher l'existence de power spikes spectaculaires.

La variance entre mains a cependant une limite : une Amélioration de trajectoire comme Homing, Perforation ou Ricochet ne doit pas être presque inutile dès qu'il n'y a qu'une seule cible. Ces cartes peuvent recevoir un petit rendement offensif minimal en plus de leur utilité afin qu'une mauvaise série de tirages reste jouable.

À l'inverse, les multiplicateurs d'impacts — projectiles simultanés, salves et cadence — doivent se payer entre eux. Les combiner doit produire un build clairement excellent, mais pas multiplier gratuitement le DPS par quatre ou six avant même une Fusion élémentaire.

Même règle pour les Éléments : Feu, Eau, Air, Terre, Lumière et Ténèbres gardent des fonctions très différentes, mais aucun Élément ne doit à lui seul ajouter un multiplicateur disproportionné à une main déjà excellente. Ténèbres reste orienté gros procs, Lumière sustain, Terre impact lourd, Air précision/vitesse, etc., avec des rendements globaux du même ordre de grandeur.

---

# 27. AMÉLIORATIONS HÉROS — POOL ACTUEL

## Égide

Annule la première attaque subie de chaque salle.

## Régénération

Soigne le héros entre les salles.

Quantité : À ÉQUILIBRER.

## Avidité

Augmente l'XP et les Gouttes obtenues.

La nature exacte de l'XP concernée doit être vérifiée lors de l'intégration avec les systèmes existants :

**À DÉFINIR précisément entre XP de run / XP permanente / combinaison des deux.**

## Courageux

Augmente les dégâts progressivement lorsque les PV du héros diminuent.

## Mannequin

Augmente les statistiques lorsque le héros reste immobile.

Cet Amélioration doit exploiter le gameplay fondamental :

**immobile = attaque automatique.**

Il récompense les longues fenêtres pendant lesquelles le joueur réussit à DPS sans devoir se déplacer.

---

# 28. AMÉLIORATIONS PHÉNOMÈNE — POOL ACTUEL

## Familier tireur

Invoque un familier à distance.

Il attaque automatiquement les ennemis avec des projectiles.

Exemple de Fusion :

Familier tireur + Élément → les attaques du familier appliquent cet Élément.

## Météores

À intervalles réguliers :

un météore tombe sur un ennemi.

Caractéristiques :

* impact puissant ;
* AoE ;
* fréquence relativement faible.

Les Fusions élémentaires doivent donc pouvoir être plus violentes que sur une source de dégâts rapide.

## Zone autour du héros

Crée une zone de dégâts centrée sur le héros.

Elle encourage à jouer plus proche des ennemis et augmente le risque.

## Familier gardien

Familier orienté corps-à-corps.

Il :

* attaque les ennemis ;
* peut les tanker ;
* possède des PV ;
* peut mourir ;
* revient après un certain délai.

## Orbes chargées

Le héros accumule automatiquement des orbes.

Direction actuelle :

* environ 1 orbe toutes les 2 secondes ;
* maximum d'environ 3 orbes ;
* lorsqu'une attaque est déclenchée, les orbes stockées partent avec elle.

Cela crée naturellement :

**esquive/mouvement → accumulation → arrêt → burst.**

Valeurs exactes : À TESTER.

---

# 29. NOMBRE D'AMÉLIORATIONS

Pool actuel :

### Projectile

6

### Héros

5

### Phénomène

5

Total actuel :

**16 Améliorations standards.**

Ce n'est PAS le pool final.

Quelques Améliorations supplémentaires doivent probablement être ajoutés avant la version finale.

Ne pas en ajouter automatiquement lors de l'implémentation sans nouvelle décision de design.

---

# 30. COFFRE DE RUN

Il existe **un seul coffre par tentative.**

Il évolue selon le dernier palier vaincu.

### Salle 5 vaincue

Mini coffre.

### Salle 10 vaincue

Petit coffre.

### Salle 15 vaincue

Coffre moyen.

### Salle 20 vaincue

Grand coffre.

Exemple :

le joueur atteint la salle 15 mais perd contre le miniboss.

→ coffre conservé = Petit coffre.

Il faut **vaincre** le palier pour améliorer le coffre.

Les quatre coffres ne sont PAS cumulés.

---

# 31. DÉFAITE

Il n'existe aucun checkpoint de reprise.

Mort :

→ fin de la run.

La prochaine tentative recommence depuis le début du chapitre.

Cependant :

les ressources permanentes déjà obtenues ne sont pas perdues.

Le coffre correspondant au meilleur palier vaincu est également conservé.

---

# 32. UX DE FIN DE RUN

La mort doit provoquer très peu de friction.

Séquence cible :

**mort → animation très courte → ouverture du coffre → loot → retour automatique au menu principal.**

Pas d'écran supplémentaire :

* Rejouer ;
* Menu ;
* résumé imposé ;
* statistiques bloquant le joueur.

Une éventuelle page de statistiques facultative pourra être ajoutée plus tard.

Le chemin principal doit rester extrêmement rapide.

---

# 33. RÉSURRECTION

Aucune résurrection native/gratuite universelle.

Pas de :

* pub ;
* monnaie ;
* bouton de seconde chance générique.

Une résurrection peut exister uniquement parce que le joueur l'a obtenue via :

* une Fusion ;
* un équipement ;
* un Passif ;
* une autre mécanique de build.

Elle devient donc un choix de construction et non une commodité extérieure au gameplay.

---

# 34. DROP D'ÉQUIPEMENT

Chaque monde possède son propre ensemble d'équipements.

Structure actuelle :

Les trois bijoux du monde sont reproposés en cycle :

* chapitres 1, 4 et 7 : premier Anneau ;
* chapitres 2 et 5 : second Anneau ;
* chapitres 3 et 6 : Collier.

Les bijoux déjà possédés des mondes retirés restent utilisables.

Les détails exacts de la compatibilité entre les deux slots Anneau restent à confirmer.

---

# 35. PROBABILITÉ DE DROP

Direction actuelle du Grand coffre :

environ **25 % de chance** de drop de l'équipement du chapitre.

Une garantie anti-malchance doit exister.

Direction actuelle :

**équipement garanti après environ 5 victoires complètes sans drop.**

Valeurs finales :

À ÉQUILIBRER.

Les coffres inférieurs peuvent avoir une très faible chance de drop, mais le Grand coffre reste la source principale.

---

# 36. ÉQUIPEMENT

Seulement :

**2 slots Anneau + 1 slot Collier.**

Le jeu ne doit PAS multiplier les emplacements d'équipement inutilement.

Chaque équipement doit proposer :

* un effet significatif ;
* un gameplay différent ;
* une vraie raison de modifier son build.

Éviter les équipements dont la seule identité est :

« celui-ci donne 7 % de stats de plus ».

---

# 37. ANCIENS ÉQUIPEMENTS

Objectif fondamental :

**un équipement intéressant obtenu au Monde 1 doit pouvoir rester jouable plus tard.**

Les nouveaux mondes ne doivent pas simplement rendre tous les anciens effets obsolètes.

Direction actuellement envisagée :

lorsque la progression atteint de nouveaux paliers d'équipement, les anciens objets peuvent recevoir un rattrapage de leurs statistiques de base.

Exemple conceptuel :

Monde 1 :
objet = 50 ATK / 50 PV.

Monde 2 :
nouvel objet = 100 ATK / 100 PV.

Débloquer le palier Monde 2 permettrait également aux objets Monde 1 d'atteindre le nouveau niveau de statistiques de base.

Ainsi :

**la progression détermine les stats brutes ; le choix d'objet détermine l'effet spécial.**

La puissance permanente maximale n'est **pas** la puissance requise pour finir
la campagne. Un joueur habile doit pouvoir vaincre le Monde V avec des Maîtrises,
une Forge, des objets et des capacités encore très incomplets s'il construit une
bonne run. Le farm sert à compenser le manque de skill et à préparer les modes
annexes / post-game.

À l'inverse, un compte totalement optimisé doit être clairement **overkill** en
Campagne. La difficulté destinée à ce profil appartient au Panthéon, au Chaos et
aux futurs paliers de farm, pas au trentième chapitre.

Le rattrapage d'équipement suit le Monde le plus avancé débloqué : un ancien objet
conserve donc son identité spéciale tout en remontant au palier statistique actuel.

---

# 38. FORGE

Les équipements eux-mêmes ne possèdent PAS un système nécessitant des doublons.

Les Pierres de forge améliorent :

**le SLOT.**

Exemple :

Anneau gauche → Forge niveau 8.

N'importe quel anneau placé dans ce slot bénéficie du niveau de Forge correspondant.

Conséquences recherchées :

* aucun investissement perdu en changeant d'équipement ;
* aucun besoin de redropper 15 fois son objet préféré ;
* expérimentation encouragée ;
* progression permanente garantie.

---

# 39. DOUBLONS

**AUCUN DOUBLON OBLIGATOIRE.**

Ne jamais introduire une mécanique nécessitant plusieurs copies identiques pour rendre un objet compétitif.

Si des doublons existent un jour, leur rôle devra être secondaire et non obligatoire.

---

# 40. CAMPAGNE — RÔLE

La Campagne est :

* l'histoire principale ;
* la progression principale ;
* la source d'équipement ;
* une source d'XP ;
* une source de Gouttes ;
* le contenu servant à avancer vers la première vraie fin.

---

# 41. MINE

La Mine est le mode annexe court destiné à **farmer les Pierres de forge**.

Elle se débloque au niveau de campagne 4, après le premier Monde complet.

Structure retenue : une arène de survie de **5 minutes**, alimentée en continu,
puis un boss final. Elle favorise AoE, gestion de foule, déplacement et survie
sous saturation.

Sa difficulté possède un palier pour chacun des 35 niveaux de campagne et suit
le dernier chapitre réellement débloqué. Ses Pierres progressent de x1,12 par
niveau de campagne, soit environ x2,21 par Monde : croissance volontairement
non linéaire sans rendre les premiers paliers insignifiants.

---

# 42. ÉPREUVES RITUELLES

Mode court destiné à obtenir/améliorer Sorts, Passifs et Ultimes.

L'Épreuve se débloque au niveau de campagne 2 et enchaîne **5 miniboss
aléatoires consécutifs**, avec très peu de temps mort. Chaque rencontre prête
une fusion alchimique aléatoire différente afin de varier le build testé.

Chaque miniboss donne un jet de récompense : **20 % de chance d'obtenir ou
d'améliorer une capacité**, soit environ une capacité par Épreuve complète en
moyenne. Un jet raté ne donne que 1–2 Gouttes, afin que ce mode ne remplace pas
la Campagne pour farmer les Maîtrises.

La récompense ne peut provenir que de la pool déjà révélée par la campagne et
une capacité au rang maximal sort de la pool. La difficulté des miniboss suit
elle aussi le dernier niveau de campagne débloqué.

---

# 43. SORTS / PASSIFS / ULTIMES

Loadout : **1 Sort + 1 Passif + 1 Ultime**. Une Maîtrise Utilitaire avancée
ouvre un deuxième slot Passif.

Les capacités ont **10 rangs**. Les actifs et ultimes gagnent +5 % de puissance
par exemplaire après le premier, jusqu'à +45 % au rang 10. Les passifs gagnent
2,5 points de pourcentage par rang, ou un effet entier aux rangs 1/4/7/10.
Les dégâts des actifs et ultimes dépendent de l'attaque du héros, sans le ratio
de projectile de la baguette ni la pénalité de Salve/Tir multiple. Deux augments
rares renforcent leurs dégâts (+25 %) ou réduisent leur récupération (−15 %).
Apothéose, épique possible aux étages 5/10/15, donne +75 % dégâts de sorts et
+25 % de rayon au sort actif. Le farm d'Épreuves sert donc à approfondir les capacités déjà accessibles,
pas à court-circuiter la progression de campagne.

La première boucle de build doit apparaître immédiatement : terminer le niveau
de campagne 1 ouvre le niveau 2 et offre **Onde alchimique rang 1** ; terminer
le niveau 2 ouvre le niveau 3 et offre **Le Grand Œuvre rang 1**. Les capacités
suivantes rejoignent progressivement la pool jusqu'au niveau 29.

Les capacités tardives peuvent être objectivement plus puissantes sur leur
spécialité, mais plusieurs choix précoces doivent rester viables grâce à leur
recharge, leur contrôle, leur fiabilité ou leurs synergies.

Les équipements peuvent également choisir un **type de projectile** sans changer
l'arme du héros. Backend actuel : standard (niveau 1), véloce (4), lourd (7),
chercheur (10) et explosif (13). Le chercheur corrige sa trajectoire ; l'explosif
inflige des dégâts de zone. Leur différenciation graphique est volontairement
reportée.

---

# 44. SORT

Capacité faisant partie régulièrement du combat.

Le fonctionnement exact dépend du Sort.

Il peut être :

* déclenché manuellement ;
* éventuellement semi-automatique/conditionnel selon le design.

L'interface mobile doit rester simple.

Éviter une multitude de boutons.

---

# 45. PASSIF

Capacité constamment active.

Les Passifs doivent pouvoir modifier :

* comportement ;
* statistiques ;
* synergies ;
* survie ;
* économie ;
* interactions avec d'autres systèmes.

---

# 46. ULTIME

L'Ultime doit rester une catégorie à part car il possède une vraie fonction.

Il utilise :

**une jauge.**

Pas simplement un cooldown.

La jauge se recharge pendant le combat.

Objectif actuel :

environ **3 à 4 utilisations sur une run complète.**

Les Ultimes doivent être particulièrement satisfaisants contre les vagues.

Exemple de philosophie :

un Ultime peut quasiment nettoyer un écran de monstres.

En revanche :

**il ne doit pas supprimer gratuitement un boss.**

Sa puissance contre une cible unique doit être sensiblement plus faible ou moins adaptée.

---

# 47. NIVEAU DE COMPTE

Le niveau permanent du compte est différent du niveau de run et du niveau de
campagne. Il ne donne pas de statistiques brutes et ne décide plus des paliers
de Mine, d'Épreuve ou de capacité : ces déblocages suivent directement
l'avancement de l'histoire afin d'être lisibles et impossibles à farmer en rond.

Le niveau de compte reste un indicateur de progression globale et une base
d'extension future pour des récompenses non indispensables à l'équilibrage.

---

# 48. MAÎTRISES

Les Gouttes servent à progresser dans un arbre de Maîtrises permanent.

Courbe cible sans farm volontaire, en ne comptant que les victoires de campagne :

* 50 % de campagne → environ 30 % des premiers rangs ;
* 70 % de campagne → environ 50 % ;
* première fin → environ 80 %.

Un peu de farm permet de rapprocher la Maîtrise du pourcentage de campagne,
mais dépasser nettement cette courbe doit coûter de plus en plus cher grâce aux
rangs supplémentaires. Le coût augmente de 25 % du prix initial par rang,
arrondi à 5 Gouttes ; les nœuds avancés ont un prix initial supérieur.

Trois branches prévues :

### Offensive

Petits bonus offensifs.

### Défensive

Petits bonus défensifs.

### Utilitaire

Confort, mobilité, économie et fonctionnalités.

La majorité des nœuds :

**petits bonus permanents.**

Certains nœuds majeurs :

**très gros déblocages.**

Exemples validés comme direction :

* +1 reroll d'Amélioration ;
* potentiellement deuxième reroll plus tard ;
* deuxième slot Passif.

L'arbre actif est défini dans `data/arbre_competences.gd` ; ses bonus ATK/PV
s'additionnent entre rangs et nœuds. La première fin ne demande pas de le maximiser.

---

# 49. REROLLS

Les level-ups proposent 3 Améliorations aléatoires.

Les Maîtrises permettent progressivement d'obtenir :

* au moins 1 reroll ;
* potentiellement 2 à terme.

Le but est :

**RNG présente mais contrôlable.**

Une mauvaise RNG doit produire un build différent, pas nécessairement une run morte.

---

# 50. PHILOSOPHIE DE RNG

Le joueur ne doit pas pouvoir garantir exactement le même build à chaque run.

Cependant :

la RNG ne doit pas produire régulièrement des choix complètement inutiles.

Objectif :

**RNG d'opportunité, pas RNG punitive.**

Le theorycraft consiste en partie à construire quelque chose de puissant avec ce que la run propose.

---

# 51. FIN DU JEU

Première vraie fin :

**terminer la campagne des 5 mondes.**

Le joueur doit pouvoir se dire :

« J'ai terminé le jeu. »

Le jeu n'a PAS vocation à retenir artificiellement le joueur pour toujours.

---

# 52. POST-GAME

Non prioritaire actuellement.

Ne pas consacrer du temps important à cette partie tant que la campagne n'est pas bonne.

## Panthéon

Contenu de maîtrise autour des boss des 5 mondes.

Possiblement boss rush.

Format exact :

À CONCEVOIR.

## Chaos / Monde infini

Mode permettant de continuer quasiment indéfiniment.

Concept :

mélanger aléatoirement des éléments déjà produits :

* monstres de différents mondes ;
* mécaniques environnementales ;
* miniboss ;
* compositions ;
* scaling très élevé.

Le mode peut devenir volontairement extrêmement difficile.

À très haut niveau :

**l'équilibrage parfait n'est plus une obligation.**

Le joueur continue essentiellement pour :

* optimiser ;
* tester des builds broken ;
* pousser toujours plus loin.

---

# 53. CONTRÔLES

Le système fondamental reste :

**le personnage se déplace → il n'attaque pas.**

**le personnage est immobile → attaque automatique.**

Cela ne doit pas être supprimé.

Deux méthodes de déplacement doivent éventuellement être comparées :

### Option A

Joystick flottant type Archero.

### Option B

Tap-to-walk / déplacement tactile plus direct.

Aucune décision définitive.

**NE PAS modifier le système de contrôles actuel pendant une refonte d'équilibrage sans demande explicite.**

Le changement éventuel doit être prototypé séparément.

---

# 54. PRINCIPES DE DESIGN NON NÉGOCIABLES

1. Le jeu reste un jeu d'esquive.

2. Le skill permet d'avancer plus rapidement.

3. Le farm permet de compenser une partie du manque de skill.

4. Le farm ne doit pas rendre totalement inutile l'esquive.

5. Une tentative ratée doit quand même produire de la progression.

6. Aucun système quotidien obligatoire.

7. Aucun système d'énergie.

8. Aucun FOMO.

9. Aucun doublon d'équipement obligatoire.

10. Changer d'équipement ne doit pas détruire les investissements permanents.

11. Les Améliorations doivent principalement modifier le gameplay.

12. Les builds extrêmement puissants sont autorisés.

13. Toutes les combinaisons n'ont pas besoin d'avoir exactement le même DPS.

14. Aucune combinaison unique ne doit dominer systématiquement toutes les autres situations.

15. L'Alambic doit provoquer une vraie montée en puissance.

16. Les Fusions élémentaires doivent être immédiatement perceptibles.

17. Un Élément n'a pas la même fonction selon qu'il est fusionné avec Projectile, Phénomène ou Héros.

18. Les 6 Améliorations d'une run doivent produire des décisions importantes plutôt qu'une accumulation de petits bonus.

19. Après le dernier Alambic, le joueur doit avoir suffisamment de temps pour profiter de son build final.

20. Un joueur puissant doit terminer les anciens chapitres beaucoup plus rapidement.

21. Ne jamais ajouter artificiellement de l'attente pour normaliser la durée d'un chapitre.

22. Les transitions doivent être extrêmement rapides.

23. La mort doit permettre un retour rapide au gameplay.

24. Le jeu doit posséder une vraie fin.

25. Le post-game est facultatif.

---

# 55. DÉCISIONS ACTUELLEMENT VERROUILLÉES

À considérer comme la direction actuelle de référence :

* jeu existant à modifier, pas à recréer ;
* 5 mondes ;
* 7 chapitres par monde ;
* 35 chapitres ;
* 20 salles par chapitre ;
* rencontres principalement fixes avec quelques variantes ;
* combats à vagues ;
* vague suivante immédiate si clean rapide ;
* miniboss aux paliers 5/10/15 ;
* salle 20 = final du chapitre ;
* boss signature uniquement au chapitre 7 ;
* 5 boss signature ;
* mécanique environnementale par monde ;
* environ 4/5/6 types de monstres sur les chapitres 1/2/7 ;
* 6 Améliorations maximum par run ;
* choix entre 3 Améliorations ;
* dix niveaux, quatre rares garantis et trois offres épiques aux étages 5/10/15 ;
* 3 Alambics ;
* Alambics avant 5/10/15 ;
* Alambic soigne 20 % PV max ;
* Alambic fournit un Élément aléatoire ;
* Élément fusionné à un Amélioration choisi ;
* Élément exclu des level-ups ;
* familles Projectile / Héros / Phénomène ;
* Élément × Projectile = propriété offensive sur projectile ;
* Élément × Phénomène = propriété adaptée au phénomène ;
* Élément × Héros = transformation du héros ;
* coffre unique évolutif ;
* coffre amélioré uniquement si le palier est vaincu ;
* aucun checkpoint ;
* mort → coffre → menu rapidement ;
* 2 anneaux + 1 collier ;
* aucun doublon obligatoire ;
* Forge appliquée aux slots ;
* Campagne = équipements/progression principale ;
* Mine = énorme vague / Pierres de forge ;
* Épreuves rituelles = 5 miniboss / capacités ;

Chaque combat d'Épreuve commence avec une Amélioration aléatoire nouvelle et
un Élément d'Alambic aléatoire, ajoutés automatiquement sous forme originale et
fusionnée. Aucun choix d'Amélioration ou d'Élément n'interrompt l'Épreuve ; la
récompense de capacité permanente reste accordée après le miniboss.
* 1 Sort ;
* 1 Passif ;
* 1 Ultime ;
* deuxième Passif via Maîtrise ;
* Ultime à jauge ;
* environ 3–4 Ultimes par run ;
* Maîtrises Offensive / Défensive / Utilitaire ;
* niveau de compte principalement utilisé pour débloquer les niveaux supérieurs des contenus annexes ;
* aucune énergie/daily/FOMO ;
* cosmétique payant uniquement si monétisation future.

---

# 56. POINTS À NE PAS INVENTER

Les systèmes suivants ne sont PAS encore suffisamment décidés.

Codex ne doit pas prendre de décisions de game design définitives à leur sujet sans nouvelle instruction :

* chiffres de dégâts ;
* PV ;
* vitesse ;
* timers ;
* scaling précis ;
* nombre final d'Améliorations ;
* nouveaux Améliorations ;
* nombre final d'Éléments ;
* mécanique finale de Foudre ;
* identité finale de l'Air ;
* valeurs exactes des effets élémentaires ;
* détails des transformations Héros ;
* arbre complet de Maîtrises ;
* économie exacte ;
* coûts de Forge ;
* vitesse de progression ;
* pool final d'équipement ;
* effets des équipements ;
* fonctionnement exact du rattrapage des anciens équipements ;
* patterns ennemis ;
* compositions finales des salles ;
* miniboss ;
* boss ;
* mécaniques des 5 mondes ;
* contrôle Joystick vs Tap-to-walk ;
* Panthéon ;
* Chaos.

Lorsqu'une valeur est nécessaire techniquement pour tester :

utiliser une constante/configuration facilement modifiable et signaler explicitement qu'elle est provisoire.

---

# 57. MÉTHODE DE MODIFICATION DU PROJET

Ne PAS appliquer tout ce document en un énorme patch.

Procéder par lots indépendants.

Ordre conseillé :

## Étape 1 — Audit

Inspecter le projet existant.

Produire :

* architecture actuelle ;
* systèmes déjà présents ;
* structure actuelle des chapitres ;
* level-up actuel ;
* Améliorations existants ;
* ennemis existants ;
* progression actuelle ;
* économie actuelle ;
* équipement actuel ;
* différence entre l'état actuel et cette spécification.

**Ne modifier aucun fichier pendant cet audit.**

## Étape 2 — Structure de run

Adapter progressivement :

* 20 salles ;
* vagues ;
* paliers ;
* 6 niveaux ;
* courbe XP ;
* 3 Alambics ;
* coffre évolutif.

Tester avant de continuer.

## Étape 3 — Améliorations

Mapper les Améliorations existants.

Conserver/réutiliser ce qui peut correspondre.

Ajouter ou modifier uniquement ce qui manque.

## Étape 4 — Alambic / Éléments

Implémenter le système élémentaire comme système séparé.

Éviter une architecture hardcodée impossible à étendre.

Chaque Amélioration doit exposer suffisamment d'informations pour pouvoir recevoir une transformation élémentaire.

## Étape 5 — Progression permanente

Adapter :

* niveau de compte ;
* Gouttes ;
* Maîtrises ;
* Forge par slot ;
* équipement ;
* drops ;
* pity.

## Étape 6 — Modes annexes

Mine puis Épreuves rituelles.

## Étape 7 — Bestiaire

Reprendre les monstres **un par un**.

Pour chaque ennemi :

* rôle ;
* pattern ;
* télégraphe ;
* vitesse ;
* menace ;
* faiblesse ;
* interaction avec les autres ennemis.

## Étape 8 — Boss

Créer/adapter les 5 boss signature lorsque le combat normal et le bestiaire sont suffisamment solides.

---

# 58. OBJECTIF FINAL POUR LE CODE

L'objectif n'est pas simplement que le jeu respecte mécaniquement cette liste.

Le résultat doit donner l'impression suivante :

**je lance une run rapidement → je combats immédiatement → je commence à construire un build → l'Alambic transforme ce build → mes synergies deviennent progressivement absurdes → je profite réellement de cette puissance → même si je meurs j'ai gagné quelque chose → je peux immédiatement décider de retenter ou d'améliorer mon compte.**

Le projet existant doit évoluer vers cette boucle progressivement.

**Préserver le jeu existant partout où cela reste compatible avec cette vision.**
