extends RefCounted

static func nombre(valeur: float, decimales := 2) -> String:
	var morceaux := String.num(valeur, decimales).trim_suffix(".00").trim_suffix(".0").split(".")
	var entier: String = morceaux[0]
	var signe := ""
	if entier.begins_with("-"):
		signe = "−"
		entier = entier.trim_prefix("-")
	var groupes: Array[String] = []
	while entier.length() > 3:
		groupes.push_front(entier.right(3))
		entier = entier.left(entier.length() - 3)
	groupes.push_front(entier)
	return signe + " ".join(groupes) + ("," + morceaux[1] if morceaux.size() > 1 else "")

static func entete(titre: String, logique: Array[String]) -> Array[String]:
	var lignes: Array[String] = ["# " + titre, "", "## Logique mathématique", ""]
	for explication: String in logique:
		lignes.append("- " + explication)
	lignes.append_array(["", "*Valeurs calculées depuis les données du jeu. Les arrondis ci-dessous servent à la lecture.*", ""])
	return lignes

static func tableau(lignes: Array[String], titres: Array[String], donnees: Array) -> void:
	if titres.is_empty(): return
	if not lignes.is_empty() and not lignes.back().is_empty(): lignes.append("")
	var colonnes: Array[String] = []
	var separateurs: Array[String] = []
	for titre: String in titres:
		colonnes.append(_cellule(titre))
		separateurs.append("---")
	lignes.append("| " + " | ".join(colonnes) + " |")
	lignes.append("| " + " | ".join(separateurs) + " |")
	for valeurs: Array in donnees:
		var cellules: Array[String] = []
		for valeur in valeurs:
			cellules.append(_cellule(str(valeur)))
		lignes.append("| " + " | ".join(cellules) + " |")
	lignes.append("")

static func _cellule(texte: String) -> String:
	return texte.replace("\r\n", "\n").replace("\r", "\n").replace("|", "\\|").replace("\n", "<br>")

