extends RefCounted

# Silhouettes originales normalisees : X transversal, Y dans le sens du tir.
# Le rendu 2D et le volume 3D lisent le meme contour, ajuste a la collision.
const CONTOURS := {
	"encrier_rampant": [Vector2(0,1),Vector2(.8,.1),Vector2(.85,-.45),Vector2(.4,-.95),Vector2(-.4,-.95),Vector2(-.85,-.45),Vector2(-.8,.1)],
	"plume_sentinelle": [Vector2(0,1),Vector2(.6,.1),Vector2(.24,-.7),Vector2(.85,-1),Vector2(0,-.8),Vector2(-.85,-1),Vector2(-.24,-.7),Vector2(-.6,.1)],
	"scribe_essaimeur": [Vector2(0,1),Vector2(.95,.25),Vector2(.7,-.7),Vector2(0,-1),Vector2(-.7,-.7),Vector2(-.95,.25)],
	"folio_orbiteur": [Vector2(0,.35),Vector2(.95,.95),Vector2(.6,-.45),Vector2(0,-.9),Vector2(-.6,-.45),Vector2(-.95,.95)],
	"marge_harceleuse": [Vector2(0,1),Vector2(.95,-.25),Vector2(.3,-.05),Vector2(.45,-1),Vector2(0,-.55),Vector2(-.45,-1),Vector2(-.3,-.05),Vector2(-.95,-.25)],
	"miroir_encre": [Vector2(-.75,-.75),Vector2(.75,-.75),Vector2(.75,.75),Vector2(-.75,.75)],
	"cachet_phaseur": [Vector2(0,1),Vector2(.9,0),Vector2(.25,-.25),Vector2(.35,-1),Vector2(-.9,0)],
	"fuseau_tisseur": [Vector2(-.35,1),Vector2(.35,1),Vector2(.9,.5),Vector2(.35,0),Vector2(-.35,-.5),Vector2(.35,-1),Vector2(-.35,-1),Vector2(-.9,-.5),Vector2(-.35,0),Vector2(.35,.5)],
	"fiole_volatile": [Vector2(-.3,1),Vector2(.3,1),Vector2(.22,.3),Vector2(.85,-.35),Vector2(.65,-.9),Vector2(-.65,-.9),Vector2(-.85,-.35),Vector2(-.22,.3)],
	"la_rature": [Vector2(-.9,-.8),Vector2(-.45,1),Vector2(-.1,-.25),Vector2(.1,.8),Vector2(.35,-.3),Vector2(.75,.6),Vector2(.95,-.85)],
	"l_errata": [Vector2(.6,1),Vector2(-.55,.6),Vector2(-.9,0),Vector2(-.55,-.6),Vector2(.6,-1),Vector2(.45,-.35),Vector2(.2,0),Vector2(.45,.35)],
	"le_correcteur": [Vector2(-.3,1),Vector2(.3,1),Vector2(.3,.3),Vector2(1,.3),Vector2(1,-.3),Vector2(.3,-.3),Vector2(.3,-1),Vector2(-.3,-1),Vector2(-.3,-.3),Vector2(-1,-.3),Vector2(-1,.3),Vector2(-.3,.3)],
	"reliure_affamee": [Vector2(0,1),Vector2(.95,-.6),Vector2(.65,-1),Vector2(0,-.65),Vector2(-.65,-1),Vector2(-.95,-.6)],
	"virgule_noire": [Vector2(.7,1),Vector2(-.25,.8),Vector2(-.85,.25),Vector2(-.7,-.45),Vector2(0,-1),Vector2(.2,-.3),Vector2(.75,.05)],
	"index_brise": [Vector2(0,1),Vector2(.9,.2),Vector2(.3,.25),Vector2(.3,-.45),Vector2(.9,-.45),Vector2(.9,-.8),Vector2(-.3,-.8),Vector2(-.3,.25),Vector2(-.9,.2)],
	"marge_hurlante": [Vector2(-1,-.4),Vector2(-.65,.5),Vector2(0,.9),Vector2(.65,.5),Vector2(1,-.4),Vector2(.5,.05),Vector2(0,.25),Vector2(-.5,.05)],
	"enlumineur_fou": [Vector2(0,1),Vector2(.25,.3),Vector2(.95,.3),Vector2(.4,-.15),Vector2(.6,-.85),Vector2(0,-.45),Vector2(-.6,-.85),Vector2(-.4,-.15),Vector2(-.95,.3),Vector2(-.25,.3)],
	"signet_sanglant": [Vector2(-.65,1),Vector2(.65,1),Vector2(.85,.2),Vector2(.4,-.95),Vector2(0,-.45),Vector2(-.4,-.95),Vector2(-.85,.2)],
	"copiste_aveugle": [Vector2(-1,.6),Vector2(-.15,1),Vector2(0,.7),Vector2(.8,.9),Vector2(1,-.6),Vector2(.15,-1),Vector2(0,-.7),Vector2(-.8,-.9)],
	"reine_givre": [Vector2(0,1),Vector2(.95,.15),Vector2(.45,-.15),Vector2(.7,-.65),Vector2(0,-1),Vector2(-.7,-.65),Vector2(-.45,-.15),Vector2(-.95,.15)],
	"maitre_orages": [Vector2(.4,1),Vector2(.1,.15),Vector2(.9,.4),Vector2(.3,-.85),Vector2(-.1,-.2),Vector2(-.65,-1),Vector2(-.85,.4),Vector2(-.25,.15)],
	"hydre_venins": [Vector2(0,1),Vector2(.55,.65),Vector2(.35,.15),Vector2(.95,-.1),Vector2(.75,-.75),Vector2(.2,-.8),Vector2(0,-.3),Vector2(-.2,-.8),Vector2(-.75,-.75),Vector2(-.95,-.1),Vector2(-.35,.15),Vector2(-.55,.65)],
	"choeur_infini": [Vector2(-.8,1),Vector2(-.25,1),Vector2(-.25,-.25),Vector2(.25,-.25),Vector2(.25,1),Vector2(.8,1),Vector2(.8,-.55),Vector2(.3,-.75),Vector2(.3,-1),Vector2(-.3,-1),Vector2(-.3,-.75),Vector2(-.8,-.55)],
	"souverain_ombres": [Vector2(1,.65),Vector2(.15,.35),Vector2(-.2,-.1),Vector2(.25,-.55),Vector2(.85,-.6),Vector2(-.15,-.95),Vector2(-.8,-.45),Vector2(-.95,.2),Vector2(-.45,.85),Vector2(.3,1)],
	"gardien_runes": [Vector2(-.7,1),Vector2(.55,1),Vector2(1,.45),Vector2(1,-.7),Vector2(.5,-1),Vector2(-.7,-1),Vector2(-1,-.45),Vector2(-1,.65)],
	"homoncule_encre": [Vector2(0,1),Vector2(.7,.45),Vector2(1,-.15),Vector2(.45,-.85),Vector2(-.45,-.85),Vector2(-1,-.15),Vector2(-.7,.45)],
	"ondine": [Vector2(0,1),Vector2(.8,.2),Vector2(.6,-.6),Vector2(0,-1),Vector2(-.6,-.6),Vector2(-.8,.2)],
	"sylphe": [Vector2(0,1),Vector2(.8,-.4),Vector2(.1,-.1),Vector2(.4,-1),Vector2(-.8,.4),Vector2(-.1,.1)],
	"golem": [Vector2(-.65,1),Vector2(.65,1),Vector2(1,0),Vector2(.65,-1),Vector2(-.65,-1),Vector2(-1,0)],
}
const BOULES := ["archiscribe_encres", "roi_braises", "devoreur_neant", "grand_alambic", "salamandre"]

static func contour(id: String) -> PackedVector2Array:
	if CONTOURS.has(id): return PackedVector2Array(CONTOURS[id])
	var points := PackedVector2Array()
	for i in 32:
		var angle := TAU * i / 32.0
		var rayon := 1.0
		if id == "roi_braises": rayon = 1.0 if i % 4 == 0 else .78
		points.append(Vector2.from_angle(angle) * rayon)
	return points
