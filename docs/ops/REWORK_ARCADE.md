# Reprise arcade — 13 septembre 2026

Direction demandée : conserver les personnages toon et la grammaire déplacement / arrêt / tir, abandonner les fusions élémentaires expérimentales, rendre les coups importants et les choix lisibles. Les mécaniques générales d’[Archero présentées par Habby](https://www.habby.com/game/detail/archero) servent de référence de genre. Les chiffres ci-dessous sont propres à Alambik, sans prétendre reproduire une formule interne d’Archero.

## Version jouable

- Héros à 78 % de sa taille précédente ; collision circulaire de rayon 20. Le contact des poursuivants et chargeurs utilise les rayons réels des deux corps. Un segment de collision complète l’Area2D des projectiles rapides pour éviter de traverser une cible entre deux positions physiques.
- 100 PV sans équipement, dégâts de campagne d’au moins 15 par coup ou projectile. Sept coups de référence tuent sans protection. Les défenses et la progression peuvent augmenter cette endurance.
- Soins de combat cumulés limités à 5 % des PV maximum par salle. Régénération et Moisson rendent 2 %. Seconde chance fonctionne une seule fois par run, pour 30 % des PV multipliés par son rang d’efficacité. Le bouclier ne se recrée plus à chaque recalcul d’augmentation.
- Haltes existantes après les salles 4, 9 et 14 : soin garanti de 50 % des PV maximum, sans multiplicateur de soin ; choix gratuit orienté projectiles et phénomènes visibles. Le soin ne dépasse jamais les PV maximum. Le système de fusion reste hors de la boucle active, y compris en Épreuves. Ses anciens catalogues restent disponibles pour compatibilité et historique.
- Deux vagues par salle ordinaire. Six seuils d’XP : 10, 26, 55, 80, 145, 220. Sans bonus d’XP, deux choix avant le boss 5, quatre avant le 10, cinq avant le 15, six avant le 20, auxquels s’ajoutent les choix de halte.
- Poursuivant au corps à corps ; sentinelle à visée annoncée de 0,65 s ; sentinelles, harceleurs et chargeurs verrouillent leur cible ou direction avant de tirer. Les préparations des harceleurs et miroirs passent par les ticks du jeu : aucune attaque ne termine sa préparation pendant la pause de visée.
- Cinq armes dans Équipement, sans niveaux d’arme ni bonus permanent. Baguette équilibrée et sceptre lourd disponibles dès le premier chapitre ; aiguille rapide au 2, branche chercheuse au 3, bâton explosif au 4. Le lourd échange dégâts ×1,50 contre cadence ×0,70 ; le rapide échange dégâts ×0,75 contre cadence ×1,35. Couleurs et proportions des traits distinctes.
- Sorts actifs : cliquer ouvre une visée avec pause complète ; toucher le terrain puis confirmer lance la zone ciblée. Annuler est gratuit et libère les anciennes commandes. Recharge en 24 à 42 impacts, avec au plus une charge toutes les 0,18 s pour éviter le remplissage instantané par une salve. Aucun sort de soin.
- Ultimes manuels : charge par éliminations, quatre utilisations maximum par run, compteur visible. Les passifs de réserve gardent un intérêt sans contourner ce maximum.
- Accueil : vrai Apprenti A en 3D animé, socle, éclairage et boutons natifs ; ancienne illustration humaine retirée de cet écran. L’icône approuvée reste inchangée.
- Trois gouttes par salle vaincue, avant bonus de chapitre, en plus du coffre éventuel. Une défaite au boss 5 donne donc 12 gouttes et finance Force (8). Dix rangs de maîtrise ; les trois premiers conservent leur valeur unitaire, puis rendement réduit afin de conserver le budget maximal des branches. Coûts par rang ×1,35. Le niveau de compte commence à 10 XP puis suit une courbe quadratique : démarrage rapide, derniers niveaux plus longs.

## Mesures et limites

- `tools/verifier_windows.ps1` : 34 suites, 14 324 assertions, aucun échec ; compilation complète et cohérence des données réussies.
- `sondes/rework_combat.gd` : contrôle du rayon, du verrouillage, de la pause, du retour écran/terrain, de l’annulation, de la recharge et des quatre ultimes. Écart de projection mesuré inférieur à 0,5 pixel logique.
- `sondes/choix_et_endurance.gd` : 15 assertions ; boss de référence à 33,27 s, 40,90 s et 37,10 s sur cible fixe, sans attaques adverses. Ce banc mesure le DPS, pas la durée garantie d’un combat réel.
- Dernière campagne automatique : 20 fins de run, aucun blocage ni erreur de script ; 18 défaites au premier boss, une avant et une après l’avoir passé. Le bot teste les enchaînements mais cette mesure ne valide ni le confort humain ni les chapitres 2–30. La difficulté reste exigeante et doit être confrontée aux essais tactiles.
- Contrôle du menu : quatre assertions et capture du vrai rendu OpenGL. La performance Android, les nouveaux modèles d’armes tenus en main, les skins et un futur système d’alambic ne sont pas validés/implémentés par cette passe.

Les anciens protocoles de fusion décrivent une expérience abandonnée ; ils ne sont plus des tests d’acceptation du jeu actuel. Les avertissements de libération RID/ObjectDB des sondes à fermeture forcée restent visibles dans les journaux.
