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
