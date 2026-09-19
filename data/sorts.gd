class_name Sorts
extends RefCounted

# Les recharges sont en secondes de jeu et ne dependent ni des impacts ni des morts.
const ACTIFS := {
	"onde_alchimique": {"nom": "Onde alchimique", "description": "500 % de l’ATK • repousse la zone • récupération 12 s", "recharge": 12.0, "rayon": 180.0, "degats": 5.0, "effet": "repousse"},
	"nova_de_givre": {"nom": "Nova de givre", "description": "500 % de l’ATK • gèle la zone • récupération 15 s", "recharge": 15.0, "rayon": 210.0, "degats": 5.0, "effet": "givre"},
	"barrage_de_braise": {"nom": "Barrage de braise", "description": "700 % de l’ATK • embrase la zone • récupération 15 s", "recharge": 15.0, "rayon": 190.0, "degats": 7.0, "effet": "braise"},
	"impulsion_foudroyante": {"nom": "Impulsion foudroyante", "description": "1 000 % de l’ATK • zone concentrée • récupération 20 s", "recharge": 20.0, "rayon": 130.0, "degats": 10.0, "effet": ""},
	"explosion_corrosive": {"nom": "Explosion corrosive", "description": "800 % de l’ATK • fragilise la zone • récupération 20 s", "recharge": 20.0, "rayon": 170.0, "degats": 8.0, "effet": "acide"},
}

const ULTIMES := {
	"grand_oeuvre": {"nom": "Le Grand Œuvre", "description": "1 500 % de l’ATK dans toute la salle • récupération 75 s", "recharge": 75.0, "degats": 15.0, "effet": ""},
	"temps_suspendu": {"nom": "Temps suspendu", "description": "500 % de l’ATK et gel de 5 s dans toute la salle • récupération 60 s", "recharge": 60.0, "degats": 5.0, "effet": "givre"},
	"transmutation_totale": {"nom": "Transmutation totale", "description": "2 000 % de l’ATK et fragilité dans toute la salle • récupération 90 s", "recharge": 90.0, "degats": 20.0, "effet": "acide"},
}

const PASSIFS := {
	"rempart_initial": {"nom": "Rempart initial", "description": "Bouclier à chaque salle • −15 % de dégâts subis • +2,5 points par rang"},
	"heritage_reactif": {"nom": "Héritage réactif", "description": "2 relances supplémentaires par aventure • +1 tous les 3 rangs"},
	"moisson_vitale": {"nom": "Moisson vitale", "description": "2,5 % des PV toutes les 6 éliminations • une élimination de moins tous les 3 rangs • plafond 5 % par salle"},
	"riposte_alchimique": {"nom": "Riposte alchimique", "description": "Être touché déclenche une onde à 200 % de l’ATK qui repousse"},
	"seconde_chance": {"nom": "Seconde chance", "description": "Une fois par aventure, survit à la mort avec 30 % des PV"},
	"reserve_ultime": {"nom": "Réserve d’ultime", "description": "Récupération de l’ultime réduite de 30 % • +2,5 points par rang"},
	"sang_froid": {"nom": "Sang-froid", "description": "Récupération du sort actif réduite de 15 % • +2,5 points par rang"},
	"dernier_rempart": {"nom": "Dernier rempart", "description": "Sous 40 % de PV, subit 30 % de dégâts en moins • +2,5 points par rang"},
	"audace": {"nom": "Audace", "description": "Sous 60 % de PV, inflige 30 % de dégâts en plus • +2,5 points par rang"},
	"echo_alchimique": {"nom": "Écho alchimique", "description": "25 % de chance de répéter le sort à 60 % de puissance • +2,5 points de chance par rang"},
}

# La campagne revele l'arsenal par petites touches. Les deux premieres capacites
# sont offertes afin que la boucle Sort + Ultime existe des le Monde I ; les
# suivantes entrent seulement dans la pool des Epreuves au fil des chapitres.
const NIVEAUX_DEBLOCAGE := {
	"onde_alchimique": 2,
	"grand_oeuvre": 3,
	"rempart_initial": 4,
	"nova_de_givre": 5,
	"heritage_reactif": 6,
	"temps_suspendu": 7,
	"moisson_vitale": 8,
	"barrage_de_braise": 10,
	"riposte_alchimique": 11,
	"seconde_chance": 13,
	"impulsion_foudroyante": 15,
	"reserve_ultime": 17,
	"sang_froid": 19,
	"transmutation_totale": 21,
	"dernier_rempart": 23,
	"explosion_corrosive": 25,
	"audace": 27,
	"echo_alchimique": 29,
}

