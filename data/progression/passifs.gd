class_name Passifs
extends RefCounted

const RANG_MAX := 2
const EMPLACEMENTS := 4
# Trois pour cent toutes les sept eliminations : meme rythme de soin que
# l'ancien 2,5 % sur six, avec une valeur entiere.
const MOISSON_SEUIL := 7
const MOISSON_POURCENT := 3
const MOISSON_PART := MOISSON_POURCENT / 100.0
const REPRISE_DELAI := 10.0
const REPRISE_DEGATS := 0.05
const SANG_FROID_DUREE := 2.0
const SANG_FROID_RALENTISSEMENT := 0.10
const AUDACE_BONUS := 0.10
const RECUPERATION_PART := 0.01
const BUTIN_BONUS := 0.05
const EXPERIENCE_BONUS := 0.05
const PALIERS_STAT := [5, 10, 15, 20, 30, 40]
const PALIERS_CADENCE := [5, 10, 15, 20, 25, 30]
const PALIERS_CRITIQUE := [2, 3, 5, 7, 10, 15]
const STAT_PAR_RANG := PALIERS_STAT[-1] / 100.0
const CADENCE_PAR_RANG := PALIERS_CADENCE[-1] / 100.0
const CRITIQUE_PAR_RANG := PALIERS_CRITIQUE[-1] / 100.0
const CHAMPS_PROGRESSIFS := ["attaque_mult", "pv_mult", "defense_mult", "cadence", "critique", "degats_critiques"]

# Le second exemplaire renforce la statistique deja acquise. Les taux de
# niveau sont des pourcentages entiers, identiques en fiche et en combat.
const CATALOGUE := {
	"vigueur": {"nom": "Vigueur", "description": "Attaque +%d à %d %% par rang selon le niveau, cumul composé." % [PALIERS_STAT[0], STAT_PAR_RANG * 100.0], "categorie": "Offensif", "icone": "puissance", "bonus": {"attaque_mult": STAT_PAR_RANG}},
	"vitalite": {"nom": "Vitalité", "description": "PV maximum +%d à %d %% par rang selon le niveau, cumul composé." % [PALIERS_STAT[0], STAT_PAR_RANG * 100.0], "categorie": "Défensif", "icone": "robustesse", "bonus": {"pv_mult": STAT_PAR_RANG}},
	"carapace": {"nom": "Carapace", "description": "Défense +%d à %d %% par rang selon le niveau, cumul composé." % [PALIERS_STAT[0], STAT_PAR_RANG * 100.0], "categorie": "Défensif", "icone": "rempart", "bonus": {"defense_mult": STAT_PAR_RANG}},
	"celerite": {"nom": "Célérité", "description": "Cadence +%d à %d %% par rang selon le niveau, cumul composé." % [PALIERS_CADENCE[0], CADENCE_PAR_RANG * 100.0], "categorie": "Offensif", "icone": "celerite", "bonus": {"cadence": CADENCE_PAR_RANG}},
	"pas_leger": {"nom": "Pas léger", "description": "Vitesse +5 % par rang, cumul composé.", "categorie": "Utilitaire", "icone": "elan", "bonus": {"vitesse": 0.05}},
	"oeil_precis": {"nom": "Œil précis", "description": "Chance critique +%d à %d points par rang selon le niveau du héros." % [PALIERS_CRITIQUE[0], CRITIQUE_PAR_RANG * 100.0], "categorie": "Offensif", "icone": "precision", "bonus": {"critique": CRITIQUE_PAR_RANG}},
	"impact_critique": {"nom": "Impact critique", "description": "Dégâts critiques +%d à %d points par rang selon le niveau du héros." % [PALIERS_STAT[0], STAT_PAR_RANG * 100.0], "categorie": "Offensif", "icone": "frappe_lourde", "bonus": {"degats_critiques": STAT_PAR_RANG}},
	"projectiles_vifs": {"nom": "Projectiles vifs", "description": "Vitesse et portée des tirs +8 % par rang, cumul composé.", "categorie": "Offensif", "icone": "trajectoire", "bonus": {"projectile": 0.08}},
	"soins_renforces": {"nom": "Soins renforcés", "description": "Soins reçus +5 % par rang, cumul composé.", "categorie": "Défensif", "icone": "regeneration", "bonus": {"soin": 0.05}},
	"recuperation": {"nom": "Récupération", "description": "Rend 1 % des PV maximum à l’entrée d’une salle par rang.", "categorie": "Défensif", "icone": "regeneration"},
	"moisson_vitale": {"nom": "Moisson vitale", "description": "Rend %d %% des PV maximum toutes les %d éliminations par rang." % [MOISSON_POURCENT, MOISSON_SEUIL], "categorie": "Défensif", "icone": "moisson_vitale"},
	"sang_froid": {"nom": "Sang-froid", "description": "Les tirs ralentissent les ennemis de 10 % pendant 2 s par rang.", "categorie": "Utilitaire", "icone": "sang_froid"},
	"rempart_initial": {"nom": "Reprise de souffle", "description": "Après 10 s sans blessure, dégâts +5 % par rang, cumul composé.", "categorie": "Offensif", "icone": "rempart_initial"},
	"audace": {"nom": "Audace", "description": "Dégâts infligés et subis +10 % par rang, cumul composé.", "categorie": "Offensif", "icone": "audace"},
	"butin_precieux": {"nom": "Butin précieux", "description": "Gouttes gagnées +5 % par rang, cumul composé.", "categorie": "Utilitaire", "icone": "abondance"},
	"savoir_pratique": {"nom": "Savoir pratique", "description": "XP de compte gagnée +5 % par rang, cumul composé.", "categorie": "Utilitaire", "icone": "savoir"},
}

