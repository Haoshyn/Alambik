# Retouches graphiques — 10 septembre 2026

## Présentation

- L’illustration originale `accueil_valide.png` reste intacte et fournit les vignettes de navigation et les boutons illustrés. Le nouveau `accueil_fond_portrait.png`, dérivé de cette illustration sans interface incrustée, remplit la surface d’Aventure en conservant ses proportions. Les contrôles sont placés indépendamment de l’image et dans la zone sûre. Plus de bandes internes en haut et en bas de l’accueil ; les bandes système sur les formats autres que 9:16 restent celles du projet.
- La navigation illustrée est un contrôle commun à Équipement, Aventure, Maîtrises et Sorts. Son indicateur actif change avec la page. Les fenêtres modales la désactivent comme auparavant.
- Un emplacement d’équipement vide n’a aucune icône de bijou. L’état de collection vide est uniquement textuel.
- `tools/generer_icones.py` produit 83 SVG originaux, chargés par identifiant via `StyleAzur.glyphe`. Ricochet, Météores et Courageux ont leurs silhouettes propres. Les listes de sorts, les emplacements équipés, les récompenses et les boutons de combat partagent les mêmes glyphes. Une fusion conserve le glyphe de son amélioration ; les cartes de fusion y ajoutent le médaillon élémentaire.

## Combat

- Salle de campagne : 1260 × 1900, contre 1500 × 2100 précédemment. Trois compositions de trois obstacles centraux, séparés par au moins 240 unités. Les retraits latéraux sont de vrais rectangles physiques ; le contour triangulé du sol et ses bordures consomment ces mêmes rectangles. Les boss et les Épreuves conservent leur espace dégagé. La Mine garde ses bords libres pour les apparitions.
- Caméra à 48° : la projection des positions logiques reste identique grâce à `Pont3D`. La vue montre davantage les silhouettes des modèles.
- Mage : chapeau souple rabattu, boucles de cheveux, pèlerine, broche, chaîne et ornements du manteau. Source Blender et GLB régénérés ; 54 734 triangles, 11 surfaces, six animations. `tools/blender/heros_azur.py` permet de reproduire le modèle.
- Projectiles : le proxy spécifique dessine un cœur clair et une coque teintée, puis un ruban sur les positions réelles de la trajectoire. Les tirs ennemis ont un cœur en losange. La magie de base du héros est violette. Les effets réduits raccourcissent les rubans et diminuent les halos.
- Portail : nouvelle arche de calcaire et cuivre gravé, voile ovale animé et particules montantes. `tools/blender/portail_azur.py` régénère sa source et son GLB ; `build_all.py` appelle également ce constructeur. Les effets réduits passent de douze à quatre particules et ralentissent le voile.
- Transition de salle : fond Cuivre & Azur, tracé de porte et petit sceau au-dessus du titre. Les délais et les règles de passage restent ceux de l’orchestrateur.

## Vérification

Godot 4.7.1, profil isolé dans `tmp/profil/`. Les changements d’équilibrage effectués parallèlement dans le workspace sont conservés.

- `verifier.sh` via `tools/verifier_windows.ps1` : 30 suites, 12 021 assertions, zéro échec ; selftest sans erreur de compilation.
- `sondes/interface_azur.gd` : 18 contrôles, zéro échec.
- `sondes/formats_mobile.gd` : 1 378 contrôles, zéro échec, sur cinq formats ; navigation, recouvrements, fenêtres modales et lancement du combat.
- `sondes/retouches_graphiques.gd` : 11 contrôles, zéro échec ; absence de bijoux fictifs, animation du mage et portail réduit ; captures studio et transition.
- `sondes/integration_3d.gd` : zéro échec, projections, animation réelle, nettoyage et portail. Dernière scène : 116 appels de dessin, 22 600 primitives sur RTX 4070 SUPER. Pas une mesure Android.

Les sondes de parties ont exposé les limites de l’ancien bot devant plusieurs obstacles : marges de projectile utilisées pour un personnage plus large et tir prolongé sans impact. `sondes/navigation_bot.gd` lui fournit désormais un trajet par les coins libres des obstacles, sans modifier les commandes humaines ni téléporter le personnage. Des tests vérifient le trajet au contact de chaque obstacle vers le portail.

