class_name Passifs
extends RefCounted

const RANG_MAX := 2
const EMPLACEMENTS := 4
const MOISSON_SEUIL := 6
const MOISSON_PART := 0.025
const REPRISE_DELAI := 10.0
const REPRISE_DEGATS := 0.05
const SANG_FROID_DUREE := 2.0
const SANG_FROID_RALENTISSEMENT := 0.10
const AUDACE_BONUS := 0.10
const RECUPERATION_PART := 0.01
const BUTIN_BONUS := 0.05
const EXPERIENCE_BONUS := 0.05

# Chaque valeur est celle du rang 1 ; le second exemplaire double le bonus.
const CATALOGUE := {
	"vigueur": {"nom": "Vigueur", "description": "Augmente l’attaque de 5 % par rang, après les maîtrises.", "categorie": "Offensif", "icone": "puissance", "bonus": {"attaque_mult": 0.05}},
	"vitalite": {"nom": "Vitalité", "description": "Augmente les PV maximum de 5 % par rang, après les maîtrises.", "categorie": "Défensif", "icone": "robustesse", "bonus": {"pv_mult": 0.05}},
	"carapace": {"nom": "Carapace", "description": "Augmente la défense de 5 % par rang.", "categorie": "Défensif", "icone": "rempart", "bonus": {"defense_mult": 0.05}},
	"celerite": {"nom": "Célérité", "description": "Augmente la cadence de tir de 4 % par rang, après les maîtrises.", "categorie": "Offensif", "icone": "celerite", "bonus": {"cadence": 0.04}},
	"pas_leger": {"nom": "Pas léger", "description": "Augmente la vitesse de déplacement de 5 % par rang.", "categorie": "Utilitaire", "icone": "elan", "bonus": {"vitesse": 0.05}},
	"oeil_precis": {"nom": "Œil précis", "description": "Ajoute 2 points de chance critique par rang.", "categorie": "Offensif", "icone": "precision", "bonus": {"critique": 0.02}},
	"impact_critique": {"nom": "Impact critique", "description": "Ajoute 5 points de dégâts critiques par rang.", "categorie": "Offensif", "icone": "frappe_lourde", "bonus": {"degats_critiques": 0.05}},
	"projectiles_vifs": {"nom": "Projectiles vifs", "description": "Augmente la vitesse et la portée des tirs de 8 % par rang.", "categorie": "Offensif", "icone": "trajectoire", "bonus": {"projectile": 0.08}},
	"soins_renforces": {"nom": "Soins renforcés", "description": "Augmente les soins reçus de 5 % par rang.", "categorie": "Défensif", "icone": "regeneration", "bonus": {"soin": 0.05}},
	"recuperation": {"nom": "Récupération", "description": "Rend 1 % des PV maximum à l’entrée d’une salle par rang.", "categorie": "Défensif", "icone": "regeneration"},
	"moisson_vitale": {"nom": "Moisson vitale", "description": "Rend 2,5 % des PV maximum toutes les 6 éliminations par rang.", "categorie": "Défensif", "icone": "moisson_vitale"},
	"sang_froid": {"nom": "Sang-froid", "description": "Les tirs ralentissent les ennemis de 10 % pendant 2 s par rang.", "categorie": "Utilitaire", "icone": "sang_froid"},
	"rempart_initial": {"nom": "Reprise de souffle", "description": "Après 10 s sans blessure, dégâts +5 % par rang.", "categorie": "Offensif", "icone": "rempart_initial"},
	"audace": {"nom": "Audace", "description": "Dégâts infligés et subis +10 % par rang.", "categorie": "Offensif", "icone": "audace"},
	"butin_precieux": {"nom": "Butin précieux", "description": "Augmente les gouttes gagnées de 5 % par rang.", "categorie": "Utilitaire", "icone": "abondance"},
	"savoir_pratique": {"nom": "Savoir pratique", "description": "Augmente l’XP de compte gagnée de 5 % par rang.", "categorie": "Utilitaire", "icone": "savoir"},
}

static func contient(id: String) -> bool:
	return CATALOGUE.has(id)

static func donnees(id: String) -> Dictionary:
	return CATALOGUE.get(id, {})

static func rang_max(_id: String = "") -> int:
	return RANG_MAX

static func rang_passif(passifs: Dictionary, id: String) -> int:
	return clampi(int(passifs.get(id, 0)), 0, RANG_MAX)

