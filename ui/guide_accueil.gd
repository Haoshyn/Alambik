class_name GuideAccueil
extends GuideTutoriel

func presenter() -> void:
	match ParcoursTutoriel.prochaine_etape():
		"combat":
			afficher("Bienvenue dans l’atelier", "Découvrez les bases dans un niveau séparé de cinq étages, avec un mini-boss. Vous recevrez votre première baguette et, en cas de victoire, %d gouttes : le prix d’un premier rang de maîtrise.\n\nVous pourrez passer le tutoriel en haut à droite à tout moment." % DonneesTutoriel.recompense_gouttes(), [["combat", "Commencer les cinq étages"]])
		"accueil":
			afficher("Vos premiers pas continuent ici", "La première Épreuve et la Mine sont maintenant ouvertes : essayez les deux avant de vous lancer dans une longue campagne !\n\nCampagne : gouttes, XP, pierres, bijoux et déblocages.\nMine : surtout des pierres de forge.\nÉpreuves : capacités, rangs de capacités et Cœurs de mana.\n\nCommencez par acheter une maîtrise avec vos %d gouttes, puis choisissez votre spécialisation gratuite." % DonneesTutoriel.recompense_gouttes(), [["accueil", "Découvrir mes maîtrises"], ["plus_tard", "Explorer à mon rythme"]])
		"maitrises":
			afficher("Un premier progrès permanent", "Dans Maîtrises, achetez un premier rang de Force maîtrisée, Constitution ou Alchimie réparatrice. Le cadeau finance un seul de ces rangs.\n\nChoisissez aussi votre spécialisation : elle oriente votre style de jeu. Le premier choix est gratuit. L’XP de compte donnera ensuite des points d’attributs à répartir.", [["maitrises", "Ouvrir les maîtrises"], ["plus_tard", "Plus tard"]])
		"musique":
			afficher("Choisissez votre musique", "Dans Paramètres → Ambiance sonore, choisissez séparément le morceau de l’aventure et celui de l’atelier. Vous pouvez le changer manuellement, même pendant une partie depuis Pause.\n\nRéglez aussi les volumes, les secousses et les effets visuels. Garder la sélection actuelle est tout à fait possible.", [["musique", "Voir les paramètres audio"], ["plus_tard", "Plus tard"]])
		"mine":
			afficher("Essayez la Mine", "La Mine est déjà accessible. Survivez aux vagues, puis affrontez le boss final. Les pierres gagnées servent à forger vos armes, vos bijoux et vos familiers dans Équipement.\n\nMême une tentative perdue peut rapporter des pierres selon votre durée de survie. Essayez ce mode dès maintenant !", [["mine", "Tester la première Mine"], ["plus_tard", "Plus tard"]])
		"epreuve_sorts":
			afficher("Votre premier sort vous attend", "Essayez l’Épreuve de magie de niveau 1 : cinq boss, avec un choix d’augmentation après chacun des quatre premiers.\n\nSon coffre peut donner Onde alchimique (sort actif) ou Moisson vitale (passif), ainsi qu’un Cœur de mana. Un sort n’est pas garanti à chaque victoire : rejouez ce niveau pour obtenir les capacités manquantes et améliorer leurs rangs.\n\nDès que vous aurez obtenu un sort actif ici, nous verrons ensemble comment l’équiper et le lancer.", [["epreuve_sorts", "Tester l’Épreuve 1"], ["plus_tard", "Plus tard"]])
		"commandes":
			var id := ParcoursTutoriel.sort_a_expliquer()
			afficher("Votre premier sort actif d’épreuve", "%s est disponible ! Équipez-le dans Sorts pour l’utiliser.\n\nTouchez son icône en combat, choisissez une cible si vous utilisez la visée manuelle, puis attendez sa recharge avant de recommencer.\n\nLes paramètres proposent trois gestes : icône avec visée manuelle, icône visant l’ennemi proche, ou tape courte dans l’arène visant l’ennemi proche. Les ultimes ont leur propre icône et les passifs équipés agissent sans bouton." % str(Sorts.donnees(id)["nom"]), [["commandes", "Équiper ce sort et voir les commandes"], ["plus_tard", "Plus tard"]])
		"sort":
			afficher("À vous de lancer un sort", "Votre sort actif se retrouve dans l’onglet Sorts. En combat, utilisez son icône à droite ou une tape courte dans l’arène selon le mode choisi. Attendez ensuite que sa recharge soit terminée.\n\nEssayez-le dans une aventure ; vous pouvez changer de geste à tout moment dans Pause → Paramètres.", [["sort", "Équiper mon sort"], ["campagne", "Essayer en campagne"], ["plus_tard", "Plus tard"]])
		"fin":
			afficher("L’atelier est à vous", "Vous avez acheté une maîtrise, découvert les paramètres, essayé la Mine et les Épreuves, puis lancé un sort.\n\nAlternez ces modes pour progresser : campagne pour les déblocages, Mine pour la forge et Épreuves pour les capacités. Bonne aventure !", [["fin", "Terminer le tutoriel"]])
