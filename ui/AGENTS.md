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

## Choix figes du proprietaire

Les cinq menus sont entierement figes dans leur etat actuel. Ne retoucher
les elements suivants que sur demande explicite les visant, y compris
lorsqu'un style ou un composant commun pourrait les affecter. Ce gel porte
sur les menus uniquement, pas sur les regles, l'equilibrage ou la progression
des systemes de jeu correspondants.

- Heros : ecran conserve, textes Classe et Reinitialiser gratuit centres et
  agrandis, points a repartir dans leur propre cartouche a droite. Conserver
  les jauges, les attributs et le reste de l'agencement.
- Equipement : presentation actuelle entierement conservee.
- Aventure : presentation actuelle conservee ; les nombres des gouttes et
  pierres sont colores, plus grands et marques, sans petit fond noir propre
  au texte a droite du symbole.
- Maitrises : constellation et fiche conservees ; bouton de reinitialisation
  centre, cadre plus grand et caracteres plus grands, gras et contrastes.
- Passifs : presentation actuelle entierement conservee, dont les filtres
  Tous, Offensif, Defensif, Utilitaire
  et les quatre emplacements Passif 1 a 4. Le fond reprend la clairiere sous
  un voile indigo progressif, plus calme derriere la collection.
  Aucun rectangle sombre sous Collection des passifs, les indications de
  limite/rangs/provenance, les noms, A decouvrir ou les descriptions. Aucun
  empilement de cadres de texte dans les fiches. Les glyphes et accents de
  couleur structurent la collection sans peinture elementaire chargee.

L'etat valide le 27 septembre 2026 est la reference des cinq menus ; les
retouches deja demandees ne sont pas une autorisation permanente de les reprendre.