`vingt_runs.sh` via `tools/verifier_windows.ps1 -VingtRuns` : **20 fins de partie, zéro blocage et zéro erreur de script**. La série finale compte 11 victoires et 9 défaites du bot ; elle valide le déroulement, pas la difficulté pour un humain. Détail : `tmp/retouches-vingt-runs-definitifs.log`.

Aperçu local : `tmp/retouches-apercu.html`. Les captures sont de vrais rendus Godot ; le studio du mage et du portail sert à inspecter les modèles agrandis.

Limites : validation sur téléphone physique encore à faire. Les diagnostics Windows de certificats et de ressources au nettoyage graphique restent présents ; aucun de ces contrôles ne mesure la batterie, la chauffe ou la fluidité sur Android. Aucune APK/AAB n’a été produite par cette retouche.

## Seconde passe — mage, tirs et portail

Cette passe remplace le mage ornementé et l'arche décrits plus haut. Les captures de référence Archero/Meowgik ont servi à étudier les proportions et la lisibilité ; aucun de leurs assets n'est intégré. Référence consultée : https://www.androidauthority.com/archero-guide-heroes-abilities-1086651/.

- Mage entièrement reconstruit en géométrie Blender : grosse tête sans bouche, mains et bottes larges, robe violette, chapeau courbé et écharpe turquoise. 8 816 triangles, dix surfaces ; source `.blend` et GLB disponibles. Six animations conservées, pivots adaptés et geste de bâton dirigé vers l'avant.
- Le déplacement commande l'orientation. À l'arrêt, le mage garde sa direction ; le prochain tir l'oriente vers sa cible et relance le geste même pendant une salve. La barre de vie dégage le chapeau.
- Projectiles ennemis rouges, cœur crème et contour sombre opaque. Le mélange alpha conserve leur contraste sur sol clair ; les effets réduits gardent le corps et le contour. La taille visuelle augmente sans changer les collisions.
- Portail à anneau continu azur/cuivre, bord lumineux et centre sombre animé ; 5 652 triangles, trois surfaces. Douze particules, quatre en effets réduits.

Validation finale sur Godot 4.7.1 : 30 suites, 12 027 assertions, zéro échec ; selftest compilé. Quatre assertions ajoutées sur les directions de marche, l'arrêt et la visée. Sonde studio : 11 contrôles, zéro échec. Intégration graphique : zéro échec, vérification du bras à l'attaque et du redémarrage des salves ; 120 appels de dessin et 15 940 primitives sur la scène capturée (PC, pas une mesure Android).

Vingt runs exécutées : vingt fins de partie, vingt défaites, aucune erreur de script, **un blocage du bot en salle 4, graine 4**. Reproduit avec le rendu headless, qui ne crée pas le monde 3D. Cette réserve sur la navigation du bot reste ouverte ; la série ne constitue pas une validation de difficulté. Les réglages de combat modifiés parallèlement dans le dossier sont conservés. Logs : `tmp/mage-verification.log`, `tmp/mage-integration.log`, `tmp/mage-studio.log`, `tmp/mage-vingt-runs.log`, `tmp/mage-graine4.log`.

Aperçu actualisé : `tmp/mage-apercu.html`. Captures Godot de face, de dos, en attaque, en salle et du portail. Les avertissements de certificats Windows et de ressources au nettoyage persistent. Validation sur téléphone physique non effectuée.

## Troisième passe — proportions humaines et articulation

La demande du propriétaire remplace ici la silhouette compacte précédente et l'ancienne consigne de pixel art du document de direction artistique. Nouveau mage original à tête réduite, menton et pommettes modelés, iris, sourcils, mèches courbes, cou dégagé, taille marquée, manteau ouvert et membres continus. Les surfaces subdivisées ont des normales lissées ; MSAA 4× pour les contours 3D. Source Blender et GLB reconstruits : 77 244 triangles avant les LOD importés par Godot, dix surfaces, six animations.

Le squelette comporte douze os. Chaque jambe possède hanche, genou et cheville, chaque bras épaule et coude. Les poids sont mélangés autour des articulations et dans le manteau. Les transformations des maillages sont appliquées avant le skinning pour conserver la prise du bâton. La marche calcule la flexion à partir d'une trajectoire de pied, alterne les appuis et conserve le buste stable ; elle ne met aucune animation d'échelle sur le corps. L'attaque articule épaule et coude. La cadence s'adapte à la vitesse de déplacement ; la marche est prioritaire lorsqu'on repart et l'orientation tourne progressivement.

