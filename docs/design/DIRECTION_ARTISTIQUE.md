# Direction artistique active

Repère du jeu actuel, à consulter pour une tâche visuelle. Les anciennes fiches
de `human/` sont archivées dans `../OldAlambik/` depuis la racine du projet ;
elles conservent les idées historiques sans définir le rendu actuel.

## Identité et combat

- Fantasy alchimique originale, lumineuse et aventureuse : encre, fioles,
  grimoires, sceaux et magie. La lisibilité sur téléphone prime sur l'ornement.
- Le combat utilise des modèles et effets 3D sur une simulation 2D.
- Le héros est Aster chibi (10 octobre 2026), un modèle original de jeu
  mobile construit par `tools/blender/heros_chibi.py` : environ deux têtes de
  haut, tête ronde lisse, grands yeux violets à double reflet, joues roses,
  petite bouche, mèches bleu argenté ; chapeau violet à pointe recourbée,
  ruban d'or, gemme turquoise et étoile ; robe bleu roi en poire avec ourlet
  et cape d'or, col et revers blancs, ceinture à boucle, manches bouffantes,
  moufles et grosses bottes. Palette vive en aplats, liseré de contre-jour et
  contour sombre ; le visage reste sans ombre ni contour. Il reprend le
  squelette d'Aster V7 raccourci et ses huit actions, ainsi que la baguette
  et le grimoire. L'ancien modèle reste dans `assets/3d/characters/aster/`.
  La collision reste `HEROS_RAYON`. Le tir rapide
  à l'arrêt anime le bras et légèrement le buste, avec les pieds stables.
- Les onze monstres communs et les vingt boss sont des objets alchimiques
  vivants : encriers à pattes, plumes, grimoires ouverts, masques et fioles.
  Leurs volumes distinguent l'encre sombre, la céramique mate, le tissu,
  le parchemin ivoire, le cuivre satiné et l'acier. Un atlas peint partagé,
  des UV continus, des ombres de creux douces et des lumières par sommet
  donnent du relief aux matières ; une petite carte partagée règle leurs reflets.
  Plis souples, pans fins, paupières sculptées et pierres taillées précisent
  les silhouettes. Les plumes suivent leurs nervures, les couvercles leur
  charnière et les pattes leurs joints. Les variantes changent les teintes, les proportions
  et de courts appendices minéraux, aquatiques, aériens ou ardents.
- Pattes, bras, couvertures, ailes, têtes et bouchons sont articulés séparément.
  Les pattes plient sur deux segments avec un pli stable. Chaque pied décrit
  un cycle sous le corps : appui en ligne droite puis retour en arc. La
  cadence suit la vitesse pour que le pied posé recule au rythme du corps ;
  la foulée est bornée par la portée, les pattes ne s'écartent jamais. Le
  corps rebondit légèrement à chaque pas ; les pieds se reposent à l'arrêt.
  Les êtres flottants inclinent
  leur corps dans le déplacement ; pages et pans suivent avec du retard.
  Préparation, frappe et recul gardent les volumes rigides, sans pulsation
  permanente du corps. Le gel immobilise aussi les membres.
  La dernière pose se contracte brièvement à la mort,
  après retrait de la collision. Les effets réduits conservent les gestes
  utiles, retirent l'oscillation de repos et raccourcissent la disparition.
- Les silhouettes, impacts et télégraphes doivent rester distincts. Les effets
  décoratifs ne masquent pas les dangers et ne rendent pas les hitbox ambiguës.
