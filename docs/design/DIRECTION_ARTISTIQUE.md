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
  maîtrises en chemins de constellation, sorts en cartes régulières avec glyphes
  et fiches contextuelles à la demande,
  parure en trois sceaux décalés. Titres et ressources restent hors des cadres.
- Réserver les cadres aux actions et aux lectures détaillées. Les légers
  chevauchements concernent les illustrations, jamais le texte ou les commandes.
  Les surfaces à coins de 40 px réservent au moins 44 px horizontalement et
  42 px verticalement ; les contenus ancrés manuellement ont leurs propres marges.
  Les cercles contiennent seulement des signes compacts ; leurs légendes longues
  se placent en dehors. Revoir les captures après chaque changement de silhouette.

- Direction retenue : fantasy magique stylisée avec du volume, entre le réalisme
  peint et le cartoon plat. Bleu pervenche et violet du mage dominent ; turquoise
  magique et champagne servent d'accents, avec des ombres indigo.
  Pas de bois sculpté, de grain ni de microgravures dans les contrôles.
  Le décor reste naturel : jardin calme et magie visible mais légère, sans thème céleste.
- Boutons en émail, cadres biseautés simples, larges reflets et zones de lecture
  ivoire avec encre bleue. Le relief ne repose pas sur de gros contours noirs.
  Déclinaison retenue pour les cadres : A « Sceaux liquides », contour arrondi
  en émail indigo, bec verseur en métal lavande grisé et lentille de coin.
  Palette des cadres : bleus et violets nuancés selon leur fonction, ivoire
  lavande pour la lecture, violet plus soutenu pour les actions, cyan dans les
  détails magiques ;
  les silhouettes et les couleurs propres aux icônes sont conservées. Les nœuds et commandes
  d'attributs utilisent des sceaux circulaires. L'onglet actif éclaire son emblème et
  son libellé cyan, avec un trait court sous celui-ci ; aucun anneau supplémentaire.
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
- L'accueil associe `accueil_fond_anime.png` et `accueil_mage_detoure.png`, créés
  depuis l'illustration commune `accueil_mage_clairiere.png`. Le mage respire et
  se balance autour de ses pieds ; son ombre le garde ancré sur le sceau.
  `shaders/accueil_vivant.gdshader` laisse fixes le ciel, les nuages, les montagnes
  et les rives. Quelques feuilles et herbes frémissent avec de petites brises
  irrégulières ; seule la lumière de l'eau miroite discrètement.
  `ui/composants/lueurs_accueil.gd` anime la baguette, quelques lucioles et les
  runes. `academie_arcanique.png` reprend la même lumière
  dans les pages. L'onglet Héros reprend le mage illustré et détouré de l'accueil.
  Les lectures restent ivoire
  lavande avec encre indigo.
  Ce sont des illustrations, pas des icônes ni un menu aplati.
- La scène illustrée conserve le rapport de ses sources : mise à l'échelle uniforme
  pour couvrir l'écran, centrée sur le mage, puis rognage du surplus. Ne pas étirer
  séparément le fond et le personnage. Le réglage « animations et flashes réduits »
  arrête les mouvements et lueurs décoratifs.
- L'accueil reste `ui/accueil_clairiere.tscn` pour conserver les références.
  Profil et ressources en haut, héros au centre, Mine et Épreuves sur les bords
  juste au-dessus de la destination ; Jouer en bas, suivi des cinq onglets :
  Héros, Équipement, Aventure, Maîtrises et Sorts.
- Typographie : DM Sans gras pour la lecture et extra-gras pour les commandes ;
  Fondamento pour le logo et les grands titres. Le logo en champagne clair se
  détache du ciel bleu-violet par un contour et une ombre indigo. Les textes
  sur illustration ont une ombre nette ou un voile indigo discret ; les petites
  légendes ne reposent jamais sur un contour épais. Garder les
  textes longs en DM Sans. Les deux familles sont fournies avec leur licence OFL
  dans `assets/fonts/`.
