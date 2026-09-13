# Fusions expérimentales — 12 septembre 2026

> Expérience abandonnée le 13 septembre 2026 à la demande du propriétaire. Ce document est historique ; voir [la reprise arcade](REWORK_ARCADE.md) pour le jeu actuel.

Première version jouable autorisée par le propriétaire : expérimenter des runs différentes, découvrir des interactions et orienter la suite à partir des essais. Cette version ne prétend pas figer l'équilibrage de toute la campagne.

## Essayer

`tools/essayer_fusions.ps1` ouvre directement le premier Alambic avec trois augmentations tirées au hasard, puis laisse jouer la suite normalement. Profil séparé dans `tmp/essai-fusions/`, sans accès à la progression réelle. `-Graine 2` change les propositions ; `-DepuisDebut` commence une vraie run sans dotation. La dotation du raccourci sert aux essais et n'est pas une mesure de progression débutante.

Les Alambics de campagne et de Mine utilisent les nouvelles recettes. Les Épreuves rituelles conservent pour cette première expérimentation leur génération élémentaire précédente. Les anciens identifiants et effets restent compatibles ; aucune sauvegarde permanente n'est migrée ni effacée.

## Choisir et découvrir

- Une montée de niveau propose des familles différentes tant que le pool le permet ; le tirage reste aléatoire et reproductible par graine.
- L'Alambic propose jusqu'à trois recettes différentes compatibles avec les augmentations possédées. Le soin de 20 % reste inchangé.
- L'augmentation de départ reste active. Une seule transformation par support, et une même recette ne s'empile pas.
- Si une fusion Feu ou Eau est acquise, la première proposition favorise une recette de l'autre élément lorsqu'elle est disponible. Les autres propositions restent libres.
- Les explications figurent sur les cartes ; l'inventaire de pause conserve les recettes acquises.
- Les fusions se réinitialisent avec la run. Marques, charges et actions différées sont vidées entre les salles, et les délais sont suspendus pendant les panneaux.

## Dix recettes

| Famille du support | Recette | Comportement |
|---|---|---|
| Projectile | Braises en chaîne | Trois impacts préparent une explosion différée. Une cible amorcée qui meurt libère aussi sa braise. |
| Projectile | Perles de rupture | Tous les quatre impacts, éclatement de zone qui mouille. Recharge pour éviter les déclenchements démesurés des salves. |
| Projectile | Retour de souffle | Trois lancers produisent deux projectiles guidés supplémentaires. Ils peuvent alimenter les braises et perles d'autres fusions. |
| Héros | Pas de rosée | Le déplacement charge au plus trois projectiles d'eau, libérés au prochain lancer. |
| Héros | Souffle de secours | Un dégât reçu ou une Égide cassée déclenche une poussée et dissipe les projectiles proches. Recharge de six secondes. Les boss ne sont pas repoussés. |
| Héros | Cœur de fournaise | Quatre lancers sans repartir en course déclenchent une flamme sous la cible ; bouger remet le compteur à zéro. |
| Phénomène | Jardin de failles | Une zone annoncée germe sous un ennemi puis explose. Le ralentissement de l'Eau facilite la touche. |
| Phénomène | Constellation liquide | Un courant relie trois ennemis distincts, les blesse et les mouille. |
| Sceau | Cercle de distillation | L'aura amorce les ennemis proches avec des braises, sans leur infliger de dégâts directs à chaque pulsation. |
| Sceau | Réserve lumineuse | Toutes les quatre éliminations : soin de 3 % ; à pleine vie, réserve offensive pour le prochain lancer, plafonnée à deux charges. |

Les valeurs exécutées sont dans `data/catalogue_recettes.gd`. Le module `scripts/ameliorations/atelier_fusions.gd` gère les événements ; l'écran ne porte aucune logique de combat. Les dégâts supplémentaires utilisent les statistiques de base du héros afin de ne pas multiplier à nouveau les gains de tirs multiples.

## Réactions et limites

Feu + Eau, dans les deux ordres : explosion de vapeur. Elle consomme les marques, ne réapplique aucun élément et dispose d'une recharge par cible. Il ne peut donc pas y avoir de boucle instantanée auto-entretenue. Les marques expirent et leur nombre est plafonné.

Les zones et les chaînes respectent les obstacles. La poussée vérifie le trajet et les limites de salle. Les effets visuels passent par le rendu d'effets existant, compatible avec la 3D ; pas de nouveaux modèles lourds.

Cette première sélection offre dix comportements partagés par les familles, pas une recette unique pour chacune des 180 associations théoriques. Elle sert à identifier les interactions plaisantes avant de développer des transformations propres à certaines augmentations. Les modèles du héros et les chiffres de progression permanente sont conservés.

## Ce qu'il faut observer en jouant

- Est-ce qu'une fusion se ressent dès la salle suivante ?
- Est-ce que charger en courant puis lancer est agréable ?
- Est-ce que la vapeur se comprend sans lire un guide ?
- Le choix d'une recette fait-il hésiter, ou existe-t-il une réponse systématique ?
- Les cercles et réactions laissent-ils les attaques ennemies lisibles ?
- Le premier boss demande-t-il une décision intéressante ou simplement trop d'esquives ?

La difficulté du premier boss reste un point à éprouver : l'endurance de 30–45 secondes ne suffit pas à elle seule à garantir un bon combat débutant.

## Vérifications

Tests de catalogue : supports valides, familles couvertes, non-cumul, propositions distinctes, piste de réaction et compatibilité des anciens identifiants.

`sondes/fusions_experimentales.gd` exerce les dix recettes, l'ordre des éléments, le plafond de réaction, la mort d'une cible amorcée, les impacts réels de projectile, l'acquisition, la pause et le nettoyage des salles. Option `--capture` : rendu de l'Alambic en portrait et validation de l'acquisition via le panneau. Logs dans `tmp/fusions-experimentales.log` et `tmp/fusions-capture.log` ; capture `tmp/alambic-recettes.png`.

Résultats finaux : 33 suites / 16 886 assertions sans échec et selftest valide. Sonde de combat : 30 assertions sans échec. Le contrôle graphique précédent a aussi validé l'acquisition par le panneau. Les avertissements de libération de ressources au nettoyage du moteur persistent.

Vingt runs finales : aucune erreur de script, 19 fins sans blocage et un blocage du bot graine 3 en salle 2, avec un ennemi à 1 PV derrière les obstacles, avant le premier Alambic. Aucune victoire de campagne ; la plupart des bots meurent au premier boss et les meilleurs atteignent la salle 10. Ne pas présenter ces résultats comme un équilibre global validé. Log : `tmp/fusions-vingt-runs-final.log`. Un premier essai avait révélé une erreur de tableau typé dans les dégâts de zone ; elle a été corrigée et la sonde couvre désormais chaque recette. Aucun APK exporté.
