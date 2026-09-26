extends RefCounted

# Dimensions de presentation ; les collisions et les trajectoires restent dans Tir.
const PROFILS := {
	"trait": {"couleur": Color("ff614c"), "rotation": 0.0, "trainee": 0.075},
	"aiguille": {"couleur": Color("ff536b"), "rotation": 0.0, "trainee": 0.070},
	"eclat": {"couleur": Color("ff982f"), "rotation": 2.4, "trainee": 0.095},
	"lame": {"couleur": Color("ff62b0"), "rotation": 3.2, "trainee": 0.080},
	"vrille": {"couleur": Color("ff6b47"), "rotation": 6.0, "trainee": 0.095},
}
const REFLET := Color("fff0b9")
const POINTS_TRAINEE := 8
const POINTS_TRAINEE_REDUITS := 3

static func profil(silhouette: String) -> Dictionary:
	return PROFILS.get(silhouette, PROFILS["trait"])