- Les cinq familiers suivent une direction de petites créatures fantasy
  élégantes, à l'anatomie soignée, choisie par le propriétaire le 7 octobre.
  L'homoncule est un renard violet au museau fin et à la queue d'encre ; la
  salamandre a un corps reptilien allongé, quatre pattes pliées et une crête
  ambrée ; l'ondine associe une anatomie de loutre à des branchies et une queue
  nageoire ; le sylphe a un bec, de grandes ailes à rémiges et une queue
  divisée ; le golem est un petit gardien de pierre à épaules et avant-bras
  marqués. Crâne, nuque, thorax et bassin sont sculptés d'un seul tenant.
  Les yeux restent petits, intégrés au visage, avec des arcades et des reflets
  discrets. La silhouette porte l'identité ; les accessoires restent limités.
  Leurs couleurs peintes passent du dos coloré aux plans ventraux ivoire.
  Ces anatomies animales les distinguent des objets vivants du bestiaire.
  Les GLB sont dans `assets/3d/familiers/`, les sources Blender et la référence
  originale dans `assets/3d/sources/familiers/`, les générateurs dans
  `tools/blender/familiers_*.py`. `modeles_familiers_3d.gd` charge les sculptures
  et leurs pivots anatomiques. La peinture par sommet tient sur une matière
  par pivot, sans lumière ni transparence supplémentaires. Les gestes suivent
  le déplacement et le tir réel ; le repos se fige en effets réduits.
- Les effets des rares portent un émail turquoise et un cœur ivoire : cercles
  orbitaux, trait périodique et météorite facettée. L'anneau de chute annonce
  sa zone réelle ; le mode réduit conserve les positions et les gestes utiles.
  Les formes sont procédurales et originales.
- Les dégâts infligés s'affichent en nombres entiers épais (Nunito très grasse,
  contour sombre) au-dessus de la cible : jaillissement, montée freinée et
  dérive alternée, puis fondu. Les critiques sont plus gros, dorés, inclinés et
  éclatent dans des rayons ; la braise est orange et plus petite. Les nombres
  restent complets jusqu'à 9 999, puis s'abrègent sans décimale (12k, 2M).
  Les impacts proches sont regroupés ; les dégâts subis par le héros montent
  en rouge, précédés d'un signe moins. Les effets réduits gardent un seul
  nombre sobre par cible, sans rebond ni dérive.
- Retours de combat : éclair blanc bref sur l'ennemi touché, ombre de contact
  sous chaque acteur (les ombres projetées restent coupées sur Android),
  éclats plus nombreux, noyau lumineux aux impacts et aux morts, anneau et
  secousse pour les élites et les boss. Les coups reçus, la mort d'un élite ou
  d'un boss et la météorite secouent la caméra (option Secousses) ; un
  micro-arrêt de quelques centièmes souligne les coups reçus et la chute d'un
  boss. Une vignette indigo concentre le regard ; le rendu 3D passe en courbe
  filmique, plus contrasté et saturé, avec un halo doux sur les éléments clairs.
  Les effets réduits retirent halo, micro-arrêts, éclairs et jaillissements.
- Chaque tireur possède un contour de projectile original, partagé par ses
  rendus 2D et 3D. Le volume et sa lueur suivent les dimensions de collision ;
  les grosses boules, les traits et les lames revenantes se distinguent par
  leur contour, leur mouvement et leur rythme. Teinte et petits sceaux gardent
  la variante du monde lisible. Les tirs des familiers ont leurs propres
  contours propres, avec des volumes magiques effilés ivoire et azur, des
  nervures lumineuses et des sillages courbes. Leur construction 3D appartient à
  `scripts/presentation/formes_projectiles_familiers.gd`. La signature alliée
  reste opaque et reconnaissable en effets réduits ; le halo discret se retire.
- Les traits ennemis fins ont un volume épaissi, une teinte saturée et un bord
  sombre opaque. Le reflet reste localisé ; leur lisibilité ne dépend pas du
  halo ni des effets complets. Le sillage des tirs rapides est court et effilé
  pour distinguer le corps dangereux de sa traînée.
- Les tirs ont des biseaux en relief et une signature lumineuse intérieure :
  nervure, goutte, découpe de lame ou couronne d'orbe. Le cœur s'anime doucement
  sans agrandir le corps dangereux. Les effets réduits figent ce mouvement et
  masquent le halo ; le corps opaque et le sillage restent présents.
- Les boomerangs de boss ont un corps épais et coloré, lisible pendant leur
  rotation et leur retour. L’éventail part du lanceur ; les boss mobiles
  gardent leur position pendant l’annonce des trajectoires.
