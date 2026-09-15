# Bijoux : un pouvoir au niveau 10 — 16 septembre 2026

Cette règle remplace les trois pouvoirs aux niveaux 10/20/30.
Chaque bijou augmente les dégâts et les PV. **Un seul effet spécial se débloque
au niveau 10** ; au-delà, seuls les bonus de statistiques progressent.

## Statistiques et forge

Budget de base par emplacement : anneau 75 points de pourcentage, bague 65,
collier 70. Les mondes changent la répartition dégâts/PV et le pouvoir proposé,
avec un budget total constant. Aucun bonus lié au monde atteint par le compte.
Premier anneau : +50 % dégâts, +25 % PV. Aucun bonus de cadence, même via l’effet.

Chaque niveau de forge multiplie les bonus par **1,0816**. Coût du prochain achat
à partir du niveau `n` : `arrondi(8 × 1,12^min(n,10) × 1,18^max(n−10,0))`.
Plafond technique actuel : **100**, largement au-delà du pouvoir de niveau 10.
La fiche affiche le bonus actuel, celui du prochain niveau et le pouvoir unique.

Les anciens niveaux de forge version 1 restent convertis en version 2 par
`arrondi_supérieur(n/2)` : 20 → 10, 60 → 30. Cette conversion antérieure conserve
la puissance de forge investie ; elle n’est pas répétée sur les comptes version 2.
Le coût futur suit désormais la nouvelle formule exponentielle.

## Combat et présentation

Les pouvoirs vivent dans `data/effets_bijoux.gd` et utilisent les effets de combat
existants. Ils sont actifs seulement sur un objet équipé dans un slot compatible.
Un même pouvoir n’est pas dupliqué ; il ne consomme aucun choix de run et n’est
pas proposé inutilement au draft. Les effets des objets ne polluent pas l’héritage.

Les aperçus « ! » affichent l’illustration et la probabilité issues de l’offre
réelle. Toucher un objet montre son image, ses bonus à l’obtention et au niveau 10,
et la description de son pouvoir. Les sorts ont eux aussi une fiche illustrée.

`tests/test_effets_bijoux.gd` couvre les trente objets aux niveaux 0 à 100,
les slots, le draft et les migrations. `sondes/effets_bijoux.gd` vérifie leurs
pouvoirs dans une vraie scène de combat et leurs fiches sur trois formats d’écran.
