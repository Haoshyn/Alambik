extends RefCounted

# Durees et couleurs du rendu, independantes de la resolution des degats.
const PROFILS := {
	"onde_alchimique": {"couleur": Color("bd91f5"), "duree": 0.85},
	"nova_de_givre": {"couleur": Color("71dcff"), "duree": 1.1},
	"barrage_de_braise": {"couleur": Color("ff823d"), "duree": 1.0},
	"impulsion_foudroyante": {"couleur": Color("ffde70"), "duree": 0.55},
	"explosion_corrosive": {"couleur": Color("91e35d"), "duree": 1.2},
	"vortex_alchimique": {"couleur": Color("a98bff"), "duree": 1.15},
	"grand_oeuvre": {"couleur": Color("f3d18a"), "duree": 1.65},
	"temps_suspendu": {"couleur": Color("a6dfff"), "duree": 1.8},
	"transmutation_totale": {"couleur": Color("8cf0ba"), "duree": 1.6},
	"purification_totale": {"couleur": Color("fff1c0"), "duree": 1.5},
}
const RAYON_ULTIME := 620.0
const MAX_SIMULTANES := 8
const PERCUSSION_DUREE := 0.18
const PERCUSSION_DUREE_ULTIME := 0.26
const ULTIMES := ["grand_oeuvre", "temps_suspendu", "transmutation_totale", "purification_totale"]