const RECOMPENSES_CAMPAGNE := {
	2: "onde_alchimique",
	3: "grand_oeuvre",
}

static func contient(id: String) -> bool:
	return ACTIFS.has(id) or PASSIFS.has(id) or ULTIMES.has(id)

static func niveau_deblocage(id: String) -> int:
	return int(NIVEAUX_DEBLOCAGE.get(id, Chapitres.nombre()))

static func disponible_au_niveau(id: String, niveau_campagne: int) -> bool:
	return contient(id) and niveau_campagne >= niveau_deblocage(id)

static func recompense_campagne(niveau_campagne: int) -> String:
	return str(RECOMPENSES_CAMPAGNE.get(niveau_campagne, ""))

static func donnees(id: String) -> Dictionary:
	for catalogue in [ACTIFS, PASSIFS, ULTIMES]:
		if catalogue.has(id):
			return catalogue[id]
	return {}

static func _pourcentage(valeur: float) -> String:
	return String.num(valeur * 100.0, 1).trim_suffix(".0").replace(".", ",")

static func resume_rang(id: String, rang: int) -> String:
	var rang_affiche := clampi(rang, 1, Reglages.CAPACITE_RANG_MAX)
	var efficacite := 1.0 + float(rang_affiche - 1) * Reglages.CAPACITE_BONUS_PAR_RANG
	var passif := {id: efficacite}
	if ACTIFS.has(id) or ULTIMES.has(id):
		return "%s %% de l’ATK" % _pourcentage(float(donnees(id)["degats"]) * efficacite)
	match id:
		"rempart_initial": return "Bouclier par salle et −%s %% de dégâts subis" % _pourcentage(bonus_passif(passif, id, Reglages.REMPART_REDUCTION))
		"heritage_reactif": return "%d relances supplémentaires" % relances_heritage(passif)
		"moisson_vitale": return "%s %% des PV toutes les %d éliminations" % [_pourcentage(Reglages.MOISSON_PART), seuil_moisson(passif)]
		"riposte_alchimique": return "%s %% de l’ATK par riposte" % _pourcentage(Reglages.RIPOSTE_PART_DEGATS * efficacite)
		"seconde_chance": return "Résurrection avec %s %% des PV" % _pourcentage(soin_seconde_chance(passif))
		"reserve_ultime": return "−%s %% de récupération de l’ultime" % _pourcentage(bonus_passif(passif, id, Reglages.RESERVE_ULTIME_REMISE))
		"sang_froid": return "−%s %% de récupération du sort actif" % _pourcentage(bonus_passif(passif, id, Reglages.SANG_FROID_RECHARGE))
		"dernier_rempart": return "−%s %% de dégâts subis sous %s %% des PV" % [_pourcentage(bonus_passif(passif, id, Reglages.DERNIER_REMPART_REDUCTION)), _pourcentage(Reglages.DERNIER_REMPART_SEUIL_PV)]
		"audace": return "+%s %% de dégâts sous %s %% des PV" % [_pourcentage(bonus_passif(passif, id, Reglages.AUDACE_BONUS)), _pourcentage(Reglages.AUDACE_SEUIL_PV)]
		"echo_alchimique": return "%s %% de chance de répéter le sort" % _pourcentage(chance_echo(passif))
	return ""

static func progression_rang(id: String) -> String:
	if id == "heritage_reactif":
		return "+1 relance tous les %d rangs." % Reglages.PASSIF_RANGS_PAR_PALIER
	if id == "moisson_vitale":
		return "Une élimination de moins tous les %d rangs, jusqu’à %d." % [Reglages.PASSIF_RANGS_PAR_PALIER, Reglages.MOISSON_SEUIL_MIN]
	if PASSIFS.has(id) and id != "riposte_alchimique":
		return "+%s points de pourcentage par rang." % _pourcentage(Reglages.PASSIF_BONUS_PAR_RANG)
	return "+%s %% des dégâts de base par rang." % _pourcentage(Reglages.CAPACITE_BONUS_PAR_RANG)