- Les attaques au contact des boss montrent le secteur ou le cercle complet
  de la frappe. Le corps s'arme, frappe puis récupère à l'arrêt ; la direction
  annoncée ne se retourne pas vers le joueur au dernier instant.
- Les apparitions, frappes instantanées et tirs rapides sont annoncés en rouge contrasté, commun aux
  cinq mondes : cercle au point d’arrivée ou d’impact, traits dans les directions
  de tir et couloir pour les charges. Le danger attend la fin de son annonce.
  Les tirs lents peuvent se lire en mouvement sans annonce ; le corps des
  poursuivants et chargeurs reste dangereux au contact.
- Le centre de l'arène reste calme ; le décor plus riche se place en bordure.
  Les couleurs des mondes distinguent leur ambiance sans brouiller les attaques.
- Les salles prennent la forme d'ateliers alchimiques : encriers à plume et
  grimoires ouverts pour Encre, distillateurs et herbes pour Terre, fontaines
  à coquille et fioles pour Eau, moulins et tuyaux d'orgue pour Air, creusets
  et fourneaux pour Feu. Cuivre, céramique et verrerie opaque les relient.
  Ces volumes sont construits dans `scripts/presentation/ornements_monde.gd` ;
  leurs silhouettes sont originales et leurs palettes viennent de
  `data/presentation/decors_mondes.gd`.
- Le sol associe l'enduit ciré B à une bordure d'émail de fantaisie.
  Depuis le 9 octobre 2026, un dallage de pierre original
  (`assets/visual/sols/dalles_jeu.png`, `tools/generer_dalles_sol.py`) est
  multiplié sur l'enduit en espace monde : joints sombres, biseau éclairé en
  haut à gauche, dalles carrées à l'écran malgré l'anamorphose. Il donne
  l'échelle d'une arène ; la peinture et les teintes du monde restent dessous.
  Les murs de salle sont continus et plus hauts, avec couronnement d'émail,
  filet de cuivre et pilier serti à chaque angle ; ceux du premier plan,
  tournés vers la caméra, restent bas. La matière est continue, talochée et légèrement satinée, avec de larges
  passages d'outil visibles de près. La peinture originale, ses origines et
  les anciennes sources conservées figurent dans `assets/visual/sols/ORIGINE.md`.
  Violet pour Encre, sauge dorée pour Terre, turquoise pour Eau, bleu ciel
  pour Air, mauve et ambre pour Feu. Les pigments restent présents de près.
  Chaque étage répartit de grandes reprises plus chaudes, des plages
  patinées et un passage légèrement poli. Leurs limites sont irrégulières
  et fondues dans la matière ; le centre reste
  calme. Le sens de la taloche change aussi dans les reprises. Les nuances
  et les déformations de la peinture appartiennent au même maillage de sol.
  Une bordure d'émail coloré et un filet doré suivent les parois.
  Aucun livre, feuille, médaillon ni grand pictogramme n'est plaqué au sol.
  La bordure est construite par `scripts/presentation/bordures_sol.gd`,
  dans un seul maillage texturé avec des couleurs de sommets. Elle reste
  sous les flaques et les acteurs, découpée sur le contour réel.
  Le décalage de la frise et le cadrage de la peinture varient également. La graine
  dépend du monde, de l'étage et de la variante ; la même salle garde son
  dessin à chaque reconstruction. Ces détails restent sous les acteurs,
  sans halo ni couleur de danger.
  En campagne, les profils alternent galeries étroites, salles allongées,
  cours arrondies, murs ondulés, renfoncements et alcôves. La largeur reste
  bornée à celle de référence, y compris au fond des alcôves. Proportions,
  arrondis, côté et emplacement des reliefs varient de façon déterministe
  par étage. Les collisions et la présentation partagent ces mêmes parois ;
  le passage central reste libre.
  La géométrie du sol et des bordures est découpée sur ce contour réel,
  avec une frise d'émail et de cuivre. Les modes annexes gardent leurs contours.
  Les décors des rives sont des volumes proches des vrais murs, y compris
  dans les galeries étroites et près des alcôves. Lanternes serties, établis
  de potions, jarres, champignons, coraux, carillons, cristaux et appareils
  forment des ensembles distincts. Leur nombre, leur emplacement, leur
  orientation et leur échelle changent par étage. Leur emprise entière
  reste hors du contour jouable ; aucun nouvel obstacle invisible n'est ajouté.
  Les murets et rochers portent également des lanternes ou massifs miniatures,
  dans l'emprise du couvert physique, pour habiter le cadre près du héros.
  Les appareils hauts restent sur les côtés et au fond. Les couverts portent
  des reliures, fioles, plantes ou creusets en gardant leur emprise de collision ;
  leurs surfaces reprennent la céramique peinte de l'atlas original du bestiaire.
  Les bains des appareils et les moulins s'arrêtent en effets réduits.
  Les textures utilisent mipmaps et compression pour Android. Les éléments
  immobiles sont regroupés par matière en conservant les UV et les couleurs
  des sommets, pour limiter les appels de dessin sur téléphone.
  L'export d'aperçu convertit les couleurs de sommets sRGB en linéaire pour
  que les peintures ne soient pas éclaircies lors du rendu Blender.
  Les sols y conservent aussi leur absence d'ombre portée.