`tools/blender/heros_azur.py` possède le constructeur, le squelette et les animations du mage ; `build_all.py` les appelle aussi lors d'une reconstruction globale. Les animations rigides du bestiaire restent séparées.

Validation Godot 4.7.1 : `verifier.sh`, 30 suites, 12 032 assertions, zéro échec ; selftest compilé. `sondes/mage_articule.gd` : 80 contrôles, zéro échec, dont flexion du genou, compensation de la cheville et stabilité du buste sur 32 poses. `sondes/integration_3d.gd` : zéro échec ; 116 appels de dessin et 20 444 primitives sur la capture PC. Logs : `tmp/mage-humain-verification.log`, `tmp/mage-articule.log`, `tmp/mage-humain-integration.log`.

Aperçu animé : `tmp/mage-humain-apercu.html` ; 32 captures Godot avec pause, choix de pose et vitesse de lecture. L'aperçu ne remplace pas une mesure sur téléphone : le coût du MSAA et du nouveau modèle reste à contrôler sur appareil. Les avertissements Windows de certificats et de ressources à la fermeture persistent.


Série finale `vingt_runs.sh` : vingt fins de partie (9 victoires, 11 défaites), aucune erreur de script ; un blocage du bot en salle 2, graine 3, avec un ennemi restant à 1 PV. Réserve sur la navigation automatique conservée ; ces runs headless ne chargent pas le rendu 3D. Détail : `tmp/mage-humain-vingt-runs.log`.

## Quatrième passe — refonte complète et volume de profil

Le propriétaire rejette la silhouette précédente sur des captures de face et de profil. La nouvelle construction remplace tous ses vêtements, son visage, sa coiffure, son couvre-chef, ses membres et son bâton : mage à capuche profonde, manteau bleu-vert ouvert, pourpoint bleu nuit, manches épaisses, jambes raccourcies et accessoires de cuivre. La géométrie donne au torse, au bassin et au dos une profondeur plus importante. Le constructeur réutilise les outils de génération et adapte le squelette articulé aux nouveaux volumes.

Le proxy du héros utilise maintenant une échelle uniforme : l'anamorphose du sol n'est plus appliquée au personnage. Les autres acteurs conservent leurs réglages. Une assertion vérifie cette échelle. La sonde `mage_articule.gd` capture les quatre vues cardinales ; l'intégration ajoute une capture de profil avec la caméra du jeu.

Source et GLB régénérés : 115 780 triangles avant LOD Godot, dix surfaces, six animations. Validation : 30 suites, 12 033 assertions, zéro échec ; selftest compilé. Sonde studio : 80 contrôles, zéro échec ; intégration graphique : zéro échec, 120 appels de dessin et 21 188 primitives sur la capture PC. Ces mesures ne valident pas les performances sur téléphone.

Aperçu : `tmp/mage-capuche-apercu.html`, avec marche animée, vues de face/profil/dos et comparaison en salle. Logs : `tmp/mage-capuche-verification.log`, `tmp/mage-capuche-studio.log`, `tmp/mage-capuche-integration.log`. Les diagnostics de certificats et de ressources au nettoyage graphique restent présents.

## Mage manga — transposition de la référence approuvée

Référence validée explicitement par le propriétaire : `assets/3d/references/mage_valide.png`. Elle remplace la capuche rejetée et les silhouettes précédentes. Le modèle reprend chapeau violet courbé, grande tête, visage manga avec bouche et yeux violets, mèches plates en pointe, veste à pans et liserés, écharpe turquoise, bottes et gants sombres, bijoux de cuivre et baguette à cristal violet.

Le visage sculpté possède des UV et une texture peinte. Un atlas distinct fournit le tissu violet, la soie turquoise, le cuir et les cheveux. Ces deux images originales sont dans `assets/3d/textures/mage/` ; elles sont embarquées dans le GLB et empaquetées dans le `.blend`. Les textures ont été générées à partir de la référence approuvée ; la géométrie et le squelette sont construits par Blender. Le résultat en jeu est une reconstruction 3D, distincte du rendu illustré de référence.

`tools/blender/mage_manga.py` contient la géométrie, les UV, les poids et les animations. `heros_azur.py` reste le point d'entrée. Le générateur global isole les matériaux du héros pour ne pas texturer involontairement le bestiaire lors d'un build complet ; contrôle Blender de l'isolation et de l'empaquetage réussi.