static func augments() -> String:
	var lignes := entete("Liste des augments", [
		"Chaque choix ne dure que pour la tentative en cours. Aucun augment ne crée une attaque autonome.",
		"Dans une même famille, les bonus positifs s’additionnent : deux bonus de 40 % donnent +80 %. Aucun bonus de défense ne coûte de l’attaque, de la cadence ou des PV.",
		"Les seules réductions concernent la multiplication des tirs : Salve, Battement triple et chaque Tir double multiplient indépendamment les dégâts de tous les projectiles par %s. Les diagonales ont leur propre puissance et Ricochet perd de la puissance entre cibles." % nombre(ReglagesAugments.MALUS_TIRS_MULT),
		"Le groupe des bonus de run multiplie une seule fois les statistiques permanentes.",
		"Critique : les points de chance s’ajoutent, jusqu’à 100 %. Les points de dégâts critiques s’ajoutent au coefficient critique.",
		"Salves et projectiles supplémentaires ne garantissent pas que tous les tirs atteignent la même cible.",
		"Les malus restent actifs avec les légendaires. Les classes Sorcier et Moine n’ajoutent aucun bonus.",
		"Augmenter les PV maximum ne soigne pas, sauf Égide qui rend toute la vie à son acquisition. Égide multiplie les PV après les autres bonus. Un bouclier revient à chaque salle sans cumuler les charges des salles précédentes.",
		"Couronne incisive convertit une part du critique excédant 100 % en dégâts critiques, selon sa fiche. Sans Couronne, cet excédent est perdu. Les soins indiqués sont multipliés par les bonus de soins et limités aux PV manquants.",
		"Campagne et Mine : %d niveaux donnent %d choix, sans commun. Le niveau %d garantit un légendaire ; %d autres niveaux tirés sans remise donnent un épique, les %d restants un rare. Aucun choix supplémentaire n’est ajouté avant un boss." % [ProgressionAugments.niveau_max(), ProgressionAugments.niveau_max(), ProgressionAugments.NIVEAU_LEGENDAIRE, ProgressionAugments.NOMBRE_EPIQUES, ProgressionAugments.niveau_max() - ProgressionAugments.NOMBRE_EPIQUES - 1],
		"Un seul légendaire supplémentaire peut remplacer un rare ou un épique, avec %s %% de probabilité par run. Son niveau est uniforme parmi les %d niveaux hors garantie, premier niveau compris. Une run à deux légendaires conserve donc %d ou %d épiques ; le nombre total de choix reste identique. Les %d offres de chaque choix restent aléatoires. Les Épreuves gardent leurs quatre choix après boss." % [nombre(ProgressionAugments.CHANCE_LEGENDAIRE_BONUS * 100.0), ProgressionAugments.niveau_max() - 1, ProgressionAugments.NOMBRE_EPIQUES - 1, ProgressionAugments.NOMBRE_EPIQUES, ProgressionAugments.NOMBRE_CHOIX],
		"Les choix épiques ou légendaires n’ajoutent aucun soin automatique de rareté. Le soin propre à Égide reste actif.",
	])
	for rarete: String in [Reactif.RARE, Reactif.EPIQUE, Reactif.LEGENDAIRE]:
		var titre_rarete := str({Reactif.RARE: "Rares",
			Reactif.EPIQUE: "Épiques", Reactif.LEGENDAIRE: "Légendaires"}[rarete])
		lignes.append_array(["## " + titre_rarete, ""])
		for id: String in CatalogueReactifs.ids():
			var reactif := CatalogueReactifs.par_id(id)
			if reactif.rarete != rarete: continue
			lignes.append_array(["### " + reactif.nom, ""])
			lignes.append_array(["**Maximum :** %d copie%s." % [reactif.copies_permises(), "s" if reactif.copies_permises() > 1 else ""], ""])
			var rangs: Array = []
			for copies in range(1, reactif.copies_permises() + 1):
				rangs.append([copies, DetailsReactif.texte(reactif, copies)])
			tableau(lignes, ["Copies cumulées", "Effets cumulés"], rangs)
	return "\n".join(lignes).strip_edges() + "\n"

