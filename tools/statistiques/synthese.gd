extends RefCounted

const Listes = preload("res://tools/statistiques/listes.gd")
const Modeles = preload("res://tools/statistiques/modeles.gd")
const Attribution = preload("res://tools/statistiques/attribution.gd")
const ProfilReference = preload("res://tools/statistiques/profil_reference.gd")

const LIBELLES_BONUS := {
	"attaque_base": ["ATK brute", 1.0, ""], "pv_base": ["PV bruts", 1.0, ""],
	"defense_base": ["Défense brute", 1.0, ""], "attaque_mult": ["ATK", 100.0, " %"],
	"pv_mult": ["PV", 100.0, " %"], "defense_mult": ["Défense", 100.0, " %"],
	"cadence": ["cadence", 100.0, " %"], "critique": ["chance critique", 100.0, " points"],
	"degats_critiques": ["dégâts critiques", 100.0, " points"],
	"vitesse": ["déplacement", 100.0, " %"], "projectile": ["vitesse et portée des tirs", 100.0, " %"],
	"soin": ["soins", 100.0, " %"], "butin": ["butin", 100.0, " %"],
}

static func n(valeur: float, decimales := 2) -> String:
	return Listes.nombre(valeur, decimales)

static func ajouter(lignes: Array[String]) -> void:
	var profil := ProfilReference.construire()
	var partage := Attribution.calculer_permanent(profil)
	var permanent: Dictionary = partage["total"]
	var total := Modeles.mesurer(profil)
	var parts: Array = partage["parts"]
	var noms: Array = partage["noms"]
	var repartition: Array[String] = []
	for index in parts.size():
		var part: Dictionary = parts[index]
		repartition.append("%s **%s %%**" % [str(noms[index]), n(float(part["dps"]) / float(permanent["dps"]) * 100.0, 1)])
	var socle: Dictionary = partage["base"]
	repartition.append("socle du héros à son niveau **%s %%**" % n(float(socle["dps"]) / float(permanent["dps"]) * 100.0, 1))
	lignes.append("**Compte au maximum, avant les augments : %s DPS permanents, %s PV et %s Défense.** Le matériel est celui optimisé pour le panier classique détaillé plus bas ; il reste identique pendant la comparaison." % [n(float(permanent["dps"])), n(float(permanent["pv"])), n(float(permanent["defense"]))])
	lignes.append("")
	lignes.append("**Répartition de 100 %% de ce DPS permanent :** %s. Les cinq sources et le socle de niveau partagent leurs synergies ; les augments sont exclus de cette répartition." % " ; ".join(repartition))
	lignes.append("Cible : environ 20 % de DPS par source permanente sur ce compte complet, interactions comprises ; le contrôle accepte 18 à 24 % pour conserver l’utilité des cinq objets. Les proportions varient avec les achats, les passifs équipés et les attributs choisis ; les PV, la Défense et chaque statistique individuelle ne suivent pas ce partage de dégâts.")
	lignes.append("")
	_gain_en_run(lignes, permanent, total)
	lignes.append_array(["## Fiche : socle permanent puis augments", "",
		"Les contributions se calculent sans augment et s’additionnent au chiffre de départ. La colonne de droite montre ensuite le même build avec le panier classique illustratif. Un impact peut diminuer alors que le DPS monte grâce aux projectiles et aux salves supplémentaires.", ""])
	var lignes_stats: Array = []
	for mesure: Array in [["attaque", "Attaque"], ["tir_moyen", "Dégâts moyens par projectile du héros"],
		["cadence", "Attaques par seconde"], ["dps_heros", "DPS du héros"], ["dps_familier", "DPS du familier"],
		["dps", "DPS total"], ["pv", "PV maximum"], ["defense", "Défense"]]:
		var cle := str(mesure[0])
		lignes_stats.append([str(mesure[1]), "**%s**" % n(float(permanent[cle])), _ventilation(partage, cle), "**%s**" % n(float(total[cle]))])
	Listes.tableau(lignes, ["Statistique", "Départ permanent", "Sources permanentes : valeur et part du départ", "Après les augments classiques"], lignes_stats)
	lignes.append("Le tir normal vaut **%s**, le critique **%s**, avec **%s %%** de chance critique. La moyenne inclut aussi Cinquième impact si l’anneau choisi le possède. Une attaque envoie **%d projectile(s) frontal(aux) × %d salves**. Les DPS supposent que tous touchent et que les effets conditionnels d’anneau sont actifs." % [n(float(total["tir_normal"])), n(float(total["tir_critique"])), n(float(total["critique"]) * 100.0), int(total["projectiles_frontaux"]), int(total["salves"])])
	lignes.append("")
	_ordre_formules(lignes, profil, total)
	_sources_directes(lignes, profil)
	_profil(lignes, profil)
	_attributs(lignes, profil)
	_sensibilite(lignes, partage)
	lignes.append_array(["### Comment lire les proportions", "",
		"Pour les cinq sources permanentes, on mesure chaque source dans les 120 ordres possibles et on moyenne son apport. Ce partage de Shapley répartit les synergies entre équipement, attributs, maîtrises, passifs et Cœurs. Ces contributions, plus le socle du héros, retombent exactement sur le DPS permanent sans augments.", "",
		"Le gain des augments répond à une autre question : combien de DPS a été ajouté pendant la run au même build ? Il vaut DPS final − DPS permanent, et sa part du DPS final vaut 1 − 1 / multiplicateur de run. Il ne fait pas partie des 100 % de sources permanentes.", "",
		"La colonne de contribution est une répartition du socle, pas une prévision de nerf. Le tableau de retrait garde les augments absents et retire une source permanente entière. Ces pertes se chevauchent et ne s’additionnent pas ; elles ne prédisent pas directement l’effet d’un nerf de 10 %.", ""])

