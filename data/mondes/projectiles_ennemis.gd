class_name ProjectilesEnnemis
extends RefCounted

# Une identite par tireur, conservee dans tous ses motifs et toutes ses variantes.
# Les dimensions de collision servent aussi au volume dessine.
const PROFILS := {
	"encrier_rampant": {"nom": "Goutte d’encre", "vitesse": 480.0, "rayon": 16.0, "longueur": 40.0},
	"plume_sentinelle": {"nom": "Pointe de plume", "vitesse": 4500.0, "rayon": 10.0, "longueur": 66.0},
	"scribe_essaimeur": {"nom": "Graine de papier", "vitesse": 520.0, "rayon": 14.0, "longueur": 28.0},
	"folio_orbiteur": {"nom": "Feuillet boomerang", "vitesse": 420.0, "rayon": 20.0, "longueur": 40.0, "trajectoire": "aller_retour", "retour": 850.0},
	"marge_harceleuse": {"nom": "Épine de ruban", "vitesse": 1150.0, "rayon": 10.0, "longueur": 48.0},
	"miroir_encre": {"nom": "Carreau à ricochet", "vitesse": 300.0, "rayon": 18.0, "longueur": 36.0, "rebonds": 1},
	"cachet_phaseur": {"nom": "Losange fendu", "vitesse": 820.0, "rayon": 13.0, "longueur": 38.0},
	"fuseau_tisseur": {"nom": "Fil torsadé", "vitesse": 600.0, "rayon": 11.0, "longueur": 38.0, "trajectoire": "sinus"},
	"fiole_volatile": {"nom": "Éclat d’ampoule", "vitesse": 300.0, "rayon": 13.0, "longueur": 30.0},
	"la_rature": {"nom": "Griffe de rature", "vitesse": 470.0, "rayon": 14.0, "longueur": 54.0},
	"l_errata": {"nom": "Parenthèse de retour", "vitesse": 600.0, "rayon": 26.0, "longueur": 52.0, "trajectoire": "aller_retour", "retour": 2000.0},
	"le_correcteur": {"nom": "Croix de correction", "vitesse": 410.0, "rayon": 21.0, "longueur": 42.0},
	"reliure_affamee": {"nom": "Dent de reliure", "vitesse": 440.0, "rayon": 16.0, "longueur": 46.0},
	"virgule_noire": {"nom": "Virgule tournante", "vitesse": 640.0, "rayon": 24.0, "longueur": 48.0, "trajectoire": "aller_retour", "retour": 2000.0},
	"index_brise": {"nom": "Flèche à encoche", "vitesse": 960.0, "rayon": 11.0, "longueur": 68.0},
	"marge_hurlante": {"nom": "Onde ouverte", "vitesse": 290.0, "rayon": 24.0, "longueur": 48.0, "trajectoire": "sinus"},
	"enlumineur_fou": {"nom": "Étoile enluminée", "vitesse": 340.0, "rayon": 22.0, "longueur": 44.0},
	"signet_sanglant": {"nom": "Sceau de cire", "vitesse": 380.0, "rayon": 23.0, "longueur": 46.0},
	"copiste_aveugle": {"nom": "Double page", "vitesse": 520.0, "rayon": 15.0, "longueur": 54.0},
	"archiscribe_encres": {"nom": "Orbe d’écriture", "vitesse": 350.0, "rayon": 30.0, "longueur": 60.0},
	"roi_braises": {"nom": "Soleil de braise", "vitesse": 310.0, "rayon": 34.0, "longueur": 68.0},
	"reine_givre": {"nom": "Cristal de marée", "vitesse": 500.0, "rayon": 14.0, "longueur": 72.0, "trajectoire": "sinus"},
	"maitre_orages": {"nom": "Éclair fourchu", "vitesse": 900.0, "rayon": 12.0, "longueur": 72.0},
	"hydre_venins": {"nom": "Trèfle de venin", "vitesse": 370.0, "rayon": 26.0, "longueur": 52.0},
	"choeur_infini": {"nom": "Diapason errant", "vitesse": 400.0, "rayon": 15.0, "longueur": 48.0, "trajectoire": "sinus"},
	"souverain_ombres": {"nom": "Croissant obscur", "vitesse": 640.0, "rayon": 30.0, "longueur": 60.0, "trajectoire": "aller_retour", "retour": 2100.0},
	"gardien_runes": {"nom": "Bloc runique", "vitesse": 240.0, "rayon": 32.0, "longueur": 64.0, "rebonds": 2},
	"devoreur_neant": {"nom": "Anneau du vide", "vitesse": 270.0, "rayon": 35.0, "longueur": 70.0},
	"grand_alambic": {"nom": "Globe alchimique", "vitesse": 250.0, "rayon": 38.0, "longueur": 76.0, "rebonds": 1},
}
const RETOUR_PAUSE := 0.22
const REBOND_VITESSE_MAX := 475.0
const RETOUR_VITESSE_MAX := 625.0
const RETOUR_BOSS_VITESSE_MAX := 1500.0
const RETOUR_BOSS_ANGLES := [-0.26, 0.0, 0.26]
const RETOUR_BOSS_CADENCE := 1.40
const RETOUR_BOSS_DEGATS := 0.72
const DENSITE_BOSS_LARGES := 1.45
const RAYON_BOSS_LARGE := 24.0
const AMPLITUDE := 42.0
const FREQUENCE := 0.75
const VITESSE_ANNONCE := 1200.0
const REACTION_SANS_ANNONCE := 0.40

