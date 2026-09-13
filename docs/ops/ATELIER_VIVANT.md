# Atelier vivant — intégration du 13 septembre 2026

## Contrôle des paramètres en jeu — v3

Les listes déroulantes conservaient l'ancien style sombre alors que leurs
boutons étaient déjà habillés en Atelier. Les trois listes (musique en jeu,
musique du menu et raccourci du sort) utilisent désormais parchemin, texte encre,
sélection turquoise et indicateurs cohérents. Leur hauteur maximale tient compte
des marges de l'écran ; les intitulés longs ne forcent plus la largeur du bouton.
Curseurs de volume : rail fin et poignée cuivre/turquoise originale. Les options
acceptent les retours à la ligne ; le panneau développeur se déplie sous son titre.

Contrôles headless : 14 397 assertions générales, 38 contrôles fonctionnels dont
ouverture des trois listes pendant la pause, choix de chaque musique et du
raccourci, volumes indépendants et retour à la pause sans reprise du combat.
840 contrôles de disposition et 1 774 contrôles sur six formats sans échec.
Vingt simulations terminées sans blocage ni erreur de script. Les diagnostics
de ressources non libérées à la sortie du harnais général persistent.
Aucune fenêtre visible ni nouvelle capture graphique ; rendu Pixel à confirmer.
APK exportée : `build/alambic-menus-atelier-v3.apk`.

## Reprise des menus — planche de référence du propriétaire

La première intégration était trop plate et éloignée de la planche fournie.
Cette passe remplace les grands aplats par des cadres à neuf tranches : papier
dégradé, double filet, coins gravés et reflets cuivre. Le fond d'atelier reste
visible autour des panneaux, avec un voile violet discret. Cinzel est embarquée
pour les titres (licence SIL OFL conservée) ; DM Sans assure les descriptions.

- Équipement : cases violettes, bijoux agrandis, fiche illustrée fixe au-dessus
  des actions, cinq nouvelles illustrations d'armes originales.
- Maîtrises : médaillons reliés sur parchemin, cadenas illustrés et fiche de
  sélection. Les trente nœuds et leurs règles d'achat restent accessibles.
- Sorts : quatre cases illustrées, catégories violettes, cartes avec nom,
  description et état équipé séparés ; hauteur adaptée au contenu.
- Le cadre commun s'applique aussi aux améliorations, à la pause, aux réglages,
  aux modes, aux haltes et aux récompenses. La navigation reçoit le même relief.
- Accueil : suppression du masque rectangulaire crème au profit d'un cartouche ;
  compteurs élargis, textes sur une ligne avec ellipse si nécessaire, icône de
  paramètres SVG au lieu d'un caractère pouvant manquer dans la police.

Sources principales : `scripts/presentation/cadres_atelier.gd`,
`scripts/presentation/style_azur.gd`, `ui/equipement.gd`,
`ui/arbre_competences.gd`, `ui/sorts.gd`, `ui/accueil_3d.gd`.
Provenance des images et de la police : `assets/visual/atelier/ORIGINE.md`.

Contrôles effectués sans aucune fenêtre visible : 34 suites / 14 397 assertions,
1 774 contrôles de formats et navigation sur six formats, 19 contrôles des
actions réelles, 844 contrôles des hauteurs et largeurs des textes et boutons.
Les sondes de formats et d'interface fonctionnent désormais aussi en headless,
sans demander de capture ni attendre une image du moteur. Le contrôle de
disposition ne valide pas le rendu graphique final sur téléphone ; aucune
nouvelle capture Godot n'est présentée comme vérification visuelle de cette passe.
Les diagnostics de ressources non libérées à la fermeture du harnais général
persistent, sans erreur de script ni assertion en échec.

Vingt simulations terminées sans blocage ni erreur de script : défaites entre
les salles 4 et 6, zéro échec technique. Export et vérification Android réussis.
APK : `build/alambic-menus-atelier-v2.apk`.

## Résultat

La direction A approuvée est intégrée dans les écrans natifs Godot : fond d'atelier original, héros 3D animé au premier plan, palette ivoire/cuivre/violet/turquoise, coins arrondis, titres renforcés et navigation dessinée avec des icônes SVG originales. Le modèle et les animations du héros restent ceux déjà validés.

Le style commun couvre équipement et Forge, maîtrises, sorts, améliorations, pause, paramètres, campagne et modes, halte, inventaire des améliorations et bilan. Les armes occupent un sélecteur compact ; les sorts ont quatre emplacements et des catégories sélectionnées explicitement. Les paramètres utilisent des interrupteurs, les deux volumes indépendants et une section de progression repliable. Les données affichées viennent toujours des catalogues et de la sauvegarde.

