# Interface du scriptorium

Assets originaux créés pour Alambik le 20 septembre 2026.

- `scriptorium.png` : illustration générée puis retravaillée avec ImageGen pour une fantasy plus lumineuse, aux surfaces lisses et sans grain de toile ; sans texte incorporé.
- `peint/icones.png`, `peint/panneau.png`, `peint/action.png` : assets originaux générés avec ImageGen, en volume peint, or arrondi et émail violet ou turquoise, pour raccorder l'interface au héros. Ils remplacent les cadres et emblèmes vectoriels dans les styles partagés. Les icônes sont découpées en atlas ; panneaux et boutons utilisent neuf zones.
- Les SVG originaux restent disponibles pour les éléments spécialisés : jauges, séparateurs, halos, coffre et décorations.
- Les glyphes d'augments et le héros d'accueil réutilisent les illustrations déjà présentes dans `assets/visual/manga/` et `assets/visual/arcane/`.

Palette : violet, saphir, or chaud, turquoise et crème. Textes et valeurs restent des contrôles Godot afin de suivre la progression et les dimensions du téléphone. Le shader `interface_peinte.gdshader` est réservé aux illustrations et panneaux sans texte ; les boutons et glyphes gardent le rendu natif Godot. Les cadres sont importés à 128 px pour conserver une dorure fine lors de leur découpage neuf zones.