Quatorze os : racine, hanches, genoux, chevilles, épaules, coudes, poignets et écharpe. Six animations : repos, course, attaque, touche, mort et victoire. La main avance et le poignet oriente la baguette lors du tir. Les liserés suivent les poids du manteau ; la marche conserve un buste stable. Les poses sont interpolées par Godot et la cadence suit la vitesse de déplacement. Échelle uniforme et MSAA 4× conservés.

Modèle : 90 420 triangles avant LOD Godot, douze objets de matériau, GLB de 6 925 908 octets. Les douze objets peuvent contenir plusieurs surfaces (le visage distingue le dos de la tête). Rendu de contrôle PC : 122 appels de dessin et 24 870 primitives dans la salle. La fluidité, la chauffe et le coût du MSAA sur téléphone physique ne sont pas mesurés.

Validation finale Godot 4.7.1 : 30 suites, 12 033 assertions, zéro échec ; selftest compilé. `mage_articule.gd` : 83 contrôles, zéro échec, dont présence des textures, chaîne du poignet, genoux et chevilles, stabilité des 32 poses. Intégration graphique : zéro échec, dont déplacement effectif de la main pendant l'attaque. Les avertissements Windows de certificats et de ressources au nettoyage persistent.

Vingt runs : vingt fins de partie, sept victoires et treize défaites ; aucune erreur de script, un blocage du bot en salle 2 (graine 3, ennemi à 1 PV). Ce problème de navigation automatique reste ouvert. Les simulations headless ne chargent pas le modèle 3D. Logs : `tmp/manga-verification.log`, `tmp/manga-construction.log`, `tmp/manga-studio.log`, `tmp/manga-integration.log`, `tmp/manga-vingt-runs.log`.

Aperçu du modèle réellement rendu : `tmp/mage-manga-apercu.html` — référence approuvée, repos, marche animée, attaque, quatre côtés et vues en salle.

## Mage compact — lisibilité depuis la caméra du jeu

Correction de la silhouette trop haute : jambes ramenées à 62 % de leur hauteur précédente au-dessus des semelles, buste à 70 %, tête élargie de 14 %. Le haut du chapeau est raccourci. Le visage et le chapeau sont relevés de 14°, la frange remontée et le bord avant raccourci pour dégager les yeux à l'inclinaison de jeu de 48°. Violet, écharpe turquoise et baguette conservés.

L'atlas des matières est remplacé par une peinture plus douce et mate, sans trame grossière. Les raccords UV passent derrière le costume et l'écharpe. Squelette ajusté aux nouvelles proportions, marche recalculée sur les nouvelles longueurs des jambes ; les six animations sont conservées. Barre de vie abaissée pour suivre la nouvelle silhouette. GLB et source Blender régénérés : 90 420 triangles avant LOD, douze objets de matériau, 5 647 636 octets pour le GLB.

Validation : 30 suites, 12 855 assertions, zéro échec ; compilation et selftest réussis. Studio : 83 contrôles, zéro échec ; intégration 3D : zéro échec. La sonde ajoute un gros plan à 48°, disponible dans `tmp/mage-vue-jeu.png`. Aperçu avec ancienne/nouvelle silhouette et marche : `tmp/mage-compact-apercu.html`. Les diagnostics de certificats et de ressources au nettoyage persistent ; performances sur téléphone non mesurées.

Vingt simulations terminées : neuf victoires, onze défaites, aucune erreur de script. Deux blocages de navigation du bot restent ouverts : graine 3, salle 2, ennemi à 1 PV ; graine 5, salle 13, ennemi à 31 PV. Le script signale donc deux runs en échec sur vingt. Les simulations headless ne chargent pas le modèle. Logs : `tmp/compact-verification.log`, `tmp/compact-studio.log`, `tmp/compact-integration.log`, `tmp/compact-vingt-runs.log`.

## Correction du visage pâle et des proportions de tête

Après rejet du visage précédent : largeur de tête réduite d'environ 18 %, hauteur de 10 %, profondeur de 8 %. Cheveux et chapeau suivent les nouvelles proportions. Oreilles plus petites et rapprochées du crâne. Nouvelle texture de visage au teint pêche bronzé, yeux moins larges et moins inclinés, sans reflets blancs peints sur la peau. Le dos de la tête utilise le bord uni de la même texture. Éclairage de contrôle conservé pour comparer les deux versions ; costume, corps compact et animations conservés.

