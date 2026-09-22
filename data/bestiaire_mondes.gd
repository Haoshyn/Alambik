class_name BestiaireMondes
extends RefCounted

# Une famille technique devient une creature propre a chaque monde. Les variations
# changent la tactique et la silhouette sans ajouter une seconde courbe de puissance.
const NOMS := {
	"encrier_rampant": ["Bavure affamée", "Éclat trotteur", "Goutte mordante", "Bourrasque vive", "Escarbille vorace"],
	"plume_sentinelle": ["Plume de guet", "Obélisque lance-éclats", "Aiguille des marées", "Girouette sifflante", "Tison arbalétrier"],
	"tache_veloce": ["Trait fulgurant", "Dard de silex", "Anguille de verre", "Flèche de rafale", "Mèche filante"],
	"scribe_essaimeur": ["Masque copiste", "Nid de gravats", "Conque féconde", "Nichoir des souffles", "Couveuse de braises"],
	"folio_orbiteur": ["Feuillet satellite", "Galet gravitant", "Nautile dérivant", "Anneau des vents", "Roue de scories"],
	"sceau_belier": ["Tampon cuirassé", "Bélier de schiste", "Carapace des flots", "Heurtoir céleste", "Creuset chargeur"],
	"marge_harceleuse": ["Ruban frondeur", "Liane de quartz", "Nageoire cracheuse", "Écharpe de mistral", "Salamandre d’encre"],
	"miroir_encre": ["Rosace réfléchissante", "Géode rayonnante", "Perle à facettes", "Cadran des rafales", "Lentille ardente"],
	"cachet_phaseur": ["Cachet furtif", "Scarabée des failles", "Méduse intermittente", "Nœud de courant", "Étincelle fugitive"],
	"fuseau_tisseur": ["Fuseau traceur", "Tresse de racines", "Serpentin des eaux", "Vrille des hauteurs", "Filament de forge"],
	"fiole_volatile": ["Ampoule de rature", "Mortier de glaise", "Cloche des profondeurs", "Ballon d’orage", "Alambic incandescent"],
}
const COULEURS := [Color("8764d9"), Color("a6ad56"), Color("39bcd7"), Color("9cdec9"), Color("f27836")]
const ACCENTS := [Color("efb4ff"), Color("ecc586"), Color("a5f2ff"), Color("f4efb6"), Color("ffcf69")]
const ECHELLES := [Vector3(.85,1.15,.90), Vector3(1.14,.88,1.08), Vector3(.86,1.02,1.20), Vector3(1.05,1.22,.76), Vector3(.95,1.12,1.02)]
const SILHOUETTES_TIRS := ["aiguille", "eclat", "lame", "vrille", "eclat"]
const VARIANTES := [
	{"plume_sentinelle": {"projectiles": 1, "silhouette_tir": "aiguille"}, "fiole_volatile": {"zone": "impact"}},
	{"plume_sentinelle": {"projectiles": 2, "rebonds_murs": 1, "silhouette_tir": "eclat"}, "sceau_belier": {"zone_charge": "eboulis"}, "fiole_volatile": {"zone": "eboulis"}},
	{"plume_sentinelle": {"trajectoire": "sinus", "silhouette_tir": "lame"}, "folio_orbiteur": {"trajectoire": "sinus", "silhouette_tir": "lame"}, "fiole_volatile": {"zone": "maree"}},
	{"plume_sentinelle": {"trajectoire": "sinus", "silhouette_tir": "vrille"}, "folio_orbiteur": {"trajectoire": "sinus", "silhouette_tir": "vrille"}, "tache_veloce": {"charges": 2}, "fiole_volatile": {"zone": "foudre"}},
	{"tache_veloce": {"zone_charge": "braise"}, "sceau_belier": {"zone_charge": "braise"}, "plume_sentinelle": {"silhouette_tir": "eclat", "rebonds_murs": 1}, "fiole_volatile": {"zone": "braise"}},
]
const ZONES := {
	"impact": {"aspect": "impact", "delai": 1.5, "rayon": 115.0, "duree": 0.0, "part_degats": 1.0},
	"eboulis": {"aspect": "eboulis", "delai": 1.5, "rayon": 125.0, "duree": 0.0, "part_degats": 1.1},
	"maree": {"aspect": "maree", "delai": 1.5, "rayon": 155.0, "duree": 0.0, "part_degats": .95},
	"foudre": {"aspect": "foudre", "delai": 1.5, "rayon": 105.0, "duree": 0.0, "part_degats": 1.15},
	"braise": {"aspect": "braise", "delai": 1.5, "rayon": 100.0, "duree": 2.0, "part_degats": .65},
}
const ZONE_INTERVALLE := .75
const ZONE_ECLAT_DUREE := .22
const ZONE_CHARGE_INTERVALLE := .22
const ZONE_CHARGE_RAYON := 48.0
const ZONE_CHARGE_DELAI := .65
const ZONE_CHARGE_DUREE := 1.6
const ZONE_CHARGE_DEGATS := .32
const ZONES_PLAFOND := 12
const POURSUITE_CONTACT_RECHARGE := 1.0
const ESQUIVE_RECHARGE := 2.4
const ESQUIVE_DUREE := .20
const ESQUIVE_VITESSE := 1.85
const ESQUIVE_DISTANCE := 400.0
const ESQUIVE_SECURITE := 220.0
const ESQUIVE_COULOIR := 48.0
const ONDULATION_AMPLITUDE := 60.0
const ONDULATION_FREQUENCE := 1.15
const BOSS_ONDULATION_AMPLITUDE := 105.0
const BOSS_ONDULATION_FREQUENCE := .90
const REBOND_MARGE := 14.0
const BOSS_ZONE_PAR_MONDE := ["impact", "eboulis", "maree", "foudre", "braise"]
const BOSS_MOTIF_PAR_MONDE := ["encrage_cible", "pierres_rebondissantes", "lames_ondulees", "vrilles_errantes", "foyers_cibles"]
const BOSS_CADENCE_NOUVELLE := 1.4
const BOSS_DUREE_NOUVELLE := 4.5
const BOSS_DEGATS_NOUVEAUX := .85
const BOSS_ANGLES_NOUVEAUX := [-.30, .30]
const BOSS_ANGLES_RESSERRES := [-.14, .14]
const BOSS_ALTERNANCE_ANGLE := .10
const BOSS_ZONE_RAYON_MULT := 1.35
const BOSS_CHARGE_ANNONCE := .70
const BOSS_CHARGE_VITESSE := 3.6
const BOSS_PORTEE_PROJECTILE := 2600.0
const BOSS_ANNONCE_TIR := .65
const BOSS_DEGATS_CONTACT_RECHARGE := 1.0
const BOSS_REBONDS_MURS := 1
const ANGLES_PHASE := [PI, PI*.75, -PI*.75, PI*.5, -PI*.5]

