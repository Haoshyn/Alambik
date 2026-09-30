# Aster — héros d’Alambik

Modèle V7 aux proportions manga créé pour ce projet : corps, visage et cheveux adaptés de HairSample_Male (VRoid beta, pixiv, CC0), costume, accessoires et geste de tir originaux. Locomotion, réaction aux dégâts, incantation et chute Death01 adaptées de Quaternius Universal Animation Library Standard (CC0).

Le Blender modifiable et les mentions détaillées sont dans `../../sources/characters/aster/`. La scène active est `res://scenes/3d/aster.tscn` ; elle lie les maillages au squelette, applique les matières et expose les noms d’animations du jeu.

Le modèle conserve la baguette Aster pour l’arme standard. Les autres armes du catalogue sont montées sur sa prise droite. Aucun identifiant d’équipement ou de sauvegarde n’est remplacé.

La silhouette compacte reprend l’aperçu approuvé le 30 septembre 2026 : tête légèrement agrandie, jambes, buste et cou raccourcis. Le squelette et les formes du visage suivent la géométrie ; les huit animations sont conservées. Les repères `Aster_PriseArme` et `Aster_PointeBaguette`, exportés dans le même espace de repos que les maillages, définissent les attaches sans recopier leurs coordonnées dans les scripts.
