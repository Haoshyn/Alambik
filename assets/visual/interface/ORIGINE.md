# Interface — Émail arcanique

Direction A validée le 22 septembre 2026 : fantasy magique à volumes doux,
bleu-violet et ivoire lavande, avec accents cyan et champagne, sans microtextures
dans les contrôles. Palette détaillée dans `docs/design/DIRECTION_ARTISTIQUE.md`.

- `tools/refonte_svg.py` génère les pictogrammes et surfaces actifs depuis
  des formes vectorielles originales. `tools/signatures_svg.py` contient les
  gravures propres aux capacités et `tools/design_svg/` les cinq exemples
  dessinés à la main qui définissent cette construction.
  `tools/generer_email_arcanique.py` reste un point d’entrée compatible vers
  cette refonte. Les SVG Wenrexa fournis dans `SVG/` restent intacts et ne
  sont plus intégrés aux ressources actives.
- `cadres/` : surfaces séparées pour cases, cartes, boutons, compteurs, panneaux,
  navigation et zones de texte, avec variantes sélectionnées, pressées et focus.
  Taille logique 128 px, étirement en neuf zones avec coins de 40 px fixes.
  Textes et icônes restent indépendants des surfaces. Palette bleu-violet
  appliquée à chaque surface selon son rôle (lecture, action, sélection,
  navigation).
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
- `campagne_encre.png`, `campagne_terre.png`, `campagne_eau.png`,
  `campagne_air.png` et `campagne_feu.png` : cinq illustrations transparentes
  et indépendantes pour le choix du monde. Sources ImageGen respectives :
  `exec-76157d15-7984-43d0-a70d-fa6488e0a819.png`,
  `exec-3a1c6cf8-46a4-420d-90f9-7771be2a94dd.png`,
  `exec-0c067fcf-ed60-4c21-8677-60bcf7185c42.png`,
  `exec-fef64f02-8c24-4b99-94b4-410b427f9f59.png`,
  `exec-c67b0d30-4995-4931-ad85-03e998004266.png`.
- `accueil_mage_detoure.png` : mage isolé avec transparence, source ImageGen
  `exec-467be333-9b5e-4a17-9ab1-4802ae8c0c6e.png`. Leurs dimensions et leur
  recadrage communs sont conservés dans leurs sources. Le mage détouré reste
  utilisé dans l'onglet Héros.
- `chargement_clairiere.png` : écran de lancement à fiole alchimique et vapeurs
  lavande sur fond indigo, distinct du menu et dans sa palette bleu-violet/cyan.
  Créé avec ImageGen, ancien écran utilisé comme référence de palette ; source
  `exec-32ec51ca-8810-48f2-b2b3-a11ac8d48dfd.png`.
- `heros_email.png` : ancienne illustration indépendante générée avec ImageGen depuis
  la proposition A, source `exec-7a15a3a7-833f-4208-bfdf-230a1d165e99.png`.
- Les illustrations restent en PNG. Les contrôles et icônes sont vectoriels ;
  leurs textures importées utilisent un filtrage linéaire avec mipmaps.
- `clairiere_magique.png`, `heros_accueil.png`, `scriptorium.png` et les planches
  de `peint/` sont des anciennes explorations. Les générateurs du grimoire
  végétal et de vectorisation peinte ne doivent pas écraser le kit actif.

Les ressources actives sont des SVG autonomes sans image incorporée.