static func contient(id: String) -> bool:
	return CATALOGUE.has(id)

static func donnees(id: String) -> Dictionary:
	return CATALOGUE.get(id, {})

static func rang_max(_id: String = "") -> int:
	return RANG_MAX

static func rang_passif(passifs: Dictionary, id: String) -> int:
	return clampi(int(passifs.get(id, 0)), 0, RANG_MAX)

static func bonus_stats(passifs: Dictionary, niveau := Personnage.NIVEAU_MAX) -> Dictionary:
	var resultat := {}
	for id: String in passifs:
		var bonus: Dictionary = donnees(id).get("bonus", {})
		for cle: String in bonus:
			var taux := taux_par_rang(cle, float(bonus[cle]), niveau)
			var rang := rang_passif(passifs, id)
			var valeur := taux * float(rang) if cle in ["critique", "degats_critiques"] \
				else Reglages.cumul_compose_entier(taux, rang, RANG_MAX)
			resultat[cle] = float(resultat.get(cle, 0.0)) + valeur
	return resultat

static func taux_par_rang(champ: String, taux: float, niveau: int) -> float:
	if champ not in CHAMPS_PROGRESSIFS: return taux
	var paliers: Array = PALIERS_CADENCE if champ == "cadence" \
		else (PALIERS_CRITIQUE if champ == "critique" else PALIERS_STAT)
	return float(paliers[Personnage.palier_niveau(niveau)]) / 100.0

static func _bonus(passifs: Dictionary, cle: String, niveau := Personnage.NIVEAU_MAX) -> float:
	return float(bonus_stats(passifs, niveau).get(cle, 0.0))

static func multiplicateur_vitesse(passifs: Dictionary) -> float:
	return 1.0 + _bonus(passifs, "vitesse")

static func multiplicateur_cadence(passifs: Dictionary, niveau := Personnage.NIVEAU_MAX) -> float:
	return 1.0 + _bonus(passifs, "cadence", niveau)

static func multiplicateur_projectile(passifs: Dictionary) -> float:
	return 1.0 + _bonus(passifs, "projectile")

static func multiplicateur_pv(passifs: Dictionary, niveau := Personnage.NIVEAU_MAX) -> float:
	return 1.0 + _bonus(passifs, "pv_mult", niveau)

static func soin_par_salle(passifs: Dictionary) -> float:
	return RECUPERATION_PART * rang_passif(passifs, "recuperation")

static func soin_moisson(passifs: Dictionary) -> float:
	return MOISSON_PART * rang_passif(passifs, "moisson_vitale")

static func seuil_moisson(_passifs: Dictionary) -> int:
	return MOISSON_SEUIL

static func bonus_reprise(passifs: Dictionary) -> float:
	return Reglages.cumul_compose_entier(REPRISE_DEGATS, rang_passif(passifs, "rempart_initial"), RANG_MAX)

static func bonus_audace(passifs: Dictionary) -> float:
	return Reglages.cumul_compose_entier(AUDACE_BONUS, rang_passif(passifs, "audace"), RANG_MAX)

static func ralentissement_sang_froid(passifs: Dictionary) -> float:
	return SANG_FROID_RALENTISSEMENT * rang_passif(passifs, "sang_froid")

static func multiplicateur_gouttes(passifs: Dictionary) -> float:
	return 1.0 + Reglages.cumul_compose_entier(BUTIN_BONUS, rang_passif(passifs, "butin_precieux"), RANG_MAX)

static func multiplicateur_experience(passifs: Dictionary) -> float:
	return 1.0 + Reglages.cumul_compose_entier(EXPERIENCE_BONUS, rang_passif(passifs, "savoir_pratique"), RANG_MAX)

static func nombre_debloques(rangs: Dictionary, tout_debloque := false) -> int:
	if tout_debloque: return CATALOGUE.size()
	var nombre := 0
	for id: String in CATALOGUE:
		if rang_passif(rangs, id) > 0: nombre += 1
	return nombre

static func _pourcentage(valeur: float) -> String:
	return str(roundi(valeur * 100.0))

static func resume_rang(id: String, rang: int, niveau_heros := Personnage.NIVEAU_MAX) -> String:
	var niveau := clampi(rang, 1, RANG_MAX)
	var equipe := {id: niveau}
	var bonus := bonus_stats(equipe, niveau_heros)
	var libelles := {"attaque_mult": "attaque", "pv_mult": "PV maximum", "defense_mult": "défense", "cadence": "cadence", "vitesse": "vitesse", "projectile": "vitesse et portée des tirs", "soin": "soins reçus"}
	for cle: String in bonus:
		var valeur := _pourcentage(float(bonus[cle]))
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
	return "Un doublon obtenu en Épreuve porte ce passif au rang 2 et renforce la valeur acquise."
