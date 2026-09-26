extends RefCounted

# Durees et couleurs du rendu, independantes de la resolution des degats.
const PROFILS := {
	"onde_alchimique": {"couleur": Color("bb87ff"), "duree": 1.10},
	"nova_de_givre": {"couleur": Color("62dfff"), "duree": 1.35},
	"barrage_de_braise": {"couleur": Color("ff772e"), "duree": 1.35},
	"impulsion_foudroyante": {"couleur": Color("ffcf46"), "duree": 0.70},
	"explosion_corrosive": {"couleur": Color("a2f448"), "duree": 1.55},
	"vortex_alchimique": {"couleur": Color("ae77ff"), "duree": 1.55},
	"grand_oeuvre": {"couleur": Color("ffd05d"), "duree": 2.05},
	"temps_suspendu": {"couleur": Color("91eeff"), "duree": 2.10},
	"transmutation_totale": {"couleur": Color("64efaa"), "duree": 2.05},
	"purification_totale": {"couleur": Color("fff0b9"), "duree": 1.95},
}
const PASSIFS := {
	"moisson_vitale": {"couleur": Color("62f3a2"), "duree": .75},
	"reserve_ultime": {"couleur": Color("dba0ff"), "duree": .65},
}
const RAYON_ULTIME := 620.0
const MAX_SIMULTANES := 8
const PERCUSSION_DUREE := 0.18
const PERCUSSION_DUREE_ULTIME := 0.26
const ULTIMES := ["grand_oeuvre", "temps_suspendu", "transmutation_totale", "purification_totale"]