static func _a(passifs: Dictionary, id: String) -> bool:
	return passifs.has(id)

static func rang_passif(passifs: Dictionary, id: String) -> int:
	if not _a(passifs, id): return 0
	var efficacite := float(passifs[id])
	return clampi(1 + roundi((efficacite - 1.0) / Reglages.CAPACITE_BONUS_PAR_RANG), 1, Reglages.CAPACITE_RANG_MAX)

# Le dictionnaire conserve son format de sauvegarde ; on retrouve le rang pour
# ajouter des points fixes au lieu de multiplier deux petits pourcentages.
static func bonus_passif(passifs: Dictionary, id: String, base: float) -> float:
	var rang := rang_passif(passifs, id)
	return 0.0 if rang == 0 else base + float(rang - 1) * Reglages.PASSIF_BONUS_PAR_RANG

static func relances_heritage(passifs: Dictionary) -> int:
	var rang := rang_passif(passifs, "heritage_reactif")
	return 0 if rang == 0 else Reglages.HERITAGE_RELANCES + floori(float(rang - 1) / Reglages.PASSIF_RANGS_PAR_PALIER)

static func seuil_moisson(passifs: Dictionary) -> int:
	var rang := rang_passif(passifs, "moisson_vitale")
	return maxi(Reglages.MOISSON_SEUIL_MIN, Reglages.MOISSON_SEUIL - floori(float(maxi(0, rang - 1)) / Reglages.PASSIF_RANGS_PAR_PALIER))

static func soin_seconde_chance(passifs: Dictionary) -> float:
	return bonus_passif(passifs, "seconde_chance", Reglages.SECONDE_CHANCE_PART)

static func chance_echo(passifs: Dictionary) -> float:
	return bonus_passif(passifs, "echo_alchimique", Reglages.ECHO_CHANCE)

static func multiplicateur_degats(passifs: Dictionary) -> float:
	return 1.0

static func multiplicateur_degats_recus(passifs: Dictionary) -> float:
	return 1.0 - bonus_passif(passifs, "rempart_initial", Reglages.REMPART_REDUCTION)

static func multiplicateur_vitesse(passifs: Dictionary) -> float:
	return 1.0

static func multiplicateur_cadence(passifs: Dictionary) -> float:
	return 1.0

static func multiplicateur_projectile(passifs: Dictionary) -> float:
	return 1.0

static func multiplicateur_pv(passifs: Dictionary) -> float:
	return 1.0

static func soin_par_salle(passifs: Dictionary) -> float:
	return 0.0

static func donne_bouclier(passifs: Dictionary) -> bool:
	return _a(passifs, "rempart_initial")

static func multiplicateur_recharge_active(passifs: Dictionary) -> float:
	return 1.0 - bonus_passif(passifs, "sang_froid", Reglages.SANG_FROID_RECHARGE)

static func multiplicateur_charge_ultime(passifs: Dictionary) -> float:
	return 1.0 - bonus_passif(passifs, "reserve_ultime", Reglages.RESERVE_ULTIME_REMISE)

static func multiplicateur_degats_conditionnel(passifs: Dictionary, ratio_pv: float) -> float:
	return (1.0 + bonus_passif(passifs, "audace", Reglages.AUDACE_BONUS)) \
		if ratio_pv < Reglages.AUDACE_SEUIL_PV else 1.0

static func multiplicateur_degats_recus_conditionnel(passifs: Dictionary, ratio_pv: float) -> float:
	return (1.0 - bonus_passif(passifs, "dernier_rempart", Reglages.DERNIER_REMPART_REDUCTION)) \
		if ratio_pv < Reglages.DERNIER_REMPART_SEUIL_PV else 1.0

static func recharge(id: String, passifs: Dictionary, maitrises: Dictionary, arme: String) -> float:
	var d := donnees(id)
	var facteur := multiplicateur_charge_ultime(passifs) if ULTIMES.has(id) else multiplicateur_recharge_active(passifs)
	facteur *= ArbreCompetences.multiplicateur_recharge(maitrises)
	facteur *= float(CatalogueProjectiles.TYPES.get(arme, {}).get("recharge_mult", 1.0))
	return float(d.get("recharge", 0.0)) * maxf(Reglages.RECHARGE_PLANCHER, facteur)