static func bonus_stats(passifs: Dictionary) -> Dictionary:
	var resultat := {}
	for id: String in passifs:
		var bonus: Dictionary = donnees(id).get("bonus", {})
		for cle: String in bonus:
			resultat[cle] = float(resultat.get(cle, 0.0)) + float(bonus[cle]) * rang_passif(passifs, id)
	return resultat

static func _bonus(passifs: Dictionary, cle: String) -> float:
	return float(bonus_stats(passifs).get(cle, 0.0))

static func multiplicateur_vitesse(passifs: Dictionary) -> float:
	return 1.0 + _bonus(passifs, "vitesse")

static func multiplicateur_cadence(passifs: Dictionary) -> float:
	return 1.0 + _bonus(passifs, "cadence")

static func multiplicateur_projectile(passifs: Dictionary) -> float:
	return 1.0 + _bonus(passifs, "projectile")

static func multiplicateur_pv(passifs: Dictionary) -> float:
	return 1.0 + _bonus(passifs, "pv_mult")

static func soin_par_salle(passifs: Dictionary) -> float:
	return RECUPERATION_PART * rang_passif(passifs, "recuperation")

static func soin_moisson(passifs: Dictionary) -> float:
	return MOISSON_PART * rang_passif(passifs, "moisson_vitale")

static func seuil_moisson(_passifs: Dictionary) -> int:
	return MOISSON_SEUIL

static func bonus_reprise(passifs: Dictionary) -> float:
	return REPRISE_DEGATS * rang_passif(passifs, "rempart_initial")

static func bonus_audace(passifs: Dictionary) -> float:
	return AUDACE_BONUS * rang_passif(passifs, "audace")

static func ralentissement_sang_froid(passifs: Dictionary) -> float:
	return SANG_FROID_RALENTISSEMENT * rang_passif(passifs, "sang_froid")

static func multiplicateur_gouttes(passifs: Dictionary) -> float:
	return 1.0 + BUTIN_BONUS * rang_passif(passifs, "butin_precieux")

static func multiplicateur_experience(passifs: Dictionary) -> float:
	return 1.0 + EXPERIENCE_BONUS * rang_passif(passifs, "savoir_pratique")

static func nombre_debloques(rangs: Dictionary, tout_debloque := false) -> int:
	if tout_debloque: return CATALOGUE.size()
	var nombre := 0
	for id: String in CATALOGUE:
		if rang_passif(rangs, id) > 0: nombre += 1
	return nombre

static func _pourcentage(valeur: float) -> String:
	return String.num(valeur * 100.0, 1).trim_suffix(".0").replace(".", ",")

static func resume_rang(id: String, rang: int) -> String:
	var niveau := clampi(rang, 1, RANG_MAX)
	var equipe := {id: niveau}
	var bonus: Dictionary = donnees(id).get("bonus", {})
	var libelles := {"attaque_mult": "attaque", "pv_mult": "PV maximum", "defense_mult": "défense", "cadence": "cadence", "vitesse": "vitesse", "projectile": "vitesse et portée des tirs", "soin": "soins reçus"}
	for cle: String in bonus:
		var valeur := _pourcentage(float(bonus[cle]) * niveau)
		if cle == "critique": return "+%s points de chance critique" % valeur
		if cle == "degats_critiques": return "+%s points de dégâts critiques" % valeur
		return "+%s %% %s" % [valeur, str(libelles.get(cle, cle))]
	match id:
		"recuperation": return "%s %% des PV à l’entrée d’une salle" % _pourcentage(soin_par_salle(equipe))
		"moisson_vitale": return "%s %% des PV toutes les %d éliminations" % [_pourcentage(soin_moisson(equipe)), MOISSON_SEUIL]
		"sang_froid": return "Ralentissement de %s %% pendant %s s" % [_pourcentage(ralentissement_sang_froid(equipe)), String.num(SANG_FROID_DUREE, 0)]
		"rempart_initial": return "+%s %% de dégâts après %s s sans blessure" % [_pourcentage(bonus_reprise(equipe)), String.num(REPRISE_DELAI, 0)]
		"audace": return "Dégâts infligés et subis +%s %%" % _pourcentage(bonus_audace(equipe))
		"butin_precieux": return "+%s %% de gouttes" % _pourcentage(multiplicateur_gouttes(equipe) - 1.0)
		"savoir_pratique": return "+%s %% d’XP de compte" % _pourcentage(multiplicateur_experience(equipe) - 1.0)
	return ""

static func progression_rang(_id: String) -> String:
	return "Un doublon obtenu en Épreuve porte ce passif au rang 2 et double son bonus."
