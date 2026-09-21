extends RefCounted

# La chute precede l'impact ; ce delai est partage avec le declencheur de combat.
const CHUTE_METEORE := 0.32
const MAX_SIMULTANES := 24
const PROFILS := {
	"chute_meteore": {"couleur": Color("ff9a52"), "duree": CHUTE_METEORE},
	"impact_meteore": {"couleur": Color("ffae65"), "duree": 0.7},
	"chaine_alchimique": {"couleur": Color("84e8f5"), "duree": 0.36},
	"onde_de_choc": {"couleur": Color("f7d68c"), "duree": 0.55},
	"zone_heros": {"couleur": Color("91e6b0"), "duree": 0.4},
	"orbes_chargees": {"couleur": Color("e6b3ff"), "duree": 0.3},
	"frappe_gardien": {"couleur": Color("cbb1ff"), "duree": 0.28},
}