static func _gain_en_run(lignes: Array[String], permanent: Dictionary, total: Dictionary) -> void:
	var depart := float(permanent["dps"])
	var final := float(total["dps"])
	var facteur := final / depart
	var gain := final - depart
	var part := gain / final
	lignes.append("> **Avec les augments classiques illustratifs : %s → %s DPS, soit ×%s.** La run ajoute **%s DPS**, ce qui représente **%s %% du DPS final** ; le socle permanent en représente les %s %% restants." % [n(depart), n(final), n(facteur), n(gain), n(part * 100.0), n((1.0 - part) * 100.0)])
	lignes.append("")
	lignes.append("Calcul : (%s − %s) / %s = 1 − 1 / %s = %s %%. Par exemple, 1 000 → 3 000 DPS signifie que les augments ajoutent 2 000 DPS, soit 66,7 %% du total final. Ce panier fixe est illustratif ; la simulation présentée plus loin mesure la dispersion des résultats avec les offres réelles." % [n(final), n(depart), n(final), n(facteur, 4), n(part * 100.0)])
	lignes.append("")

static func _ventilation(partage: Dictionary, cle: String) -> String:
	var resultat: Array[String] = []
	var total: Dictionary = partage["total"]
	var base: Dictionary = partage["base"]
	var parts: Array = partage["parts"]
	var noms: Array = partage["noms"]
	var valeur_totale := float(total[cle])
	if not is_zero_approx(float(base[cle])):
		resultat.append("Base : %s (%s %%)" % [n(float(base[cle])), n(float(base[cle]) / valeur_totale * 100.0, 1)])
	for index in parts.size():
		var part: Dictionary = parts[index]
		var valeur := float(part[cle])
		if is_zero_approx(valeur): continue
		resultat.append("%s : %s%s (%s %%)" % [str(noms[index]), "+" if valeur > 0.0 else "", n(valeur), n(valeur / valeur_totale * 100.0, 1)])
	return "\n".join(resultat)