static func annonce_necessaire(tir: Tir, distance: float) -> bool:
	# Le tisseur garantit sa distance de reaction avant de lancer ses rubans.
	if tir.silhouette == "fuseau_tisseur": return false
	var distance_impact := maxf(0.0, distance - maxf(tir.rayon, tir.longueur * .5) - Reglages.HEROS_RAYON)
	return tir.vitesse >= VITESSE_ANNONCE or distance_impact < tir.vitesse * REACTION_SANS_ANNONCE

static func enrichir(donnees: Dictionary, id: String) -> void:
	if not PROFILS.has(id): return
	var p: Dictionary = PROFILS[id]
	donnees["projectile_id"] = id
	donnees["vitesse_projectile"] = float(p["vitesse"])
	donnees["trajectoire"] = str(p.get("trajectoire", "droite"))
	donnees["rebonds_murs"] = int(p.get("rebonds", 0))

static func appliquer(tir: Tir, donnees: Dictionary) -> void:
	var id := str(donnees.get("projectile_id", ""))
	if not PROFILS.has(id): return
	var p: Dictionary = PROFILS[id]
	tir.silhouette = id
	tir.variante_visuelle = int(donnees.get("monde_visuel", 0))
	tir.rayon = float(p["rayon"])
	tir.longueur = float(p["longueur"])
	tir.trajectoire = str(p.get("trajectoire", "droite"))
	tir.distance_retour = float(p.get("retour", 0.0))
	tir.pause_retour = RETOUR_PAUSE
	tir.rebonds_murs = int(p.get("rebonds", 0))
	tir.amplitude = float(donnees.get("amplitude", AMPLITUDE))
	tir.frequence = float(donnees.get("frequence", FREQUENCE))
	tir.portee_limitee = true
	# Les trajectoires complexes restent plus lentes et suivent la progression.
	var rythme := float(donnees.get("rythme_projectile", 1.0))
	if id == "fuseau_tisseur": tir.frequence *= maxf(1.0, rythme)
	if tir.rebonds_murs > 0: tir.vitesse = minf(tir.vitesse, REBOND_VITESSE_MAX * rythme)
	if str(donnees.get("cerveau", "")) == "boss":
		tir.portee = maxf(tir.portee, BestiaireMondes.BOSS_PORTEE_PROJECTILE)
	if tir.trajectoire == "aller_retour":
		var plafond := RETOUR_BOSS_VITESSE_MAX if str(donnees.get("cerveau", "")) == "boss" else RETOUR_VITESSE_MAX
		tir.vitesse = minf(tir.vitesse, plafond * rythme)
		# La portee totale couvre l'aller ET le retour, meme depuis le fond de salle.
		tir.portee = maxf(tir.portee, tir.distance_retour * 2.0 + tir.longueur)

static func facteur_cadence(donnees: Dictionary) -> float:
	var p: Dictionary = PROFILS.get(str(donnees.get("projectile_id", "")), {})
	return DENSITE_BOSS_LARGES if float(p.get("rayon", 0.0)) >= RAYON_BOSS_LARGE else 1.0
