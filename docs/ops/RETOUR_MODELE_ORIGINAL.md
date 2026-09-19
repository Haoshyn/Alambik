# Modèles conservés — 19 septembre 2026

- Travail actif : `assets/3d/characters/mage_reference.glb` et sa source
  `assets/3d/sources/characters/mage_reference/mage_reference.blend`.
- Modèle au début de cette séparation : `assets/3d/characters/apprenti_accueil_v2.glb`,
  source Blender au chemin précédent, shader `shaders/apprenti_accueil_surface.gdshader`.
- Original avant les retouches de sculpture : `assets/3d/characters/apprenti_secours.glb`,
  shader `shaders/apprenti_secours_surface.gdshader`, source et scripts historiques dans
  `assets/3d/sources/characters/original_avant_retouches/`. Copies récupérées depuis Git,
  sans reconstruire le modèle. Les scripts historiques servent d'archive de source.

Pour revenir à l'original avant retouches, définir dans `data/visuels_3d.gd` :
`const HEROS_MODELE := HEROS_MODELE_SECOURS`.
Pour retrouver la dernière retouche précédente, utiliser `HEROS_MODELE_ACCUEIL_V2`.
Le choix du shader suit le chemin du modèle ; aucun effacement de sauvegarde joueur.
L'atelier suit aussi cette constante. Pas de build ou de test automatique pour ce retour.

Le générateur `tools/blender/mage_reference.py` écrit uniquement le nouveau modèle et
sa source ; il n'écrase aucun des deux modèles conservés.