static func items() -> String:
	var lignes := entete("Liste des items", [
		"Forge de 0 à %d. Prix du prochain achat depuis le niveau n : %d + %d × n + %d × n² Pierres, arrondi au multiple de %d le plus proche." % [Reglages.FORGE_NIVEAU_MAX, Reglages.FORGE_COUT_BASE, Reglages.FORGE_COUT_PAR_NIVEAU, Reglages.FORGE_COUT_QUADRATIQUE, Reglages.COUT_PAS_ARRONDI],
		"Arme : attaque brute = (%s + %s × min(forge, %d) + %s × max(forge − %d, 0)) × %s^(niveau de provenance − 1)." % [nombre(CatalogueProjectiles.ATTAQUE_BASE), nombre(CatalogueProjectiles.FORGE_ATTAQUE_PAR_NIVEAU), CatalogueProjectiles.FORGE_RANGS_INITIAUX, nombre(CatalogueProjectiles.FORGE_ATTAQUE_PAR_NIVEAU_TARDIF), CatalogueProjectiles.FORGE_RANGS_INITIAUX, nombre(Reglages.EQUIPEMENT_CROISSANCE_PAR_PALIER, 3)],
		"Familier : attaque propre = (base du modèle + %s × forge) × le même facteur de provenance." % nombre(CatalogueFamiliers.FORGE_ATTAQUE_PAR_NIVEAU),
		"Bijoux : les valeurs brutes sont multipliées par %s^(%d × indice du monde), indice de 0 à %d. Les pourcentages ne le sont pas." % [nombre(Reglages.EQUIPEMENT_CROISSANCE_PAR_PALIER, 3), Chapitres.CHAPITRES_PAR_MONDE, Chapitres.MONDES.size() - 1],
		"Les tableaux donnent les statistiques finales de CHAQUE objet à CHAQUE niveau, provenance déjà appliquée.",
		"L’attaque de l’arme et des bijoux s’ajoute à la base du héros. L’attaque du familier reste séparée.",
		"Les effets des bijoux se débloquent au niveau %d. Les anciens bijoux sont conservés pour les sauvegardes ; ils ne tombent plus." % int(EffetsBijoux.PALIERS[0]),
	])
	lignes.append_array(["## Prix communs à tous les objets", ""])
	var cumul := 0
	var prix: Array = []
	for niveau in range(Reglages.FORGE_NIVEAU_MAX + 1):
		if niveau > 0: cumul += Reglages.cout_forge(niveau - 1)
		prix.append([niveau, "Maximum atteint" if niveau == Reglages.FORGE_NIVEAU_MAX else str(Reglages.cout_forge(niveau)), cumul])
	tableau(lignes, ["Niveau de forge", "Prochain achat (Pierres)", "Dépense cumulée depuis 0 (Pierres)"], prix)
	lignes.append_array(["## Armes", ""])
	for id: String in CatalogueProjectiles.TYPES:
		var d: Dictionary = CatalogueProjectiles.TYPES[id]
		lignes.append_array(["### " + str(d["nom"]), "",
			"**Provenance :** niveau de campagne %d." % CatalogueProjectiles.niveau_deblocage(id), "",
			str(d["description"]), "",
			"- Coefficient par tir : **×%s**." % nombre(float(d.get("coefficient_tir", 1.0))),
			"- Cadence propre : **×%s**." % nombre(float(d.get("cadence_mult", 1.0))), ""])
		var niveaux: Array = []
		for niveau in range(Reglages.FORGE_NIVEAU_MAX + 1):
			niveaux.append([niveau, "+" + nombre(CatalogueProjectiles.attaque_base(id, niveau))])
		tableau(lignes, ["Niveau de forge", "Attaque brute ajoutée (points)"], niveaux)
	lignes.append_array(["## Familiers", "",
		"Le familier entre dans chaque salle à sa propre position. Il alterne déplacement, visée et tir, sans suivre le héros. Ses projectiles traversent les murs et restent limités à la diagonale de la salle augmentée de leur longueur.", "",
		"Déplacement : %s s à %s px/s ; visée immobile : %s s, puis repos jusqu’au cycle suivant." % [nombre(CatalogueFamiliers.DEPLACEMENT_DUREE), nombre(CatalogueFamiliers.DEPLACEMENT_VITESSE), nombre(CatalogueFamiliers.VISEE_DUREE)], ""])
	for id: String in CatalogueFamiliers.TYPES:
		var d: Dictionary = CatalogueFamiliers.TYPES[id]
		lignes.append_array(["### " + str(d["nom"]), "",
			"**Provenance :** niveau de campagne %d." % CatalogueFamiliers.niveau_deblocage(id), "",
			str(d["description"]), "",
			"Un tir toutes les **%s s**. Son attaque propre reçoit une fois les bonus permanents d’attaque du héros, sans ses critiques." % nombre(float(d["intervalle"])), "",
			"Le DPS propre ci-dessous est indiqué avant bonus permanents, plafond et bonus finaux.", ""])
		var projectile: Dictionary = CatalogueFamiliers.PROJECTILES[id]
		lignes.append_array(["Projectile : %s px/s ; rayon %s px ; longueur %s px." % [nombre(float(projectile["vitesse"])), nombre(float(projectile["rayon"])), nombre(float(projectile["longueur"]))], ""])
		var niveaux: Array = []
		for niveau in range(Reglages.FORGE_NIVEAU_MAX + 1):
			var attaque := CatalogueFamiliers.attaque(id, niveau)
			niveaux.append([niveau, nombre(attaque), nombre(attaque / float(d["intervalle"]))])
		tableau(lignes, ["Niveau de forge", "Attaque propre (points)", "DPS propre (dégâts/s)"], niveaux)
	lignes.append_array(["## Bijoux actifs", ""])
	for anciens in [false, true]:
		if anciens: lignes.append_array(["## Bijoux historiques — sauvegardes uniquement", ""])
		for id: String in CatalogueObjets.OBJETS:
			var d: Dictionary = CatalogueObjets.OBJETS[id]
			if (int(d["monde"]) >= Chapitres.MONDES.size()) != anciens: continue
			lignes.append_array(["### " + str(d["nom"]), "",
				"**Emplacement :** %s · **Monde d’origine :** %d." % [str(d["slot"]), int(d["monde"]) + 1], ""])
			var niveaux: Array = []
			for niveau in range(Reglages.FORGE_NIVEAU_MAX + 1):
				niveaux.append([niveau, CatalogueObjets.description_bonus(id, niveau)])
			tableau(lignes, ["Niveau de forge", "Bonus de l’objet"], niveaux)
			var effets: Array = []
			for effet: String in CatalogueObjets.effets_objet(id, Reglages.FORGE_NIVEAU_MAX):
				effets.append([int(EffetsBijoux.PALIERS[0]), EffetsBijoux.nom(effet), EffetsBijoux.description(effet)])
			if not effets.is_empty():
				tableau(lignes, ["À partir du niveau", "Effet débloqué", "Détail"], effets)
	return "\n".join(lignes).strip_edges() + "\n"

