# Atelier vivant — direction visuelle

## Décisions du propriétaire — 13 septembre 2026

- La piste A, « Atelier vivant », est retenue pour l'accueil et la direction globale : fantasy alchimique chaleureuse, pierre crème, cuivre, violet et turquoise, en cohérence avec le héros 3D accepté.
- Les propositions de mondes distincts par les couleurs, les matériaux et les formes sont acceptées dans leur principe.
- Le premier monde doit donner envie de jouer. Le traitement grisâtre ne convient pas à cette première découverte ; il peut être conservé pour un monde ultérieur, dont la place reste à déterminer.
- Le héros et les monstres plaisent au propriétaire. La présente étape porte sur les environnements et les menus.

Ces décisions actualisent la direction proposée ; elles ne décrivent pas encore le rendu intégré. L'ancienne référence pixel art de `human/11_DIRECTION_ARTISTIQUE.txt` ne doit pas conduire à remplacer les personnages 3D validés.

## Maquettes acceptées et intégration autorisée

Le propriétaire a demandé « Fait tout ça ». Les deux planches acceptées déclinent Atelier vivant : équipement, maîtrises et sorts ; puis améliorations, pause, paramètres et premier monde revisité.

- Interface : panneaux ivoire, texte encre violette, cuivre discret, actions principales turquoise, fonds d'atelier plus détaillés sur les bords que derrière les informations.
- Équipement : cinq armes, trois emplacements Anneau/Collier/Bague, collection de bijoux, détails et actions distinctes d'équipement et de Forge.
- Maîtrises : trois branches Offensive/Défensive/Utilitaire, rangs et états lisibles, détail du choix et coût avant achat. Les connexions exactes doivent suivre le catalogue.
- Sorts : emplacements Actif/Passif I/Passif II/Ultime, catégories et états équipé/verrouillé explicites, description et recharge provenant des données.
- Améliorations : trois grandes cartes superposées, icône distincte, effet et contrepartie lisibles, carte entière tactile, nouveau tirage secondaire.
- Pause : priorité à Reprendre, puis améliorations de la run, paramètres et sortie.
- Paramètres : sections Audio et Confort, commandes tactiles larges ; progression séparée des réglages fréquents.
- Premier monde proposé : Encres, « Cour des alchimistes » comme appellation de travail. Grandes dalles de calcaire crème chaud, céramique turquoise, cuivre, arche évoquant un livre et végétation surtout en périphérie. Sol central calme, obstacles bas et limites lisibles.

Les textes, statistiques, inventaires, prix, connexions, HUD et états des images générées sont illustratifs. Ils ne constituent ni de nouvelles règles de gameplay ni une validation des modifications de navigation. En particulier, ne pas réintroduire les PV chiffrés du HUD sur la seule base de la maquette.

## Périmètre de l’intégration

- Décliner les composants communs dans les écrans Godot et produire les assets nécessaires ; une planche conceptuelle ne remplace pas ces composants.
- Adapter également les écrans connexes : sélection de campagne et modes, détails/Forge, inventaire des améliorations, halte et bilan de run.
- Remplacer le cadrage fixe avec bandes par un affichage adaptatif, en contrôlant la caméra, les limites du terrain, les ancrages et les zones sûres Android. Le correctif est intégré ; sa validation sur le Pixel physique reste à faire.
- Conserver la logique de campagne actuelle en réservant le traitement gris/prune au monde Ombres. Un traitement accueillant d'Encres n'impose pas de réordonner la progression.
- Vérifier le rendu sur plusieurs ratios puis sur téléphone, avec lisibilité et performances mesurées. Exécuter les vérifications du dépôt après toute modification de code ou de données.

L’intégration est décrite et mesurée dans `docs/ops/ATELIER_VIVANT.md`. Les maquettes servent de direction ; les décors intégrés utilisent une géométrie simplifiée pour le mobile.
