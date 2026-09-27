class_name EvolutionEnnemis
extends RefCounted

# Evolutions au milieu des mondes Terre, Eau et Air : ne pas cumuler
# nouvelle mecanique de terrain et durcissement des motifs a leur entree.
const SEUILS := [9,17,25]
# Le rythme progresse sans saut de vitesse a l'entree d'un monde.
const RECHARGE_FIN := .86
const PROJECTILE_FIN := 1.38
const MOUVEMENT_FIN := 1.10
const TELEGRAPHE_FIN := .92
const PROJECTILE_FIN_RENCONTRE := 1.06
const RECHARGE_FIN_RENCONTRE := .96
const SALVES := [1,1,1,2]
const INTERVALLE_SALVES := .65
const DECALAGE_ANNEAU := .13
const ANTICIPATION := [0.0,.05,.10,.15]
const PROJECTILES_AJOUT := [0,0,1,1]
const SENTINELLE_PROJECTILES_AJOUT := [0,0,2,2]
const ANNEAU_AJOUT := [0,0,1,2]
const EVENTAIL_AJOUT := [0.0,.05,.10,.15]
const REPOS_BOSS := [1.0,.975,.95,.90]
const ANNEXE_PV_BOSS := .65
const ELAN_DISTANCE := [0.0,0.0,0.0,250.0]
const ELAN_DUREE := .24
const ELAN_VITESSE := 2.0
const ELAN_PREPARATION := .50
const CONTACT_RECHARGE := 1.0
const CHARGES := [1,1,1,2]
const BOSS_ANNEAU_AJOUT := [0,0,1,2]
const BOSS_EVENTAIL := [-.65,-.5,-.25,0.0,.25,.5,.65]
const BOSS_DENTS := [-2.0,-1.0,0.0,1.0,2.0]
# Une entree plus lisible remplace les protections artificielles du tutoriel.
const CHAPITRES_ACCUEIL := 3
const ACCUEIL_MOUVEMENT := 0.82
const ACCUEIL_PROJECTILE := 0.88
const ACCUEIL_RECHARGE := 1.15
const ACCUEIL_TELEGRAPHE := 1.20

static func palier(chapitre: int) -> int:
	var resultat := 0
	for seuil in SEUILS:
		if chapitre >= seuil: resultat += 1
	return resultat

static func facteurs_rythme(chapitre: int, progression_rencontre := 0.0) -> Dictionary:
	var progression := clampf(float(chapitre) / float(Chapitres.nombre() - 1), 0.0, 1.0)
	var rencontre := clampf(progression_rencontre, 0.0, 1.0)
	var accueil := clampf(float(chapitre) / float(CHAPITRES_ACCUEIL - 1), 0.0, 1.0)
	return {
		"mouvement": lerpf(ACCUEIL_MOUVEMENT, 1.0, accueil) * lerpf(1.0, MOUVEMENT_FIN, progression),
		"projectile": lerpf(ACCUEIL_PROJECTILE, 1.0, accueil) * lerpf(1.0, PROJECTILE_FIN, progression) * lerpf(1.0, PROJECTILE_FIN_RENCONTRE, rencontre),
		"recharge": lerpf(ACCUEIL_RECHARGE, 1.0, accueil) * lerpf(1.0, RECHARGE_FIN, progression) * lerpf(1.0, RECHARGE_FIN_RENCONTRE, rencontre),
		"telegraphe": lerpf(ACCUEIL_TELEGRAPHE, 1.0, accueil) * lerpf(1.0, TELEGRAPHE_FIN, progression),
	}

static func appliquer(source: Dictionary, chapitre: int, progression_rencontre := 0.0) -> Dictionary:
	var d := source.duplicate(true)
	var facteurs := facteurs_rythme(chapitre, progression_rencontre)
	d["rythme_projectile"] = float(facteurs["projectile"])
	d["vitesse"] = float(d["vitesse"]) * float(facteurs["mouvement"])
	if d.has("vitesse_projectile"):
		d["vitesse_projectile"] = float(d["vitesse_projectile"]) * float(facteurs["projectile"])
	for cle: String in ["recharge", "repos"]:
		if d.has(cle): d[cle] = float(d[cle]) * float(facteurs["recharge"])
	d["cadence_motif_mult"] = float(facteurs["recharge"])
	for cle: String in ["telegraphe", "preparation"]:
		if d.has(cle): d[cle] = maxf(Reglages.ENNEMI_TELEGRAPHE_MIN, float(d[cle]) * float(facteurs["telegraphe"]))
	if d.has("telegraphe_contact"):
		d["telegraphe_contact"] = maxf(Reglages.ENNEMI_CONTACT_ANNONCE, float(d["telegraphe_contact"]) * float(facteurs["telegraphe"]))
	var p := palier(chapitre)
	d["evolution"] = p
	# Deux rubans non annonces gardent leur passage, meme en fin de campagne.
	if str(d["cerveau"]) == "tisseur":
		d["anticipation"] = 0.0
		d["salves"] = 1
		return d
	if p == 0: return d
	d["salves"] = SALVES[p]
	d["anticipation"] = ANTICIPATION[p]
	if d.has("projectiles_cercle"):
		d["projectiles_cercle"] = int(d["projectiles_cercle"])+ANNEAU_AJOUT[p]
	match str(d["cerveau"]):
		"sentinelle":
			# Un trait central conserve le danger sur la visee annoncee.
			d["projectiles"] = int(d.get("projectiles", 1)) + SENTINELLE_PROJECTILES_AJOUT[p]
			d["angle_eventail"] = float(d.get("angle_eventail", 0.0)) + EVENTAIL_AJOUT[p]
		"harceleur","orbiteur","phaseur":
			d["projectiles"] = mini(7,int(d.get("projectiles",1))+PROJECTILES_AJOUT[p])
			d["angle_eventail"] = float(d.get("angle_eventail",0.0))+EVENTAIL_AJOUT[p]
		"rampant":
			d["elan_distance"] = ELAN_DISTANCE[p]
			d["preparation"] = ELAN_PREPARATION
		"veloce":
			d["charges"] = CHARGES[p]
	return d