static func maitrises() -> String:
	var lignes := entete("Liste des maîtrises", [
		"Un nœud normal possède %d rangs ; un pouvoir majeur s’achète une seule fois." % Reglages.MAITRISE_RANG_MAX,
		"Bonus du nœud = bonus d’un rang × rang acquis. Les bonus d’une même statistique s’additionnent.",
		"Coût du prochain rang = coût initial × (1 + %s × rangs déjà acquis), arrondi au multiple de %d." % [nombre(Reglages.MAITRISE_COUT_AJOUT_PAR_RANG), Reglages.COUT_PAS_ARRONDI],
		"L’attaque est un pourcentage de l’attaque brute du héros ; elle ne donne pas des dégâts fixes.",
		"Dégâts moyens d’un tir, hors augments et bonus finaux = attaque × coefficient de l’arme × [1 + chance critique × (coefficient critique − 1)].",
		"Une maîtrise de critique agit sur ce dernier facteur. La cadence augmente les tirs par seconde, pas les dégâts d’un tir.",
		"Les prérequis demandent au moins un rang dans le nœud précédent, pas son maximum.",
	])
	var total := 0
	for branche: String in ArbreCompetences.BRANCHES:
		lignes.append_array(["## " + branche, ""])
		var cout_branche := 0
		for id: String in ArbreCompetences.BRANCHES[branche]:
			var d: Dictionary = ArbreCompetences.NOEUDS[id]
			var precedent: Dictionary = ArbreCompetences.NOEUDS.get(str(d.get("requis", "")), {})
			lignes.append_array(["### " + str(d["nom"]), "",
				"**Prérequis :** %s." % str(precedent.get("nom", "aucun")), ""])
			var cumul := 0
			var rangs: Array = []
			for rang in range(1, ArbreCompetences.rangs(id) + 1):
				var cout := ArbreCompetences.cout(id, rang - 1)
				cumul += cout
				rangs.append([rang, ArbreCompetences.valeur_au_rang(id, rang), cout, cumul])
			tableau(lignes, ["Rang", "Bonus acquis", "Achat du rang (Gouttes)", "Coût cumulé (Gouttes)"], rangs)
			cout_branche += cumul
		lignes.append_array(["**Total de la branche : %d Gouttes.**" % cout_branche, ""])
		total += cout_branche
	lignes.append_array(["## Coût total", "",
		"Toutes les maîtrises au maximum : **%d Gouttes**." % total, "",
		"Les comparaisons de dégâts figurent dans la [liste mathématique](liste_mathematique.md).", ""])
	return "\n".join(lignes).strip_edges() + "\n"