GLB et source Blender reconstruits. Captures à 48°, de profil et en salle vérifiées. Aperçu : `tmp/mage-visage-apercu.html`, comparaison avec `tmp/mage-visage-avant.png`. Validation : 30 suites, 12 855 assertions, zéro échec ; 83 contrôles studio et intégration 3D sans échec. Les diagnostics existants de certificats et de ressources au nettoyage persistent. Logs : `tmp/visage-verification.log`, `tmp/visage-studio.log`, `tmp/visage-integration.log`.

Vingt runs terminées : sept victoires, treize défaites ; aucune erreur de script. Deux blocages du bot : graine 3 en salle 2 (un ennemi à 1 PV), graine 13 en salle 8 (trois ennemis restants). Le script retourne un échec pour ces deux blocages. Détail : `tmp/visage-vingt-runs.log`. Ces simulations headless ne valident pas le rendu du personnage.

## Visage reconstruit et chapeau abaissé

Le propriétaire rejette encore le visage et autorise un regard à peine visible sous le chapeau. Suppression de la texture faciale plaquée : nouveau maillage à plan frontal plus plat, mâchoire courte, cou raccordé, petits yeux distincts en volume. Le bord du chapeau descend devant le regard à 48° ; le visage n'est plus relevé vers la caméra. Trois mèches de frange asymétriques et quelques masses latérales remplacent les nombreuses bandes texturées. Épaules affinées. La course utilise un appui à vitesse constante et une phase de retour du pied avec raccord de vitesse, en conservant les articulations.

Source Blender et GLB reconstruits : 89 956 triangles avant LOD, douze objets de matériau, 4 519 160 octets. Le contrôle de textures attend désormais les trois matières du costume ; le visage et les cheveux utilisent des matériaux unis. Aperçu réel : `tmp/mage-refonte-apercu.html`, capture à 48° : `tmp/mage-refonte.png`. Cette passe reste une proposition visuelle, sans validation artistique du propriétaire ni équivalence revendiquée avec l'illustration approuvée.

Validation : 30 suites, 12 855 assertions, zéro échec ; selftest compilé ; 83 contrôles studio et intégration 3D sans échec. Vingt runs terminées : onze victoires, neuf défaites, un blocage du bot en salle 11, graine 10, avec deux ennemis restants ; le script retourne donc un échec. Aucune erreur de script, diagnostics de certificats et ressources au nettoyage toujours présents. Logs : `tmp/refonte-verification.log`, `tmp/refonte-studio.log`, `tmp/refonte-integration.log`, `tmp/refonte-vingt-runs.log`.

## Petit mage animal — nouvelle construction arcade

Le propriétaire demande de repartir directement du modèle d'un personnage d'Archero adapté en mage. Référence choisie : Meowgik, qu'il avait cité auparavant, visible sur la fiche de personnage du [guide Archero](https://www.androidauthority.com/archero-guide-heroes-abilities-1086651/). Nouvelle géométrie dans `tools/blender/mage_arcade.py` : robe évasée d'un seul tenant, membres courts, tête animale sombre, petits museau et oreilles, yeux jaunes, chapeau conique recourbé, ruban doré, écharpe turquoise et baguette. Matériaux unis à la place des textures peintes précédentes. Aucune extraction de modèle du jeu ; reconstruction Blender. La validation artistique reste ouverte.

`mage_manga.py` fournit les outils de maillage, le squelette et les animations ; son constructeur appelle maintenant cette nouvelle géométrie. GLB et source Blender régénérés : 47 784 triangles avant LOD, douze objets de matériau, 1 709 460 octets. La sonde contrôle les matériaux importés sans imposer des textures devenues inutiles. Aperçu réel à 48°, trois quarts, côtés et marche : `tmp/mage-arcade-apercu.html` ; capture stable : `tmp/mage-arcade.png`.

Validation : 30 suites, 12 855 assertions, zéro échec ; studio 83 contrôles et intégration 3D sans échec. Vingt simulations terminées avec un blocage du bot, donc un échec signalé par le script. Diagnostics de certificats et de ressources au nettoyage toujours présents. Logs détaillés : `tmp/arcade-verification.log`, `tmp/arcade-studio.log`, `tmp/arcade-integration.log`, `tmp/arcade-vingt-runs.log`.

## Mage humain au grand chapeau

