# Direction artistique active

Repère du jeu actuel, à consulter pour une tâche visuelle. Les anciennes fiches
de `human/` sont archivées dans `../OldAlambik/` depuis la racine du projet ;
elles conservent les idées historiques sans définir le rendu actuel.

## Identité et combat

- Fantasy alchimique originale, lumineuse et aventureuse : encre, fioles,
  grimoires, sceaux et magie. La lisibilité sur téléphone prime sur l'ornement.
- Le combat utilise des modèles et effets 3D sur une simulation 2D.
- Le héros est le mage sculpté, avec son chapeau, ses textures, ses animations
  et une arme tenue séparée qui suit l'équipement.
- Les silhouettes, impacts et télégraphes doivent rester distincts. Les effets
  décoratifs ne masquent pas les dangers et ne rendent pas les hitbox ambiguës.
- Le centre de l'arène reste calme ; le décor plus riche se place en bordure.
  Les couleurs des mondes distinguent leur ambiance sans brouiller les attaques.

## Interface — Émail arcanique (A)

- Composer la silhouette globale avant les composants : pas de succession de
  cartes uniformes ni de présentation dashboard. Héros autour du personnage,
  maîtrises en chemins de constellation, sorts en symboles avec fiches à la demande,
  parure en trois sceaux décalés. Titres et ressources restent hors des cadres.
- Réserver les cadres aux actions et aux lectures détaillées. Les légers
  chevauchements concernent les illustrations, jamais le texte ou les commandes.
  Les surfaces à coins de 40 px réservent au moins 44 px horizontalement et
  42 px verticalement ; les contenus ancrés manuellement ont leurs propres marges.
  Les cercles contiennent seulement des signes compacts ; leurs légendes longues
  se placent en dehors. Revoir les captures après chaque changement de silhouette.

- Direction retenue : fantasy magique stylisée avec du volume, entre le réalisme
  peint et le cartoon plat. Turquoise, ivoire, bronze discret, ombres bleu lavande.
  Pas de bois sculpté, de grain ni de microgravures dans les contrôles.
  Le décor peut être naturel : jardin calme et magie discrète, sans thème céleste.
- Boutons en émail, cadres biseautés simples, larges reflets et zones de lecture
  ivoire avec encre bleue. Le relief ne repose pas sur de gros contours noirs.
  Déclinaison retenue pour les cadres : A « Sceaux liquides », contour arrondi
  en émail Charbon végétal, bec verseur en métal grisé et lentille de coin.
  Palette des cadres : sauge #829e8b, charbon #3d5749, métal #bdc6af ;
  les silhouettes et les couleurs propres aux icônes sont conservées. Les nœuds, commandes
  d'attributs et sélections d'onglets utilisent des sceaux circulaires.
- `tools/generer_email_arcanique.py` construit les SVG natifs actifs : navigation,
  ressources, contrôles, bijoux, armes, capacités, maîtrises et coffre. Chemins
  simples et dégradés larges remplacent les vectorisations de peintures denses.
  `tools/habillage_svg_source.py` adapte les silhouettes Wenrexa du dossier
  `SVG/` fourni par le propriétaire : couleurs de matière, relief léger et
  cadrage sur la silhouette visible, sans petit badge superposé. Les originaux restent intacts.
- Les cadres de `interface/cadres/` s'étirent en neuf zones avec coins fixes.
  Cases, cartes, boutons, compteurs et zones de lecture ont des assets dédiés,
  avec états de sélection, pression et focus séparés.
  Icônes, textes Godot, boutons, panneaux, personnage et décor sont indépendants.
  Le SVG est une source vectorielle ; Godot en importe une texture. Les mipmaps
  et le filtrage linéaire accompagnent les changements d'échelle. Le shader de
  détourage de l'ancien kit peint n'est plus appliqué à l'interface native.
- `academie_arcanique.png` est le décor d'accueil et des pages. Le héros est le
  modèle 3D du jeu, affiché dans un viewport transparent avec animation de repos
  par `ui/composants/portrait_heros_3d.gd` ; son cadrage suit le format disponible.
  Le décor est une cour-jardin d’alchimiste, plus lumineuse, avec bassin,
  verdure sauge et fleurs magiques discrètes ; le bas reste dégagé.
  Les lectures restent ivoire grisé.
  Ce sont des illustrations, pas des icônes ni un menu aplati.
- L'accueil reste `ui/accueil_clairiere.tscn` pour conserver les références.
  Profil et ressources en haut, héros et modes au centre, destination et Jouer
  en bas, puis cinq onglets : Héros, Équipement, Aventure, Maîtrises et Sorts.
- Les zones sûres sont prises en compte sur les quatre côtés. La largeur de
  lecture est plafonnée ; grilles et groupes d'actions se recomposent. L'accueil
  peut défiler si sa hauteur minimale dépasse la place disponible, sans rogner
  les commandes ni réduire leurs cibles tactiles.
- Menus, cartes, paramètres, pause, récompenses et HUD partagent le même kit.
  La simulation, les silhouettes de combat et les couleurs de danger gardent
  leurs règles de lisibilité ; cette refonte concerne l'habillage d'interface.
- Le rendu mobile et les changements de format doivent être jugés dans le jeu :
  la présence de sources SVG ne garantit pas seule l'absence d'artefacts.

## Fichiers de référence

- Modèle et rendu : `data/visuels_3d.gd`, `scripts/presentation/monde_3d.gd`,
  `scripts/presentation/materiaux_apprenti.gd`, `scripts/presentation/arme_tenue_3d.gd`.
- Interface : `scripts/presentation/style_azur.gd`, `ui/`,
  `assets/visual/interface/ORIGINE.md`, `assets/visual/arcane/ORIGINE.md`.
- Génération du héros : `tools/blender/mage_sculpte.py` et ses modules.