static func appliquer(source: Dictionary, id: String, chapitre: int) -> Dictionary:
	var d := source.duplicate(true)
	var monde := clampi(chapitre / Chapitres.CHAPITRES_PAR_MONDE, 0, COULEURS.size() - 1)
	d["monde_visuel"] = monde
	if str(d["cerveau"]) == "boss":
		for cle in ["motifs_phase_1", "motifs_phase_2"]:
			var motifs: Array = d[cle].duplicate()
			# La premiere attaque porte l'identite du boss. Charges, invocations
			# et pauses restent presentes ; le monde remplace un tir secondaire.
			var index := -1
			for i in range(1, motifs.size()):
				if str(motifs[i]) not in ["charge", "invocation", "pause"]:
					index = i
					break
			if index >= 0:
				motifs[index] = BOSS_MOTIF_PAR_MONDE[monde]
			else:
				motifs.insert(maxi(1, motifs.size() - 1), BOSS_MOTIF_PAR_MONDE[monde])
			d[cle] = motifs
		return d
	if not NOMS.has(id): return d
	if not d.has("silhouette_tir"): d["silhouette_tir"] = SILHOUETTES_TIRS[monde]
	var variantes: Dictionary = VARIANTES[monde]
	var variation: Dictionary = variantes.get(id, {})
	d.merge(variation, true)
	d["nom"] = str(NOMS[id][monde])
	d["couleur"] = COULEURS[monde]
	return d
