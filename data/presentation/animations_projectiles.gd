extends RefCounted

# Dimensions de presentation ; les collisions et les trajectoires restent dans Tir.
const HEROS_ECHELLE := 0.80
const PROFILS := {
	"encrier_rampant": {"couleur": Color("e16685"), "rotation": 0.0, "trainee": .10},
	"plume_sentinelle": {"couleur": Color("ffae75"), "rotation": 0.0, "trainee": .045},
	"scribe_essaimeur": {"couleur": Color("edb250"), "rotation": 1.0, "trainee": .08},
	"folio_orbiteur": {"couleur": Color("ff818a"), "rotation": 4.0, "trainee": .07},
	"marge_harceleuse": {"couleur": Color("ff506f"), "rotation": 0.0, "trainee": .045},
	"miroir_encre": {"couleur": Color("ffc071"), "rotation": 1.0, "trainee": .09},
	"cachet_phaseur": {"couleur": Color("ff78b8"), "rotation": 0.0, "trainee": .06},
	"fuseau_tisseur": {"couleur": Color("ff9568"), "rotation": 0.0, "trainee": .055},
	"fiole_volatile": {"couleur": Color("f7c14d"), "rotation": 0.0, "trainee": .08},
	"la_rature": {"couleur": Color("ffac70"), "rotation": 0.0, "trainee": .08},
	"l_errata": {"couleur": Color("ff7045"), "rotation": 2.8, "trainee": .12},
	"le_correcteur": {"couleur": Color("ec8ccc"), "rotation": 1.4, "trainee": .10},
	"reliure_affamee": {"couleur": Color("ffbd93"), "rotation": 0.0, "trainee": .09},
	"virgule_noire": {"couleur": Color("ffb235"), "rotation": 3.2, "trainee": .12},
	"index_brise": {"couleur": Color("ffe17d"), "rotation": 0.0, "trainee": .045},
	"marge_hurlante": {"couleur": Color("ff947b"), "rotation": 0.0, "trainee": .12},
	"enlumineur_fou": {"couleur": Color("ffd470"), "rotation": 1.2, "trainee": .10},
	"signet_sanglant": {"couleur": Color("ff6275"), "rotation": 0.0, "trainee": .11},
	"copiste_aveugle": {"couleur": Color("e9afd8"), "rotation": 0.0, "trainee": .07},
	"archiscribe_encres": {"couleur": Color("e382cc"), "rotation": .7, "trainee": .16},
	"roi_braises": {"couleur": Color("ff9e42"), "rotation": .6, "trainee": .17},
	"reine_givre": {"couleur": Color("f3a6ce"), "rotation": 0.0, "trainee": .065},
	"maitre_orages": {"couleur": Color("ffe286"), "rotation": 0.0, "trainee": .05},
	"hydre_venins": {"couleur": Color("e6b45b"), "rotation": 1.0, "trainee": .14},
	"choeur_infini": {"couleur": Color("ed8acb"), "rotation": 0.0, "trainee": .08},
	"souverain_ombres": {"couleur": Color("ff548d"), "rotation": 2.0, "trainee": .14},
	"gardien_runes": {"couleur": Color("eda267"), "rotation": .5, "trainee": .16},
	"devoreur_neant": {"couleur": Color("ed68c1"), "rotation": -.8, "trainee": .18},
	"grand_alambic": {"couleur": Color("ffc460"), "rotation": .6, "trainee": .19},
	"homoncule_encre": {"couleur": Color("aacfe9"), "rotation": 0.0, "trainee": .06},
	"salamandre": {"couleur": Color("bdded4"), "rotation": 0.0, "trainee": .08},
	"ondine": {"couleur": Color("94d5e7"), "rotation": 0.0, "trainee": .05},
	"sylphe": {"couleur": Color("bddef0"), "rotation": 0.0, "trainee": .04},
	"golem": {"couleur": Color("aacfcf"), "rotation": 0.0, "trainee": .09},
	"trait": {"couleur": Color("ff614c"), "rotation": 0.0, "trainee": 0.075},
	"aiguille": {"couleur": Color("ff536b"), "rotation": 0.0, "trainee": 0.070},
	"eclat": {"couleur": Color("ff982f"), "rotation": 2.4, "trainee": 0.095},
	"lame": {"couleur": Color("ff62b0"), "rotation": 3.2, "trainee": 0.080},
	"vrille": {"couleur": Color("ff6b47"), "rotation": 6.0, "trainee": 0.095},
}
const REFLET := Color("fff0b9")
const FAMILIER_IVOIRE := Color("fff4dc")
const FAMILIER_AZUR := Color("79bfd4")
const POINTS_TRAINEE := 8
const POINTS_TRAINEE_REDUITS := 3
const CONTOUR_HOSTILE := Color("24112f")
const INTERIEUR_HOSTILE := .80
const SATURATION_HOSTILE_MIN := .78
const ACCENT_HOSTILE := .08
const REFLET_HOSTILE := .18
const TRAINEE_HOSTILE_LARGEUR_MIN := .11
const TRAINEE_HOSTILE_LONGUEUR_MAX := 180.0
const TRAINEE_HOSTILE_OPACITE := .92
const TRAINEE_HOSTILE_CONTOUR := 1.25
const TRAINEE_HOSTILE_CONTOUR_OPACITE := .75

static func couleur_hostile(silhouette: String, monde: int) -> Color:
	var couleur: Color = profil(silhouette)["couleur"]
	couleur = couleur.lerp(BestiaireMondes.ACCENTS[monde], ACCENT_HOSTILE)
	return Color.from_hsv(couleur.h, maxf(SATURATION_HOSTILE_MIN, couleur.s), couleur.v)

static func profil(silhouette: String) -> Dictionary:
	return PROFILS.get(silhouette, PROFILS["trait"])