static func passifs() -> String:
	var lignes := entete("Liste des passifs", [
		"%d emplacements équipables. Un passif non équipé ne donne aucun bonus." % Passifs.EMPLACEMENTS,
		"%d rangs par passif. Bonus = valeur du rang 1 × rang ; un doublon passe au rang 2." % Passifs.RANG_MAX,
		"Pour l’attaque, les PV, la défense et la cadence, les bonus des passifs s’additionnent entre eux, puis multiplient les statistiques déjà obtenues. Un +30 % d’attaque de passifs multiplie donc cette attaque par 1,30.",
		"Les soins, la vitesse de déplacement et celle des projectiles gardent un cumul additif avec les autres sources permanentes. Les critiques s’ajoutent en points ; la chance est plafonnée à 100 %.",
		"Audace et Reprise de souffle s’additionnent dans un même facteur de dégâts finaux : 1 + Audace + Reprise active + éventuel Élan offensif du bijou. Reprise exige une période sans blessure ; Audace augmente aussi les dégâts subis.",
		"Ils s’obtiennent dans les Épreuves, sans dépense de Gouttes ni de Pierres. La campagne n’en offre pas.",
		"Une victoire a %s %% de chance de donner un passif ; il est garanti à la victoire n°%d depuis le précédent, tant qu’un rang est disponible dans cette Épreuve." % [nombre(100.0 / Reglages.EPREUVE_GARANTIE_CAPACITE), Reglages.EPREUVE_GARANTIE_CAPACITE],
		"Les nouveaux passifs du niveau sont prioritaires sur leurs doublons. Un passif au maximum sort des candidats.",
	])
	lignes.append_array(["## Accès aux Épreuves", "",
		"Il faut vaincre l’Épreuve précédente et atteindre le chapitre de campagne indiqué. Le premier niveau s’ouvre après la première victoire de campagne. Chaque niveau accessible reste rejouable ; les anciens passifs, Cœurs et records sont conservés.", ""])
	var acces: Array = []
	for niveau in range(1, Epreuves.nombre() + 1):
		acces.append([niveau, Chapitres.libelle_court(Epreuves.campagne_requise(niveau) - 1)])
	tableau(lignes, ["Épreuve", "Chapitre de campagne à débloquer"], acces)
	for categorie: String in ["Offensif", "Défensif", "Utilitaire"]:
		lignes.append_array(["## " + categorie, ""])
		for id: String in Passifs.CATALOGUE:
			var d: Dictionary = Passifs.CATALOGUE[id]
			if str(d["categorie"]) != categorie: continue
			lignes.append_array(["### " + str(d["nom"]), "",
				"**Obtention :** %s." % Epreuves.provenance(id), "",
				str(d["description"]), ""])
			var rangs: Array = []
			for rang in range(1, Passifs.rang_max(id) + 1):
				rangs.append([rang, Passifs.resume_rang(id, rang)])
			tableau(lignes, ["Rang", "Effet au niveau maximal du héros"], rangs)
	lignes.append_array(["## Cœurs de mana des Épreuves", "",
		"Chaque niveau d’Épreuve possède un Cœur unique, garanti au plus tard après %d victoires sans son Cœur." % Reglages.EPREUVE_GARANTIE_COEUR,
		"",
		"Chaque Cœur donne +%s %% de dégâts finaux ; %d Cœurs donnent au total +%s %% (addition, sans exponentielle)." % [nombre(Reglages.COEUR_MANA_BONUS_FINAL * 100.0), Epreuves.nombre(), nombre(Reglages.COEUR_MANA_BONUS_FINAL * Epreuves.nombre() * 100.0)],
		"", "## Anciennes sauvegardes", "",
		"Les anciens sorts et ultimes sont convertis en passifs lors du chargement d’une ancienne sauvegarde.", ""])
	return "\n".join(lignes).strip_edges() + "\n"

