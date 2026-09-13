class_name EvolutionEnnemis
extends RefCounted

# Trois evolutions apprises au fil de la campagne, sans gonfler les PV communs.
const SEUILS := [3,12,21]
const RECHARGE := [1.0,.94,.86,.78]
const PROJECTILE := [1.0,1.06,1.14,1.22]
const MOUVEMENT := [1.0,1.04,1.08,1.12]
const TELEGRAPHE := [1.0,.98,.92,.86]
const TELEGRAPHE_MIN := .40
const SALVES := [1,1,2,3]
const INTERVALLE_SALVES := .32
const DECALAGE_ANNEAU := .13
const ANTICIPATION := [0.0,.10,.20,.28]
const PROJECTILES_AJOUT := [0,0,2,2]
const ANNEAU_AJOUT := [0,2,4,6]
const EVENTAIL_AJOUT := [0.0,.10,.18,.24]
const REPOS_BOSS := [1.0,.95,.85,.75]
const ANNEXE_PV_BOSS := .65
const ELAN_DISTANCE := [0.0,0.0,250.0,310.0]
const ELAN_DUREE := .24
const ELAN_VITESSE := 2.0
const ELAN_PREPARATION := .50
const CONTACT_RECHARGE := 1.0
const CHARGES := [1,1,2,2]
const BOSS_ANNEAU_AJOUT := [0,2,4,6]
const BOSS_EVENTAIL := [-.65,-.5,-.25,0.0,.25,.5,.65]
const BOSS_DENTS := [-2.0,-1.0,0.0,1.0,2.0]

static func palier(chapitre: int) -> int:
	var resultat := 0
	for seuil in SEUILS:
		if chapitre >= seuil: resultat += 1
	return resultat

static func appliquer(source: Dictionary, chapitre: int) -> Dictionary:
	var d := source.duplicate(true)
	var p := palier(chapitre)
	if p == 0: return d
	d["evolution"] = p
	for cle in ["recharge","repos"]:
		if d.has(cle): d[cle] = float(d[cle])*RECHARGE[p]
	for cle in ["telegraphe","preparation"]:
		if d.has(cle): d[cle] = maxf(TELEGRAPHE_MIN,float(d[cle])*TELEGRAPHE[p])
	if d.has("vitesse_projectile"): d["vitesse_projectile"] = float(d["vitesse_projectile"])*PROJECTILE[p]
	d["vitesse"] = float(d["vitesse"])*MOUVEMENT[p]
	d["salves"] = SALVES[p]
	d["anticipation"] = ANTICIPATION[p]
	if d.has("projectiles_cercle"):
		d["projectiles_cercle"] = int(d["projectiles_cercle"])+ANNEAU_AJOUT[p]
	match str(d["cerveau"]):
		"sentinelle","harceleur","orbiteur","phaseur","tisseur":
			d["projectiles"] = mini(7,int(d.get("projectiles",1))+PROJECTILES_AJOUT[p])
			d["angle_eventail"] = float(d.get("angle_eventail",0.0))+EVENTAIL_AJOUT[p]
		"rampant":
			d["elan_distance"] = ELAN_DISTANCE[p]
			d["preparation"] = ELAN_PREPARATION
		"veloce":
			d["charges"] = CHARGES[p]
	return d
