# Interface

`INDEX.md` donne les écrans et composants. Ouvrir le script de l'écran et sa
scène, si elle existe. Les écrans construits en code réutilisent les composants
de `composants/`, les styles, la palette, les polices et les gestes tactiles.

L'interface explique les valeurs réellement calculées par les catalogues.
Les règles de gameplay ne doivent pas être réimplémentées dans une carte.
Afficher les unités, le rang courant, le gain suivant et son coût lorsque le
joueur doit décider d'une amélioration.

Préserver les zones sûres, le défilement et les interactions portrait. Vérifier
les écrans touchés sans fenêtre avec un profil de sauvegarde isolé.

## Kit et etat de reference

Le kit « Email serti » (refonte du 9 octobre 2026, demandee par le
proprietaire avec carte blanche) est la reference de tous les ecrans :

- Surfaces : `StyleBoxJeu` (`scripts/interface/style_box_jeu.gd`) via
  `StyleJeu.boite`, `StyleJeu.panneau` et `StyleJeu.carte`. Ne pas revenir aux
  aplats `StyleBoxFlat` ni aux zones de lecture ivoire pour un nouvel element.
- Textes : `StyleJeu.texte` / `StyleAzur.texte` (Nunito tres grasse, contour
  sombre, ombre). Aucun rectangle sombre sous un texte, dans aucun menu.
- Elements traces (HUD, annonces, nombres de degats) : `DessinJeu`.
- Boutons : `StyleJeu.habiller_bouton` ou `StyleAzur.bouton` ; l'appui ecrase
  puis fait rebondir le bouton avec un clic. Ambre pour l'action principale,
  rubis pour abandonner, amethyste par defaut.
- Le kit est aussi compile par les outils sans fenetre : `StyleJeu` lit les
  autoloads a l'execution (`_autoload`), jamais par leur nom global.

Hors demande explicite du proprietaire visant un ecran ou un element, ne pas
retoucher la presentation des menus Heros, Equipement, Aventure, Maitrises et
Passifs, y compris indirectement par un style, une police ou un composant
partage. Ce gel ne porte pas sur les regles, l'equilibrage ou la progression.
Les Passifs gardent leurs filtres Tous, Offensif, Defensif, Utilitaire, les
quatre emplacements, la clairiere commune et un SVG autonome par passif.