- Les zones de terrain actives sont de grandes nappes allongées aux contours
  organiques, distinctes des nuances et reprises de l'enduit. Leur rive reste
  fine ; la profondeur vient de nuances et de reflets sur une surface basse.
  Encre visqueuse violette, sables ocres striés, eau turquoise et lave à veines
  chaudes ont des peintures et normales originales, générées par
  `tools/generer_matieres_terrains.gd` et conservées dans
  `assets/visual/terrains/`, avec leurs origines. Les petits glissements des
  reflets d'encre et d'eau se figent en effets réduits. La
  silhouette 3D reprend le polygone de la simulation, sous les ombres des
  acteurs. Les rafales d'Air sont indiquées par des flèches pâles, visibles
  avant et pendant la poussée ; elles disparaissent pendant l'accalmie.

## Interface — Émail serti (refonte du 9 octobre 2026)

- Demande du propriétaire : un rendu « jeu », moins sobre. Toutes les surfaces
  passent par `scripts/interface/style_box_jeu.gd` (StyleBoxJeu) : contour
  sombre, monture dorée en dégradé, épaisseur visible sous la face, face en
  dégradé, reflet supérieur et filet clair. `scripts/interface/style_jeu.gd`
  fournit les teintes (ambre pour l'action principale, améthyste par défaut,
  azur, émeraude, rubis pour l'abandon, nuit pour les panneaux), les cartes de
  rareté (rare azur, épique améthyste, légendaire ambre avec lueur), les textes
  épais à contour et les animations communes (appui écrasé puis rebond avec
  clic, distribution des cartes). `scripts/interface/dessin_jeu.gd` dessine les
  jauges bombées, pastilles, rayons et textes des éléments tracés (HUD,
  annonces, nombres de dégâts).
- Le contraste vient de la typographie : Nunito 800 à 1000 avec contour sombre
  et ombre portée, jamais d'un petit rectangle posé sous un texte. Les anciennes
  zones de lecture ivoire deviennent de l'émail sombre ; les encres sombres sont
  converties en teintes claires par `StyleAzur.teinte_lisible`.
- HUD : pause ronde en émail, cartouche de salle avec badge de niveau et jauge
  d'XP animée, pastilles de ressources, barre de boss avec trace claire des
  dégâts récents et quatre graduations, vignette rouge pulsée quand la vie est
  basse. Des bandeaux centraux annoncent l'arrivée d'un boss et la salle nettoyée.
- Les cartes d'augment ressemblent à des cartes à collectionner : monture et
  lueur de rareté, médaillon coloré (rayons tournants pour les légendaires),
  pastilles de rareté et de rang, valeurs chiffrées en or, reflet balayant les
  épiques et légendaires. Elles sont distribuées une à une ; la carte choisie
  grossit, les autres s'effacent, et un arpège propre à la rareté retentit.
- La barre de navigation soulève l'onglet actif sur une pastille à la couleur
  de son menu ; la fin de partie affiche « VICTOIRE ! » dans des rayons dorés
  ou une défaite sobre, avec sa fanfare.

## Interface — Émail arcanique (A), état antérieur conservé quand il reste vrai

- Composer la silhouette globale avant les composants : pas de succession de
  cartes uniformes ni de présentation dashboard ; chaque menu a sa propre
  composition. Héros : le portrait 3D d'Aster sur un socle lumineux, entouré
  des cinq attributs en médaillons reliés en constellation (badge de rang,
  ajout direct « + »), avec classe, réserve de points en joyau ambre et
  réinitialisation ronde au-dessus, et le détail de l'attribut choisi
  (jauge, bonus, − et +) dans un panneau en bas. Maîtrises en chemins de
  constellation, passifs en tuiles serties avec glyphes et fiches
  contextuelles à la demande. Équipement : vitrine commune aux trois
  ateliers, le héros sur son socle avec les trois bijoux à gauche et l'arme
  et le familier à droite (un toucher ouvre l'atelier concerné) ; puis les
  statistiques en pastilles (icône, valeur dorée, libellé) et le coffret
  serti, dont les cases vides ne complètent que la dernière rangée. Ces
  vitrines gardent leur barre de défilement visible : leur hauteur suit leur
  largeur. Les titres de page ont un cartouche en émail
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
- Boutons en émail bombé serti d'or (voir la refonte ci-dessus). Les actions
  secondaires restent violettes ou indigo ; les actions principales du menu
  prennent l'accent de leur page et Jouer garde son dégradé orange et braise,
  avec un texte crème très gras à contour brun.
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
  Les sources de `tools/sources_svg/` restent intactes ; les glyphes de menu en réemploient
  les silhouettes avec de nouvelles matières et lumières.
  `tools/variantes_svg_menu.py` crée des variantes colorées du menu dans
  `assets/visual/interface/menu/` sans modifier les SVG sources.
  `tools/generer_glyphes_menus.py` compose les 30 glyphes de maîtrise et les cinq
  familiers depuis ces silhouettes SVG. `tools/generer_glyphes_passifs.py`
  compose les seize glyphes de `assets/visual/interface/menu/passifs/glyphes/`
  depuis seize silhouettes distinctes, également différentes de celles des
  maîtrises et familiers. Depuis le 9 octobre 2026, ces 51 glyphes partagent
  l'habillage « icône de jeu » de `tools/style_icone_jeu.py` : contour sombre
  épais, ombre portée, trois tons en aplats (bord éclairé en haut à gauche,
  matière, ombre franche), reflet dur et éclat. Braise pour offensif, jade
  pour défensif, améthyste pour utilitaire ; sans halo ni image incorporée.
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
  symbole et des chiffres colorés, agrandis en Grenze gras, sans petit fond noir
  sous le nombre. Le menu ne montre ni logo ni héros.
  L'onglet Héros ne montre plus de portrait. Classe et réinitialisation gratuite
  sont centrées et agrandies à gauche du cartouche dédié aux points à répartir,
  au-dessus de cinq grandes
  jauges colorées. La fiche de classe remplace temporairement les attributs.
- La clairière est composée de couches indépendantes dans
  `assets/visual/interface/clairiere_vivante/` : paysage sans ciel, végétation
  proche avec quatre rameaux découpés, reflets du lac, cascade et nuages/brumes.
  Le ciel en dégradé et les nuages sont derrière la silhouette des montagnes ;
  les branches passent devant.
  Quatre rameaux détachés oscillent autour de leurs attaches. Le paysage,
  y compris la prairie, les montagnes et les rives, reste entièrement fixe.
  Les masques SVG suivent des feuilles précises du premier plan, avec une
  souplesse décroissante vers leur attache ; les troncs et les rochers sont
  exclus. Un vent doux traverse ces feuilles avec des phases distinctes.
  Les ondes du lac sont larges, les reflets mobiles et la cascade soutenue.
  Les reflets du lac bougent dans un masque intérieur ; la cascade associe
  quatre images fondues à un courant descendant limité à son intérieur, et les
  nuages et brumes traversent lentement le cadre dans un seul sens, avec un
  retour hors champ. Six silhouettes de nuages se suivent à vitesse commune :
  cinq autres passent avant qu'une silhouette revienne, environ 3 min 38 s
  plus tard. La clairière reste visible sous les onglets, assombrie par un
  voile de lecture à 62 % sur Héros, Équipement, Maîtrises et Passifs
  (`FondMenuVivant.VOILE_PAGE`) ; l'Aventure la garde vive. L'illustration du monde choisi apparaît seulement
  dans Aventure. Maîtrises ajoute son propre voile pour laisser lire sa constellation. La sélection de campagne garde la clairière,
  le bandeau de niveau et les cinq onglets, mais masque les commandes d'Aventure
  et l'île de fond, déjà représentée sur sa carte. Son titre de monde reste
  libre au-dessus d'une grande île ; les détails du niveau et les commandes
  sont réunis dans un seul panneau fixe en bas. Les textes n'ont pas de petits
  fonds sombres individuels. Le bandeau appartient à la sélection : ses
  réglages restent accessibles et leur fermeture retrouve le monde consulté.
  Le fond couvre l'écran à échelle uniforme.
- Les maîtrises n'ont aucun grand fond de colonne ni anneau coloré autour des
  nœuds. Chaque sceau rond reçoit une teinte rouge, verte ou violette légère,
  un glyphe SVG illustré unique, plus vif et plus grand, puis un badge de
  rang posé sur le bas du sceau. Les tracés entre sceaux restent champagne.
  Les branches portent seulement Offensif, Défensif et Utilitaire, titrées sur
  une même ligne. La fiche affiche le bonus actuel, le rang suivant et le
  prérequis utile ; la réinitialisation, rare et destructive, est un bouton
  ardoise en fin d'arbre.
- Passifs reprend le titre en émail des autres menus, puis les quatre
  médaillons équipés sur une ligne dès que la largeur le permet.
  Le titre de collection, son compteur, le tri et les filtres Tous, Offensif,
  Défensif et Utilitaire précèdent la liste. Seule la collection défile sous
  ces commandes fixes. Le fond garde la clairière commune sans filtre propre.
  Les emplacements équipés forment un seul panneau serti titré
  « Passifs équipés · n / 4 ». Chaque passif est une tuile sertie à la
  couleur de sa catégorie (trois colonnes, deux en format compact) : médaillon
  creusé avec le SVG, nom, rang, bonus calculé et catégorie. Un passif
  verrouillé a une monture ardoise, une silhouette éteinte et un cadenas ;
  un passif équipé a une monture et un anneau verts. Avant découverte, le
  bonus annoncé est celui du premier rang.
  Les textes de la collection reposent dans leur tuile, jamais sur un petit
  rectangle sombre propre, y compris dans les fiches. Les cadres enluminés des filtres et les médaillons sont conservés.
  Toute l'entrée ouvre les détails ; les commandes d'équipement
  sont dans la fiche. Le glissement continue à faire défiler la collection.
  Les glyphes, cadres, textes, boutons et filtres restent des éléments indépendants.
  Les catégories et les emplacements gardent des légendes lisibles et des
  mipmaps pour les icônes réduites.
  La mention « Maîtrise requise » est supprimée et ne réserve plus de hauteur.
  Les rangs et états affichés proviennent des données réelles du jeu.
- Les îles gardent leur silhouette fixe ; leurs matières s'animent dans des zones
  définies par `data/presentation/animations_decors.gd` : encre et eau coulantes, sable,
  lave, feuillage, bannières et portails. Brumes, nuages et fumées utilisent des
  sprites distincts. La pierre et les silhouettes restent stables.
  L'option d'effets réduits fige les horloges sans masquer de couche ; les
  animations s'arrêtent aussi lorsque la page est cachée.
  Clairière et îles composent leurs plans dans un rendu sans arrondi au pixel,
  dimensionné aux pixels affichés. Cela conserve les petits déplacements des
  nuages, des brumes et des rameaux sans changer le rendu des commandes.
  Les effets réduits gardent une image figée, recalculée seulement si nécessaire.
- L'accueil reste `ui/accueil_clairiere.tscn` pour conserver les références.
  Le bas contient les cinq onglets Héros, Équipement, Aventure, Maîtrises et
  Passifs : les libellés colorés restent visibles ; l'onglet actif grandit légèrement.
- Typographie : Nunito 800 pour la lecture, 900 pour les titres et 1000 pour
  les chiffres, avec un contour sombre proportionné à la taille. La graisse des
  polices variables est déclarée par l'étiquette numérique `wght`
  (2003265652) : la clé texte était ignorée et laissait tout le jeu en graisse
  fine. Grenze reste réservée au titre des chargements ; DM Sans et Fondamento
  restent fournis. Les quatre familles ont leur licence OFL dans `assets/fonts/`.
- Les zones sûres sont prises en compte sur les quatre côtés. La largeur de
  lecture est plafonnée ; grilles et groupes d'actions se recomposent. L'accueil
  peut défiler si sa hauteur minimale dépasse la place disponible, sans rogner
  les commandes ni réduire leurs cibles tactiles.
- Les Passifs alignent les emplacements équipés et présentent chaque catégorie
  dans une grille de tuiles qui défile sans pagination. Les accents
  distinguent les fonctions offensives, défensives et utilitaires. Les
  fiches Passifs s'ouvrent au centre avec un seul cadre ; toucher le voile ou
  Fermer les referme sans réinitialiser la liste. Dans Maîtrises, une fiche de
  hauteur fixe au-dessus de la constellation montre la sélection, ses effets,
  ses rangs et son amélioration. Toucher un autre sceau remplace directement
  son contenu, sans fenêtre superposée.
  Les transitions entre onglets restent courtes et disparaissent avec les
  effets réduits.
  Les fiches d'Équipement et de Passifs utilisent un cadre bleu émaillé avec
  gravures fines aux coins et un voile bleuté. Leur ouverture et leur fermeture
  restent brèves ; les effets réduits donnent un affichage immédiat. Une action
  de forge actualise la fiche en place, montre son gain suivant et confirme
  l'achat par un court éclat. Les sous-onglets d'Équipement se fondent doucement.
- Héros et Équipement regroupent leurs informations de progression dans
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
  compteurs et une commande de pause ronde. Aucun bouton de sort n'est affiché.
  Le démarrage conserve l'illustration Alambic, son logo et sa fiole entiers ;
  le fond prolonge ses bords selon le format et les zones sûres de l'écran.
  L'entrée en partie montre l'île animée du monde choisi sur un dégradé indigo,
  son nom en Grenze, le niveau et sa phrase d'ambiance sans cartouche.
  Mine et Épreuves utilisent leur illustration dédiée. Trois points discrets
  accompagnent le chargement ; les effets réduits gardent l'image fixe.
  Les passages entre étages reprennent ce même écran avec « Étage X / Y »
  sous le niveau. Le total vient de la run ; le composant et l'illustration
  sont réutilisés jusqu'à la fin de la tentative.
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

- Modèle et rendu : `data/presentation/visuels_3d.gd`, `scripts/presentation/monde_3d.gd`,
  `scripts/presentation/materiaux_apprenti.gd`, `scripts/presentation/arme_tenue_3d.gd`.
- Interface : `scripts/presentation/style_azur.gd`, `ui/`,
  `assets/visual/interface/ORIGINE.md`, `assets/visual/arcane/ORIGINE.md`.
- Héros : `scenes/3d/aster.tscn`, `scripts/presentation/modele_aster.gd`,
  `animation_heros_3d.gd`, `tir_heros_3d.gd` et `shaders/aster_*.gdshader`.
  Source éditable et provenance : `assets/3d/sources/characters/aster/`.
  Les anciens générateurs `tools/blender/mage_sculpte.py` et leurs modules
  restent conservés, sans définir le héros actif.
- Génération du bestiaire : `tools/blender/bestiaire_sculpte.py`,
  `creatures_bestiaire.py`, `souverains_bestiaire.py` et `sculpture_bestiaire.py`.
  Origine : `assets/3d/ORIGINE_BESTIAIRE.md`.