static func _ordre_formules(lignes: Array[String], profil: Dictionary, total: Dictionary) -> void:
	var etapes: Dictionary = total["etapes_permanentes"]
	var attaque: Dictionary = etapes["attaque"]
	var pv: Dictionary = etapes["pv"]
	lignes.append_array(["## Ordre réel des calculs", "",
		"Le héros nu au niveau %d possède **%s ATK** et **%s PV** avant de répartir ses %d points. Ce socle de niveau est compté séparément des attributs." % [int(profil["niveau"]), n(float(attaque["base"])), n(float(pv["base"])), Personnage.points_totaux(int(profil["niveau"]))], "",
		"L’attaque brute vaut **%s niveau + %s attributs + %s équipement = %s**. On applique ensuite les pourcentages de l’équipement, puis les maîtrises, les passifs et les augments. Les pourcentages s’additionnent à l’intérieur d’une source ; les facteurs des sources se multiplient." % [n(float(attaque["base"])), n(float(attaque["attributs_bruts"])), n(float(attaque["equipement_brut"])), n(float(attaque["brut"]))], ""])
	var calculs: Array = []
	for definition: Array in [["attaque", "Attaque", "facteur_attaque_augments"],
		["pv", "PV", "facteur_pv_augments"], ["defense", "Défense", "facteur_defense_augments"],
		["cadence", "Cadence avant l’arme", "facteur_cadence_augments"]]:
		var etape: Dictionary = etapes[str(definition[0])]
		var facteur_augments := float(total[str(definition[2])])
		var base := float(etape["brut"]) * float(etape["facteur_attributs"])
		calculs.append([str(definition[1]), n(base, 4 if str(definition[0]) == "cadence" else 2), "×%s" % n(float(etape["facteur_equipement"])),
			"×%s" % n(float(etape["facteur_maitrises"])), "×%s" % n(float(etape["facteur_passifs"])),
			"×%s" % n(facteur_augments, 4), "**%s**" % n(float(etape["permanent"]) * facteur_augments)])
	Listes.tableau(lignes, ["Statistique", "Base brute, attributs inclus", "Équipement", "Maîtrises", "Passifs", "Augments", "Résultat"], calculs)
	lignes.append("Les valeurs affichées sont arrondies ; les calculs conservent la précision de chaque étape.")
	lignes.append("")
	lignes.append("Pour la cadence, les attributs donnent ×%s avant les autres sources et l’arme ajoute ×%s : la cadence finale atteint %s attaques/s. Les chances et les dégâts critiques s’additionnent en points ; la chance est plafonnée à 100 %% après les augments." % [n(float(etapes["cadence"]["facteur_attributs"])), n(float(total["cadence_arme"])), n(float(total["cadence"]))])
	lignes.append("")
	lignes.append("Un projectile normal suit ensuite **%s ATK de run × %s coefficient d’arme × %s malus de projectile × %s bonus conditionnels × %s Cœurs = %s dégâts**. Les Cœurs sont le dernier facteur de dégâts ; ils ne modifient ni l’ATK de run, ni les PV, ni la Défense, ni la cadence." % [n(float(total["attaque"])), n(float(total["coefficient_arme"])), n(float(total["degats_projectile_mult"]), 4), n(float(total["facteur_conditionnel"])), n(float(total["facteur_coeurs"])), n(float(total["tir_normal"]))])
	lignes.append("")
	lignes.append("Pour la moyenne, on applique la probabilité critique et l’effet moyen de l’anneau. Puis on multiplie par la cadence, les projectiles frontaux et les salves. Le familier utilise sa propre attaque de forge × le produit permanent des bonus d’attaque du héros, × le facteur d’attaque des augments ; ses tirs reçoivent les dégâts finaux et les Cœurs, sans critique ni salve du héros. Sa forge ne dépend plus de l’attaque de l’arme équipée.")
	lignes.append("")

static func _sources_directes(lignes: Array[String], profil: Dictionary) -> void:
	var maitrises: Dictionary = profil["maitrises"]
	var bonus_maitrises := {"attaque_mult": ArbreCompetences.bonus_attaque(maitrises),
		"pv_mult": ArbreCompetences.multiplicateur_pv(maitrises) - 1.0,
		"defense_mult": ArbreCompetences.multiplicateur_defense(maitrises) - 1.0,
		"cadence": ArbreCompetences.multiplicateur_cadence(maitrises) - 1.0,
		"critique": ArbreCompetences.bonus_critique(maitrises),
		"degats_critiques": ArbreCompetences.bonus_degats_critiques(maitrises),
		"vitesse": ArbreCompetences.multiplicateur_vitesse(maitrises) - 1.0,
		"projectile": ArbreCompetences.multiplicateur_projectile(maitrises) - 1.0,
		"soin": ArbreCompetences.multiplicateur_soin(maitrises) - 1.0}
	lignes.append_array(["## Ce que chaque source permanente apporte directement", ""])
	Listes.tableau(lignes, ["Source au plafond retenu", "Bonus avant combinaison"], [
		["Attributs répartis", resume_bonus(Personnage.bonus(profil["attributs"]))],
		["Cinq équipements, forge maximum", resume_bonus(Modeles.bonus_equipement(profil)) + ". S’y ajoutent la forme et le rythme de l’arme, le tir du familier et l’effet d’anneau."],
		["Toutes les maîtrises", resume_bonus(bonus_maitrises) + ". Dégâts subis −%s %%." % n(ArbreCompetences.reduction_degats(maitrises) * 100.0)],
		["Quatre passifs au rang maximum", resume_bonus(Passifs.bonus_stats(profil["passifs"]))],
		["Tous les Cœurs", "+%s %% de dégâts finaux." % n(int(profil["coeurs"]) * Reglages.COEUR_MANA_BONUS_FINAL * 100.0)],
		["Sorcier ou Moine", "Aucun bonus actuellement."]])
	lignes.append_array(["Les autres effets de soins, collecte et économie sont détaillés par rang dans les [maîtrises](liste_maitrises.md) et les [passifs](liste_passifs.md). Ils ne sont pas transformés artificiellement en dégâts dans la fiche.", ""])

