class_name DeplacementsBoss
extends RefCounted

# La distance se mesure au joueur, jamais a un point fixe en haut de salle.
const PROFILS := {
	"assaut": {"nom": "Approche directe", "distance": 290.0, "vitesse": 1.0, "tangente": .18, "repositionnement": 1.0},
	"flanc": {"nom": "Approche par le flanc", "distance": 420.0, "vitesse": .95, "tangente": .65, "repositionnement": 1.15},
	"orbite": {"nom": "Cercle mobile", "distance": 530.0, "vitesse": .85, "tangente": 1.0, "repositionnement": .90},
}
const IDENTITES := {
	"la_rature": "assaut", "l_errata": "flanc", "le_correcteur": "assaut",
	"reliure_affamee": "assaut", "virgule_noire": "orbite", "index_brise": "flanc",
	"marge_hurlante": "flanc", "enlumineur_fou": "orbite", "signet_sanglant": "assaut",
	"copiste_aveugle": "flanc", "archiscribe_encres": "flanc", "roi_braises": "assaut",
	"reine_givre": "orbite", "maitre_orages": "flanc", "hydre_venins": "assaut",
	"choeur_infini": "orbite", "souverain_ombres": "flanc", "gardien_runes": "assaut",
	"devoreur_neant": "assaut", "grand_alambic": "assaut",
}
const APPARITIONS := [Vector2(.5, .48), Vector2(.32, .48), Vector2(.68, .48),
	Vector2(.5, .64), Vector2(.32, .64), Vector2(.68, .64), Vector2(.5, .32)]
const GRILLE_REPLI := Vector2i(8, 12)
const ANTICIPATION_OBSTACLE := 110.0
const APPROCHE_CHARGE_DUREE_MAX := 2.0
const APPROCHE_LOINTAINE := 1.4
const ECARTS_CONTOURNEMENT := [0.0, PI * .25, -PI * .25, PI * .5, -PI * .5, PI * .75, -PI * .75, PI]

static func profil(donnees: Dictionary) -> Dictionary:
	return PROFILS[IDENTITES.get(str(donnees.get("projectile_id", "")), "assaut")]
