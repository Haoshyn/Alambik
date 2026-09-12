extends Node

var heros: CharacterBody2D
var salle: Node2D
var effets: Node2D
var actives: Dictionary = {}
var compteurs: Dictionary = {}
var recharges: Dictionary = {}
var marques: Dictionary = {}
var attentes: Array[Dictionary] = []
var temps := 0.0
var charge_rosee := 0.0
var perles := 0
var reserve := 0
var salle_connue := -1

func _ready() -> void:
	add_to_group("atelier_fusions")
	Jeu.inventaire_change.connect(actualiser)
	actualiser()

func actualiser() -> void:
	actives.clear()
	for id in Jeu.inventaire:
		if CatalogueRecettes.est_fusion(id) and CatalogueRecettes.creer(id) != null:
			actives[CatalogueRecettes.recette_de(id)] = true

func reinitialiser() -> void:
	compteurs.clear()
	recharges.clear()
	marques.clear()
	attentes.clear()
	charge_rosee = 0.0
	perles = 0
	reserve = 0

func _process(delta: float) -> void:
	if heros == null or heros.stats.est_mort(): return
	if salle_connue != Jeu.salle_courante:
		salle_connue = Jeu.salle_courante
		reinitialiser()
	temps += delta
	var mobile := heros.velocity.length() > Reglages.HEROS_VITESSE * CatalogueRecettes.VITESSE_CHARGE_MIN
	if mobile:
		compteurs["fournaise"] = 0
		if actives.has("rosee"):
			var r: Dictionary = CatalogueRecettes.TOUS["rosee"]
			charge_rosee += delta
			if charge_rosee >= float(r["charge"]):
				charge_rosee = 0.0
				if perles < int(r["maximum"]):
					perles += 1
					effets.onde(heros.global_position,30.0+perles*12.0,Palette.ESSENCE,0.3)
	var suivantes: Array[Dictionary] = []
	var pretes: Array[Dictionary] = []
	for attente in attentes:
		if float(attente["quand"]) <= temps: pretes.append(attente)
		else: suivantes.append(attente)
	attentes = suivantes
	for attente in pretes:
		zone(attente["position"],float(attente["rayon"]),float(attente["part"]),attente.get("element",""))
	for cle in marques.keys():
		if not marques.has(cle): continue
		var m: Dictionary = marques[cle]
		var cible: Node2D = instance_from_id(cle)
		if not is_instance_valid(cible) or cible.pv <= 0.0:
			marques.erase(cle)
			if int(m["feu"]) > 0:
				var r: Dictionary = CatalogueRecettes.TOUS["braises"]
				zone(m["position"],float(r["rayon"]),float(r["part"]),"")
		elif float(m["expire"]) < temps:
			marques.erase(cle)
		elif float(m.get("explosion",INF)) <= temps:
			marques.erase(cle)
			var r: Dictionary = CatalogueRecettes.TOUS["braises"]
			zone(cible.global_position,float(r["rayon"]),float(r["part"]),"feu")
	if get_tree().get_nodes_in_group("ennemis").is_empty(): return
	for recette in ["failles","constellation","distillation"]:
		if not actives.has(recette) or not pret(recette): continue
		var r: Dictionary = CatalogueRecettes.TOUS[recette]
		recharges[recette] = temps + float(r["recharge"])
		if recette == "failles":
			var cible := plus_proche(heros.global_position,[])
			if cible != null:
				attentes.append({"quand":temps+float(r["delai"]),"position":cible.global_position,"rayon":r["rayon"],"part":r["part"]})
				effets.onde(cible.global_position,float(r["rayon"]),Palette.OR,float(r["delai"]))
		elif recette == "constellation":
			var origine := heros.global_position
			var deja: Array[int] = []
			for i in int(r["maximum"]):
				var cible := plus_proche(origine,deja,float(r["portee"]))
				if cible == null: break
				deja.append(cible.get_instance_id())
				effets.arc(origine,cible.global_position,Palette.ESSENCE)
				origine = cible.global_position
				frapper(cible,float(r["part"]),"eau")
		else:
			zone(heros.global_position,float(r["rayon"]),0.0,"feu")

func pret(id: String) -> bool:
	return temps >= float(recharges.get(id,0.0))

func compter(id: String, seuil: int) -> bool:
	compteurs[id] = int(compteurs.get(id,0))+1
	if int(compteurs[id]) < seuil: return false
	compteurs[id] = 0
	return true

func lancer(origine: Vector2, direction: Vector2) -> void:
	if actives.has("retour"):
		var r: Dictionary = CatalogueRecettes.TOUS["retour"]
		if pret("retour") and compter("retour",int(r["seuil"])):
			recharges["retour"] = temps + float(r["recharge"])
			for signe in [-1,1]: projectile(origine,direction.rotated(float(r["angle"])*signe),float(r["part"]),false)
	if perles > 0:
		var r: Dictionary = CatalogueRecettes.TOUS["rosee"]
		for i in perles: projectile(origine,direction.rotated((i-(perles-1)*0.5)*float(r["angle"])),float(r["part"]),true)
		perles = 0
	if reserve > 0:
		projectile(origine,direction,float(CatalogueRecettes.TOUS["reserve"]["part"])*reserve,false)
		reserve = 0
	if actives.has("fournaise") and compter("fournaise",int(CatalogueRecettes.TOUS["fournaise"]["seuil"])):
		var cible := plus_proche(origine,[])
		if cible != null:
			var r: Dictionary = CatalogueRecettes.TOUS["fournaise"]
			zone(cible.global_position,float(r["rayon"]),float(r["part"]),"feu")

