class_name Stats
extends RefCounted

var pv_max: float
var pv: float
var soin_restant := INF
var soin_mult := 1.0
var vitesse: float
var cadence: float          # tirs par seconde
var attaque_base: float
var bonus_attaque: float
var degats: float           # ATK reelle permanente, avant coefficients et degats finaux
var defense: float
var critique: float
var critique_excedentaire := 0.0
var degats_critiques: float
var vitesse_projectile: float
var portee: float
var etapes_permanentes: Dictionary = {}

# Le socle du niveau reste distinct des points que le joueur choisit de repartir.
static func base_pv(niveau: int) -> float:
	return Reglages.statistique_arrondie(Reglages.HEROS_PV
		* pow(1.0 + Reglages.NIVEAU_PV_PAR_NIVEAU, clampi(niveau, 1, Personnage.NIVEAU_MAX) - 1))

static func base_degats(niveau: int) -> float:
	return Reglages.statistique_arrondie(Reglages.TIR_DEGATS
		* pow(1.0 + Reglages.NIVEAU_DEGATS_PAR_NIVEAU, clampi(niveau, 1, Personnage.NIVEAU_MAX) - 1))

static func base_cadence(niveau: int) -> float:
	return Reglages.HEROS_CADENCE * (1.0 + float(maxi(0, niveau - 1)) * Reglages.NIVEAU_CADENCE_PAR_NIVEAU)

static func composer_statistique(base: float, attributs_bruts: float, equipement_brut: float,
		facteur_attributs: float, facteur_equipement: float,
		facteur_maitrises: float, facteur_passifs: float) -> Dictionary:
	# Le combat et les explications lisent ces memes etapes. Chaque source
	# calcule son facteur avant cet appel ; les sources se multiplient ensuite.
	var brut := base + attributs_bruts + equipement_brut
	var apres_equipement := brut * facteur_attributs * facteur_equipement
	var apres_maitrises := apres_equipement * facteur_maitrises
	return {"base": base, "attributs_bruts": attributs_bruts, "equipement_brut": equipement_brut,
		"brut": brut, "facteur_attributs": facteur_attributs, "facteur_equipement": facteur_equipement,
		"apres_equipement": apres_equipement, "facteur_maitrises": facteur_maitrises,
		"apres_maitrises": apres_maitrises, "facteur_passifs": facteur_passifs,
		"permanent": apres_maitrises * facteur_passifs,
		"facteur_permanent": facteur_attributs * facteur_equipement * facteur_maitrises * facteur_passifs}

static func depuis_reglages(rangs: Dictionary = {}, passifs: Dictionary = {}, objets: Dictionary = {},
		niveau := 1, attributs: Dictionary = {}, _specialisation := "") -> Stats:
	var s := Stats.new()
	var bonus_attributs := Personnage.bonus(attributs, niveau)
	var bonus_passifs: Dictionary = Passifs.bonus_stats(passifs, niveau)
	s.etapes_permanentes["attaque"] = composer_statistique(base_degats(niveau),
		float(bonus_attributs["attaque_base"]), float(objets.get("attaque_base", 0.0)),
		1.0 + float(bonus_attributs["attaque_mult"]), 1.0 + float(objets.get("attaque_mult", 0.0)),
		ArbreCompetences.multiplicateur_attaque(rangs), 1.0 + float(bonus_passifs.get("attaque_mult", 0.0)))
	s.etapes_permanentes["pv"] = composer_statistique(base_pv(niveau),
		float(bonus_attributs["pv_base"]), float(objets.get("pv_base", 0.0)),
		1.0, 1.0 + float(objets.get("pv_mult", 0.0)),
		ArbreCompetences.multiplicateur_pv(rangs), 1.0 + float(bonus_passifs.get("pv_mult", 0.0)))
	s.etapes_permanentes["defense"] = composer_statistique(Reglages.HEROS_DEFENSE,
		float(bonus_attributs["defense_base"]), float(objets.get("defense_base", 0.0)),
		1.0, 1.0 + float(objets.get("defense_mult", 0.0)),
		ArbreCompetences.multiplicateur_defense(rangs), 1.0 + float(bonus_passifs.get("defense_mult", 0.0)))
	s.etapes_permanentes["cadence"] = composer_statistique(base_cadence(niveau), 0.0, 0.0,
		1.0 + float(bonus_attributs["cadence"]), 1.0 + float(objets.get("cadence", 0.0)),
		ArbreCompetences.multiplicateur_cadence(rangs), 1.0 + float(bonus_passifs.get("cadence", 0.0)))
	s.pv_max = float(s.etapes_permanentes["pv"]["permanent"])
	s.pv = s.pv_max
	s.vitesse = Reglages.HEROS_VITESSE * (ArbreCompetences.multiplicateur_vitesse(rangs) \
		+ float(bonus_passifs.get("vitesse", 0.0)) + float(objets.get("vitesse", 0.0)))
	s.cadence = float(s.etapes_permanentes["cadence"]["permanent"])
	s.attaque_base = float(s.etapes_permanentes["attaque"]["brut"])
	# Cette API est aussi utilisee par le familier, sur sa propre attaque brute.
	s.bonus_attaque = float(s.etapes_permanentes["attaque"]["facteur_permanent"]) - 1.0
	s.degats = s.attaque_reelle()
	s.defense = float(s.etapes_permanentes["defense"]["permanent"])
	var chance_critique := float(bonus_attributs["critique"]) + float(objets.get("critique", 0.0)) \
		+ ArbreCompetences.bonus_critique(rangs) + float(bonus_passifs.get("critique", 0.0))
	s.critique = clampf(chance_critique, 0.0, 1.0)
	s.critique_excedentaire = maxf(0.0, chance_critique - 1.0)
	s.degats_critiques = float(bonus_attributs["degats_critiques"]) \
		+ float(objets.get("degats_critiques", 0.0)) + ArbreCompetences.bonus_degats_critiques(rangs) \
		+ float(bonus_passifs.get("degats_critiques", 0.0))
	s.soin_mult = ArbreCompetences.multiplicateur_soin(rangs) \
		+ float(bonus_passifs.get("soin", 0.0)) + float(objets.get("soin", 0.0))
	var projectile_mult := ArbreCompetences.multiplicateur_projectile(rangs) \
		+ float(bonus_passifs.get("projectile", 0.0)) + float(objets.get("projectile", 0.0))
	s.vitesse_projectile = Reglages.TIR_VITESSE * projectile_mult
	s.portee = Reglages.TIR_PORTEE * projectile_mult
	return s

func attaque_reelle(bonus_supplementaire := 0.0) -> float:
	return attaque_base * maxf(Reglages.MODS_PLANCHER, 1.0 + bonus_attaque + bonus_supplementaire)

func blesser(montant: float) -> void:
	pv = maxf(0.0, pv - montant)

func soigner(montant: float) -> void:
	if est_mort():
		return
	var rendu := minf(maxf(0.0, montant) * soin_mult, minf(pv_max - pv, soin_restant))
	pv += rendu
	soin_restant -= rendu

func soigner_garanti(montant: float) -> void:
	# Une riposte mortelle peut tuer un ennemi et declencher un soin avant que
	# le heros traite sa mort ; seul le Sursis d'un bracelet peut le relever.
	if est_mort():
		return
	pv = minf(pv_max, pv + maxf(0.0, montant) * soin_mult)

func est_mort() -> bool:
	return pv <= 0.0