static func monstres() -> String:
	var lignes := entete("Liste des monstres", [
		"Les statistiques de base ci-dessous sont multipliées par le niveau de campagne puis par la salle. Voir la [liste mathématique](liste_mathematique.md) pour chaque coefficient.",
		"Les variantes des cinq mondes changent les noms et certaines attaques, pas la courbe de PV ni de dégâts de la famille.",
		"Un élite multiplie les PV par %s, les dégâts par %s et la vitesse par %s." % [nombre(RangsEnnemis.ELITE_PV), nombre(RangsEnnemis.ELITE_DEGATS), nombre(RangsEnnemis.ELITE_VITESSE)],
		"Les boss appliquent en plus leurs facteurs dédiés ; leurs motifs peuvent infliger une fraction des dégâts de base.",
		"Les dégâts indiqués sont avant la Défense et les réductions du héros. La vitesse est en pixels de simulation par seconde.",
	])
	_rythme_monstres(lignes)
	for id: String in CatalogueEnnemis.TOUS:
		var d: Dictionary = CatalogueEnnemis.TOUS[id]
		lignes.append_array(["## " + str(d["nom"]), "",
			"**Rang :** %s." % str(d.get("rang_boss", RangsEnnemis.categorie(id))), ""])
		var statistiques: Array = [
			["Points de vie", nombre(float(d["pv"])) + " PV"],
			["Dégâts", nombre(float(d["degats"])) + " dégâts"],
			["Vitesse", nombre(float(d["vitesse"])) + " px/s"],
		]
		if d.has("recharge") and str(d["cerveau"]) != "poursuivant":
			statistiques.append(["Intervalle d’attaque", nombre(float(d["recharge"])) + " s"])
		var recharge_contact := BestiaireMondes.BOSS_DEGATS_CONTACT_RECHARGE if str(d["cerveau"]) == "boss" else BestiaireMondes.POURSUITE_CONTACT_RECHARGE
		statistiques.append(["Contact du corps", "Dégâts immédiats ; délai entre contacts %s s" % nombre(recharge_contact)])
		if str(d["cerveau"]) == "veloce":
			statistiques.append_array([
				["Durée de charge en terrain libre", nombre(float(d["duree_charge"])) + " s ; trajet annoncé arrêté au premier mur ou obstacle"],
				["Portée de déclenchement", nombre(Cerveaux.portee_charge(d, Reglages.ENNEMI_VITESSE_MULT)) + " px avant coefficients de niveau et ralentissements, hitboxes comprises"],
			])
		if str(d["cerveau"]) == "boss":
			var deplacement := DeplacementsBoss.profil(d)
			statistiques.append_array([
				["Déplacement", str(deplacement["nom"]) + " vers le joueur"],
				["Distance recherchée", nombre(float(deplacement["distance"])) + " px"],
				["Déplacement entre motifs de tir", nombre(float(deplacement["repositionnement"])) + " s"],
				["Portée totale des projectiles", nombre(BestiaireMondes.BOSS_PORTEE_PROJECTILE) + " px"],
			])
		if d.has("part_degats_projectile"):
			statistiques.append(["Dégâts du projectile", nombre(float(d["part_degats_projectile"]) * 100.0) + " % des dégâts de base"])
		if ProjectilesEnnemis.PROFILS.has(id) and str(d["cerveau"]) not in ["poursuivant", "artilleur"]:
			var projectile: Dictionary = ProjectilesEnnemis.PROFILS[id]
			var trajectoire := str(projectile.get("trajectoire", "droite"))
			statistiques.append_array([
				["Projectile", str(projectile["nom"])],
				["Vitesse du projectile", nombre(float(projectile["vitesse"])) + " px/s avant coefficients"],
				["Rayon de collision", nombre(float(projectile["rayon"])) + " px"],
				["Longueur de collision", nombre(float(projectile["longueur"])) + " px"],
				["Trajectoire", {"droite": "Droite", "sinus": "Ondulation", "aller_retour": "Aller-retour sur un axe fixe"}[trajectoire]],
				["Rebonds sur les murs", str(projectile.get("rebonds", 0))],
			])
			if trajectoire == "aller_retour":
				statistiques.append(["Demi-tour", "Après %s px ou au premier mur ; arrêt %s s avant retour" % [nombre(float(projectile["retour"])), nombre(ProjectilesEnnemis.RETOUR_PAUSE)]])
				if str(d["cerveau"]) == "boss":
					statistiques.append(["Salve de boomerangs", "%d branches en éventail dirigé vers le joueur" % ProjectilesEnnemis.RETOUR_BOSS_ANGLES.size()])
		tableau(lignes, ["Statistique", "Valeur de base"], statistiques)
		if AttaquesContactBoss.PROFILS.has(id):
			var contact: Dictionary = AttaquesContactBoss.PROFILS[id]
			lignes.append_array(["### Attaque au contact : " + str(contact["nom"]), "",
				"Approche limitée et abandonnée si le joueur reste inaccessible. L’annonce commence à portée, avec une visée verrouillée et une seule frappe. Le boss reste immobile pendant sa récupération ; aucune salve simultanée.", ""])
			tableau(lignes, ["Paramètre", "Valeur"], [
				["Approche maximale", nombre(float(contact["approche"])) + " s"],
				["Annonce", nombre(float(contact["annonce"])) + " s"],
				["Portée depuis le centre", nombre(float(contact["portee"])) + " px"],
				["Angle de frappe", nombre(rad_to_deg(float(contact["arc"]))) + "°"],
				["Récupération immobile", nombre(float(contact["repos"])) + " s"],
			])
		if BestiaireMondes.NOMS.has(id):
			lignes.append_array(["### Variantes par monde", ""])
			var noms: Array = BestiaireMondes.NOMS[id]
			var variantes: Array = []
			for monde in noms.size():
				variantes.append([str(Chapitres.MONDES[monde]["nom"]), str(noms[monde])])
			tableau(lignes, ["Monde", "Nom de la variante"], variantes)
	return "\n".join(lignes).strip_edges() + "\n"