- Les zones sûres sont prises en compte sur les quatre côtés. La largeur de
  lecture est plafonnée ; grilles et groupes d'actions se recomposent. L'accueil
  peut défiler si sa hauteur minimale dépasse la place disponible, sans rogner
  les commandes ni réduire leurs cibles tactiles.
- Les Sorts alignent les emplacements équipés et présentent chaque catégorie
  dans une grille de deux colonnes qui défile sans pagination. Actifs, Passifs
  et Ultimes prennent respectivement un accent cyan, lilas et champagne. Les
  fiches Sorts et Maîtrises s'ouvrent au centre, au-dessus de la page courante ;
  toucher le voile ou Fermer les referme sans réinitialiser la liste.
  Les transitions entre onglets restent courtes et disparaissent avec les
  effets réduits.
- Menus, cartes, paramètres, pause, récompenses et HUD partagent le même kit.
  La simulation, les silhouettes de combat et les couleurs de danger gardent
  leurs règles de lisibilité ; cette refonte concerne l'habillage d'interface.
- Le rendu mobile et les changements de format doivent être jugés dans le jeu :
  la présence de sources SVG ne garantit pas seule l'absence d'artefacts.

### Charte colorimétrique

| Rôle | Teintes de référence | Emploi |
| --- | --- | --- |
| Identité | violet du mage `#735AAD`, lavande `#D0BAF3` | personnage, sélection, magie liée au héros |
| Atmosphère | pervenche `#8FA9DE`, bleu brume `#B7C5EE` | ciel, pierre et végétation des deux décors ; garder le centre calme |
| Socle | indigo `#253459`, ombre `#263154` | navigation, voiles sur le décor, contours et ombre des textes clairs |
| Surfaces courantes | bleu émail `#5A70A1` vers `#2C4170` | cases, cartes et commandes secondaires ; reflets plus clairs en haut |
| Action et sélection | violet `#7659AD` vers `#413478`, lilas `#8E76C7` | actions principales puis état sélectionné ; l'état ne repose pas sur la couleur seule |
| Lecture | ivoire lavande `#FAF8FF` vers `#E3E5F6`, encre `#253052` | panneaux et texte long ; encre atténuée `#53617D` pour le secondaire |
| Magie | cyan `#8FE5F1` | baguette, runes, petits reflets et focus, jamais de grande nappe cyan |
| Chaleur | champagne `#DBC4A0` | boucles du mage, petits ornements et récompenses, en quantité réduite |

- Les surfaces changent de valeur avec leur rôle et leur emplacement : lecture
  claire sur les pages, boutons violets sur le décor, barre de navigation indigo
  au bas de l'écran, sélection lilas. Leurs dégradés fournissent une lumière et
  une profondeur communes sans en faire des aplats identiques.
- Sur une illustration claire, un texte clair reçoit une ombre indigo ou un voile ;
  dans un panneau clair, le texte passe en encre indigo. Pour les contrôles et le
  texte, viser les contrastes WCAG 2.2 : 4,5:1 pour le texte courant, 3:1 pour le
  grand texte et les composants nécessaires à la compréhension. La petite
  décoration n'est pas un indicateur unique d'état.
- Les couleurs de danger, de rareté et des mondes gardent leurs significations
  propres pendant le combat ; la charte règle d'abord l'accueil et les menus.

Références pour les rôles et les contrastes :
[Material 3, couleurs et palettes tonales](https://developer.android.com/codelabs/m3-design-theming),
[WCAG 2.2, contrastes des textes et des composants](https://www.w3.org/TR/WCAG22/).

## Fichiers de référence

- Modèle et rendu : `data/visuels_3d.gd`, `scripts/presentation/monde_3d.gd`,
  `scripts/presentation/materiaux_apprenti.gd`, `scripts/presentation/arme_tenue_3d.gd`.
- Interface : `scripts/presentation/style_azur.gd`, `ui/`,
  `assets/visual/interface/ORIGINE.md`, `assets/visual/arcane/ORIGINE.md`.
- Génération du héros : `tools/blender/mage_sculpte.py` et ses modules.
