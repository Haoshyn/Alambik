# Données et équilibrage

`INDEX.md` oriente vers un catalogue par catégorie. Les fichiers de ce dossier
sont la source des valeurs, des coûts et des formules ; les consommateurs
et les listes lisibles doivent appeler ces fonctions.

Exprimer une progression par des coefficients nommés et une formule courte.
Les ennemis dépendent du niveau, de la salle et du mode, jamais du build
actuel. Toute comparaison de dégâts doit préciser attaque brute, critiques,
cadence, nombre de cibles et conditions des bonus.

Les rares de statistiques donnent des bonus directs courts. Les effets
autonomes comme le guidage, les cercles de contact, le trait periodique et
la meteorite de zone n'ajoutent pas de statistiques. Ne pas greffer un effet
a un augment de statistiques existant : ajouter un choix distinct.
Ces effets automatiques agissent meme en mouvement. Les passifs
viennent des Épreuves. Aucun sort actif ni ultime. Les classes sont conservées
avec bonus neutres jusqu'à une demande explicite de les redéfinir.

Les rares ont une utilite comparable et des effets distincts. Les epiques et
legendaires donnent des gains marques sans rendre obligatoire un combo offensif.
Aucun compromis attaque/defense, PV/cadence
ou mobilite : les seules pertes sont celles des tirs multiples et rebonds.
Les reductions des tirs viennent de ReglagesAugments. Salve et Battement
triple se cumulent en quatre salves, dans les deux ordres ; les gains de
debit des deux choix s'additionnent. Le debit des salves, tirs paralleles et
cadence partage un cumul additif. Attaque et puissance des projectiles de run
s'additionnent aussi. Les choix critiques conservent leurs gains propres, sans
croisement multiplicatif entre leurs bonus. Aucun legendaire n'annule les
reductions. Les copies de Tir double gardent un gain utile. Les valeurs de
pourcentage des augments sont des multiples de cinq.

Aucune valeur d'amelioration ne porte de decimale, quelle que soit la source
(augments, attributs, maitrises, passifs, Coeurs, armes, familiers, bijoux,
forge). Les cumuls composes passent par `Reglages.cumul_compose_entier` :
gains entiers par rang, jamais decroissants, et dernier rang egal a l'arrondi
du cumul compose. Un facteur inferieur a 1 s'affiche en pourcentage retire
(−30 %), une duree en secondes entieres ou en pourcentage de la valeur de base.
Si un arrondi deplace l'equilibre, compenser sur une autre valeur entiere
plutot que reintroduire une decimale, puis relancer les controles d'equilibre. Les choix de niveau
suivent ProgressionAugments : aucun commun ni choix bonus lie a une salle.
Les gains de resistance effective et de DPS des rares doivent etre
comparables, selon les conditions des effets ; la defense ne doit plus
depasser systematiquement l'attaque.
Les sources permanentes progressent par petits gains ; le rare reste utile,
l'epique puissant et le legendaire exceptionnel, avec une puissance forte
assumee. Reduire l'echelle commune des statistiques doit reduire aussi les
gains bruts des attributs et les arrondis de forge, jamais les pourcentages.
Sur une progression ordinaire, eliminer un monstre intact en une attaque
reste exceptionnel avec des rares seuls ; les choix offensifs accelerent
ensuite les rencontres. Un mixte avec quelques choix offensifs reste viable,
meme avec un legendaire defensif. Un fort sur-farm peut
depasser le chapitre suivant, puis le chapitre d'apres doit reprendre une marge.
Aucun plancher de coups, plafond de degats ou ajustement au build ne garantit
ce resultat : verifier les courbes fixes et les achats reels en simulation.
Le deblocage progressif des augments est reporte, sans modification des offres.

Après changement d'un catalogue : vérifier les consommateurs, les migrations
nécessaires, puis régénérer `statistiques_jeu/` avec l'outil de statistiques.
Ne jamais mettre à jour une liste à la main pour masquer un écart de code.
