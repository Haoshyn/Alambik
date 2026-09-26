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
  cartes uniformes ni de présentation dashboard. Héros autour de grandes jauges colorées,
  maîtrises en chemins de constellation, sorts en cartes régulières avec glyphes
  et fiches contextuelles à la demande,
  parure en trois sceaux décalés. Les titres de page ont un cartouche en émail
  à bord champagne et coins enluminés ; les ressources gardent leur espace propre.
- Réserver les cadres aux actions et aux lectures détaillées. Les légers
  chevauchements concernent les illustrations, jamais le texte ou les commandes.
  Les surfaces courantes à coins de 40 px réservent au moins 44 px
  horizontalement et 42 px verticalement ; la capsule Jouer utilise des coins
  de 58 px et ses propres marges. Les contenus ancrés manuellement ont leurs
  propres marges.
  La campagne place sept repères sur les lieux peints d’une grande île animée.
  Les symboles sont centrés dans les sceaux SVG et les numéros figurent dessous.
  Le monde change par balayage ou avec deux grandes flèches latérales.
  Mine et Épreuves ont leurs propres parcours.
  Les autres écrans s’ouvrent dans l’atelier illustré, avec une magie discrète
  en bordure et immobile lorsque les effets sont réduits.
  Les cercles contiennent seulement des signes compacts ; leurs légendes longues
  se placent en dehors. Revoir les captures après chaque changement de silhouette.

- Direction retenue : fantasy magique stylisée avec du volume, entre le réalisme
  peint et le cartoon plat. Bleu pervenche et violet du mage dominent ; turquoise
  magique et champagne servent d'accents, avec des ombres indigo.
  Pas de bois sculpté, de grain ni de microgravures dans les contrôles.
  Le décor reste naturel : jardin calme et magie visible mais légère, sans thème céleste.
- Boutons en émail mat, bord métallique fin et zones de lecture ivoire avec
  encre bleue. Les reflets sont localisés ; éviter les grosses gemmes répétées,
  les contours blancs continus et les ombres épaisses qui donnent un aspect
  plastique. Les actions secondaires restent violettes ou indigo ; les actions
  principales du menu prennent l'accent de leur page et Jouer utilise un dégradé
  orange et braise adoucie, bordé de cuivre, avec texte crème calligraphié.
  Les signes magiques utilisent le cyan par touches. Les nœuds de maîtrise
  utilisent des sceaux circulaires ; les attributs du héros associent un glyphe,
  une jauge graduée animée et des commandes en émail +/− pour répartir les points. L'onglet actif agrandit
  son emblème ; chaque onglet garde son libellé et son accent. Les séparateurs
  et les filets de navigation sont des SVG autonomes, sans halo de sélection.
- `tools/refonte_svg.py` dessine les SVG natifs actifs : navigation, ressources,
  contrôles, bijoux, armes, capacités et maîtrises. Le coffre de fin de run
  utilise deux illustrations PNG assorties pour sa caisse et son couvercle.
  Les pictogrammes principaux sont des objets illustrés aux formes originales, composés de
  pièces et de reflets distincts. Les capacités possèdent une base illustrée
  selon leur fonction et une gravure redessinée pour chacune dans
  `tools/signatures_svg.py`. Les exemples sources se trouvent dans
  `tools/design_svg/`. Chaque icône et chaque cadre reste un
  fichier autonome, repositionnable dans Godot. Le générateur historique
  `tools/generer_email_arcanique.py` reste un point d’entrée compatible ;
  Les sources de `SVG/` restent intactes ; les glyphes de menu en réemploient
  les silhouettes avec de nouvelles matières et lumières.
  `tools/variantes_svg_menu.py` crée des variantes colorées du menu dans
  `assets/visual/interface/menu/` sans modifier les SVG sources.
  `tools/generer_glyphes_menus.py` compose les 30 glyphes de maîtrise et les 18
  glyphes de sorts depuis ces silhouettes SVG, chacun dans son fichier sans
  motif secondaire superposé.
- Les cadres de `interface/cadres/` s'étirent en neuf zones avec coins fixes.
  Les cases, cartes et actions secondaires ont des angles coupés et un filet
  léger ; les compteurs sont arrondis, Jouer prend une forme de capsule et les
  zones de lecture gardent un bord fin et des angles doux. Leurs états de
  sélection, pression et focus restent séparés.
  Icônes, textes Godot, boutons, panneaux, personnage et décor sont indépendants.
  Le SVG est une source vectorielle ; Godot en importe une texture. Les mipmaps
  et le filtrage linéaire accompagnent les changements d'échelle. Le shader de
  détourage de l'ancien kit peint n'est plus appliqué à l'interface native.
