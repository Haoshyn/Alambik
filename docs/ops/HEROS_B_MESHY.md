# Héros B — étude Meshy texturée et articulée

État actuel : le modèle B est intégré au combat. Les premières sections décrivent les livraisons successives ; la dernière section décrit le contrôleur et l’asset actuels.

Le propriétaire a fourni `Meshy_AI_Starweave_Apprentice_0910143029_generate.glb` depuis Téléchargements. Le fichier est conservé sans modification dans `assets/3d/sources/characters/heros_b/meshy_original.glb`. Il contient 267 804 triangles, aucun matériau, aucune UV, aucun squelette et aucune animation.

## Résultat de cette étape

- Source modifiable : `assets/3d/sources/characters/heros_b/heros_b_texture.blend`. Le modèle haute définition y reste caché ; les images sont empaquetées.
- Étude exportée : `assets/3d/characters/heros_b_etude.glb`.
- Géométrie : **36 000 triangles**, **86.6 % de réduction**, une surface de matériau. Le nettoyage fusionne les doublons à très faible tolérance, traite les faces dégénérées et recalcule les normales avant réduction.
- Texture couleur et normales tangentes : **2048 × 2048**, dans `assets/3d/textures/heros_b/` et embarquées dans le GLB. Taille GLB : **11,827,720 octets**. Le fichier texturé est plus gros que le GLB gris malgré sa géométrie réduite.
- Palette du concept B : chapeau et manteau violets, écharpe turquoise, cheveux bruns, peau pêche, yeux ambrés, cuir brun, détails cuivre et fiole cyan.
- Les quatre vues d’argile du véritable maillage servent de supports à une peinture assistée par génération d’image. Les couleurs sont projetées avec pondération des normales et de la visibilité, puis cuites dans les UV : elles ne dépendent plus de la caméra à l’exécution. Les supports de peinture restent dans le sous-dossier `peintures/` de la source.

## Portée

Le héros actuel en combat reste inchangé. Le fichier `heros_b_etude.glb` conserve l’**étude statique texturée**. Une première version articulée séparée est maintenant disponible (voir ci-dessous). La réduction triangulée n’est pas une retopologie manuelle pour l’animation. Le bâton et l’adaptation finale au combat restent à réaliser. Le premier squelette et les six clips sont décrits ci-dessous.

Quelques raccords de peinture et ornements restent imparfaits à fort grossissement, notamment autour des accessoires et de la ceinture. Les reliefs et proportions viennent du modèle Meshy, qui n’est pas une copie géométrique exacte du concept. La lisibilité des mouvements et les performances Android ne sont pas encore validées.

## Contrôles

Blender 5.2.1 : 0 arête ouverte et 0 arête non-manifold sur les maillages source et réduit. Mesure échantillonnée de distance source vers réduit : moyenne 0,000321 et maximum 0,005914 pour une hauteur normalisée de 1,8. Cela mesure l’écart de surface, pas la qualité d’une future déformation.

Godot 4.7.1 : **31 suites, 12 881 assertions, zéro échec**, selftest compilé. Import du GLB et contrôle graphique réussis : couleur, normales, surface unique, étude sans squelette. Les messages de ressources non libérées à la fermeture persistent. L’import initial a été bloqué par un fichier Blender temporaire ; `tmp/meshy-heros/.gdignore` exclut maintenant les fichiers d’étude du scan de ressources.

Vingt graines ont une fin de partie enregistrée : dix victoires et dix défaites. **Un blocage du bot**, graine 4, salle 4, ennemi à 11 PV. La première commande a été interrompue avec le code 143 après la graine 14 ; les graines 15 à 20 ont été exécutées avec le même corps de script et zéro échec supplémentaire. Pas de SCRIPT ERROR dans les traces des parties. Les simulations headless ne chargent pas ce modèle 3D.

Des modifications de musique étaient réalisées en parallèle dans le workspace ; elles n’ont pas été modifiées par cette intervention.

## Reproduction

Depuis la racine, avec le binaire Blender disponible :