static func _profil(lignes: Array[String], profil: Dictionary) -> void:
	lignes.append_array(["## Le profil utilisé", "",
		"**Tout est au plafond de progression**, avec une répartition polyvalente des attributs et quatre passifs équipés. Ce n’est pas un maximum simultané de chaque statistique : privilégier l’attaque, les PV ou le rendement économique conduit à des choix différents.", "",
		"Le matériel ci-dessous maximise le DPS frontal continu total parmi **%d combinaisons d’équipements actuellement obtenables**, à attributs, passifs et augments identiques. Les bijoux historiques réservés aux anciennes sauvegardes sont exclus. Le meilleur matériel pour résister ou toucher une cible mobile peut être différent." % ProfilReference.nombre_combinaisons(), ""])
	var arme := str(profil["arme"])
	var familier := str(profil["familier"])
	var donnees_arme: Dictionary = CatalogueProjectiles.TYPES[arme]
	var donnees_familier: Dictionary = CatalogueFamiliers.TYPES[familier]
	var equipement: Array = [
		["Arme", str(donnees_arme["nom"]), int(profil["forge_arme"]), "+%s ATK brute. %s" % [n(CatalogueProjectiles.attaque_base(arme, int(profil["forge_arme"]))), str(donnees_arme["description"])]],
		["Familier", str(donnees_familier["nom"]), int(profil["forge_familier"]), "%s attaque propre, un tir toutes les %s s. %s" % [n(CatalogueFamiliers.attaque(familier, int(profil["forge_familier"]))), n(float(donnees_familier["intervalle"])), str(donnees_familier["description"])]]]
	var bijoux: Dictionary = profil["bijoux"]
	var forge: Dictionary = profil["forge_bijoux"]
	for slot: String in ["anneau", "bracelet", "collier"]:
		var id := str(bijoux[slot])
		var objet: Dictionary = CatalogueObjets.OBJETS[id]
		var descriptions: Array[String] = [CatalogueObjets.description_bonus(id, int(forge[id]))]
		for effet: String in CatalogueObjets.effets_objet(id, int(forge[id])):
			descriptions.append(EffetsBijoux.description(effet))
		equipement.append([slot.capitalize(), str(objet["nom"]), int(forge[id]), "\n".join(descriptions)])
	Listes.tableau(lignes, ["Emplacement", "Modèle", "Forge", "Statistiques et effet"], equipement)
	var passifs: Dictionary = profil["passifs"]
	var passifs_texte: Array[String] = []
	for id: String in passifs:
		passifs_texte.append("%s rang %d" % [str(Passifs.donnees(id)["nom"]), int(passifs[id])])
	lignes.append("**Passifs :** %s. **Cœurs :** %d. **Maîtrises :** tous les rangs des trois branches." % [", ".join(passifs_texte), int(profil["coeurs"])])
	lignes.append("")
	var cumuls := {}
	var raretes := {Reactif.RARE: 0, Reactif.EPIQUE: 0, Reactif.LEGENDAIRE: 0}
	for id: String in profil["augments"]:
		cumuls[id] = int(cumuls.get(id, 0)) + 1
		var rarete := CatalogueReactifs.par_id(id).rarete
		raretes[rarete] = int(raretes.get(rarete, 0)) + 1
	var augments: Array = []
	for id: String in cumuls:
		var reactif := CatalogueReactifs.par_id(id)
		augments.append([reactif.nom, int(cumuls[id]), reactif.nom_rarete(), DetailsReactif.texte(reactif, int(cumuls[id]))])
	lignes.append("**Run classique illustrative :** %d rares, %d épiques et %d légendaire, sans légendaire bonus. Elle mêle dégâts et survie ; les offres aléatoires ne garantissent pas cette combinaison et ce panier ne représente pas leur médiane." % [int(raretes[Reactif.RARE]), int(raretes[Reactif.EPIQUE]), int(raretes[Reactif.LEGENDAIRE])])
	Listes.tableau(lignes, ["Augment", "Copies", "Rareté", "Effet cumulé"], augments)

