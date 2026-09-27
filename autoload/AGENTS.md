# État et sauvegarde

`jeu.gd` porte la session, `reglages_joueur.gd` la progression persistante,
`sons.gd` l'audio, `ecran.gd` l'adaptation à l'écran.

Une suppression de fonctionnalité doit migrer les anciennes données sans
perdre monnaies, équipement, maîtrises ni rangs conservés. Versionner les
migrations et les rendre idempotentes. Ne jamais utiliser la vraie sauvegarde
pour une vérification. Aucun chiffre de progression dans une migration sauf
une ancienne valeur nécessaire à la conversion, clairement identifiée.
