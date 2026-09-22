# Interface — Émail arcanique

Direction A validée le 22 septembre 2026 : fantasy magique à volumes doux,
bleu-violet et ivoire lavande, avec accents cyan et champagne, sans microtextures
dans les contrôles. Palette détaillée dans `docs/design/DIRECTION_ARTISTIQUE.md`.

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
  Textes et icônes restent indépendants des surfaces. Palette bleu-violet
  appliquée par `tools/palette_cadres.py` selon les rôles (lecture, action,
  sélection, navigation), sans changement de silhouette.
- `equipement/`, `armes/` et `../azur/glyphes/` : SVG natifs du même kit.
- `academie_arcanique.png` : cour-jardin d'alchimiste en lumière pervenche,
  générée avec ImageGen depuis `exec-c03e3e5d-fb90-4ec8-8bc3-2b7921e4379c.png`
  et le nouvel accueil ; source active `exec-aa297b86-19bc-45e3-9445-903050898759.png`.
- `accueil_mage_clairiere.png` : accueil complet généré avec ImageGen à partir
  de la clairière `exec-9d36c702-f864-44af-b40c-d036376f1ae8.png` et du mage
  `exec-16d43dd8-3eb5-4b79-bfc6-a3549fb6bd9b.png` ; source finale
  `exec-ec7b4eee-6008-4ac4-8986-b0f566a8a11f.png`, retravaillée en bleu-violet
  dans `exec-16a0b57f-242d-40f0-bd74-6ed50facb2b8.png` puis éclaircie dans
  `exec-305a623a-3b0c-4e71-ad84-1cb6f57302e9.png`. Source de référence pour
  les deux couches de l'accueil animé.
- `accueil_fond_anime.png` : fond sans mage, source ImageGen
  `exec-4a7fe8c6-8dcc-4ab9-aae3-145ac642c7c6.png`.
- `accueil_mage_detoure.png` : mage isolé avec transparence, source ImageGen
  `exec-467be333-9b5e-4a17-9ab1-4802ae8c0c6e.png`. Leurs dimensions et leur
  recadrage communs sont définis dans `ui/composants/illustration_accueil.gd`.
  L'onglet Héros réutilise le même mage détouré que l'accueil.
- `heros_email.png` : ancienne illustration indépendante générée avec ImageGen depuis
  la proposition A, source `exec-7a15a3a7-833f-4208-bfdf-230a1d165e99.png`.
- Les illustrations restent en PNG. Les contrôles et icônes sont vectoriels ;
  leurs textures importées utilisent un filtrage linéaire avec mipmaps.
- `clairiere_magique.png`, `heros_accueil.png`, `scriptorium.png` et les planches
  de `peint/` sont des anciennes explorations. Les générateurs du grimoire
  végétal et de vectorisation peinte ne doivent pas écraser le kit actif.

Les SVG Wenrexa fournis sont utilisés directement comme sources vectorielles.
Aucun PNG de ces packs n'est incorporé dans les icônes SVG du jeu.