- L'accueil utilise la clairière sans personnage comme fond animé et une
  illustration PNG transparente distincte pour chacun des cinq mondes. Seule
  l'illustration du monde choisi apparaît au centre, sans carte rectangulaire ;
  la toucher ouvre la sélection de campagne. Mine, le cartouche du monde et
  Épreuves partagent une rangée juste au-dessus de Jouer, plus large et centré.
  Jouer lance directement le chapitre choisi.
  Le niveau et l'XP occupent le haut gauche ; les monnaies ont chacune leur
  symbole et un petit cadre à droite. Le menu ne montre ni logo ni héros.
  L'onglet Héros ne montre plus de portrait. Classe et réinitialisation gratuite
  sont regroupées à gauche du compteur de points, au-dessus de cinq grandes
  jauges colorées. La fiche de classe remplace temporairement les attributs.
- La clairière est composée de couches indépendantes dans
  `assets/visual/interface/clairiere_vivante/` : paysage sans ciel, végétation
  proche avec quatre rameaux découpés, reflets du lac, cascade et nuages/brumes.
  Le ciel en dégradé et les nuages sont derrière la silhouette des montagnes ;
  les branches passent devant.
  Quatre rameaux détachés oscillent autour de leurs attaches ; les troncs,
  montagnes, rives et pierres restent fixes. Les reflets du lac bougent dans
  un masque intérieur, la cascade boucle sur quatre images fondues, et les
  nuages et brumes traversent lentement le cadre dans un seul sens, avec un
  retour hors champ. La clairière reste visible sous les cinq onglets ;
  l'illustration du monde choisi apparaît seulement dans Aventure. Les autres
  pages gardent un voile de lecture léger, plus sombre dans Maîtrises pour
  laisser lire sa constellation. La sélection de campagne garde la clairière,
  le bandeau de niveau et les cinq onglets, mais masque les commandes d'Aventure
  et l'île de fond, déjà représentée sur sa carte. Le fond couvre l'écran à
  échelle uniforme.
- Les maîtrises n'ont aucun grand fond de colonne ni anneau coloré autour des
  nœuds. Chaque sceau rond reçoit une teinte rouge, verte ou violette légère,
  un glyphe SVG illustré unique, plus vif et plus grand, puis une capsule de
  rang séparée juste en dessous. Les tracés entre sceaux restent champagne.
  Les branches portent seulement Offensif, Défensif et Utilitaire. La fiche
  affiche le bonus actuel, le rang suivant et le prérequis utile ; la
  réinitialisation reste accessible dans un bouton compact centré en haut.
- Sorts commence directement par ses trois catégories et quatre médaillons
  équipés sur une ligne dès que la largeur le permet, sans bandeau de niveau
  ni slogan. Seule la collection défile sous ces commandes fixes. Les cartes
  ont un fond peint élémentaire : braise, givre, foudre, acide, onde ou vortex,
  associé à leur effet. Un voile local protège les textes et un seul bord
  métallique à coins enluminés apporte du relief, sans coins de viseur ni cadre
  autour du glyphe. Toute la carte ouvre les détails ; les commandes d'équipement
  sont dans la fiche. Le glissement continue à faire défiler la collection.
  Les glyphes, cadres, textes, boutons et filtres restent des éléments indépendants.
  Les catégories et les emplacements occupent un bandeau plus généreux, avec
  des légendes colorées lisibles et des mipmaps pour les icônes réduites.
  La mention « Maîtrise requise » est supprimée et ne réserve plus de hauteur.
  Les rangs et états affichés proviennent des données réelles du jeu.
- Les îles gardent leur silhouette fixe ; leurs matières s'animent dans des zones
  définies par `data/animations_decors.gd` : encre et eau coulantes, sable,
  lave, feuillage, bannières et portails. Brumes, nuages et fumées utilisent des
  sprites distincts. La pierre et les silhouettes restent stables.
  L'option d'effets réduits fige les horloges sans masquer de couche ; les
  animations s'arrêtent aussi lorsque la page est cachée.
