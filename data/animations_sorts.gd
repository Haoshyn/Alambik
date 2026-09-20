extends RefCounted

# Durees et couleurs du rendu, independantes de la resolution des degats.
const PROFILS := {
	"onde_alchimique": {"couleur": Color("dfbbff"), "duree": 0.65},
	"nova_de_givre": {"couleur": Color("8eeaff"), "duree": 0.9},
	"barrage_de_braise": {"couleur": Color("ffac58"), "duree": 0.85},
	"impulsion_foudroyante": {"couleur": Color("fff3a6"), "duree": 0.5},
	"explosion_corrosive": {"couleur": Color("a5ef70"), "duree": 1.0},
	"vortex_alchimique": {"couleur": Color("b7a1ff"), "duree": 0.9},
	"grand_oeuvre": {"couleur": Color("f3d18a"), "duree": 1.25},
	"temps_suspendu": {"couleur": Color("a6dfff"), "duree": 1.4},
	"transmutation_totale": {"couleur": Color("b9ffbf"), "duree": 1.2},
	"purification_totale": {"couleur": Color("fff1c0"), "duree": 1.1},
}
const RAYON_ULTIME := 620.0
const MAX_SIMULTANES := 8