static func _rythme_monstres(lignes: Array[String]) -> void:
	lignes.append_array(["## Rythme et esquive", "",
		"La vitesse des tirs et la recharge progressent avec le niveau et l’avancée de la tentative, indépendamment du build. Les multiplicateurs ci-dessous s’appliquent aux profils de base ; les tirs ordinaires ajoutent ×%s en vitesse, les boss ×%s. Les plafonds des ricochets et des allers-retours suivent aussi la progression." % [nombre(Reglages.ENNEMI_PROJECTILE_VITESSE_MULT), nombre(Reglages.BOSS_PROJECTILE_VITESSE_MULT)], ""])
	var rythmes: Array = []
	for chapitre in [0, 6, 17, 27, Chapitres.nombre() - 1]:
		var debut := EvolutionEnnemis.facteurs_rythme(chapitre)
		var fin := EvolutionEnnemis.facteurs_rythme(chapitre, 1.0)
		rythmes.append([str(chapitre + 1), nombre(float(debut["projectile"])), nombre(float(fin["projectile"])),
			nombre(float(debut["recharge"])), nombre(float(fin["recharge"])), nombre(float(debut["telegraphe"]))])
	tableau(lignes, ["Niveau", "Vitesse début ×", "Vitesse fin ×", "Recharge début ×", "Recharge fin ×", "Annonce ×"], rythmes)
	var tisseur := CatalogueEnnemis.par_id("fuseau_tisseur")
	var sentinelle := CatalogueEnnemis.par_id("plume_sentinelle")
	lignes.append_array([
		"La sentinelle tire à %s px/s avant coefficients. Dès le début de l’annonce, elle fixe une visée anticipant la course pendant sa préparation et un vol plafonné à %s px. Une course régulière est menacée à mi-distance ; changer de direction ou se couvrir permet l’esquive. À l’autre bout de la salle, le temps de vol laisse une marge latérale. Chaque éventail garde un trait central." % [nombre(float(sentinelle["vitesse_projectile"])), nombre(ProjectilesEnnemis.SENTINELLE_ANTICIPATION_PORTEE)], "",
		"Les boss apparaissent près du milieu, sur une place libre. Ils avancent, prennent un flanc ou tournent autour du joueur selon leur identité. Leurs motifs disponibles varient dans l’ordre selon la distance et les obstacles, sans répétition immédiate. Les mêlées ne s’arment qu’à portée et les approches ratées sont abandonnées.", "",
		"Les tireurs utilisent la portée réelle de leurs projectiles sans attendre leur distance de placement ; les tireurs fuyards gardent leur recul. Les phaseurs se téléportent aussi de loin, vers une place libre annoncée. Les invocateurs appellent à distance et restent capables de tirer une fois leurs renforts épuisés.", "",
		"Une charge exige une cible atteignable et une voie libre, y compris après la préparation et avant un enchaînement. Le déplacement suit exactement le segment annoncé, limité par les murs et obstacles. Un ralentissement empêchant de couvrir ce segment avant le départ annule la charge ; après le départ, il allonge le trajet dans le temps sans raccourcir sa distance.", "",
		"Les boomerangs des boss sont plus épais, saturés et bordés de sombre. Leur éventail compte %d branches ; leur plafond de vitesse est %s px/s avant progression, contre %s px/s pour les monstres ordinaires. La portée totale couvre les deux trajets ; un mur provoque le retour." % [ProjectilesEnnemis.RETOUR_BOSS_ANGLES.size(), nombre(ProjectilesEnnemis.RETOUR_BOSS_VITESSE_MAX), nombre(ProjectilesEnnemis.RETOUR_VITESSE_MAX)], "",
		"Les tirs lents partent sans tracé préalable. Une annonce est requise dès %s px/s de vitesse réelle, ou si le temps avant impact est inférieur à %s s après prise en compte des hitboxes. La règle suit la progression et les plafonds des trajectoires. Les impacts de zone et les frappes préparées gardent leur avertissement ; tout monstre ou boss vivant blesse dès le contact physique, même gelé, après son apparition. Les murs protègent du contact et les cadavres ne blessent pas." % [nombre(ProjectilesEnnemis.VITESSE_ANNONCE), nombre(ProjectilesEnnemis.REACTION_SANS_ANNONCE)], "",
		"Quand elle est nécessaire, l’annonce ordinaire dure au moins %s s, celle d’une salve de boss %s s. La visée annoncée reste verrouillée jusqu’au départ." % [nombre(Reglages.ENNEMI_TELEGRAPHE_MIN), nombre(BestiaireMondes.BOSS_ANNONCE_TIR)], "",
		"Le tisseur lance %d rubans sans annonce ni anticipation : écart %s px, amplitude %s px, fréquence initiale %s Hz. La fréquence suit ensuite la hausse de vitesse. Il recule si le temps de vol devient inférieur à %s s ; son passage reste ouvert à tous les niveaux." % [int(tisseur["projectiles"]), nombre(float(tisseur["ecart_lateral"])), nombre(float(tisseur["amplitude"])), nombre(float(tisseur["frequence"])), nombre(BestiaireMondes.TISSEUR_REACTION_MIN)], "",
		"Salle de référence : %s × %s px ; zoom caméra %s. Les variantes de forme appliquent leurs proportions à cette taille." % [nombre(Reglages.ARENE_TAILLE.x), nombre(Reglages.ARENE_TAILLE.y), nombre(Reglages.ARENE_CAMERA_ZOOM, 4)], ""])