```sh
blender --background --python tools/blender/preparer_heros_meshy.py -- preparer
blender --background --python tools/blender/preparer_heros_meshy.py -- cuire
```

La seconde commande utilise les quatre peintures enregistrées ; elle n’appelle pas de service payant. Les fichiers originaux et les peintures sont requis. Le fichier de rapport est `assets/3d/sources/characters/heros_b/rapport.json`.

Captures Blender : `tmp/meshy-heros/trois_quarts_texture.png`, `face_texture.png`, `dos_texture.png`, `jeu_texture.png`. Captures Godot : `godot_studio.png`, `godot_jeu.png` dans le même dossier. Logs : `preparation.log`, `cuisson.log`, `verification.log`, `godot.log`, `vingt-runs.log` et `vingt-runs-fin.log`.

## Provenance

Géométrie générée avec Meshy à partir de la référence originale Alambik, puis modifiée dans Blender. Pour le compte gratuit décrit par le propriétaire, Meshy annonce une licence CC BY 4.0 avec attribution de Meshy : conserver cette provenance avec le modèle. Source : [offre gratuite Meshy](https://help.meshy.ai/en/articles/15696428-what-is-included-on-the-free-plan).

## Première articulation — 10 septembre 2026

- Source : `assets/3d/sources/characters/heros_b/heros_b_anime.blend`.
- Export : `assets/3d/characters/heros_b_anime.glb`, 12 608 292 octets.
- 19 os : racine, bassin, torse, tête ; cuisse/tibia/pied et bras/avant-bras/main de chaque côté ; trois pans de manteau.
- 36 000 triangles, matériau et textures inchangés, quatre influences maximum par sommet. Poids par zones anatomiques, lissés sur les arêtes puis normalisés. Visage et chapeau suivent la tête. Pas de squelette facial ou de doigts individuels.
- Six actions à 30 images/seconde : `repos` (2 s), `course` (0,8 s), `attaque` (0,6 s), `touche` (0,4 s), `mort` (1,2 s), `victoire` (2 s). Les actions sont exportées par pistes NLA ; l’action repos est sélectionnée à l’ouverture du Blender.
- Course sur place avec trajectoires de pieds et flexion des genoux ; mouvement léger des pans. Correction verticale de chaque image pour placer le point le plus bas au sol. Chute recentrée autour du bassin.

Reproduction : `blender --background --python tools/blender/animer_heros_meshy.py`. L’étape nécessite la source texturée. Aucun service Meshy ni paiement.

Contrôle Blender sur toutes les images des six clips : écarts au sol inférieurs à 0,000001 unité et premières/dernières géométries identiques pour repos et course. Ces mesures ne prouvent pas l’absence d’intersections entre vêtements et membres. Les doigts qui s’étiraient dans la première pose de victoire ont été corrigés en supprimant leur influence résiduelle du manteau. Rapport de génération : `rapport_animation.json` à côté du Blender ; contrôle des poses : `tmp/meshy-heros/controle_rig.json`.

Godot importe un Skeleton3D à 19 os et les six animations nommées ; couleur et normales restent chargées. Vidéo produite à partir du GLB dans Godot, pas d’une simulation d’image. Contrôles : `tmp/meshy-heros/controle-animation.log`, `video-animation.log`, `controle-rig-blender.log`.

Il s’agit d’une **première version animée à revoir visuellement**, pas d’une validation de production Android. Les manches et accessoires Meshy peuvent encore se déformer dans les gestes amples ; il n’y a ni simulation de tissu ni contrôle complet des collisions du manteau. L’attaque est un geste de bras sans bâton. L’intégration dans le combat, le réglage de la cadence/vitesse avec le jeu et le contrôle sur téléphone restent à faire.

Copie utilisateur : `/home/giovanni/Documents/Heros_Alambik_B/Animation/` (Blender, GLB, aperçu vidéo et consignes).

Contrôles du projet après articulation : `./verifier.sh` termine avec 31 suites, 12 881 assertions, zéro échec et selftest compilé (avertissements habituels de ressources à la fermeture). `./sondes/vingt_runs.sh` termine les 20 graines : 10 victoires, 10 défaites, mais **3 signalements de blocage du bot (graines 4, 15, 20)**, donc code de sortie 3. Pas de SCRIPT ERROR. Ces runs headless ne chargent pas le nouveau modèle et ne valident pas son rendu. Logs : `tmp/meshy-heros/verification-animation.log` et `runs-animation.log`.

## Correction de l’articulation V2

Le propriétaire a signalé des plis d’épaule mal placés, les bras trop écartés et une flexion des genoux incohérente. La première vérification de bouclage/contact au sol n’était pas suffisante pour valider ces mouvements.

Corrections dans `tools/blender/animer_heros_meshy.py` :

- Pivots de hanche/genou/cheville et des bras recentrés en profondeur sur le corps (l’origine du Meshy est centrée sur sa boîte globale, pas sur ses articulations).
- Transition des poids bras/torse déplacée vers l’épaule ; les parties hautes de la manche suivent davantage le bras.
- Bras abaissés de 0,36 radian depuis la pose de référence, coudes légèrement fléchis ; balancement opposé à la jambe de même côté.
- Branche de flexion positive pour le genou, bassin abaissé de 3,5 cm pendant la course pour garder une chaîne de jambe atteignable. Flexion mesurée entre 30,92° et 68,22°, sans inversion sur les 25 images de la boucle.
- Séparation des pans avant/arrière et des jambes par leurs positions en profondeur, en plus des pans latéraux. Cela réduit les influences croisées entre pantalon et manteau.

Le générateur vérifie maintenant la direction du genou à partir des positions évaluées hanche/genou/cheville et l’écart latéral coude/épaule à chaque image de course (maximum mesuré 3,91 cm). Le contrôle Blender des six clips confirme le raccord exact des boucles et le point bas au sol à une tolérance de 0,000001 unité. Ce ne sont toujours pas des tests exhaustifs des collisions du vêtement.

GLB V2 : 12 612 224 octets, toujours 19 os et 36 000 triangles. Fichiers `_v2.blend`, `_v2.glb` et `Apercu_animations_v2.mp4` copiés dans `/home/giovanni/Documents/Heros_Alambik_B/Animation/`. La vidéo Godot montre la course de face, de profil et de trois-quarts, puis les autres gestes. L’ancienne livraison reste disponible pour comparaison. Pas de remplacement du personnage de combat.

Export V2 recalé à t=0 (`export_anim_slide_to_zero`) pour supprimer la première image maintenue et retrouver une course de 0,8 s. Le contrôle de la boucle prend sa durée réellement importée, pas une durée supposée. Contrôle Godot réussi : 25 échantillons, deux genoux dans le bon sens, coudes rapprochés et poses initiale/finale identiques. Log : `tmp/meshy-heros/controle-course-godot-v2.log`.

Vérification V2 : 31 suites, 12 881 assertions, zéro échec, selftest compilé. Vingt simulations terminées : 9 victoires, 11 défaites ; un signalement de blocage du bot (graine 13, salle 8), code de sortie 1. Aucun SCRIPT ERROR dans les runs. Les simulations ne chargent pas ce modèle séparé. Logs : `verification-animation-v2.log` et `runs-animation-v2.log` dans `tmp/meshy-heros/`.

## Essai intégré au combat

À la demande du propriétaire, `Visuels3D.HEROS_MODELE` pointe maintenant vers `heros_b_anime.glb`. `monde_3d.gd` utilise ce réglage lors de la création du héros. L’ancien GLB reste disponible. Échelle uniforme 1 conservée, hauteur source 1,8, pas de changement des collisions ou des statistiques de jeu.

`Visuels3D.HEROS_CADENCE_COURSE` vaut 1,0 pour conserver le cycle nominal de 0,8 s ; la vitesse du personnage module encore la lecture. Une fin de rafale pendant le déplacement ne lance plus l’attaque visuelle et ne remet donc plus la course au début. Les noms d’os de la sonde d’intégration sont adaptés au squelette B.

La sonde `sondes/integration_3d.gd` vérifie le modèle effectivement chargé en salle, les 19 os et les six clips, le mouvement des articulations, la cadence, la continuité pendant une rafale mobile, l’attaque à l’arrêt, l’ancrage aux collisions, le nettoyage des proxies et le profil réduit. Résultat : zéro échec. Des avertissements de ressources/GL non libérées persistent à la fermeture. Captures : `tmp/atelier-validation.png`, `tmp/mage-profil-en-jeu.png`, `tmp/atelier-portail-reduit.png` ; trace `tmp/meshy-heros/integration-combat.log`.

Les six clips sont présents dans l’asset ; les états déjà gérés par le proxy pilotent repos/course/attaque/touche/mort. L’écran de fin met toujours la partie en pause : cette étape n’ajoute pas de mise en scène de victoire. Le bâton reste absent. Les performances sur téléphone ne sont pas encore mesurées.

Essai PC séparé : `tmp/meshy-heros/essai_jouable.gd`, lancé sans bot, avec sauvegarde désactivée et menu pause ouvert. Le joystick tactile est émulé par cliquer-glisser dans la moitié basse gauche.

Validation de l’intégration : `./verifier.sh` passe (31 suites, 12 881 assertions, zéro échec et selftest compilé). Les vingt runs sont terminés : 9 victoires, 11 défaites ; 2 signalements de blocage du bot, aucun SCRIPT ERROR. Détail :

- graine 4 : BLOCAGE salle 4 apres 120s : ennemis restants=1 (304.0, 498.0)(pv=11)  heros=(669.0, 874.0) tirs=65 touches=58 murs=5 perdus=2
- graine 5 : BLOCAGE salle 16 apres 120s : ennemis restants=4 (886.0, 863.0)(pv=30) (1002.0, 1021.0)(pv=18) (845.0, 1744.0)(pv=27) (1082.0, 1585.0)(pv=8)  heros=(742.0, 1273.0) tirs=337 touches=279 murs=54 perdus=4

Logs : `tmp/meshy-heros/verification-integration.log`, `runs-integration.log`, `integration-combat.log`. Une capture de 12 secondes en vraie partie avec bot, sans sauvegarde, est livrée dans `/home/giovanni/Documents/Heros_Alambik_B/Animation/En_combat.mp4`. La fenêtre d’essai utilisateur est lancée séparément, sans bot et initialement en pause.

## Bâton et fluidité

La demande suivante ajoute le bâton du concept (`docs/art/heros_b_meshy/04_baton.png`) et assouplit les mouvements.

- `tools/blender/baton_heros_meshy.py` construit le fût sombre, la prise, les bagues et la monture cuivre, l’orbe violet et les pointes. Le maillage est déformé rigidement par `main_droite`, comme un accessoire tenu. Les doigts de la main Meshy sont repliés dans la géométrie de base ; ce n’est pas un rig de doigts indépendant.
- Corps : 36 000 triangles ; bâton : 3 572 ; total : **39 572 triangles**. Toujours 19 os. Le bâton ajoute quatre matériaux simples. GLB : **12 743 268 octets**.
- Course : la trajectoire de retour du pied conserve maintenant la vitesse horizontale aux raccords avec l’appui. Petit rebond du bassin, rotations opposées bassin/torse ; main droite compensée pour calmer le balancement du bâton. Les genoux restent dans la bonne branche de flexion, vérifiée par le générateur.
- Dans le proxy : fondus course/repos de 0,18 s, entrée du tir de 0,12 s, cadence des pas interpolée. Des tirs rapprochés partagent le geste en cours ; ils ne ramènent plus le bras brutalement au début. Cela privilégie un geste continu plutôt qu’un geste complet par projectile d’une rafale.

Contrôle Blender de chaque image des six clips : liaison rigide à la main vérifiée (erreur maximale inférieure à 0,000001 unité), pointe du bâton toujours au-dessus du sol (minimum mesuré 0,00386 unité pendant la course). Cela ne prouve pas l’absence de toute intersection entre le bâton et les vêtements. La main est une prise simplifiée issue du Meshy.

La sonde d’intégration vérifie la présence du bâton et la continuité des tirs rapprochés. Son contrôle du bras attend désormais la fin du fondu avant de comparer les poses : `seek()` seul ne fait pas avancer ce fondu. Sonde finale : **zéro échec**. Les avertissements de ressources/GL à la fermeture persistent.

Sources : `heros_b_anime.blend`, `animer_heros_meshy.py` et `baton_heros_meshy.py`. Copie utilisateur : fichiers `Heros_Alambik_B_baton.blend` / `.glb` dans `Documents/Heros_Alambik_B/Animation/`. Le modèle du combat est mis à jour via le même chemin actif.

Validation finale bâton/fluidité : 31 suites, 12 881 assertions, zéro échec ; selftest compilé ; sonde d’intégration graphique à zéro échec. Vingt runs terminés : 10 victoires, 10 défaites, zéro blocage signalé et aucun SCRIPT ERROR. Logs : `tmp/meshy-heros/verification-baton.log`, `integration-baton.log`, `runs-baton.log`, `controle-baton-blender.log`.

Vidéos livrées : `Documents/Heros_Alambik_B/Animation/Apercu_baton.mp4` (poses et course), `En_combat_baton.mp4` (12 secondes de vraie partie avec bot). Une fenêtre d’essai sans bot, sans sauvegarde, a été relancée en pause avec le nouvel asset.


## Reprise de la fluidité et des matières

Le propriétaire a demandé une amélioration forte du personnage et de ses animations. Cette reprise conserve la silhouette et les textures du modèle B, et remplace son pilotage en jeu. Après le premier aperçu, le propriétaire a précisé les défauts : manche dans la main ouverte, intersection avec le chapeau, genoux trop bas et allure de marche. Le résultat final décrit ci-dessous tient compte de ces corrections.

- **Animation Blender** : clés à 60 Hz ; course de 0,533 s (contre 0,8 s), repos de 3 s, attaque de 0,5 s. Foulée de 40 cm par appui, genoux remontés de 0,43 à 0,53 m avec longueurs et poids adaptés. Chaque pied reste en appui pendant 34 % du cycle : il existe désormais une phase aérienne, jusqu’à 3,79 cm au-dessus du sol. Retour horizontal du pied avec vitesse et accélération raccordées, flexion du genou contrôlée. Le rebond du bassin n’est plus annulé par une remise au sol de tout le corps à chaque image. Torse penché et en contre-rotation, compression/étirement de 2,5 %, bras gauche plus ample ; pans latéraux accompagnant les cuisses et pan arrière projeté derrière. Nouvel os `chapeau` à poids progressifs sur la calotte : le bord reste solidaire de la tête. Les attaques ont une impulsion plus rapide et une récupération plus longue.
- **Main et bâton** : les anciens doigts ouverts sont retirés et remplacés par un gant à paume, raccord de poignet, quatre doigts recourbés et pouce opposé. Le manche passe devant la paume ; l’orbe est inclinée vers l’extérieur et vers l’avant. L’attaque et la victoire compensent les rotations du bras pour éviter le chapeau. Main et bâton restent liés à `main_droite`. Corps 35 543 triangles, bâton 3 572, gant 1 968 : **41 083 triangles**, quatre influences maximum, 20 os ; GLB de 12 828 192 octets. Le nouveau gant ajoute deux surfaces simples.
- **Contrôleur** : `scripts/presentation/animation_heros_3d.gd` construit un `AnimationTree`. Le mélange repos/course est continu, la cadence est lissée ; les tirs et les impacts utilisent des gestes limités aux os du haut du corps. Les jambes et le bassin conservent exactement la même animation pendant ces gestes. Les rafales rapprochées ne redémarrent pas l’attaque. La mort prend la priorité et conserve sa dernière pose. Les clips complets restent consultables dans le GLB avec un `AnimationPlayer`, mais le combat passe par l’arbre.
- **Déplacement affiché** : `suivi_visuel_2d.gd` conserve deux positions de physique et les interpole pour le modèle et la caméra. La seconde interpolation native de la caméra est désactivée dans ce chemin. Les téléportations se recalent immédiatement. La rotation diagonale tient compte de la projection ; léger mouvement d’inclinaison dans les virages. Ces changements concernent le rendu, pas les collisions ou les statistiques.
- **Matières** : `shaders/heros_matiere.gdshader` conserve les textures et la surface unique du corps. Le cuivre reçoit un reflet plus serré ; le tissu un reflet doux aux angles rasants. Les normales sont atténuées et les textures utilisent les mipmaps et le filtrage anisotrope. La classification du cuivre repose sur les couleurs de la texture : il ne s’agit pas d’une nouvelle carte PBR peinte à la main. Ce shader est appliqué par le proxy Godot ; le GLB autonome garde son matériau standard.

Vérifications Godot 4.7.1 :

- `./verifier.sh` : 31 suites, 12 882 assertions, zéro échec ; selftest compilé.
- `sondes/fluidite_heros_3d.gd` en headless : **609 assertions, zéro échec**. Comparaison de deux squelettes avec/sans tirs et impacts, rafales, état de mort, phase de course identique à 30/60/120 fps, interpolation et téléportation.
- `sondes/integration_3d.gd` avec rendu : **zéro échec**, modèle effectif, gestes superposés, liaison caméra/modèle, orientation et nettoyage. Pose finale de mesure : 115 appels de dessin et 37 164 primitives sur Radeon 610M, sans valeur de référence Android.
- `tools/blender/controler_heros_meshy.py` : 922 échantillons, y compris entre les clés. Boucles repos/course identiques aux extrémités et genoux dans le bon sens. Pénétration maximale du pied inférieure à 0,71 mm entre les clés ; suspension maximale de 3,79 cm. Le talon du bâton reste au moins à 9,51 cm du sol (17,69 cm pendant la course) ; erreur de liaison à la main inférieure à 0,000001 unité. Aucune intersection bâton/chapeau sur les six clips ni dans **256 combinaisons** course/attaque et course/impact (mélanges à 50 et 100 %).
- `./sondes/vingt_runs.sh` : vingt fins de partie (10 victoires, 10 défaites), **1 blocage du bot** signalé (graine 4, salle 4, ennemi à 11 PV), aucun `SCRIPT ERROR`. Code de sortie 1. Log final : `vingt-runs-final.log`. Ces runs headless ne chargent pas le rendu 3D. Les blocages de bot sont aussi présents dans les validations antérieures ; cette reprise ne corrige pas l’IA.

Les diagnostics de ressources non libérées à la fermeture persistent. Les contrôles d’appui ne prouvent pas l’absence de toutes les intersections entre vêtements et membres. Le maillage Meshy n’a pas reçu de retopologie manuelle ; la course reste stylisée et la cadence ne garantit pas un verrouillage exact des pieds sur la distance parcourue. Pas de validation sur téléphone physique, ni de garantie de 60 fps Android.

Reproduction depuis la racine, avec les binaires disponibles dans le PATH :

```sh
blender --background --python-exit-code 1 --python tools/blender/animer_heros_meshy.py
blender --background --python-exit-code 1 --python tools/blender/controler_heros_meshy.py
godot --headless --path . --import
godot --headless --path . --script sondes/fluidite_heros_3d.gd
godot --path . --script sondes/integration_3d.gd
godot --path . --audio-driver Dummy --disable-render-loop --fixed-fps 60 --script sondes/apercu_heros_3d.gd
ffmpeg -framerate 60 -i tmp/heros-polissage/images/%04d.png -c:v libx264 -crf 18 -pix_fmt yuv420p -movflags +faststart tmp/heros-polissage/apercu.mp4
```

`sondes/apercu_heros_3d.gd` produit douze secondes du modèle et du contrôleur utilisés en combat : repos/course, profil, course avec tirs et impact, arrêt et rafales. Le dossier de capture contient un `.gdignore` pour éviter l’import des centaines d’images par l’éditeur. Logs et mesures : `tmp/heros-polissage/`. API du mélange : [AnimationTree](https://docs.godotengine.org/en/stable/tutorials/animation/animation_tree.html).