static func _attributs(lignes: Array[String], profil: Dictionary) -> void:
	var points := Personnage.points_totaux(Personnage.NIVEAU_MAX)
	lignes.append_array(["## Attributs : le vrai maximum disponible", "",
		"Au niveau **%d**, le compte possède **%d points à répartir au total**. On peut tous les placer dans un attribut, mais les maxima de la dernière colonne ne sont pas cumulables. La fiche utilise tous les points ; leurs bonus bruts sont renforcés ensuite par les maîtrises et les passifs." % [Personnage.NIVEAU_MAX, points], ""])
	lignes.append("Les attributs offensifs prennent progressivement leur puissance avec le niveau du héros. Leur rendement décroît quand on concentre davantage de points dans le même attribut ; la Vitalité et la Sagesse gardent leur calcul par point.")
	lignes.append("")
	lignes.append("Pour Force, Agilité et Intelligence, le poids de p points vaut **2 × %s × p / (%s + p)**. Au niveau n, on le multiplie par **%s + (1 − %s) × ((n − 1) / (%d − 1))²**, puis par le coefficient de l’attribut. Le gain d’un point est la différence entre p + 1 et p au même niveau, pas un bonus constant par point." % [n(Personnage.POINTS_RENDEMENT), n(Personnage.POINTS_RENDEMENT), n(Personnage.PUISSANCE_INITIALE), n(Personnage.PUISSANCE_INITIALE), Personnage.NIVEAU_MAX])
	lignes.append("")
	var attributs: Dictionary = profil["attributs"]
	var donnees: Array = []
	for id: String in Personnage.ATTRIBUTS:
		var definition: Dictionary = Personnage.ATTRIBUTS[id]
		var rang := int(attributs.get(id, 0))
		donnees.append([str(definition["nom"]), rang, resume_bonus(Personnage.bonus({id: rang})),
			resume_bonus(Personnage.gain_point(id, rang, int(profil["niveau"]))), resume_bonus(Personnage.bonus({id: points}))])
	Listes.tableau(lignes, ["Attribut", "Points du profil", "Bonus dans cette fiche", "Gain du prochain point au même niveau", "Maximum individuel : %d points" % points], donnees)
	lignes.append("Dans Héros, le total acquis et le gain du prochain point utilisent Personnage.bonus au niveau courant. Les valeurs affichées sont arrondies à trois décimales ; les calculs gardent leur précision. Les ATK, PV et Défense bruts sont renforcés ensuite par les autres sources. Les points de critique s’ajoutent avant le plafond de chance.")
	lignes.append("")

static func _sensibilite(lignes: Array[String], partage: Dictionary) -> void:
	var total: Dictionary = partage["total"]
	var sans: Array = partage["sans_source"]
	var noms: Array = partage["noms"]
	var donnees: Array = []
	for index in sans.size():
		var mesure: Dictionary = sans[index]
		donnees.append([str(noms[index]), n(float(mesure["dps"])),
			"%s %%" % n((1.0 - float(mesure["dps"]) / float(total["dps"])) * 100.0),
			n(float(mesure["pv"])), n(float(mesure["defense"]))])
	lignes.append_array(["## Retrait d’une source permanente, sans augment", "",
		"On retire une source permanente entière et on garde tous les autres choix identiques, sans réoptimiser et sans aucun augment. Retirer l’équipement signifie arme, familier et bijoux absents ; le socle du héros reste capable d’un tir simple pour mesurer les contributions.", ""])
	Listes.tableau(lignes, ["Source retirée", "DPS restant", "Perte de DPS total", "PV restants", "Défense restante"], donnees)

static func resume_bonus(bonus: Dictionary) -> String:
	var morceaux: Array[String] = []
	for cle: String in LIBELLES_BONUS:
		var valeur := float(bonus.get(cle, 0.0))
		if is_zero_approx(valeur): continue
		var regle: Array = LIBELLES_BONUS[cle]
		morceaux.append("%s%s%s %s" % ["+" if valeur > 0.0 else "", n(valeur * float(regle[1])), str(regle[2]), str(regle[0])])
	return "Aucun bonus" if morceaux.is_empty() else " ; ".join(morceaux)