Les dix décors sont décrits dans `data/decors_mondes.gd`. Le premier monde reste Encres : pierre crème texturée, céramique turquoise, végétation périphérique et entrée en arche. Les autres mondes combinent cinq motifs de dallage et cinq familles d'ornements, avec des palettes propres. Le traitement gris/prune est utilisé plus tard pour Ombres. Les collisions et l'ordre de campagne sont conservés. Les salles ont une géométrie plus simple que les illustrations conceptuelles ; celles-ci ne sont pas des captures ni des assets de salle directement utilisables.

Les petits maillages procéduraux immobiles sont regroupés par matériau à la construction. Le sol conserve son matériau dédié et son contour issu des collisions. Le regroupement ignore les anciens objets en attente de suppression lors d'un changement de salle.

## Affichage mobile

`canvas_items` + `expand` remplace le cadre fixe avec bandes. Le décor remplit l'écran, les proportions sont préservées, les boutons respectent les marges calculées par `Ecran`. L'accueil conserve une composition centrale sur les formats larges. La caméra centre un axe lorsque l'écran montre plus que la salle, au lieu de borner sa position avec des limites inversées.

Les mesures de zone sûre comprennent maintenant un écran logique 1080 × 2400 avec encoche et zone de gestes. Aucun Pixel physique n'était connecté par ADB pendant cette intervention : confort tactile, découpe réelle de l'écran, chauffe et performances Android restent à valider sur l'appareil.

## Vérifications finales

Toutes les sondes utilisent le profil de test isolé de `tools/verifier_windows.ps1`, ou désactivent la sauvegarde avant leurs fixtures. La progression réelle du propriétaire n'a pas été utilisée pour les captures.

- `./verifier.sh` via le wrapper Windows : **34 suites, 14 397 assertions, zéro échec** ; selftest de compilation et cohérence réussi.
- `./sondes/vingt_runs.sh` via le wrapper : **20 fins de run, zéro blocage et zéro erreur de script**. Le bot perd les vingt runs : 18 fins en salle 5, une en salle 6, une en salle 8. Durées de 39 s à 1 min 39 s. Cela valide la terminaison, pas la difficulté pour un humain.
- `sondes/formats_mobile.gd` : **1 775 contrôles, zéro échec**, formats 540 × 960, 540 × 1200, 540 × 1320, 480 × 800, 768 × 1024 et 960 × 540. Vérification du remplissage physique sans bandes, proportions, boutons visibles et absence de recouvrement de navigation.
- `sondes/interface_azur.gd` : **19 contrôles, zéro échec** : équipement, coût de Forge, achat de maîtrise explicite, mode mémorisé, reroll épuisé, double appui, volume, héros animé et navigation fixe. La sonde a été actualisée pour tester le héros 3D actuel au lieu de l'ancien shader d'accueil.
- `sondes/integration_3d.gd` : **zéro échec**, projections, animations, portail, nettoyage et mode réduit. Scène mesurée : **114 appels de dessin, 46 202 primitives** sur RTX 4070 SUPER. La première version non regroupée mesurait 232 appels ; ce n'est pas une mesure de performances sur téléphone.
- `sondes/atelier_vivant.gd` : captures des menus et rendu des dix profils sans erreur de script ou de shader.
- APK debug exportée et signature vérifiée : `build/alambic-atelier-vivant.apk` (129 260 748 octets lors de cet export). Le SDK installé a utilisé ses build-tools 35.0.1 en repli ; l'export et sa vérification ont abouti.

Godot signale encore des ressources et textures présentes à l'arrêt de plusieurs sondes, notamment le selftest, les formats et l'intégration 3D. Ces diagnostics de nettoyage restent ouverts ; ils ne sont pas assimilés à une absence totale de diagnostics moteur.

## Consultation et reproduction

- Galerie locale des captures réelles : `tmp/atelier-apercu.html`.
- Journaux : `tmp/atelier-verification-final.log`, `tmp/atelier-vingt-runs-final.log`, `tmp/atelier-formats-final.log`, `tmp/atelier-interface-final.log`, `tmp/atelier-integration-final.log`, `tmp/atelier-planches-final.log`, `tmp/atelier-export.log`.
- Les captures de menus de la galerie utilisent des fixtures de développement pour montrer les contenus. Les dix vues de salles sont cadrées en entier pour comparer leur géométrie ; `tmp/atelier-validation.png` montre le cadrage réel du combat.
- Assets originaux dans `assets/visual/atelier/` : fond illustré et texture de calcaire générés pour Alambic, icônes vectorielles écrites pour cette interface. Aucune maquette avec texte n'est utilisée comme interface interactive.