- L'accueil reste `ui/accueil_clairiere.tscn` pour conserver les références.
  Le bas contient les cinq onglets Héros, Équipement, Aventure, Maîtrises et
  Sorts : les libellés colorés restent visibles ; l'onglet actif grandit légèrement.
- Typographie : DM Sans gras pour la lecture, extra-gras pour les chiffres et
  les bonus ; Grenze à graisse native 750 pour les titres, attributs, noms de
  sorts et onglets. Fondamento reste disponible pour les anciens éléments.
  Les textes sur illustration ont
  une ombre nette ou un voile indigo discret ; les petites légendes ne reposent
  jamais sur un contour épais. Garder les textes longs en DM Sans. Les trois
  familles sont fournies avec leur licence OFL dans `assets/fonts/`.
- Les zones sûres sont prises en compte sur les quatre côtés. La largeur de
  lecture est plafonnée ; grilles et groupes d'actions se recomposent. L'accueil
  peut défiler si sa hauteur minimale dépasse la place disponible, sans rogner
  les commandes ni réduire leurs cibles tactiles.
- Les Sorts alignent les emplacements équipés et présentent chaque catégorie
  dans une grille de deux colonnes qui défile sans pagination. Actifs, Passifs
  et Ultimes prennent respectivement un accent mauve, jade et corail. Les
  fiches Sorts s'ouvrent au centre avec un seul cadre ; toucher le voile ou
  Fermer les referme sans réinitialiser la liste. Dans Maîtrises, une fiche de
  hauteur fixe au-dessus de la constellation montre la sélection, ses effets,
  ses rangs et son amélioration. Toucher un autre sceau remplace directement
  son contenu, sans fenêtre superposée.
  Les transitions entre onglets restent courtes et disparaissent avec les
  effets réduits.
- Héros, Équipement et Sorts regroupent leurs informations de progression dans
  un cartouche fin ; les attributs et les branches de Maîtrises gardent leurs
  accents propres. Les sceaux Offensif, Défensif et Utilitaire prennent chacun
  une teinte rouge corail, vert jade ou mauve. Les augments ont une plaque
  asymétrique distincte des cases
  de catalogue, avec un filet de rareté près du nom.
  L'inventaire des bijoux montre vingt petites cases par page. Chaque arme et
  familier présente son illustration SVG et ses statistiques dans sa carte ;
  les familles d'armes et de familiers ont des accents distincts.
- Menus, cartes, paramètres, pause, récompenses et HUD partagent le même kit.
  Dans le HUD, le temps de salle reste en bandeau, les ressources sont en deux
  compteurs et les commandes de pause et de sorts sont rondes. La transition
  d'entrée reprend le portail sur un halo discret et un cartouche de monde.
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
| Action et sélection | violet `#7659AD` vers `#413478`, lilas `#8E76C7` | actions secondaires et états choisis hors accents du menu ; l'état ne repose pas sur la couleur seule |
| Lecture | ivoire lavande `#FAF8FF` vers `#E3E5F6`, encre `#253052` | panneaux et texte long ; encre atténuée `#53617D` pour le secondaire |
| Magie | cyan `#8FE5F1` | baguette, runes, petits reflets et focus, jamais de grande nappe cyan |
| Chaleur | champagne `#DBC4A0` | boucles du mage, petits ornements et récompenses, en quantité réduite |
| Accents des menus | corail `#FF7773`, jade `#65E3A5`, bleu vif `#69D7F5`, or `#FFD15C`, mauve `#C7A0FF` | branches et catégories ; onglets vert, lavande, bleu, champagne et rose, par touches |

- Les surfaces changent de valeur avec leur rôle et leur emplacement : lecture
  claire sur les pages, actions principales colorées, barre de navigation indigo
  au bas de l'écran et sélection lumineuse. Leurs dégradés fournissent une lumière et
  une profondeur communes sans en faire des aplats identiques.
- Le socle de navigation prend un émail indigo sombre et un filet cuivre ;
  les accès Mine et Épreuves gardent des sceaux séparés, bronze et améthyste.
  Leurs actions reprennent ces accents, tandis que les compteurs distinguent
  les gouttes cyan des pierres violettes. La légende de campagne reste près des
  commandes de départ ; elle partage
  avec le panneau de niveau un émail indigo nuancé et un filet champagne.
  La couleur du monde teinte légèrement ce fond sans concurrencer l’illustration.
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
