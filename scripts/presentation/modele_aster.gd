extends Node3D

const ANIMATIONS := {
	"Idle":"repos", "Walk":"marche", "Run":"course", "Hit":"touche",
	"Attack":"attaque", "Aim":"visee", "Cast":"incantation", "Death":"mort",
}
const MATIERE := preload("res://shaders/aster_anime.gdshader")
const CONTOUR := preload("res://shaders/aster_contour.gdshader")
var _visage: MeshInstance3D
var _formes: Dictionary = {}
var _temps := 0.0
var _impact := 0.0
var _mort := false

func _ready() -> void:
	var squelette := find_child("Skeleton3D",true,false) as Skeleton3D
	var lecteur := find_child("AnimationPlayer",true,false) as AnimationPlayer
	# La bibliotheque de chaque instance peut etre renommee sans affecter
	# le portrait, les outils de capture ou une autre instance du personnage.
	var bibliotheque := lecteur.get_animation_library("").duplicate(true) as AnimationLibrary
	lecteur.remove_animation_library("")
	for original: String in ANIMATIONS:
		if bibliotheque.has_animation(original):
			bibliotheque.rename_animation(original,ANIMATIONS[original])
	lecteur.add_animation_library("",bibliotheque)
	for nom: String in ["repos","marche","course","visee"]:
		lecteur.get_animation(nom).loop_mode = Animation.LOOP_LINEAR
	for noeud: MeshInstance3D in find_children("*","MeshInstance3D",true,false):
		if noeud.skin != null:
			noeud.skeleton = noeud.get_path_to(squelette)
		_appliquer_matiere(noeud)
	_visage = find_child("Aster_Face",true,false) as MeshInstance3D
	for i in range(_visage.mesh.get_blend_shape_count()):
		_formes[str(_visage.mesh.get_blend_shape_name(i))] = i
	lecteur.play("repos")
	lecteur.advance(0.0)

func _appliquer_matiere(maillage: MeshInstance3D) -> void:
	# Isoler la baguette evite que la destruction d'un acteur invalide les
	# matieres de ses trois surfaces encore utilisees par une autre instance.
	if maillage.name == "Aster_Wand":
		maillage.mesh = maillage.mesh.duplicate() as ArrayMesh
	for index in range(maillage.mesh.get_surface_count()):
		var originale := maillage.get_active_material(index) as StandardMaterial3D
		if originale == null: continue
		if originale.resource_name.begins_with("M00_") or originale.resource_name.begins_with("F00_"): continue
		var matiere := ShaderMaterial.new()
		matiere.shader = MATIERE
		matiere.set_shader_parameter("couleur_base",originale.albedo_color)
		matiere.set_shader_parameter("texture_base",originale.albedo_texture)
		matiere.set_shader_parameter("utiliser_texture",originale.albedo_texture != null)
		matiere.set_shader_parameter("metal",originale.metallic)
		matiere.set_shader_parameter("couleur_sommets",originale.vertex_color_use_as_albedo or originale.resource_name == "SilverHair")
		matiere.set_shader_parameter("emission",.15 if originale.resource_name.contains("Gem") else 0.0)
		matiere.set_shader_parameter("couleur_emission",originale.albedo_color)
		matiere.set_shader_parameter("visage",1.0 if originale.resource_name == "Face" else 0.0)
		if not originale.resource_name.contains("Gold") and not originale.resource_name.contains("Gem") and originale.resource_name != "Face":
			var contour := ShaderMaterial.new()
			contour.shader = CONTOUR
			contour.set_shader_parameter("epaisseur",.0005 if originale.resource_name.contains("Hair") else .00065)
			matiere.next_pass = contour
		maillage.set_surface_override_material(index,matiere)

func exprimer_impact() -> void:
	_impact = .5

func exprimer_mort() -> void:
	_mort = true

func _process(delta: float) -> void:
	_temps += delta
	_impact = maxf(0.0,_impact-delta)
	var clignement := maxf(0.0,1.0-absf(fmod(_temps,2.5)-1.75)/.095)
	_forme("Blink",1.0 if _mort else maxf(clignement,_impact*1.5))
	_forme("Angry",.08 if not _mort else 0.0)
	_forme("Sorrow",.5 if _mort else _impact*.6)
	_forme("A",_impact*.2 if not _mort else 0.0)

func _forme(nom: String, valeur: float) -> void:
	if is_instance_valid(_visage) and _formes.has(nom):
		_visage.set_blend_shape_value(int(_formes[nom]),valeur)
