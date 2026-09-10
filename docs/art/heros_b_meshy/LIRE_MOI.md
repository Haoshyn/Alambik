# Héros B — préparation Meshy

Le propriétaire a validé le concept B « Mage compact » et la planche face/profil/dos. Les quatre images individuelles sont des préparations issues de cette planche, sans titres ni lignes de construction. Le modèle de combat actuel n’a pas été remplacé par ces images. Le propriétaire a depuis fourni le GLB brut. Son étude allégée et texturée est décrite dans `docs/ops/HEROS_B_MESHY.md`. Les étapes ci-dessous restent la trace du parcours de génération.

## Première génération du personnage

1. Ouvrir Image to 3D dans Meshy et importer **01_face.png** comme référence principale.
2. Pour un premier essai, commencer avec cette face seule : elle définit le visage, les proportions et le costume. Choisir une pose A si cette option est disponible.
3. Si Multi-View est disponible dans le compte, **02_profil_gauche.png** et **03_dos.png** peuvent servir de références secondaires. La documentation consultée indique Meshy 7 et un abonnement Pro ou supérieur pour cette option. Multi-View et Smart Topology ne sont pas compatibles simultanément ; le remaillage vient ensuite.
4. Utiliser Remove Background dans Meshy pour chaque image ajoutée. Ne pas importer la planche complète ni le bâton dans la génération du personnage.
5. Examiner le volume avant de texturer : ressemblance du visage, taille de tête, silhouette du chapeau, séparation mains/buste et entre les jambes. Comparer aussi depuis une vue plongeante à 48°, proche de celle du combat.
6. Lorsque la forme convient, générer les textures puis exporter le personnage en GLB avec ses textures pour la reprise Blender. Conserver également la version source avant optimisation.

Les images restent des références artistiques générées, pas des projections géométriques garanties. La courbure du chapeau, les plis et les petits ornements varient encore selon l’angle. En cas de contradiction, la face prévaut ; éviter de multiplier les générations avant d’examiner un premier résultat. La sacoche est à gauche du personnage, la fiole à droite et la sangle rejoint l’épaule droite à la hanche gauche.

## Bâton séparé

Générer **04_baton.png** dans une tâche Image to 3D indépendante. Pas de pose ni d’animation humanoïde. Vérifier que la hampe reste droite et que la monture de l’orbe n’est pas fusionnée en bloc. Exporter séparément en GLB avec les textures. L’échelle relative au personnage sera ajustée dans Blender.

## Ce qu’il faut rapporter

Les GLB du héros et du bâton, avec leurs textures si elles sont externes. Ils serviront à vérifier la géométrie, préparer les articulations et intégrer les animations dans Godot. Une première vue 3D peut être examinée avant la phase de textures.

## Références officielles consultées le 10 septembre 2026

- [Meshy — Image to 3D](https://help.meshy.ai/en/articles/9996860-how-to-use-meshy-image-to-3d)
- [Meshy — Multi-View](https://help.meshy.ai/en/articles/12634481-how-to-use-multi-view)