Le propriétaire conserve la direction simple mais demande un humain avec un chapeau plus grand masquant le visage. Suppression du museau, des oreilles pointues et des yeux jaunes ; tête humaine sobre, petites tempes brunes, mains avec pouces. Bord du chapeau élargi de 23 % et abaissé devant le visage. La capture à 48° confirme que le visage est masqué. Robe violette, écharpe turquoise, baguette et animations conservées.

Source `tools/blender/mage_arcade.py`, GLB et Blender régénérés : 47 080 triangles avant LOD, dix objets de matériau, 1 673 916 octets. Aperçu : `tmp/mage-humain-cache-apercu.html` ; capture stable : `tmp/mage-humain-cache.png`. Validation : 30 suites, 12 855 assertions, zéro échec ; 83 contrôles studio et intégration 3D sans échec. Les diagnostics existants de certificats et de ressources au nettoyage persistent. Logs : `tmp/humain-cache-verification.log`, `tmp/humain-cache-studio.log`, `tmp/humain-cache-integration.log`.

Les 32 poses de marche sont maintenant capturées à l'angle de jeu pour contrôler le masquage du visage en mouvement. Vingt simulations terminées : sept victoires, treize défaites, aucune erreur de script ; un blocage du bot en salle 11, graine 1, avec un ennemi à 29 PV. Le script signale donc un échec. Détail : `tmp/humain-cache-vingt-runs.log`.

## Reprise Blender du héros de combat — 10 septembre 2026

Le mage humain conserve sa silhouette compacte, son visage abrité par le chapeau et ses couleurs violet/turquoise. Le chapeau possède désormais un bord ondulé avec liseré cuivre et une pointe construite par sections perpendiculaires à sa courbure. Le manteau comprend deux pans ouverts, une pèlerine, une ceinture et des coutures. Une sacoche, deux fioles, des broches et une tête de baguette en cornue renforcent l'identité d'alchimiste. Les métaux, le tissu et le cristal ont des réponses à la lumière distinctes ; les accessoires utilisent des volumes moins subdivisés.

Exécution locale avec Blender **5.2.1** : le connecteur ChatIA était indisponible (endpoint hors ligne). La géométrie reproductible reste dans `tools/blender/mage_arcade.py`, via `tools/blender/heros_azur.py`. La source `assets/3d/sources/characters/heros.blend` et le modèle réellement chargé en combat `assets/3d/characters/heros.glb` ont été reconstruits. Quatorze os, six animations conservées : repos, course, attaque, touche, mort, victoire. Les accessoires de la baguette suivent la main droite ; les deux pans d'écharpe suivent son os animé.

Export : **51 760 triangles, dix surfaces, 1 846 384 octets** pour le GLB. Le modèle précédent comptait 47 080 triangles et 1 673 916 octets. Aucun changement de statistiques, de collisions ou de caméra. La qualité artistique de cette proposition reste à apprécier par le propriétaire.

Comparaison avec un éclairage Blender identique : `tmp/heros-comparaison.html`, `tmp/heros-avant.png`, `tmp/heros-apres.png`. Captures Godot : `tmp/mage-vue-jeu.png`, `tmp/mage-marche/`, `tmp/retouches-heros-attaque.png`, `tmp/atelier-validation.png`.

Validation Godot **4.7.1** : 30 suites, 12 855 assertions, zéro échec ; selftest compilé. Studio `mage_articule.gd` : 83 contrôles, zéro échec, captures de marche, attaque et quatre côtés. Intégration `integration_3d.gd --fixed-fps 60` : zéro échec, 125 appels de dessin et 19 432 primitives dans la pose mesurée sur Radeon 610M. Un essai à temps réel avait compté sept proxies au lieu de huit ; la vérification avec pas fixe réussit. Les diagnostics de ressources non libérées à la fermeture demeurent. Ce contrôle PC ne mesure pas les performances sur téléphone.

Journaux : `tmp/heros-construction.log`, `tmp/heros-verification.log`, `tmp/heros-studio.log`, `tmp/heros-integration.log`, `tmp/heros-integration-fixe.log`, `tmp/heros-vingt-runs.log`.

Vingt simulations terminées : **neuf victoires, onze défaites, aucune erreur de script**. Un blocage du bot est signalé à la graine 9, salle 9, avec deux ennemis à 13 et 18 PV ; `vingt_runs.sh` retourne donc **un échec sur vingt**. Ces simulations headless ne chargent pas le héros 3D. Le problème de navigation automatique reste ouvert.
