# Six kits de direction artistique — Alambik

Explorations séparées du jeu actif. Les compositions et planches sont au format portrait 1080 × 1920 (9:16).

- A : Cartoon arcanique ; B : Magie graphique ; C : Alchimie pop.
- D : Hologramme arcanique ; E : Laboratoire de potions ; F : Sceaux de combat.
- `A/` à `F/` : `composition.png` pour la vue téléphone ; `planche.png` pour les éléments ; versions SVG éditables incluses.
- `icones/` : 16 SVG natifs par piste, chemins et aplats uniquement, aucun bitmap incorporé.
- `surfaces/` : boutons sans texte, états normal/pressé/inactif, panneau de lecture, compteurs, socle de navigation, sélection d’onglet et bouton de mode. Les textes et les icônes sont à superposer dans des contrôles distincts.
- `theme.json` : palette, dimensions et marges proposées pour l’étirement en neuf zones. Ces marges restent à ajuster lors de l’intégration Godot.
- `decor.svg` et `commun/mage.png` : décor et illustration du héros indépendants. Le héros est une illustration matricielle originale générée avec ImageGen ; ce n’est pas une icône.
- Les SVG de composition embarquent une copie du héros pour rester portables. Ils servent de références visuelles, jamais d’asset de menu aplati à intégrer.

Les pistes D–F s’inspirent des archives Wenrexa fournies dans `nourriture pour ia/` : contours holographiques turquoise, silhouettes des potions, couleurs cyan/ambre des sorts et emblèmes RPG. Les icônes proposées ici ont été redessinées en SVG simples ; les PNG des packs ne sont pas incorporés.

Les six pistes partagent les mêmes fonctions et un héros commun pour comparer l’habillage. Les nombres, le chapitre et le niveau des aperçus sont des exemples de mise en page. Aucun branchement au jeu ni test Godot n’est inclus dans cette exploration de DA.

Générateur des sources : `tools/proposer_kits_interface.py` à la racine du dépôt.