func projectile(origine: Vector2, direction: Vector2, part: float, eau: bool) -> void:
	var tir := Tir.de_base(heros.stats)
	tir.degats *= part
	tir.drapeaux.append("homing")
	if eau: tir.effets.append("eau")
	salle.tirer(tir,origine,direction,false)

func impact(cible: Node2D, eau := false) -> void:
	if not is_instance_valid(cible) or cible.pv <= 0.0: return
	if actives.has("braises"): marquer(cible,"feu")
	if eau: marquer(cible,"eau")
	if actives.has("perles") and pret("perles") and compter("perles",int(CatalogueRecettes.TOUS["perles"]["seuil"])):
		var r: Dictionary = CatalogueRecettes.TOUS["perles"]
		recharges["perles"] = temps + float(r["recharge"])
		zone(cible.global_position,float(r["rayon"]),float(r["part"]),"eau")

func marquer(cible: Node2D, element: String) -> void:
	if not is_instance_valid(cible) or cible.pv <= 0.0: return
	var cle := cible.get_instance_id()
	if not marques.has(cle) and marques.size() >= int(CatalogueRecettes.REACTION["maximum_marques"]): return
	var m: Dictionary = marques.get(cle,{"feu":0,"eau":false,"expire":0.0})
	m["position"] = cible.global_position
	m["expire"] = temps + float(CatalogueRecettes.REACTION["duree_marque"])
	if element == "feu":
		m["feu"] = int(m["feu"])+1
		effets.onde(cible.global_position,24.0+minf(float(m["feu"]),3.0)*8.0,Palette.BRAISE,0.25)
		if int(m["feu"]) >= int(CatalogueRecettes.TOUS["braises"]["seuil"]) and not m.has("explosion"):
			m["explosion"] = temps + float(CatalogueRecettes.TOUS["braises"]["delai"])
	else: m["eau"] = true
	marques[cle] = m
	if int(m["feu"]) > 0 and bool(m["eau"]) and pret("vapeur_%d" % cle):
		marques.erase(cle)
		recharges["vapeur_%d" % cle] = temps + float(CatalogueRecettes.REACTION["recharge"])
		# La reaction ne pose aucun etat : elle ne peut pas se reproduire elle-meme.
		zone(cible.global_position,float(CatalogueRecettes.REACTION["rayon"]),float(CatalogueRecettes.REACTION["part"]),"")
		effets.onde(cible.global_position,float(CatalogueRecettes.REACTION["rayon"]),Color(0.85,0.95,1.0),0.35)

func frapper(cible: Node2D, part: float, element := "") -> void:
	if not is_instance_valid(cible) or cible.pv <= 0.0: return
	var etats: Array[String] = []
	if element == "eau": etats.append("eau")
	if part > 0.0 or not etats.is_empty(): cible.recevoir_degats(heros.stats.degats*part,etats)
	if element != "": marquer(cible,element)

func zone(origine: Vector2, rayon: float, part: float, element := "") -> void:
	var couleur := Palette.ESSENCE if element == "eau" else Palette.BRAISE if element == "feu" else Palette.OR
	effets.onde(origine,rayon,couleur,0.4)
	for cible in get_tree().get_nodes_in_group("ennemis"):
		if is_instance_valid(cible) and cible.global_position.distance_to(origine) <= rayon \
				and Geometrie.ligne_libre(origine,cible.global_position,salle.obstacles()):
			frapper(cible,part,element)

func plus_proche(origine: Vector2, deja: Array, portee := INF) -> Node2D:
	var resultat: Node2D = null
	var distance := portee
	for cible in get_tree().get_nodes_in_group("ennemis"):
		if not is_instance_valid(cible) or cible.pv <= 0.0 or cible.get_instance_id() in deja: continue
		var d := origine.distance_to(cible.global_position)
		if d < distance and Geometrie.ligne_libre(origine,cible.global_position,salle.obstacles()):
			distance = d
			resultat = cible
	return resultat

func protection(_position: Vector2) -> void:
	if not actives.has("secours") or not pret("secours"): return
	var r: Dictionary = CatalogueRecettes.TOUS["secours"]
	recharges["secours"] = temps + float(r["recharge"])
	zone(heros.global_position,float(r["rayon"]),float(r["part"]))
	for cible in get_tree().get_nodes_in_group("ennemis"):
		if is_instance_valid(cible) and cible.global_position.distance_to(heros.global_position) < float(r["rayon"]) and not cible.is_in_group("boss"):
			var destination: Vector2 = cible.global_position + heros.global_position.direction_to(cible.global_position)*float(r["poussee"])
			if Geometrie.ligne_libre(cible.global_position,destination,salle.obstacles()):
				cible.global_position = Geometrie.contraindre_dans_rect(destination,heros.limites,Reglages.HEROS_RAYON)
	for tir in get_tree().get_nodes_in_group("tirs_ennemis"):
		if tir.global_position.distance_to(heros.global_position) < float(r["rayon"]): tir.queue_free()

func elimination(_experience: int) -> void:
	if not actives.has("reserve") or not compter("reserve",int(CatalogueRecettes.TOUS["reserve"]["seuil"])): return
	var r: Dictionary = CatalogueRecettes.TOUS["reserve"]
	if heros.stats.pv >= heros.stats.pv_max:
		reserve = mini(reserve+1,int(r["maximum"]))
	else: heros.stats.soigner(heros.stats.pv_max*float(r["soin"]))
	effets.onde(heros.global_position,80.0,Palette.ESSENCE,0.35)
