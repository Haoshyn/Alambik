extends RefCounted

# Enveloppes visuelles uniquement ; les collisions restent sur les acteurs 2D.
const ATTAQUE_DUREE := 0.32
const ATTAQUE_REARMEMENT := 0.10
const IMPACT_DUREE := 0.16
const LISSAGE_POSE := 18.0
const LISSAGE_ORIENTATION := 12.0
const CADENCE_MIN := 0.65
const CADENCE_MAX := 1.65
const PREPARATION_COMPRESSION := 0.14
const PREPARATION_INCLINAISON := 0.14
const CHARGE_INCLINAISON := 0.24
const RECUL := 0.11
const PHASE_HAUTEUR := 0.12
const IMPACTS_MAX := 32
const IMPACTS_REDUITS := 10
const PERCUSSION_DUREE := 0.30
const DISSIPATION_DUREE := 0.52
const PERCUSSION_RAYON := 34.0
const DISSIPATION_RAYON := 100.0
const LOB_HAUTEUR := 160.0
const ZONES_COULEURS := {
	"impact": Color("c49aff"), "eboulis": Color("e3bd7e"),
	"maree": Color("77d9ed"), "foudre": Color("ffed9e"), "braise": Color("ff9b50"),
}
const PROFILS := {
	"sol": {"souffle": 0.022, "cadence": 7.0, "pas": 0.035, "roulis": 0.025},
	"vif": {"souffle": 0.025, "cadence": 12.0, "pas": 0.075, "roulis": 0.055},
	"lourd": {"souffle": 0.018, "cadence": 5.0, "pas": 0.018, "roulis": 0.040},
	"flottant": {"souffle": 0.025, "cadence": 5.5, "pas": 0.050, "roulis": 0.060},
	"boss": {"souffle": 0.014, "cadence": 3.5, "pas": 0.018, "roulis": 0.020},
}

static func profil(donnees: Dictionary) -> Dictionary:
	var cerveau := str(donnees.get("cerveau", ""))
	if cerveau == "boss": return PROFILS["boss"]
	if str(donnees.get("categorie", "")) == "costaud": return PROFILS["lourd"]
	if cerveau in ["poursuivant", "veloce"]: return PROFILS["vif"]
	if cerveau in ["orbiteur", "phaseur", "harceleur", "artilleur"]: return PROFILS["flottant"]
	return PROFILS["sol"]
