# Interface — Émail arcanique

Direction A validée le 22 septembre 2026 : fantasy magique à volumes doux,
bronze, turquoise et ivoire, sans thème nature ni microtextures dans les contrôles.

- `tools/generer_email_arcanique.py` appelle `tools/habillage_svg_source.py` :
  navigation, ressources, bijoux et capacités utilisent les silhouettes Wenrexa
  fournies par le propriétaire dans `SVG/`. Les originaux restent intacts ; les
  copies ajoutent couleurs de matière, ombre et liseré. Les petits sceaux de
  variantes ont été retirés ; les silhouettes sont centrées sur leur contenu visible
  avec `tools/sources_email/cadrages_wenrexa.json` (bornes alpha des originaux).
  Les contrôles absents du pack conservent leurs tracés originaux Alambik.
- `cadres/` : surfaces séparées pour cases, cartes, boutons, compteurs, panneaux,
  navigation et zones de texte, avec variantes sélectionnées, pressées et focus.
  Taille logique 128 px, étirement en neuf zones avec coins de 40 px fixes.
  Textes et icônes restent indépendants des surfaces. Palette Charbon végétal
  (sauge #829e8b, charbon #3d5749, métal grisé #bdc6af), appliquée par
  `tools/palette_cadres.py`, sans changement de silhouette.
- `equipement/`, `armes/` et `../azur/glyphes/` : SVG natifs du même kit.
- `academie_arcanique.png` : cour-jardin d’alchimiste, pierre claire et verdure sauge,
  générée avec ImageGen, source `exec-c03e3e5d-fb90-4ec8-8bc3-2b7921e4379c.png`.
- Le héros affiché utilise désormais `Visuels3D.HEROS_MODELE` dans un viewport
  transparent indépendant, à l’accueil et dans l’onglet Héros.
- `heros_email.png` : ancienne illustration indépendante générée avec ImageGen depuis
  la proposition A, source `exec-7a15a3a7-833f-4208-bfdf-230a1d165e99.png`.
- Les illustrations restent en PNG. Les contrôles et icônes sont vectoriels ;
  leurs textures importées utilisent un filtrage linéaire avec mipmaps.
- `clairiere_magique.png`, `heros_accueil.png`, `scriptorium.png` et les planches
  de `peint/` sont des anciennes explorations. Les générateurs du grimoire
  végétal et de vectorisation peinte ne doivent pas écraser le kit actif.

Les SVG Wenrexa fournis sont utilisés directement comme sources vectorielles.
Aucun PNG de ces packs n'est incorporé dans les icônes SVG du jeu.
